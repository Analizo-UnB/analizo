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

  open($raw_report, "<", $report_path) or return %metrics;

  while(<$raw_report>) {
    if($_ =~ m/<tr><td class="SUMM_DESC">([^<]+)<\/td><td class="Q">([\d]+)<\/td>/) {
      $metrics{$1} = $2;
    }
  }

  close($raw_report);
  return %metrics;
}

sub actually_process {
  my ($self, @input_files) = @_;
  my %metrics;
  my $files_list = join(' ', @input_files);
  my $output_folder = "/tmp/analizo-clang-analyzer";

  my $analyze_command = "scan-build -o $output_folder gcc -c $files_list >/dev/null 2>/dev/null";

  #FIXME: Eval removed due to returning bug
  system($analyze_command);
  my $html_report = glob("$output_folder/*/index.html");
  %metrics = $self->filter_html_report($html_report);
  system("rm -rf $output_folder");
  $self->feed(%metrics);
}

sub feed {
}

1;

