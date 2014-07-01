package Analizo::Batch::Runner::Sequential;
use Analizo::Command::metrics_batch;

use strict;
use warnings;

use base qw( Analizo::Batch::Runner );

sub actually_run {
  my ($self, $batch, $output, $opt) = @_;
  my $i = 0;

  while (my $job = $batch->next()) {
    require Analizo::Command::metrics_batch;
    $job = Analizo::Command::metrics_batch->extractor_and_language_apply($opt,$job);
    $job->execute();
    $output->push($job);
    $i++;
    $self->report_progress($job, $i, $batch->count);
  }
}

1;
