package t::Analizo::Extractor::Clang;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use Data::Dumper;

use Analizo::Extractor::Clang;
use Analizo::Batch::Job::Directories;

my $directories = new Analizo::Batch::Job::Directories();
my $extractor = Analizo::Extractor->load('Doxyparse');
$extractor->process($directories->_filter_files('t/samples/calls/cpp/'));
my $callsDoxyParse = $extractor->model;
print(Dumper($callsDoxyParse)); # FIXME remove this

my $directories = new Analizo::Batch::Job::Directories();
my $extractor = Analizo::Extractor->load('Clang');
$extractor->process($directories->_filter_files('t/samples/calls/cpp/'));
my $calls = $extractor->model;
print(Dumper($calls)); # FIXME remove this
# print(Dumper($hello_world)); # FIXME remove this
# print(Dumper($doxyparsemodel)); # FIXME remove this


sub cpp_classes : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/animals/cpp'));
  my $animals = $extractor->model;
  
  my @expected = qw(Animal Cat Dog Mammal main);
  my @got = sort($animals->module_names);
  is_deeply(\@got, \@expected);
}

sub cpp_abstract_classes : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/animals/cpp'));
  my $animals = $extractor->model;

  my @expected = qw(Animal);
  my @got = sort($animals->abstract_classes);
  is_deeply(\@got, \@expected);
}

sub c_modules : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/hello_world/c'));
  my $hello_world = $extractor->model;

  my @expected = qw(hello_world main);
  my @got = sort($hello_world->module_names);
  is_deeply(\@got, \@expected);
}

sub inheritance : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/animals/cpp'));
  my $animals = $extractor->model;

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
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/animals/cpp'));
  my $animals = $extractor->model;

  $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/hello_world/c/hello_world.c'));
  my $hello_world = $extractor->model;

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
               't/samples/animals/cpp/cat.h',
               't/samples/animals/cpp/cat.cc'
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

  is_deeply(\$filesc,\$hello_world->{files});

  is(@keys,@animals_keys);
  is(@vals,@animals_vals);
}

sub cpp_methods : Test {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/animals/cpp'));
  my $animals = $extractor->model;

  my @expected = qw(Animal::name);
  my $got = $animals->{modules}->{Animal}->{functions};
  is_deeply($got, \@expected);
}

sub cpp_calls : Test {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/calls/cpp/main.cpp'));
  my $calls = $extractor->model;

  my @expected = qw(Person::Person main::plusTwo main::sum Person::getAge Person::old_id);
  my @got = keys  %{$calls->{calls}->{"main::main"}};
  @got = sort @got;
  @expected = sort(@expected);
  is_deeply(\@got, \@expected);
}

sub cpp_variables : Test {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/animals/cpp'));
  my $animals = $extractor->model;

  my @expected = qw(Cat::_name);
  my $got = $animals->{modules}->{Cat}->{variables};
  is_deeply($got, \@expected);
}

sub c_functions : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/hello_world/c'));
  my $hello_world = $extractor->model;

  my @expected = qw(hello_world::hello_world_destroy hello_world::hello_world_new hello_world::hello_world_say);
  my @got = sort(@{$hello_world->{modules}->{hello_world}->{functions}});
  is_deeply(\@got, \@expected, 'functions in hello_world module');

  my $main_functions = $hello_world->{modules}->{main}->{functions};

  is_deeply($main_functions, ['main::main'], 'functions in main module');

}

sub c_function_parameters : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/hello_world/c'));
  my $hello_world = $extractor->model;

  my $expected = 1;
  my $got = $hello_world->{parameters}->{'hello_world::hello_world_say'};

  is($got, $expected,"parameters in hello_world_say");
}

sub cpp_function_parameters : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/parameter/'));
  my $cpp_hello_world = $extractor->model;

  my $expected = 4;
  my $got = $cpp_hello_world->{parameters}->{'HelloWorld::foo'};
  is($got, $expected,"parameters in foo");
}

sub c_global_variables : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/hello_world/c'));
  my $hello_world = $extractor->model;

  my @expected = qw(hello_world_id);
  my @got = sort(@{$hello_world->{modules}->{hello_world}->{variables}});
  is_deeply(\@got, \@expected, 'global variables in hello_world module');
}


sub conditional_paths : Tests {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/hello_world/c/hello_world.c'));
  my $hello_world = $extractor->model;

  $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/conditionals/c'));
  my $conditionals_c = $extractor->model;

  $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/conditionals/cpp'));
  my $conditionals_cpp = $extractor->model;

  my @expected = qw(1 1 1);
  my @got = sort(values(%{$hello_world->{conditional_paths}}));
  is_deeply(\@got, \@expected,"hello world conditional paths");

  @expected = qw(1 2 3 4 5);
  @got = sort(values(%{$conditionals_c->{conditional_paths}}));
  is_deeply(\@got, \@expected,"conditionals c folder conditional paths");

  @expected = qw(1 3);
  @got = sort(values(%{$conditionals_cpp->{conditional_paths}}));
  is_deeply(\@got, \@expected,"conditionals cpp folder conditional paths");
}

sub method_protection : Test {
  my $directories = new Analizo::Batch::Job::Directories();
  my $extractor = Analizo::Extractor->load('Clang');
  $extractor->process($directories->_filter_files('t/samples/clang_parser/'));
  my $clang = $extractor->model;

  my @expected = ("public") x 5;
  my @got = values %{$clang->{protection}};

  is_deeply(\@got, \@expected, 'protection for person methods');
}

# TODO - based on functionality from doxyparse extractor
#
# function call/uses
# variable references
# method LOC (?)

# TODO from my head
# calls between C++ methods
# standalone functions in C++ code
# calls between C functions
# calls between C functions and C++ methods

__PACKAGE__->runtests;
