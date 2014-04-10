package Analizo::Metric::PotentialInsecureTempFileInCall;
use strict;
use base qw(Class::Accessor::Fast Analizo::ModuleMetric);

__PACKAGE__->mk_accessors(qw( model ));

sub new {
  my ($package, %args) = @_;
   my @instance_variables = (
    model => $args{model}
  );
  return bless { @instance_variables }, $package;
}

sub description {
  return "Potential insecure temporary file in call";
}

sub calculate {
  my ($self, $module) = @_;

  return 0 if (!defined $self->model->security_metrics('Potential insecure temporary file in call', $module));

  return $self->model->security_metrics('Potential insecure temporary file in call', $module);

}

1;

