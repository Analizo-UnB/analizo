package Analizo::Extractor::Bxref::Tree;

use strict;
use warnings;


sub new {
	my $package = shift;
	return bless {@_}, $package;
}

sub add_method_to_self {
	my ($self, $file, $module, $element_method, $element_usage, $element_name, $element_type, $element_package) = @_;

	if ($element_usage =~ /^subused$/ && !($element_type =~ /\?/)) {
		if (!($element_package =~ /main/ || $element_package =~ /(lexical)/)){
			$self->{$file}->{$module}->{$element_method}->{"called_methods"}->{$element_name} = $element_package;
		}	
		else {
			$self->{$file}->{$module}->{$element_method}->{"called_methods"}->{$element_name} = $self->father_seeker($element_name);
		}
	}
}

sub father_seeker {
	my ($self, $method_name) = @_;
	my $files;
	my $modules;
	my $methods;

	foreach (keys %$self) {
		$files = $self->{@_};

		foreach (keys %$files) {
			$modules = $files->{$_};

			foreach (keys %$modules) {

				if ($_ =~ /$method_name/) {
					$methods = $modules->{$_} unless (/global_variables/);
				}					

				foreach (keys %$methods) {
					if ($_ =~ /method_parent/){ 
						return ($methods->{$_});
					}
				}
			}
		}
	}
}

sub building_tree {
	my $file;
  my $module;
	my $element_method;
	my $element_usage;
	my $element_name;
	my $element_line;
	my $element_type;
	my $element_package;
  my $full_name;

	my ($self, $lines, @files) = @_;

	chomp $lines;

	#FIX FILE NAMES

	#				$1		$2				$3		$4			$5			$6		$7
	#				file    module::method line   package -----type---    name    ---used----  
	if ($lines =~ /^(\S+)\s+(\S+)\s+(\d+)\s(\S+)\s+([@*&\$%?>-]+)\s(\S+)\s+([a-zA-Z]+)$/) {
		$file = $1;
		$full_name = $2;
    	$element_line = $3;
		$element_package = $4;
		$element_type = $5;
		$element_name = $6;
		$element_usage = $7;

    if ($full_name =~ /(\S+)::(\S+)/){
      $module = $1;
      $element_method = $2;
    } else{
        $module = $full_name;
        $element_method = "(global)";
      }

		#FIX FILE NAMES
    if ($module =~ /\(/){
		  $self->{$file}->{$module}->{"global_variables"} = 0 if (!defined ($self->{$file}->{$module}) && grep {$_ eq $file} @files);
    }

		if (grep {$_ eq $file} @files) {

			if ($element_usage =~ /^intro$/) {
				push @{$self->{$file}->{$module}->{$element_method}->{"local_variable_names"}}, $element_name;

				if ($module =~ /\(/){ 
					$self->{$file}->{$module}->{"global_variables"} ++;
				}
			} else {
				if ($element_line != 0 && $element_usage =~ /^used$/) {
					if (grep{$_ eq $element_name} @{$self->{$file}->{$module}->{$element_method}->{"local_variable_names"}}){
						$self->{$file}->{$module}->{$element_method}->{"used_variable_names"}->{$element_name} = 0;
					} else {
						$self->{$file}->{$module}->{$element_method}->{"used_variable_names"}->{$element_name} = 1;
					  }
				}

				if ($element_usage =~ /^subdef$/ && $element_line != 0) {
					my @another_method_full_name = split "::", $element_name;
					$element_name = $another_method_full_name[$#another_method_full_name];
					$self->{$file}->{$module}->{$element_name}->{"method_parent"} = $file;
				}
			}
			
			$self->add_method_to_self ($file, $module, $element_method, $element_usage, $element_name, $element_type, $element_package);
		}
	}
	
	return $self;
}

1;

