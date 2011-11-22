use strict;
use warnings;

use Log::Contextual qw(:log);

my $DEVEL = 1;#($ENV{PLACK_ENV} || '') eq 'development';
my $htdocs = './htdocs';

use RDF::NS;
my $NS = RDF::NS->new('20111102');

use RDF::Flow;
my $BASE = "http://example.org/";
my $SOURCE = rdflow( from => "$htdocs/rdf", name => "directory 'rdf'" );

use Plack::Builder;
use Data::Dumper;

my $app = sub {
	my $env = shift;
	log_warn { Dumper($env); };
	[ 404, [ 'Content-Type' => 'text/html' ], [ "Not found\n" ] ];
};

builder {

  # logging and debugging
  enable_if { $DEVEL } 'Debug';
  enable_if { $DEVEL } 'Debug::TemplateToolkit';
  enable 'ConsoleLogger';
  enable_if { $DEVEL } 'Log::Contextual', level => 'trace';
  enable_if { !$DEVEL } 'Log::Contextual', level => 'warn';

  enable 'Static', 
    root => $htdocs,
    path => qr{\.(css|png|gif|js|ico)$};

  # enable 'JSONP';
  enable 'RDF::Flow',
		base         => $BASE,
		empty_base   => 1,
		source       => $SOURCE,
		namespaces   => $NS,
		pass_through => 1;

  # TODO: enable TemplateToolkit and use RDF::Lazy

  $app;
};
