package t::Analizo::Extractor::Clang;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use Data::Dumper;

use Analizo::Extractor::Clang;
use Analizo::Extractor::Doxyparse;

my $doxyextractor = Analizo::Extractor->load('Doxyparse');
$doxyextractor->process('t/samples/hello_world/c/hello_world.c');
my $doxyparsemodel = $doxyextractor->model;

my $extractordoxyparse1 = Analizo::Extractor->load('Doxyparse');
$extractordoxyparse1->process('t/samples/animals/cpp');
my $animalsdoxyparse = $extractordoxyparse1->model;

my $extractor1 = Analizo::Extractor->load('Clang');
$extractor1->process('t/samples/animals/cpp');
my $animals = $extractor1->model;

my $extractor2 = Analizo::Extractor->load('Clang');
$extractor2->process('t/samples/hello_world/c');
my $hello_world = $extractor2->model;

my $extractor3 = Analizo::Extractor->load('Clang');
$extractor3->process('t/samples/hello_world/c/hello_world.c');
my $hello_world3 = $extractor3->model;

my $extractor4 = Analizo::Extractor->load('Clang');
$extractor4->process('t/samples/animails/cpp/main.cc');
my $main_model = $extractor4->model;

print(Dumper($animals)); # FIXME remove this
print(Dumper($hello_world)); # FIXME remove this

sub cpp_classes : Tests {
  my @expected = qw(Animal Cat Dog Mammal main);
  my @got = sort($animals->module_names);
  is_deeply(\@got, \@expected);
}

sub cpp_abstract_classes : Tests {
  my @expected = qw(Animal);
  my @got = sort($animals->abstract_classes);
  is_deeply(\@got, \@expected);
}

sub c_modules : Tests {
  my @expected = qw(hello_world main);
  my @got = sort($hello_world->module_names);
  is_deeply(\@got, \@expected);
}

sub inheritance : Tests {
  my @expected = qw(Animal);
  my @got = $animals->inheritance('Mammal');
  is_deeply(\@got, \@expected);

  @expected = qw(Mammal);
  @got = $animals->inheritance('Cat');
  is_deeply(\@got, \@expected);

  @got = $animals->inheritance('Dog');
  is_deeply(\@got, \@expected);
}

sub current_file : Tests{
	my $files = {
                      'main' => [
                                  't/samples/animals/cpp/main.cpp',
                                  't/samples/animals/cpp/main.cc'
                                ],
                      'Animal' => [
                                    't/samples/animals/cpp/animal.h'
                                  ],
                      'Mammal' => [
                                    't/samples/animals/cpp/mammal.h'
                                  ],
                      'Dog' => [
                                 't/samples/animals/cpp/dog.cc',
                                 't/samples/animals/cpp/dog.h'
                               ],
                      'Cat' => [
                                 't/samples/animals/cpp/cat.cc',
                                 't/samples/animals/cpp/cat.h'
                               ]
	 };

	my $filesc = {
		      'hello_world' => [
					 't/samples/hello_world/c/hello_world.c'
				       ]
	};

  my @keys = sort { $files->{$a} <=> $files->{$b} } keys(%$files);
  my @vals = @{$files}{@keys};

  my @animals_keys = sort { $animals->{files}->{$a} <=> $animals->{files}->{$b} } keys%{($animals->{files})};
  my @animals_vals = @{$animals->{files}}{@animals_keys};

	is_deeply(\$filesc,\$hello_world3->{files});

	# is_deeply(\$files, \$animals->{files}); # FIXME Random orders in hash
  is(@keys,@animals_keys);
  is(@vals,@animals_vals);
}

sub cpp_methods : Test {
  my @expected = qw(name);
  my $got = $animals->{modules}->{Animal}->{functions};
  is_deeply($got, \@expected);
}

sub cpp_variables : Test {
  my @expected = qw(_name);
  my $got = $animals->{modules}->{Cat}->{variables};
  is_deeply($got, \@expected);
}

sub c_functions : Tests {
  my @expected = qw(hello_world_destroy hello_world_new hello_world_say);
  my @got = sort(@{$hello_world->{modules}->{hello_world}->{functions}});
  is_deeply(\@got, \@expected, 'functions in hello_world module');

  my $main_functions = $hello_world->{modules}->{main}->{functions};
  is_deeply($main_functions, ['main'], 'functions in main module');
}

sub c_function_parameters : Tests {
    my $expected = 1;
    my $got = $hello_world->{parameters}->{'hello_world::hello_world_say'};

    is($got, $expected,"parameters in hello_world_say");
}

sub c_global_variables : Tests {
  my @expected = qw(hello_world_id);
  my @got = sort(@{$hello_world->{modules}->{hello_world}->{variables}});
  is_deeply(\@got, \@expected, 'global variables in hello_world module');
}

sub update_method_name : Tests {
  my $expected = "file::method";
  my $got = Analizo::Extractor::Clang::update_method_name("file","method");
  is($got, $expected,"Update method name");
}

# TODO - based on functionality from doxyparse extractor
#
# current module
# current filename
# function declaration
# variable declaration
# function call/uses
# variable references
# public members
# method LOC (?)
# method parameters
# method conditional paths
# abstract classes

# TODO from my head
# fully-qualified names (think namespaces)
# calls between C++ methods
# standalone functions in C++ code
# calls between C functions
# calls between C functions and C++ methods

__PACKAGE__->runtests;
