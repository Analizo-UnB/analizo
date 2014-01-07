package t::Analizo::Extractor::ClangStaticAnalyzer;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;

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

sub filter_html_report_empty_file : Tests {
  my $extractor = new Analizo::Extractor::ClangStaticAnalyzer;
  my $report_path = "t/clang_analyzer_reports/blank.html";
  my %metrics = $extractor->filter_html_report($report_path);
  my $metrics_size = keys %metrics;
  is($metrics_size, 0, "undefined expected for empty files");
}

__PACKAGE__->runtests;

