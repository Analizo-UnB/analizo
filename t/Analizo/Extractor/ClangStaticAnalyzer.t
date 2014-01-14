package t::Analizo::Extractor::ClangStaticAnalyzer;
use base qw(Test::Class);
use Test::More tests => 4;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;
use Analizo::Extractor::ClangStaticAnalyzer;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Analizo::Extractor::ClangStaticAnalyzer');
  my $extractor = Analizo::Extractor->load('ClangStaticAnalyzer');
  isa_ok($extractor, 'Analizo::Extractor::ClangStaticAnalyzer');
  isa_ok($extractor, 'Analizo::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Analizo::Extractor->load('ClangStaticAnalyzer'))->model, 'Analizo::Model');
}

#sub test_actually_process : Tests {
#  no warnings 'redefine';
#  our %global_metrics;
#
#  sub overriden_feed {
#    my ($self, %metrics) = @_;
#    %global_metrics = %metrics;
#  }
#
#  *Analizo::Extractor::ClangStaticAnalyzer::feed = \&overriden_feed;
#
#  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
#  $extractor->actually_process("t/samples/clang_analyzer/division_by_zero.c", "t/samples/clang_analyzer/dead_assignment.c");
#  my $metrics_size = keys %global_metrics;
#  is($metrics_size , 2, "2 bugs expected");
#}

__PACKAGE__->runtests;

