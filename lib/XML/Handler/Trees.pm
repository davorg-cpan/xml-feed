use strict;

package XML::Handler::Trees;
use vars qw/$VERSION/;
$VERSION = '0.02';

package XML::Handler::Tree;

sub new {
  my $class = ref($_[0]) || $_[0];
  bless {},$class;
}

sub start_document {
  my $self=shift;
  $self->{Lists}=[];
  $self->{Curlist}=$self->{Tree}=[];
}

sub start_element {
  my ($self,$element)=@_;
  my $newlist;
  if (exists $element->{LocalName}) {
    # namespaces are available!
    $newlist = [{}];
    foreach my $attr (values %{$element->{Attributes}}) {
      if ($attr->{NamespaceURI}) {
        $newlist->[0]{"{$attr->{NamespaceURI}}$attr->{LocalName}"} = $attr->{Value};
      }
      else {
        $newlist->[0]{$attr->{Name}} = $attr->{Value};
      }
    }
  }
  elsif (ref $element->{Attributes} eq 'HASH') {
    $newlist=[{map {$_=>$element->{Attributes}{$_}} keys %{$element->{Attributes}}}];
  }
  else {
    $newlist=[{map {$_=>$element->{Attributes}{$_}{Value}} keys %{$element->{Attributes}}}];
  }
  push @{ $self->{Lists} }, $self->{Curlist};
  if (exists($element->{LocalName}) && $element->{NamespaceURI}) {
    push @{ $self->{Curlist} }, "{$element->{NamespaceURI}}$element->{LocalName}" => $newlist;
  }
  else {
    push @{ $self->{Curlist} }, $element->{Name} => $newlist;
  }
  $self->{Curlist} = $newlist;
}

sub end_element {
  my ($self,$element)=@_;
  $self->{Curlist}=pop @{$self->{Lists}};
}

sub characters {
  my ($self,$text)=@_;
  my $clist = $self->{Curlist};
  my $pos = $#$clist;
  if ($pos>0 and $clist->[$pos-1] eq '0') {
    $clist->[$pos].=$text->{Data};
  }
  else {
    push @$clist,0=>$text->{Data};
  }
}

sub comment {}

sub processing_instruction {}

sub end_document {
  my $self=shift;
  delete $self->{Curlist};
  delete $self->{Lists};
  $self->{Tree};
}

package XML::Handler::EasyTree;

sub new {
  my $class=shift;
  $class=ref($class) || $class;
  my $self={Noempty=>0,Latin=>0,Searchable=>0,@_};
  $self->{Noempty}||=$self->{Searchable};
  bless $self,$class;
}

sub start_document {
  my $self = shift;
  $self->{Lists} = [];
  $self->{Curlist} = $self->{Tree} = [];
}

sub start_element {
  my ($self,$element)=@_;
  $self->checkempty();
  my $newlist=[];
  my $newnode;
  if ($self->{Searchable}) {
    $newnode= XML::Handler::EasyTree::Searchable->new( Name => $self->nsname($element), Content => $newlist );
  }
  else {
    $newnode={type=>'e',attrib=>{},name=>$self->nsname($element),content=>$newlist};
  }
  if (exists $element->{LocalName}) {
    while (my ($name,$obj) = each %{$element->{Attributes}}) {
      $newnode->{attrib}{$name} = $self->encode($obj->{Value});
    }
  }
  elsif (ref $element->{Attributes} eq 'HASH') {
    while (my ($name,$val)=each %{$element->{Attributes}}) {
      $newnode->{attrib}{$self->nsname($name)}=$self->encode($val);
    }
  }
  else {
    foreach my $att (keys %{$element->{Attributes}}) {
      $newnode->{attrib}{$self->nsname($element->{Attributes}{$att})}=$self->encode($element->{Attributes}{$att}{Value});
    }
  }
  push @{ $self->{Lists} }, $self->{Curlist};
  push @{ $self->{Curlist} }, $newnode;
  $self->{Curlist} = $newlist;
}

sub end_element {
  my $self=shift;
  $self->checkempty();
  $self->{Curlist}=pop @{$self->{Lists}};
}

sub characters {
  my ($self,$text)=@_;
  my $clist=$self->{Curlist};
  if (!@$clist || $clist->[-1]{type} ne 't') {
    push @$clist,{type=>'t',content=>''};
  }
  $clist->[-1]{content}.=$self->encode($text->{Data});
}

sub processing_instruction {
  my ($self,$pi)=@_;
  $self->checkempty();
  my $clist=$self->{Curlist};
  push @$clist,{type=>'p',target=>$self->encode($pi->{Target}),content=>$self->encode($pi->{Data})};
}

sub comment {}

sub end_document {
  my $self = shift;
  $self->checkempty();
  delete $self->{Curlist};
  delete $self->{Lists};
  if ($self->{Searchable}) {
    return XML::Handler::EasyTree::Searchable->new( Name => '__TOPLEVEL__', Content => $self->{Tree} );
  } 
  $self->{Tree};
}

sub nsname {
  my ($self,$name)=@_;
  if (ref $name) {
    if (defined $name->{NamespaceURI}) {
      $name="{$name->{NamespaceURI}}$name->{LocalName}";
    }
    else {
      $name=$name->{Name};
    }
  }
  return $self->encode($name);    
}

sub encode {
  my ($self,$text)=@_;
  if ($self->{Latin}) {
    $text=~s{([\xc0-\xc3])(.)}{
      my $hi = ord($1);
      my $lo = ord($2);
      chr((($hi & 0x03) <<6) | ($lo & 0x3F))
     }ge;
  }
  $text;
}

sub checkempty() {
  my $self=shift;
  if ($self->{Noempty}) {
    my $clist=$self->{Curlist};
    if (@$clist && $clist->[-1]{type} eq 't' && $clist->[-1]{content}=~/^\s+$/) {
      pop @$clist;
    }
  }
}

package XML::Handler::EasyTree::Searchable;

#
# new() returns a new node with the same structure at the `newnode'
# hashref
#
# Usage: XML::Handler::EasyTree::Searchable->new( Name => $name, Content => $content );
#
sub new {
  my $type = shift;
  my $class = ref($type) || $type || die "must supply a object type" ;

  my %opts = @_;

  my $name = $opts{Name} || '';
  my $content = $opts{Content} || undef;

  return bless ( {
		  type    => 'e',
		  attrib  => {},
		  name    => $name, 
		  content => $content,
		 }, $class);
}

#
# name() returns the name of the node. Ideally, it should return a
# "fully qualified" name, but it doesn't
#
sub name {
  my $self = shift;
  return $self->{name};
}

#
# value() returns the value associated with an object
#
sub value {
  my $self = shift;

  return( undef )
    unless( ( exists $self->{content} ) && ( defined $self->{content} ) );

  my $possible = $self->{content};

  die "not an array" unless( "$possible" =~ /ARRAY/ );

  $possible = $possible->[0];

  return( undef )
    unless( ( exists $possible->{type} ) && ( $possible->{type} eq 't' ) );

  return( undef )
    unless( ( exists $possible->{content} ) && ( defined $possible->{content} ) );

  return $possible->{content};
}

#
# usage: $newobj = $obj->child( $name );
#
# child() returns a child (elements only) of the object with the $name
#
# for the case where there is more than one child that match $name,
# the array context semantics haven't been completely worked out:
# - in an array context, all children are returned.
# - in scalar context, the first child matching $name is returned.
#
# In a scalar context, The XML::Parser::SimpleObj class returns an
# object containing all the children matching $name, unless there is
# only one child in which case it returns that child (see commented
# code). I find that behavior confusing.
# 
sub child {
  my $self = shift;
  my $spec = shift || '';

  my $array = $self->{content};

  my @rv;
  if( $spec ) {
    @rv = grep { $_->{name} eq $spec } grep { $_->{type} eq 'e' } @$array;
  } else {
    @rv = grep { $_->{type} eq 'e' } @$array;
  }

  my $num = scalar( @rv );
  
  if( wantarray() ) {
    return @rv; 
  } else {
    return '' unless( $num );
    return $rv[0] if( $num == 1 );
    # my $class = ref( $self );
    # return $class->new( Name => "__magic_child_list_object__", Content => [ @rv ] );
  }
}

#
# usage: @children = $obj->children( $name );
#
# children() returns a list of all children (elements only) of the
# $obj that match $name -- in the order in which they appeared in the
# original xml text.
#
sub children {
  my $self = shift;
  my $array = $self->{content};
  my $spec = shift || '';


  my @rv;
  if( $spec ) {
    @rv = grep { $_->{name} eq $spec } grep { $_->{type} eq 'e' } @$array;
  } else {
    @rv = grep { $_->{type} eq 'e' } @$array;
  }

  return @rv;
}

#
# usage: @children_names = $obj->children_names();
#
# children_names() returns a list of all the names of the objects
# children (elements only) in the order in which they appeared in the
# original text
#
sub children_names {
  my $self = shift;
  my $array = $self->{content};

  return map { $_->{name} } grep { $_->{type} eq 'e' } @$array;
}

#
# usage: $attrib = $obj->attribute( $att_name );
#
# attribute() returns the string associated with the attribute of the
# object. If not found returns a null string.
#
sub attribute {
  my $self = shift;
  my $spec = shift || return '';

  return '' unless( ( exists $self->{attrib} ) && ( defined $self->{attrib} ) );

  my $attrib = $self->{attrib};
  return '' unless( ( exists $attrib->{$spec} ) && ( defined $attrib->{$spec} ) );

  return $attrib->{$spec};
}
  
#
# usage: @attribute_list = $obj->attribute_list();
#
# attribute_list() returns a list (in no particular order) of the
# attribute names associated with the object
#
sub attribute_list {
  my $self = shift;

  return '' unless( ( exists $self->{attrib} ) && ( defined $self->{attrib} ) );

  my $attrib = $self->{attrib};
  return '' unless( "$attrib" =~ /HASH/ );

  return keys %$attrib;
}

#
# usage: $text = $obj->dump_tree();
#
# dump_tree() returns a textual representation (in xml form) of the
# object's heirarchy. Only elements are processed.
#
#
sub dump_tree {
  my $self = shift;
  my %opts = @_;

  my $pretty = delete $opts{-pretty};

  my $name	= $self->name();
  my $value	= $self->value();
  my @children	= $self->children();

  my $text = '';
  unless( $name eq '__TOPLEVEL__' ) {
      $text .= "<$name";
      for my $att ( $self->attribute_list() ) {
	  $text .= sprintf( " %s=\"%s\"", $att, encode($self->attribute( $att )) );
      }
      $text .= ">";

      if( $value ) {
	  $text .= encode($value);
      }
  }

  
  for my $child ( @children ) {
    $text .= $child->dump_tree();
  }

  unless( $name eq '__TOPLEVEL__' ) {
      $text .= "</$name>";
  }

  return $text;
}

#
# usage: $text = $obj->pretty_dump_tree();
#
# pretty_dump_tree() is identical to dump_tree(), except that newline
# and indentation embellishments are added
#
sub pretty_dump_tree {
  my $self = shift;
  my $tab = shift || 0;

  my $indent = " " x ( 2 * $tab );

  my $name	= $self->name();
  my $value	= $self->value();
  my @children	= $self->children();

  my $text = '';
  unless( $name eq '__TOPLEVEL__' ) {
      $text .= "$indent<$name";
      for my $att ( $self->attribute_list() ) {
	  $text .= sprintf( " %s=\"%s\"", $att, encode($self->attribute( $att )) );
      }
      $text .= ">";
      
      if( defined $value ) {
	  $text .= encode($value);
	  $text .= "</$name>\n";
	  return $text;
      } else {
	  $text .= "\n";
      }
  }

  for my $child ( @children ) {
    $text .= $child->pretty_dump_tree( $tab + 1 );
  }

  unless( $name eq '__TOPLEVEL__' ) {
      $text .= "$indent</$name>\n";
  }

  return $text;
}

sub encode {
  my $encstr=shift;
  my %encodings=('&'=>'amp','<'=>'lt','>'=>'gt','"'=>'quot',"'"=>'apos');
  $encstr=~s/([&<>"'])/&$encodings{$1};/g;
  $encstr;
}

package XML::Handler::TreeBuilder;

use vars qw(@ISA);
@ISA=qw(XML::Element);

sub new {
  require XML::Element; 
  my $class = ref($_[0]) || $_[0];
  my $self = XML::Element->new('NIL');
  $self->{'_element_class'} = 'XML::Element';
  $self->{'_store_comments'}     = 0;
  $self->{'_store_pis'}          = 0;
  $self->{'_store_declarations'} = 0;
  $self->{_stack}=[];
  bless $self, $class;
}
  
sub start_document {}

sub start_element {
  my ($self,$element)=@_;
  my @attlist;
  if (exists $element->{LocalName}) {
    @attlist=map {$_=>$element->{Attributes}{$_}{Value}} keys %{$element->{Attributes}};
  }
  elsif (ref $element->{Attributes} eq 'HASH') {
    @attlist=map {$_=>$element->{Attributes}{$_}} keys %{$element->{Attributes}};
  } 
  else {
    @attlist=map {$_=>$element->{Attributes}{$_}{Value}} keys %{$element->{Attributes}};
  }
  if(@{$self->{_stack}}) {
    push @{$self->{_stack}}, $self->{'_element_class'}->new($element->{Name},@attlist);
    $self->{_stack}[-2]->push_content( $self->{_stack}[-1] );
  }
  else {
    $self->tag($element->{Name});
    while(@attlist) {
      $self->attr(splice(@attlist,0,2));
    }
    push @{$self->{_stack}}, $self;
  }
}

sub end_element {
  my $self=shift;
  pop @{$self->{_stack}};
  return
}

sub characters {
  my ($self,$text)=@_;
  $self->{_stack}[-1]->push_content($text->{Data});
}
    
sub comment {
  my ($self,$comment)=@_;
  return unless $self->{'_store_comments'};
  (@{$self->{_stack}} ? $self->{_stack}[-1] : $self)->push_content(
      $self->{'_element_class'}->new('~comment', 'text' => $comment->{Data})
    );
  return;
}

sub processing_instruction {
  my ($self,$pi)=@_;
  return unless $self->{'_store_pis'};
  (@{$self->{_stack}} ? $self->{_stack}[-1] : $self)->push_content(
      $self->{'_element_class'}->new('~pi', 'text' => "$pi->{Target} $pi->{Data}")
    );
  return;
}

sub end_document {    
  my $self=shift;
  return $self;
}

sub _elem # universal accessor...
{
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

sub store_comments { shift->_elem('_store_comments', @_); }
sub store_declarations { shift->_elem('_store_declarations', @_); }
sub store_pis      { shift->_elem('_store_pis', @_); }

1;
__END__

=head1 NAME

XML::Handler::Trees - PerlSAX handlers for building tree structures

=head1 SYNOPSIS

  use XML::Handler::Trees;
  use XML::Parser::PerlSAX;

  my $p=XML::Parser::PerlSAX->new();
  my $h=XML::Handler::Tree->new();
  my $tree=$p->parse(Handler=>$h,Source=>{SystemId=>'file.xml'});

  my $p=XML::Parser::PerlSAX->new();
  my $h=XML::Handler::EasyTree->new(Noempty=>1);
  my $easytree=$p->parse(Handler=>$h,Source=>{SystemId=>'file.xml'});

  my $p=XML::Parser::PerlSAX->new();
  my $h=XML::Handler::TreeBuilder->new();
  $h->store_pis(1);
  my $tree=$p->parse(Handler=>$h,Source=>{SystemId=>'file.xml'});

=head1 DESCRIPTION

XML::Handler::Trees provides three PerlSAX handler classes for building
tree structures.  XML::Handler::Tree builds the same type of tree as the
"Tree" style in XML::Parser.  XML::Handler::EasyTree builds the same
type of tree as the "EasyTree" style added to XML::Parser by
XML::Parser::EasyTree.  XML::Handler::TreeBuilder builds the same type
of tree as Sean M. Burke's XML::TreeBuilder.  These classes make it
possible to construct these tree structures from sources other than
XML::Parser.

All three handlers can be driven by either PerlSAX 1 or PerlSAX 2
drivers.  In all cases, the end_document() method returns a reference to
the constructed tree, which normally becomes the return value of the
PerlSAX driver.

=head1 CLASS XML::Handler::Tree

This handler builds the same type of tree structure as the "Tree" style
in XML::Parser.  Some modules such as Dan Brian's XML::SimpleObject work
with this type of tree.  See the documentation for XML::Parser for details.  

=head2 METHODS

=over 4

=item $handler = XML::Handler::Tree->new()

Creates a handler object.

=back

=head1 CLASS XML::Handler::EasyTree

This handler builds a lightweight tree structure representing the XML 
document.  This structure is, at least in this author's opinion, easier to 
work with than the "standard" style of tree.  It is the same type of
structure as built by XML::Parser when using XML::Parser::EasyTree, or
by the get_simple_tree method in XML::Records.

The tree is returned as a reference to an array of tree nodes, each of
which is a hash reference. All nodes have a 'type' key whose value is
the type of the node: 'e' for element nodes, 't' for text nodes, and 'p'
for processing instruction nodes. All nodes also have a 'content' key
whose value is a reference to an array holding the element's child nodes
for element nodes, the string value for text nodes, and the data value
for processing instruction nodes. Element nodes also have an 'attrib'
key whose value is a reference to a hash of attribute names and values and a 'name'
key whose value is the element's name.  Processing instructions also have
a 'target' key whose value is the PI's target. 

EasyTree nodes are ordinary Perl hashes and are not objects.  Contiguous 
runs of text are always returned in a single node.

The reason the parser returns an array reference rather than the root 
element's node is that an XML document can legally contain processing 
instructions outside the root element (the xml-stylesheet PI is commonly 
used this way).

If namespace information is available (only possible with PerlSAX 2),
element and attribute names will be prefixed with their (possibly empty)
namespace URI enclosed in curly brackets, and namespace prefixes will be
stripped from names.

=head2 METHODS

=over 4

=item $handler = XML::Handler::EasyTree->new([options])

Creates a handler object.  Options can be provided hash-style:

=over 4

=item Noempty

If this is set to a true value, text nodes consisting entirely of
whitespace will not be stored in the tree.  The default is false.

=item Latin

If this is set to a true value, characters with Unicode values in the
Latin-1 range (160-255) will be stored in the tree as Latin-1 rather
than UTF-8.  The default is false.

=item Searchable

If this is set to a true value, the parser will return a tree of XML::Handler::EasyTree::Searchable
objects rather than bare array references, providing access to the navigation methods
listed below.  The top-level node returned will be a dummy element node with a name of "__TOPLEVEL__".
It is false by default.  Setting this option automatically enables the Noempty option.

=back

=back

=head2 XML::Handler::EasyTree::Searchable METHODS

If the Searchable option is set, all nodes in the tree will be XML::Handler::EasyTree::Searchable objects,
which have the same structure as EasyTree nodes but also implement the following methods similar to
those in XML::SimpleObject.

=over 4

=item $name = $node->name()

Returns the name of the node. Ideally, it should return a
"fully qualified" name, but it doesn't.

=item $val = $node->value()

Returns the text value associated with a node object.  Returns undef if the node has
no text children or its first child is not a text node.

=item $newobj = $obj->child( $name );

Returns a child (elements only) of the object with the $name.

For the case where there is more than one child that match $name,
the array context semantics haven't been completely worked out:
- in an array context, all children are returned.
- in scalar context, the first child matching $name is returned.

In a scalar context, The XML::Parser::SimpleObj class returns an
object containing all the children matching $name, unless there is
only one child in which case it returns that child (see commented
code). I find that behavior confusing.

=item @children = $obj->children( $name );

Returns a list of all children (elements only) of the
$obj that match $name -- in the order in which they appeared in the
original xml text.

=item @children_names = $obj->children_names();

Returns a list of all the names of the objects
children (elements only) in the order in which they appeared in the
original text.

=item $attrib = $obj->attribute( $att_name );

Returns the string associated with the attribute of the
object. If not found returns a null string.

=item @attribute_list = $obj->attribute_list();

Returns a list (in no particular order) of the
attribute names associated with the object

=item $text = $obj->dump_tree();

Returns a textual representation (in xml form) of the
object's hierarchy. Only elements are processed. The result will
be in whatever character encoding the SAX driver delivered (which may
not be the same encoding as the original source).

=item $text = $obj->pretty_dump_tree();

Identical to dump_tree(), except that newline
and indentation embellishments are added

=back

=head2 EXAMPLE

 #! /usr/bin/perl -w
 
 use XML::Handler::Trees;
 use XML::Parser::PerlSAX;
 use strict;
 
 my $p=XML::Parser::PerlSAX->new();
 my $h=XML::Handler::EasyTree->new( Searchable=>1 );
 my $easytree=$p->parse( Handler => $h, Source => { SystemId => 'systemB.xml' } );
 
 my $vme = $easytree->child( "vmesystem" );
 
 print "\n";
 print "vmesystem config: ", $vme->attribute( "configuration_name" ), "\n";
 
 print "\n";
 print "vmesystem children: ", join( ', ', $vme->children_names() ), "\n";
 
 print "\n";
 print "gps model is ", $vme->child( "gps" )->child( "model" )->value(), "\n";
 my $gps = $vme->child( "gps" );
 print "gps slot is ", $gps->child( "slot" )->value(), "\n";
 
 print "\n";
 print "reconstructed XML: \n";
 print $easytree->dump_tree(), "\n";
 
 # print "\n";
 # print "recontructed XML (pretty): \n";
 # print $easytree->pretty_dump_tree(), "\n";
 
 print "\n";
 exit;

=head1 CLASS XML::Handler::TreeBuilder

This handler builds XML document trees constructed of
XML::Element objects (XML::Element is a subclass of HTML::Element
adapted for XML).  To use it, XML::TreeBuilder and its prerequisite
HTML::Tree need to be installed.  See the documentation for those
modules for information on how to work with these tree structures.

=head2 METHODS

=over 4

=item $handler = XML::Handler::TreeBuilder->new()

Creates a handler which builds a tree rooted in an XML::Element.

=item $root->store_comments(value)

This determines whether comments will be stored in the tree (not all SAX
drivers generate comment events).  Currently, this is off by default.

=item $root->store_declarations(value)

This determines whether markup declarations will be stored in the tree.
Currently, this is off by default.  The present implementation does not
store markup declarations in any case; this method is provided for future use.

=item $root->store_pis(value)

This determines whether processing instructions will be stored in the tree.
Currently, this is off (false) by default.

=back

=head1 AUTHOR

Eric Bohlman (ebohlman@omsdev.com)

PerlSAX 2 compatibility added by Matt Sergeant (matt@sergeant.org)

XML::EasyTree::Searchable written by Stuart McDow (smcdow@moontower.org)

Copyright (c) 2001 Eric Bohlman.

Portions of this code Copyright (c) 2001 Matt Sergeant.

Portions of this code Copyright (c) 2001 Stuart McDow.

All rights reserved. This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

 L<perl>
 L<XML::Parser>
 L<XML::SimpleObject>
 L<XML::Parser::EasyTree>
 L<XML::TreeBuilder>
 L<XML::Element>
 L<HTML::Element>
 L<PerlSAX>

=cut

