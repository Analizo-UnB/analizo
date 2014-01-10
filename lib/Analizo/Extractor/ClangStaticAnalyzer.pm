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

  #FIXME: Insert regex to enter right directory
  my $html_report = "$output_folder/2014-01-09-1/index.html";
  my $analyze_command = "scan-build -o $output_folder gcc -c $files_list >/dev/null 2>/dev/null";

  #FIXME: Eval removed due to returning bug
  system($analyze_command);
  %metrics = $self->filter_html_report($html_report);
  system("rm -rf $output_folder");
  $self->feed(%metrics);
}

sub feed {
  my ($self, %metrics) = @_;

  while (($key, $value) = each (%metrics)){

    if ($key eq 'Division by zero') {
      $self->model->set_number_of_divisions_by_zero($value);
    }

    if ($key eq 'Returning null reference') {
      $self->model->set_number_of_returning_null_reference($value);
    }

    if ($key eq 'Called function pointer is an uninitalized pointer value') {
      $self->model->set_number_of_called_function_pointer_is_an_uninitalized_pointer_value($value);
    }

    if ($key eq 'Branch condition evaluates to a garbage value') {
      $self->model->set_number_of_branch_condition_evaluates_to_a_garbage_value($value);
    }

    if ($key eq 'Return of address to stack-allocated memory') {
      $self->model->set_number_of_return_of_address_to_stack_allocated_memory($value);
    }

    if ($key eq 'Stack address stored into global variable') {
      $self->model->set_number_of_stack_address_stored_into_global_variable($value);
    }

    if ($key eq 'Result of operation is garbage or undefined') {
      $self->model->set_number_of_result_of_operation_is_garbage_or_undefined($value);
    }

    if ($key eq 'Assigned value is garbage or undefined') {
      $self->model->set_number_of_assigned_value_is_garbage_or_undefined($value);
    }

    if ($key eq 'The left expression of the compound assignment is an uninitialized value. The computed value will also be garbage') {
      $self->model->set_number_of_the_left_expression_of_the_compound_assignment_is_an_uninitialized_value($value);
    }

    if ($key eq 'Illegal whence argument') {
      $self->model->set_number_of_illegal_whence_argument($value);
    }

    if ($key eq 'NULL stream pointer') {
      $self->model->set_number_of_NULL_stream_pointer($value);
    }

    if ($key eq 'Double fclose') {
      $self->model->set_number_of_double_fclose($value);
    }

    if ($key eq 'Resource Leak') {
      $self->model->set_number_of_resource_leak($value);
    }

    if ($key eq 'Uninitialized value used as mutex for @synchronized') {
      $self->model->set_number_of_uninitialized_value_used_as_mutex_for_synchronized($value);
    }

    if ($key eq 'Nil value used as mutex for @synchronized() (no synchronization will occur)') {
      $self->model->set_number_of_nil_value_used_as_mutex_for_synchronized($value);
    }

    if ($key eq 'Garbage return value') {
      $self->model->set_number_of_garbage_return_value($value);
    }

    if ($key eq 'Dangerous pointer arithmetic') {
      $self->model->set_number_of_dangerous_pointer_arithmetic($value);
    }

    if ($key eq 'Use fixed address') {
      $self->model->set_number_of_use_fixed_address($value);
    }

    if ($key eq 'Pointer subtraction') {
      $self->model->set_number_of_pointer_subtraction($value);
    }

    if ($key eq 'Out-of-bound array access') {
      $self->model->set_number_of_out_of_bound_array_access($value);
    }

    if ($key eq 'Cast region with wrong size') {
      $self->model->set_number_of_cast_region_with_wrong_size($value);
    }

    if ($key eq 'Cast from non-struct type to struct type') {
      $self->model->set_number_of_returning_null_reference($value);
    }

    if ($key eq 'Array subscript is undefined') {
      $self->model->set_number_of_cast_from_non_struct_type_to_struct_type($value);
    }

    if ($key eq 'Return of pointer value outside of expected range') {
      $self->model->set_number_of_return_of_pointer_value_outside_of_expected_range($value);
    }

    if ($key eq 'Branch condition evaluates to a garbage value') {
      $self->model->set_number_of_branch_condition_evaluates_to_a_garbage_value($value);
    }

    if ($key eq 'Dereference of undefined pointer value') {
      $self->model->set_number_of_dereference_of_undefined_pointer_value($value);
    }

    if ($key eq 'Dereference of null pointer') {
      $self->model->set_number_of_dereference_of_null_pointer($value);
    }

    if ($key eq 'Assignment of a non-Boolean value') {
      $self->model->set_number_of_assignment_of_a_non_boolean_value($value);
    }

    if ($key eq 'Break out of jail') {
      $self->model->set_number_of_break_out_of_jail($value);
    }

    if ($key eq 'uninitialized variable captured by block') {
      $self->model->set_number_of_uninitialized_variable_captured_by_block($value);
    }

    if ($key eq 'Out-of-bound access') {
      $self->model->set_number_of_out_of_bound_access($value);
    }

    if ($key eq 'Dangerous variable-length array (VLA) declaration') {
      $self->model->set_number_of_dangerous_variable_length_array_declaration($value);
    }

    if ($key eq 'Sum of expressions causes overflow') {
      $self->model->set_number_of_sum_of_expressions_causes_overflow($value);
    }
  }
}

1;


