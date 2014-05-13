package Analizo::Extractor::ClangStaticAnalyzerTree;

use strict;
use warnings;

my $tree;

sub new {
  $tree = undef;
  my $package = shift;
  return bless {@_}, $package;
}

sub building_tree {
  my ($self, $line, $file_name) = @_;
  my $bug_name;
  my $line_number;

  if($line =~ m/<\/td><td class="DESC">([^<]+)<\/td><td>([^&]+)<\/td><td class="Q">([\d]+)<\/td><td class="Q">/) {
    $bug_name = $1;
    $line_number = $3;

    if(!defined $tree->{$file_name}->{$bug_name}->{$line_number}) {
      $tree->{$file_name}->{$bug_name}->{$line_number} = 1;
    }
    else {
      $tree->{$file_name}->{$bug_name}->{$line_number}++;
    }
  }

  return $tree;
}

1;
