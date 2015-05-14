package Analizo::Extractor::Clang;

use strict;

use base qw(Analizo::Extractor);

use File::Basename;
use Cwd;
use Clang;
use Data::Dumper;

sub new {
  my $package = shift;
  return bless { files => {}, visited_nodes => { }, @_ }, $package;
}

sub actually_process($@) {
  my ($self, @input) = @_;

  my $index = Clang::Index -> new(0);
  my $is_c_code = 1;
  if (grep { $_ =~ /\.(cc|cxx|cpp)$/ } @input) {
    $is_c_code = 0;
  }

  for my $file(@input){
	$self->add_file($file);
  }

  for my $file (@input) {
    #$self->add_file($file);
    my $tunit = $index->parse($file);
    my $node = $tunit->cursor;
    $self->_visit_node($node, $is_c_code);
  }
}

sub _visit_node($$$) {
    my ($self, $node, $is_c_code) = @_;

    my $name = $node->spelling;
    my $kind = $node->kind->spelling;
    my ($file, $line, $column) = $node->location();

    # FIXME find other way of skipping nodes outside of the analyzed tree?
    if ($file =~ m/^\/usr/) {
        return;
    }

    if($is_c_code){
	$self->manager_c_files($node,$file,$name,$kind);
    }else{

	$self->manager_cpp_files($node,$file,$name,$kind);
    }
    my $children = $node->children;
    foreach my $child(@$children){
	$self->_visit_node($child,$is_c_code);
    }
}

sub manager_cpp_files{
        my ($self,$node,$file,$name,$kind) = @_;
	if ($kind eq 'ClassDecl') {
	      $self->current_module($name);
	      $self->_get_files_module($name);
	      _find_children_by_kind($node, 'C++ base class specifier',
		sub {
		  my ($child) = @_;
		  my $superclass = $child->spelling;
		  $superclass =~ s/class //; # FIXME should follow the reference to the actual class node instead
		  if (! grep { $_ eq $superclass } $self->model->inheritance($name)) {
		    $self->model->add_inheritance($name, $superclass);
		  }
		}
	      );
	      _find_children_by_kind($node, 'CXXMethod',
		sub {
		  my ($child) = @_;
		  my $method = $child->spelling;
		  $self->model->declare_function($name, $method, $method);
		  if($child->is_pure_virtual && !(grep {$self->current_module eq  $_ }($self->model->abstract_classes))) {
              		$self->model->add_abstract_class($self->current_module);
                  }
		}
	      );
	      _find_children_by_kind($node, 'FieldDecl',
		sub {
		  my ($child) = @_;
		  my $variable = $child->spelling;
		  $self->model->declare_variable($name, $variable, $variable);
		}
	      );
	    }

	    #when it is a cpp file but it is not a class as the main.cpp file
	    if( $kind eq 'FunctionDecl'){
			$self->model->declare_module($name);
			$self->_get_files_module($name);
	    }

}


sub manager_c_files{
      my ($self,$node,$file,$name,$kind) = @_;

      if ($kind eq 'TranslationUnit') {
	      my $module_name = basename($name,(".c",".h"));
	      $self->current_module($module_name);
	      $module_name =~ s/\.\w+$//;
	      $self->_get_files_module($module_name,1);
	      _find_children_by_kind($node, 'FunctionDecl',
		sub {
		  my ($child) = @_;
		  my $function = $child->spelling;
		  my ($child_file) = $child->location;
		  return if ($child_file ne $name);
		  $self->model->declare_function($module_name, $function, $function);

		  _find_children_by_kind($child, 'ParmDecl',
		    sub{
			my($child_of_node) = @_;
			my $parameter = $child_of_node->spelling;

				if($file =~ /.h$/){
					return;
				}

			my $num_parameters = $self->model->{parameters}->{$name};
			my $function_name = update_method_name($self->model->{module_names}[0],$child->spelling);
			$num_parameters = ($num_parameters == undef)?1:$num_parameters+1;

			$self->model->add_parameters($function_name, $num_parameters);
		    }
		);


		}
	      );

	      _find_children_by_kind($node, 'VarDecl',
		sub {
		  my ($child) = @_;
		  my $variable = $child->spelling;
		  my ($child_file) = $child->location;
		  return if ($child_file ne $name);
		  $self->model->declare_variable($module_name, $variable, $variable);
		}
	      );
    }

}

sub update_method_name {
  my ($module, $method) = @_;
  my $final_name = "${module}::${method}";
  return $final_name;
}

sub _find_children_by_kind($$$) {
  my ($node, $kind, $callback) = @_;
  for my $child (@{$node->children}) {
    if ($child->kind->spelling eq $kind) {
      &$callback($child);
    }
  }
}

sub add_file{
  my ($self,$file) = @_;
  my $filename = basename($file,('.c','.h','.cpp','.cc' ));
  $filename = lc($filename);
  $self->{files}->{$filename} ||=[];
  push(@{$self->{files}->{$filename}},$file);
}

sub _get_files_module{
  my ($self, $module,$is_c_code) = @_;
  my $module_lc;
  if($is_c_code){
    $module_lc = basename($module,('.c'));
  }
  $module_lc = lc($module);
   if(exists($self->{files}->{$module_lc})){
     my @implementations =   @{$self->{files}->{$module_lc}};
     foreach my $impl (@implementations) {
        $self->model->declare_module($module, $impl);
     }
  }
}

1;
