package t::Analizo::Metric::ResultIsGarbage;
use base qw(Test::Class);
use Test::More;

use strict;
use warnings;
use File::Basename;

use Analizo::Model;
use Analizo::Metric::ResultIsGarbage;

eval('$Analizo::Metric::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

use vars qw($model $rogu);

sub setup : Test(setup) {
  $model = new Analizo::Model;
  $rogu = new Analizo::Metric::ResultIsGarbage(model => $model);
}

sub use_package : Tests {
  use_ok('Analizo::Metric::ResultIsGarbage');
}

sub has_model : Tests {
  is($rogu->model, $model);
}

sub description : Tests {
  is($rogu->description, "Result of operation is garbage or undefined");
}

sub calculate : Tests {
  is($rogu->calculate('file'), 0, 'file without garbage or undefined operation');

  my $test->{'0'} = 1;
  $model->declare_security_metrics('Result of operation is garbage or undefined', 'file', $test);
  is($rogu->calculate('file'), 1, 'one module, with 1 Result of operation that is garbage or undefined');
}

__PACKAGE__->runtests;