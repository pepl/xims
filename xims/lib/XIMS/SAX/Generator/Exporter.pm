# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::Exporter;

use strict;
use vars qw(@ISA);
@ISA = qw(XIMS::SAX::Generator::Content);

use XIMS::SAX::Generator::Content;
use XML::Filter::CharacterChunk;

##
#
# SYNOPSIS
#    $generator->prepare( $ctxt );
#
# PARAMETER
#    $ctxt : the appcontext object
#
# RETURNS
#    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData
#
# DESCRIPTION
#
#
sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %object_types = ();
    my %data_formats = ();

    my %encargs;
    $encargs{Encoding} = XIMS::DBENCODING() if XIMS::DBENCODING();
    $self->{FilterList} = [ XML::Filter::CharacterChunk->new(%encargs, TagName=>[qw(body abstract)]) ];

    my $doc_data = { context => {} };

    $doc_data->{context}->{object} = {$ctxt->object->data()};

    $object_types{$ctxt->object->object_type_id()} = 1;
    $data_formats{$ctxt->object->data_format_id()} = 1;

    if ( $ctxt->properties->content->childrenbybodyfilter ) {
        $doc_data->{context}->{object}->{children} = $ctxt->object->body();
        delete $doc_data->{context}->{object}->{body};
    }
    else {
        $self->_set_children( $ctxt, $doc_data, \%object_types, \%data_formats );
    }

    $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types, \%data_formats );

    return $doc_data;
}

# helper function to fetch the children.
sub _set_children {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    my $object = $ctxt->object();

    my %childrenargs = ( published => 1, User => $ctxt->user ); # only get published children
    my @object_type_ids;
    if ( $ctxt->properties->content->getchildren->objecttypes and scalar @{$ctxt->properties->content->getchildren->objecttypes} > 0 ) {
        my $ot;
        foreach my $name ( @{$ctxt->properties->content->getchildren->objecttypes} ) {
            $ot = XIMS::ObjectType->new( name => $name );
            push(@object_type_ids, $ot->id()) if defined $ot;
        }
        $childrenargs{object_type_id} = \@object_type_ids;
    }

    my @children = $object->children_granted( %childrenargs );
    if ( scalar( @children ) > 0 ) {
        foreach my $child ( @children ) {
            # remember the seen objecttypes
            $object_types->{$child->object_type_id()} = 1;
            $data_formats->{$child->data_format_id()} = 1;
        }
    }

    $doc_data->{context}->{object}->{children} = {object => \@children};
}

1;
