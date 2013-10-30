package Analizo::Extractor::BxrefFile;
use strict;
use warnings;

use base qw(Analizo::Extractor::Bxref);

sub use_filters {
  0;
}

sub actually_process {
  my $self = shift;
  my $bxref_filename = shift;
  open BXREF_FILE , '<', $bxref_filename or die $!;
  while(<BXREF_FILE>){
    $self->feed($_);
  } 
  close BXREF_FILE;
  if($@){
    warn($@);
    exit -1;
  }
}

1;
