use strict;
use warnings;
package RDF::Flow::URIMap;

use parent 'RDF::Flow::Source';
use RDF::Flow::Source qw(:util);

use Plack::Util::Accessor qw(source map);

use RDF::Trine qw(iri statement);

sub map_node {
	my ($self, $node) = @_;
	return $node unless $node->isa('RDF::Trine::Node::Resource');

	local $_ = $node->uri_value;
	$self->map->();
	$node->uri( $_ );

	return $node;
}

sub retrieve_rdf {
    my ($self, $env) = @_;

	my $rdf = $env->{'rdflow.data'} or return;
	return unless $self->map;
	$rdf = $rdf->as_stream unless $rdf->isa('RDF::Trine::Iterator');

	my $result = RDF::Trine::Model->new;

	# iterate over statements
	while (my $st = $rdf->next) {
		my ($s,$p,$t) = $st->nodes;
		$result->add_statement( statement( map { $self->map_node($_) } $st->nodes) );
	}

	return $result;
}

1;
