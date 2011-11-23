use strict;
use warnings;

# find local directories
use File::Spec::Functions qw(catdir rel2abs);
use File::Basename qw(dirname);
my $PWD = dirname($0);

# find local modules in 'lib' directory
use lib 'lib'; #rel2abs(catdir($PWD,'lib'));

# determine logging level and environment (deployment or development)
my $PLACK_ENV = $ENV{PLACK_ENV} || 'deployment';
my $LOGLEVEL = ($PLACK_ENV eq 'deployment' ? 'warn' : 'trace');

# Lazy RDF namespaces
use RDF::NS;
my $NS = RDF::NS->new('20111102');

# basic source of RDF data
use RDF::Flow;
my $BASE = "http://example.org/";
my $SOURCE = rdflow( 
    from => rel2abs(catdir($PWD,'htdocs','rdf')), 
    name => "directory 'rdf'" );

# core functionality put into this package
use SWIB11App;
my $app = SWIB11App->new(
    base   => $BASE,
    source => $SOURCE
);
 
# web application stack
use Plack::Builder;

builder {

    # debugging
    enable_if { $PLACK_ENV ne 'deployment' } 'Debug';
    enable_if { $PLACK_ENV ne 'deployment' } 'Debug::TemplateToolkit';

    # logging
    enable 'SimpleLogger';
    enable 'Log::Contextual', level => $LOGLEVEL; 

    # static files from directory 'htdocs'
    enable 'Static',
            path => qr{\.(gif|png|jpg|ico|js|css|xsl)$},
            root => rel2abs(catdir($PWD,'htdocs'));

    # retrieve and possibly serve RDF data from $SOURCE
    enable 'JSONP';
    enable 'RDF::Flow',
		    base         => $BASE,
    		source       => $SOURCE,
	    	namespaces   => $NS,
		    pass_through => 1;

    $app;
};
