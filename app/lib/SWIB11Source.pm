use strict;
use warnings;
package SWIB11Source;

use parent 'RDF::Flow::Source';
use RDF::Flow::Source qw(:util);

# constructor attributes
use Plack::Util::Accessor qw(source base);

# Lazy RDF namespaces
use RDF::NS;
my $NS = RDF::NS->new('20111102');

# Trine RDF
use RDF::Trine qw(statement iri);

sub retrieve_rdf {
    my ($self, $env) = @_;
    my $uri = rdflow_uri($env) or return;
	my $dbp = $uri;

	my $base = $self->base;
	return unless $dbp =~ s{^$base}{http://de.dbpedia.org/resource/};

	my $rdf = RDF::Trine::Model->new;
	$rdf->add_statement( statement( 
		iri($uri), iri($NS->owl_sameAs), iri($dbp) 
	) );

	return $rdf;
}

1;
