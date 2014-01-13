package t::Analizo::Extractor::ClangStaticAnalyzerTree;
use base qw(Test::Class);
use Test::More tests => 5;

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;
use Analizo::Extractor::ClangStaticAnalyzerTree;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

my $tree;

sub before : Test(setup) {
  $tree = new Analizo::Extractor::ClangStaticAnalyzerTree;
}

sub after : Test(teardown){
  $tree = undef;
}

sub constructor : Tests {
  use_ok('Analizo::Extractor::ClangStaticAnalyzerTree');
  my $extractor = Analizo::Extractor->load('ClangStaticAnalyzerTree');
  isa_ok($extractor, 'Analizo::Extractor::ClangStaticAnalyzerTree');
}

sub building_tree_with_reports_from_radom_file  : Tests {
  my $report_path = "t/clang_analyzer_reports/analizo_org.html";
  my $report_tree;
  my $metrics_size = 0;

  open (my $file_report, '<', $report_path) or die $!;
  while(<$file_report>){
    $report_tree = $tree->building_tree($_);
  }
  close ($file_report);

  $metrics_size = keys $report_tree if defined $report_tree;
  is($metrics_size , 0, "No metrics expected");
}

sub building_tree_with_reports_empty_file  : Tests {
  my $report_path = "t/clang_analyzer_reports/blank.html";
  my $report_tree;
  my $metrics_size = 0;

  open (my $file_report, '<', $report_path) or die $!;
  while(<$file_report>){
    $report_tree = $tree->building_tree($_);
  }
  close ($file_report);

  $metrics_size = keys $report_tree if defined $report_tree;
  is($metrics_size , 0, "No metrics expected");
}

sub building_tree_with_reports_from_multiple_files : Tests {
  my $report_path = "t/clang_analyzer_reports/libreoffice.html";
  my $report_tree;

  open (my $file_report, '<', $report_path) or die $!;
  while(<$file_report>){
    $report_tree = $tree->building_tree($_);
  }
  close ($file_report);

  my $metrics_size = keys $report_tree;
  ok($metrics_size > 0, "metrics expected");

  undef $tree;
}

__PACKAGE__->runtests;
