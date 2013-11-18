package t::Analizo::Extractor::Bxref::Xref;

use base qw(Test::Class);
use Test::More 'no_plan';

use strict;
use warnings;
use File::Basename;

eval ('$Analizo::Extractor::QUIET = 1;');

sub new_xref_extractor() {
  my $model = new Analizo::Model;
  return Analizo::Extractor::Bxref::Xref->new(model => $model);
}

sub constructor : Tests {
	use_ok('Analizo::Extractor::Bxref::Xref');
	my $extractor = new_xref_extractor();
	isa_ok($extractor, 'Analizo::Extractor::Bxref::Xref');
	isa_ok($extractor->model, 'Analizo::Model');
}

#sub current_module : Tests {
#	my $extractor = Analizo::Extractor->load('Xref');
	
#	$extractor->current_module('module1.pl');
#	is($extractor->current_module, 'module1.pl', 'must be able to set the current module');

#	$extractor->current_module('module2.pm');
#	is($extractor->current_module, 'module2.pm', 'must be able to set the current module');
#}

__PACKAGE__->runtests;

