package t::Analizo::Extractor::Bxref;
use base qw(Test::Class);
use Test::More 'no_plan'; # REMOVE THE 'no_plan'

use strict;
use warnings;
use File::Basename;

use Analizo::Extractor;

eval('$Analizo::Extractor::QUIET = 1;'); # the eval is to avoid Test::* complaining about possible typo

sub constructor : Tests {
  use_ok('Analizo::Extractor::Bxref');
  my $extractor = Analizo::Extractor->load('Bxref');
  isa_ok($extractor, 'Analizo::Extractor::Bxref');
  isa_ok($extractor, 'Analizo::Extractor');
}

sub has_a_model : Tests {
  isa_ok((Analizo::Extractor->load('Bxref'))->model, 'Analizo::Model');
} 

sub current_module : Tests {
	my $extractor = Analizo::Extractor->load('Bxref');
	$extractor->current_module('module1.pl');
	is($extractor->current_module, 'module1.pl', 'must be able to set the current module');
	$extractor->current_module('module2.pm');
 	is($extractor->current_module, 'module2.pm', 'must be able to set the current module');
}

sub current_file_strip_pwd : Tests {
	use Cwd;
	my $pwd = getcwd();
	my $extractor = new Analizo::Extractor::Bxref;
	$extractor->feed("File $pwd/perl/test.pl");
	is($extractor->current_file(), 'perl/test.pl');
}

__PACKAGE__->runtests;
