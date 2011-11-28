use strict;
use warnings;

# find local directories
use File::Spec::Functions qw(catdir rel2abs);
use File::Basename qw(dirname);
my $PWD = dirname($0);

my $HTDOCS = rel2abs(catdir($PWD,'htdocs'));

# find local modules in 'lib' directory
use lib 'lib'; #rel2abs(catdir($PWD,'lib'));

# determine logging level and environment (deployment or development)
my $PLACK_ENV = $ENV{PLACK_ENV} || 'deployment';
my $LOGLEVEL = ($PLACK_ENV eq 'deployment' ? 'warn' : 'trace');

# Lazy RDF namespaces
use RDF::NS;
my $NS = RDF::NS->new('20111102');

# basic source of RDF data
use RDF::Flow qw(rdflow union);
my $BASE = "http://example.org/";
#my $BASE = "http://de.dbpedia.org/resource/";
my $SOURCE = rdflow( 
    from => rel2abs(catdir($PWD,'htdocs','rdf')), 
    name => "directory 'rdf'" );

# in addition, get DBPedia
use RDF::Flow::LinkedData;
my $dbpedia = RDF::Flow::LinkedData->new(
    name => "DBPedia",
	match => sub { 
		# http://example.org/ABC => http://de.dbpedia.org/resource/ABC
		$_[0] =~ s{^$BASE}{http://de.dbpedia.org/resource/};
	},
);

use RDF::Flow::Union;
use RDF::Flow::URIMap;

# map dbpedia URI to our local URI
my $map = RDF::Flow::URIMap->new;
$map->map( sub { s{^http://de.dbpedia.org/resource/}{$BASE}; } );
# $map->map( sub { s{^$BASE}{http://de.dbpedia.org/resource/}g; } );

$SOURCE = union(
	$SOURCE,
	$dbpedia,
)->pipe_to($map);

# core functionality put into this package
use SWIB11App;
my $swib11app = SWIB11App->new(
    base   => $BASE,
    source => $SOURCE
);
 
# web application stack
use Plack::Builder;
use Plack::Middleware::TemplateToolkit;

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
            root => $HTDOCS;

    # retrieve and possibly serve RDF data from $SOURCE
    enable 'JSONP';
    enable 'RDF::Flow',
		    base         => $BASE,
    		source       => $SOURCE,
	    	namespaces   => $NS,
		    pass_through => 1;

    # core driver
    enable sub { 
        my $app = shift;
        sub { 
            my $env = shift;
            $env->{'tt.vars'} = { } unless $env->{'tt.vars'};
            $env->{'tt.vars'}->{'uri'} = $env->{'rdflow.uri'};
#            $env->{'tt.vars'}->{'formats'} = keys %FORMATS;

            my $response = $swib11app->call( $env );

            # direct response
            return $response if $response;

            # otherwise pass to Plack::Middleware::TemplateToolkit
            $env->{'tt.vars'}->{error}     = $env->{'rdflow.error'};
            $env->{'tt.vars'}->{timestamp} = $env->{'rdflow.timestamp'};
            $env->{'tt.vars'}->{cached} = 1 if $env->{'rdflow.cached'};

            $app->($env);
        }
    };

    Plack::Middleware::TemplateToolkit->new( 
        INCLUDE_PATH => $HTDOCS,
        RELATIVE => 1,
        INTERPOLATE => 1, 
        pass_through => 0,
        request_vars => [qw(base)],
        404 => '404.html', 
        500 => '500.html'
    );
};
