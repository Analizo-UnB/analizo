package t::Analizo::Extractor::BxrefFile;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Analizo::Extractor::BxrefFile');
  my $extractor = Analizo::Extractor->load('BxrefFile');
  isa_ok($extractor, 'Analizo::Extractor::BxrefFile');
  isa_ok($extractor, 'Analizo::Extractor');
}

__PACKAGE__->runtests;
