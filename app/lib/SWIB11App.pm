use strict;
use warnings;
package SWIB11App;

use parent 'Plack::Component';

# constructor attributes
use Plack::Util::Accessor qw(source base);

# Lazy RDF namespaces
use RDF::NS;
my $NS = RDF::NS->new('20111102');

use RDF::Lazy;
use CGI qw(escapeHTML);
use Data::Dumper;
use RDF::Dumper;


# This method is called on startup
sub prepare_app {
    my $self = shift;

    #    
    # set some $self->{...} variables if needed
    #
}

# Receives the PSGI $env hash and returns a PSGI reponse
sub call {
    my ($self, $env) = @_;

    # TODO: enable TemplateToolkit and use RDF::Lazy

    my $ttl = rdfdump($env->{'rdflow.data'});
    my $uri = $env->{'rdflow.uri'};
    my $h1  = $uri; #escapeHTML( uri_unescape( $uri ) );
    my @html = "<body><h1><a href='". escapeHTML($uri) . "'>$h1</a></h1>".
                   "<pre>" . escapeHTML($ttl) . "</pre></body>" . Dumper($self->source);
    return [ 200, [ 'Content-Type', 'text/html; charset=UTF8' ], [ @html ] ]; 


    return [ 404, [ 'Content-Type' => 'text/html' ], [ "Not found\n" ] ];
}

1;
