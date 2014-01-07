package Analizo::Extractor::ClangStaticAnalyzer;

use base qw(Analizo::Extractor);

use Cwd;

sub new {
  my ($package, @options) = @_;
  return bless { files => [], @options }
}

sub filter_html_report {
  my ($self, $report_path) = @_;
  my $raw_report;
  my %metrics;
  open($raw_report, "<", $report_path) or die $!;

  while(<$raw_report>) {
    if($_ =~ m/<tr><td class="SUMM_DESC">([A-Za-z\s\.]+)<\/td><td class="Q">([\d]+)<\/td>/) {
    }
    else {
    }
  }
  return %metrics;
}

1;

