#! /usr/bin/perl

package Analizo::Extractor::Bxref::Xref;

use strict;
use warnings;

use base qw(Analizo::Extractor);
use Analizo::Extractor::Bxref::Tree;
use Data::Dumper;

sub new {
	my $package = shift;
	return bless { files => [], @_}, $package;
}

sub _file_to_module {
	my ($self, $file) = @_;
	my @tmp_name = split "/", $file;
	my $module_name = $tmp_name[$#tmp_name];
	$module_name =~ s/\.pm//;
	$module_name =~ s/\.pl//;
	
	return $module_name;
}

sub _function_declarations {
	my ($self, $function) = @_;

	if (!($function =~ /global_variables/)) {
		my $function = $self->_qualified_name($self->current_module, $_);
		$self->model->declare_function($self->current_module, $function);
		$self->{current_member} = $function;
	}
}

sub _variable_declarations {
	my ($self, $methods) = @_;

	foreach (keys %$methods) {
		my $local_variables = $methods->{$_};

		if (/local_variable_names/) {
			foreach (@$local_variables) {
				my $variable = $self->_qualified_name($self->current_module, $_);
				$self->model->declare_variable($self->current_module, $variable);
				$self->{current_member};
			}
		}
	}
}

sub feed {
	my ($self, $tree) = @_;

	foreach (keys %$tree) {
		my $file = $self->_strip_current_directory($_);
		$self->current_file($file);
		$self->_add_file($file);

		my $module_name = $self->_file_to_module($file);
		$self->current_module($module_name);

		my $files = $tree->{$_};

		foreach (keys %$files) {
			$self->_function_declaration($_);

			my $methods = $files->{$_} if (/new/);
			$self->_variable_declarations($methods);
		}
	}
}

sub actually_process {
	my ($self, @files) = @_;
	my $tree;

#	my $xref_tree = new Analizo::Extractor::Bxref::Tree;
	my $xref_tree;
	foreach my $input_file (@files) {
		open ANALISES, "perl -MO=Xref,-r $input_file 2> /dev/null | " or die $!;

		while (<ANALISES>) { 
			$tree = $xref_tree->building_tree($_, @files);
    }

		close ANALISES;
	}

	$self->feed($tree);

	print Dumper ($self);

	if ($@) {
		warn($@);
		exit -1;
	}
}

1;


