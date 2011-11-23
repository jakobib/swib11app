use strict;
use warnings;
package SWIB11App;

use parent 'Plack::Component';

# constructor attributes
use Plack::Util::Accessor qw(source base);

# Lazy RDF namespaces
use RDF::NS;
my $NS = RDF::NS->new('20111102');

# hack to be fixed in RDF::NS
delete $NS->{$_} for qw(new uri can isa);

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

    # RDF data retrieved via RDF::Flow ($self->source)
    my $rdf = $env->{'rdflow.data'};
    my $uri = $env->{'rdflow.uri'};

    if ( $rdf and $rdf->size ) {
        my $lazy = RDF::Lazy->new( $rdf, namespaces => $NS );
        $env->{'tt.vars'}->{'uri'} = $lazy->resource($uri);
    }

    # set the specific template
    $env->{'tt.template'} = 'index.html';
    
    return; # no PSGI return, so pass to next middleware
}

1;
