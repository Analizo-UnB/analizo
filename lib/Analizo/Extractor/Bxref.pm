package Analizo::Extractor::Bxref;

use strict;
use warnings;

use base qw(Analizo::Extractor);

use File::Temp qw/ tempfile /;
use Cwd;

sub new {
  my $package = shift;
  return bless { files => [], @_ }, $package;
}

sub _add_file {
  my ($self, $file) = @_;
  push (@{$self->{files}}, $file);
}

sub _perl_hack {
  my ($self, $module) = @_;
  my $current = $self->current_file;
	if(defined($current) && $current =~ /^(.*)\.(t)$/) {
		my $prefix = $1;
		#look for a previously added .pm or .pl
		my @implementations = grep { $_ =~ /^$prefix\.(pm|pl)$/} @{$self->{files}};
		foreach my $impl (@implementations) {
			$self->model->declare_module($module, $impl);
		}
	}
}

sub feed {
  my ($self, $line) = @_;
	
	#current file declaration
	if ($line =~ /^File (.*)$/) {
 		my $file = _strip_current_directory($1);
 		$self->current_file($file);
 		$self->_add_file($file);
	}
}

sub _strip_current_directory {
  my($file) = @_;
  my $pwd = getcwd();
  $file =~ s/^$pwd\///;
  return $file;
}

sub actually_process {
  my $self = shift;
  my ($temp_handle, $temp_filename) = tempfile();
  foreach my $input_file (@_) {
    print $temp_handle "$input_file\n"
  }
  close $temp_handle;

  eval {
    open BXREF, "perl -MO=Xref $temp_filename |" or die $!;
    while (<BXREF>) {
      $self->feed($_);
    }
    close BXREF;
    unlink $temp_filename;
  };
  if($@) {
    warn($@);
    exit -1;
  }
}

1;

