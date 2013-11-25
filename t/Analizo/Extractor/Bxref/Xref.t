package t::Analizo::Extractor::Bxref::Xref;

use base qw(Test::Class);
use Test::More;
use Data::Dumper;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;
use Analizo::Extractor::Bxref::Xref;
use Analizo::Extractor::Bxref::Tree;

eval ('$Analizo::Extractor::QUIET = 1;');

my $extractor;
my $xref_tree;

sub new_xref_extractor () {
	my $model = new Analizo::Model;
	return Analizo::Extractor::Bxref::Xref->new( model => $model);
}

sub new_tree_xref_extractor () {
	return new Analizo::Extractor::Bxref::Tree();
}

sub before : Test(setup) {
	$extractor = new_xref_extractor();
	$xref_tree = new_tree_xref_extractor();
}

sub constructor : Tests {
	use_ok('Analizo::Extractor::Bxref::Xref');
	use_ok('Analizo::Extractor::Bxref::Tree');
	my $extractor = new_xref_extractor();
	isa_ok($extractor, 'Analizo::Extractor::Bxref::Xref');
	isa_ok($extractor, 'Analizo::Extractor');
}

sub has_a_model : Tests {
	isa_ok((Analizo::Extractor->load('Bxref::Xref'))->model, 'Analizo::Model');
}

sub current_directory : Tests {
	use Cwd;
	my $pwd = getcwd();
	my $file_name;
	my $extractor = new_xref_extractor();

	$file_name = $extractor->_strip_current_directory("$pwd/sample/animal.pm");
	is($file_name, "sample/animal.pm", "must return name of the file");
}

#sub adding_current_file_in_the_model : Tests {
#	my $extractor = new_xref_extractor();

#}

sub extracting_module_name : Tests {
	my $extractor = new_xref_extractor();
	my $module_name;

	$module_name = $extractor->_file_to_module("analizo/t/sample/animal.pm");
	is($module_name, "animal", "must return name of the module");
	$module_name = $extractor->_file_to_module("analizo/t/sample/animal.pl");
	is($module_name, "animal", "must return name of the module");
} 

sub qualifing_name : Tests {
	my $extractor = new_xref_extractor();
	my $name;

	$name = $extractor->_qualified_name("animal", "new");
	is($name, "animal::new", "must return name");
}

sub detect_file_in_the_model : Tests {
	my $tree;

	$tree = $xref_tree->building_tree('Person.pm        Employee::new    52 (lexical)       $ self             intro', 'Person.pm');
	$extractor->feed($tree);

	is($extractor->model->{files}->{'Employee'}[0], "Person.pm", "must set the current file in the files array");
	is($extractor->{files}[0], "Person.pm", 'must set the current file in the model');
	is($extractor->current_file, 'Person.pm', 'must set the current file');
}

sub detect_module_in_the_model : Tests {
	my $tree;

	$tree = $xref_tree->building_tree('Person.pm        Employee::new    52 (lexical)       $ self             intro', 'Person.pm');
	$extractor->feed($tree);	

	is($extractor->model->{module_names}[0], "Employee", "must set the current module in the files array");
	is($extractor->current_module, "Employee", "must set the current module in the extractor");
}


sub detect_function_in_the_model : Tests {
	my $tree;

	$tree = $xref_tree->building_tree('Person.pm        Employee::new    52 (lexical)       $ self             intro', 'Person.pm');
	$extractor->feed($tree);

    is($extractor->model->{modules}->{'Employee'}->{functions}[0], "Employee::new", 'must set the current function in the model');
    is($extractor->current_member, 'Employee::new', 'must set the current function');
}

__PACKAGE__->runtests;
