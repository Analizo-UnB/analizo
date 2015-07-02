package t::Analizo::Extractor;
use base qw(Test::Class);
use Test::More;
use Test::Exception;

use strict;
use warnings;

use Analizo::Extractor;
use Analizo::LanguageFilter;
use Analizo::Model;

# Redefine constructor so that this test class can instantiate
# Analizo::Extractor directly
use Test::MockModule;
my $AnalizoExtractor = new Test::MockModule('Analizo::Extractor');
$AnalizoExtractor->mock('new', sub { return bless {}, 'Analizo::Extractor'});

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  isa_ok(new Analizo::Extractor, 'Analizo::Extractor');
}

sub has_a_current_member : Tests {
  can_ok('Analizo::Extractor', 'current_member');
}

##############################################################################
# BEGIN test of indicating current module
##############################################################################
sub current_module : Tests {
  my $extractor = new Analizo::Extractor;
  $extractor->current_module('module1.c');
  is($extractor->current_module, 'module1.c', 'must be able to set the current module');
  $extractor->current_module('module2.c');
  is($extractor->current_module, 'module2.c', 'must be able to change the current module');
}

sub current_file : Tests {
  my $extractor = new Analizo::Extractor;
  is($extractor->current_file, undef);
  $extractor->current_file('file1.c');
  is($extractor->current_file, 'file1.c');
}

sub current_file_plus_current_module : Tests {
  my $extractor = new Analizo::Extractor;

  my $model = new Analizo::Model;
  $extractor->{model} = $model;

  $extractor->current_file('person.cpp');
  $extractor->current_module('Person');

  is_deeply($model->{module_by_file}->{'person.cpp'}, ['Person']);
}

sub process_must_delegate_to_actually_process : Tests {
  my $called = 0;
  no warnings;
  local *Analizo::Extractor::actually_process = sub { $called = 1; };
  use warnings;
  Analizo::Extractor->new->process;
  ok($called);
}

sub load_doxyparse_extractor : Tests {
  lives_ok { Analizo::Extractor->load('Doxyparse') };
}

sub fail_when_load_invalid_extractor : Tests {
  dies_ok { Analizo::Extractor->load('ThisNotExists') };
}

sub load_doxyparse_extractor_by_alias : Tests {
  lives_ok {
    isa_ok(Analizo::Extractor->load('doxy'), 'Analizo::Extractor::Doxyparse');
  }
}

sub dont_allow_code_injection: Tests {
  lives_ok {
    isa_ok(Analizo::Extractor->load('Clang; die("BOOM!")'), 'Analizo::Extractor::Clang');
  }
}



__PACKAGE__->runtests;
