package Analizo::Metric::AverageMethodLinesOfCode;
use strict;
use base qw(Class::Accessor::Fast);
use Statistics::Descriptive;

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Average Method Lines of Code";
}

sub calculate {
  my ($self, $module) = @_;

  my $statisticalCalculator = Statistics::Descriptive::Full->new();
  for my $function ($self->model->functions($module)) {
    $statisticalCalculator->add_data($self->model->{lines}->{$function} || 0);
  }
  return $statisticalCalculator->mean();
}

1;

