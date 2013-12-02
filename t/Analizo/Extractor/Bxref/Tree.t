package t::Analizo::Extractor::Bxref::Tree;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use Analizo::Extractor::Bxref::Tree;
use Data::Dumper;

my $tree;
my @files;

sub before : Test(setup) {
	$tree = new Analizo::Extractor::Bxref::Tree;
	@files = ("Person.pm");
}

sub after : Test(teardown){
	$tree = undef;
	@files = undef;
}

sub contructor : Tests {
	use_ok('Analizo::Extractor::Bxref::Tree');
	isa_ok($tree,'Analizo::Extractor::Bxref::Tree');
}

sub number_of_global_variables : Tests {
	my $num_global_variables;
	
	$tree = $tree->building_tree('Person.pm        (main)           3 (lexical)       $ abc          intro',@files);	

	$num_global_variables = $tree->{'Person.pm'}->{'(main)'}->{'global_variables'};
	is($num_global_variables, 1, 'Number of global variables must be 1');		
}

sub file_name : Tests {
	my $file;	

	$tree = $tree->building_tree('Person.pm        Person::setFirstName    25 (lexical)       $ firstName  intro',@files);	

	foreach (keys %$tree){
		$file = $_;
	}	
	
	is($file,'Person.pm', 'Name of file must be Person.pm');
	
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
  my $result_tree = new Analizo::Extractor::Bxref::Tree;
 
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

sub method_parent : Tests {
	my $methods;
	my $method_parent;
	
	$tree = $tree->building_tree('Person.pm        (definitions)    78 Employee        & getLastName      subdef',@files);	
	
	$methods = $tree->{'Person.pm'}->{'(definitions)'}->{'getLastName'};
	
	foreach (%$methods){
		$method_parent = $_;
	}
	
	is($method_parent,'Person.pm', 'Name of method parent of getLastName must be Person.pm');
	
}

sub called_method : Tests {
	my $method;
	my $called_method;
	
	$tree = $tree->building_tree('Person.pm Employee::print_employee  85 Employee    & print_person   subused',@files);	
	
	$method = $tree->{'Person.pm'}->{'Employee'}->{'print_employee'}->{'called_methods'};
	
	foreach (keys %$method){
		$called_method = $_;
	}
	
	is($called_method,'print_person','Name of called method must be print_person');
}

__PACKAGE__->runtests;
