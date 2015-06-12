package t::Analizo::Command::metrics_batch;
use strict;
use warnings;
use base qw(t::Analizo::Test::Class);
use Test::More;
use t::Analizo::Test;
use Analizo;

BEGIN {
  use_ok 'Analizo::Command::metrics_batch'
};

sub constructor : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metrics-batch');
  isa_ok($cmd, 'Analizo::Command::metrics_batch');
}

sub is_a_subclass_of_Analizo_Command : Tests {
  my $analizo = Analizo->new;
  my ($cmd) = $analizo->prepare_command('metrics-batch');
  isa_ok($cmd, 'Analizo::Command');
}

sub testing_functionality_of_extractor_and_language_apply : Tests {
	my $job = mock(new Analizo::Batch::Job::Directories);
	my $analizo = Analizo->new;
	my ($cmd) = $analizo->prepare_command('metrics-batch');
	my $job_function = $cmd->extractor_and_language_apply(my $opt,$job);
	ok($job == $job_function);
	isa_ok($job_function, 'Analizo::Batch::Job::Directories');
}

__PACKAGE__->runtests;
