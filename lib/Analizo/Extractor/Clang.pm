package Analizo::Extractor::Clang;

use strict;
use warnings;

use File::Basename;
use base qw(Analizo::Extractor);

use Cwd;
use Clang;

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

  for my $file(@input) {
    $self->add_file($file);
  }

  for my $file (@input) {
    my $tunit = $index->parse($file);
    my $node = $tunit->cursor;

    $self->_visit_node($node, $is_c_code);
  }
}

sub _visit_node($$$) {
  my ($self, $node, $is_c_code) = @_;

  my $name = $node->spelling;
  my $kind = $node->kind->spelling;
  my $children = $node->children;
  my ($file, $line, $column) = $node->location();

  # FIXME find other way of skipping nodes outside of the analyzed tree?
  if ($file =~ m/^\/usr/) {
    return;
  }

  if($is_c_code) {
    $self->manager_c_files($node,$file,$name,$kind);
  } else {
    $self->manager_cpp_files($node,$file,$name,$kind);
  }

  if ($kind eq 'IfStmt'|| $kind eq 'CaseStmt') {
    $self->identify_conditional_path();
  }

  foreach my $child(@$children) {
    $self->_visit_node($child,$is_c_code);
  }
}

sub manager_cpp_files {
  my ($self,$node,$file,$name,$kind) = @_;

  if ($kind eq 'ClassDecl') {
    $self->current_module($name);
    $self->_get_files_module($name);

    _find_children_by_kind ($node, 'C++ base class specifier',
      sub {
        my ($child) = @_;
        my $superclass = $child->spelling;

        $superclass =~ s/class //; # FIXME should follow the reference to the actual class node instead

        if (!grep {$_ eq $superclass} $self->model->inheritance($name)) {
          $self->model->add_inheritance($name, $superclass);
        }
      }
    );

    _find_children_by_kind ($node, 'CXXConstructor',
      sub {
        my ($child) = @_;
        my $method = $child->spelling;
        my $access = $child->access_specifier;

        $self->{current_member} = $child;
        $self->identify_conditional_path(); 
        $self->model->declare_function($name, qualified_name($child));
        $self->model->add_protection(qualified_name($child),$access) if $access eq 'public';
      }
    );

    _find_children_by_kind ($node, 'CXXMethod',
      sub {
        my ($child) = @_;
        my $access = $child->access_specifier;
        my $num_parameters = $child->num_arguments();
        my $method = qualified_name($child);
        my $function_name = qualified_name($child);

        $self->{current_member} = $child;
        $self->model->declare_function($name, $method);
        $self->model->add_protection($method,$access) if $access eq 'public';
        $self->identify_conditional_path();

        if ($child->is_pure_virtual && !(grep {$self->current_module eq  $_ }($self->model->abstract_classes))) {
          $self->model->add_abstract_class($self->current_module);
        }

        $self->model->add_parameters($function_name, $num_parameters);
      }
    );

    _find_children_by_kind ($node, 'FieldDecl',
      sub {
        my ($child) = @_;
        my $variable = qualified_name($child);

        $self->model->declare_variable($name, $variable, $variable);
        $self->{current_member} = $child;
      }
    );
  }

  #when it is a cpp file but it is not a class, as the main.cpp file
  if ($kind eq 'FunctionDecl') {
    my $module = $self->_get_basename($file); 
    my $access = $node->access_specifier;
    $access =  $access eq 'invalid' ? 'public': $access;

    $self->current_module($module);
    $self->model->declare_function($module, qualified_name($node));

    $self->_get_files_module($module);
    $self->model->add_protection(qualified_name($node), $access);
  }
}

sub manager_c_files {
  my ($self,$node,$file,$name,$kind) = @_;

  if ($kind eq 'TranslationUnit') {
    my $module_name = $self->_get_basename($name);

    $self->current_module($module_name);
    $self->_get_files_module($module_name,1);

    _find_children_by_kind($node, 'FunctionDecl',
      sub {
        my ($child) = @_;
        my $function = $child->spelling;
        my $access = $node->access_specifier;
        my ($child_file) = $child->location;
        my $num_parameters = $child->num_arguments();
        my $function_name = qualified_name($child);

        return if ($child_file ne $name);

        $self->{current_member} = $child;
        $self->identify_conditional_path();

        $access =  $access eq 'invalid' ? 'public': $access;
        $self->model->declare_function($module_name, qualified_name($child));
        $self->model->add_protection(qualified_name($child), $access);

        $self->model->add_parameters($function_name, $num_parameters); 
	    }
    );

    _find_children_by_kind($node, 'VarDecl',
      sub {
        my ($child) = @_;
        my $variable = $child->spelling;
        my ($child_file) = $child->location;

        return if ($child_file ne $name);

        $self->model->declare_variable($module_name, $variable, $variable);
        $self->{current_member} = $child;
      }
    );
  }
}

sub identify_conditional_path {
  my($self) = @_;
  my $function_name = qualified_name($self->current_member);
  my $num_paths = $self->model->{conditional_paths}->{$function_name};
  
  $num_paths = ($num_paths)?$num_paths+1:1;
  $self->model->add_conditional_paths($function_name, $num_paths);
}

sub qualified_name {
  my ($node) = @_;
  my @matches = ($node->USR() =~ m/@(\w+)/g);
  my $final_name;

  if ($matches[0] eq "C"){
    $final_name = $matches[1]."::".$matches[3];
  }
  else{
    $final_name = $matches[1];  
  }
  
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

sub _get_basename {
  my ($self, $file) = @_;
  my $filename = basename($file,('.c','.h','.cpp','.cc' ));
  
  return $filename;
}

sub add_file {
  my ($self,$file) = @_;
  my $filename = $self->_get_basename($file);
  
  $filename = lc($filename);
  $self->{files}->{$filename} ||=[];
  push(@{$self->{files}->{$filename}},$file);
}

sub _get_files_module {
  my ($self, $module,$is_c_code) = @_;
  my $module_lc;

  if($is_c_code){
    $module_lc = $self->_get_basename($module);
  }

  $module_lc = lc($module);
  
  if(exists($self->{files}->{$module_lc})){
    my @implementations = @{$self->{files}->{$module_lc}};
    
    foreach my $impl (@implementations) {
       $self->model->declare_module($module, $impl);
    }
  }
}

1;
