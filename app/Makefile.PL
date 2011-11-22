#!/usr/bin/env perl
use ExtUtils::MakeMaker;
WriteMakefile(
    PREREQ_PM => {

		# Plack, Log::Contextual, TemplateToolkit und RDF::Flow
		'Plack::Middleware::TemplateToolkit' => '0.25',
		'Plack::Middleware::Log::Contextual' => '0',
		'Plack::Middleware::RDF::Flow' => 0,

		'RDF::Trine' => '0.136',
		'RDF::Lazy' => 0,

		# Ebenfalls hilfreich
		'RDF::NS' => '2011102',
		'RDF::Dumper' => 0,

		# Zusätzliche Module
		'LWP::Simple' => 0,
	}
);
