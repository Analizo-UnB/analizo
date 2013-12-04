package t::Analizo::Extractor::B::Tree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use Analizo::Extractor::B::Tree;
use Data::Dumper;

my $tree;
my @files;

sub before : Test(setup) {
	$tree = new Analizo::Extractor::B::Tree;
	@files = ("Person.pm");
}

sub after : Test(teardown){
	$tree = undef;
	@files = undef;
}

sub contructor : Tests {
	use_ok('Analizo::Extractor::B::Tree');
	isa_ok($tree,'Analizo::Extractor::B::Tree');
}

sub number_of_global_variables : Tests {
	my $num_global_variables;
	
	$tree = $tree->building_tree('Person.pm        (main)           3 (lexical)       $ abc          intro',@files);	

	$num_global_variables = $tree->{"Person.pm"}->{"(main)"}->{"global_variables"};
	is($num_global_variables, 1, 'Number of global variables must be 1');		
}

sub file_name : Tests {
	my $file;	

	$tree = $tree->building_tree('Person.pm        Person::setFirstName    25 (lexical)       $ firstName  intro',@files);	

	foreach (keys %$tree){
		$file = $_;
	}	
	
	is($file,"Person.pm", 'Name of file must be Person.pm');
	
}

sub module_name : Tests {	
	my $file;
	my $module;

	$tree = $tree->building_tree('Person.pm        Person::setFirstName    25 (lexical)       $ firstName  intro',@files);	

	$file = $tree->{'Person.pm'};
	
	foreach (keys %$file){
		$module = $_;
	}
		
	is($module, 'Person', 'Name of module must be Person');
}

sub method_name : Tests {
	my $module;
	my $method;

	$tree = $tree->building_tree('Person.pm        Person::setFirstName    25 (lexical)       $ firstName  intro',@files);
	
	$module = $tree->{'Person.pm'}->{'Person'};
	
	foreach (keys %$module){
		$method = $_;
	}
	
	is($method,'setFirstName', 'Name of method must be setFirstName');
	
}

sub variable_name : Tests {
	my $method;
	my $variable;

	$tree = $tree->building_tree('Person.pm        Person::setFirstName    25 (lexical)       $ firstName  used',@files);

	$method = $tree->{'Person.pm'}->{'Person'}->{'setFirstName'}->{'used_variable_names'};

	foreach (keys %$method){
		$variable = $_;
	}
	
	is($variable,'firstName', 'Name of variable must be firstName');
}

sub use_of_variable : Tests {
	my $is_used;
  my $result_tree = new Analizo::Extractor::B::Tree;
 
  $result_tree = $tree->building_tree('Person.pm        Person::setFirstName    25 main       $ firstName  used' ,@files);
		
	$is_used = $result_tree->{'Person.pm'}->{'Person'}->{'setFirstName'}->{'used_variable_names'}->{'firstName'};	
		
	is($is_used, 1, 'Variable firstName must be used'.Dumper($tree));
}

sub local_variable_names : Tests {
	my @local_variable_name;
	my $variable;

	$tree = $tree->building_tree('Person.pm        Person::setFirstName    25 (lexical)       $ firstName  intro',@files);

	@local_variable_name = @{$tree->{'Person.pm'}->{'Person'}->{'setFirstName'}->{'local_variable_names'}};

	foreach  (@local_variable_name){
		$variable = $_;
	}
	
	is($variable,'firstName', 'Name of variable must be firstName');	
}

__PACKAGE__->runtests;
