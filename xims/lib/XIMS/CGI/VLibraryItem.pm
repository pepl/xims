# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::VLibraryItem;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::CGI;
use XIMS::VLibrary;
use XIMS::VLibAuthor;
use XIMS::VLibAuthorMap;
use XIMS::VLibKeyword;
use XIMS::VLibKeywordMap;
use XIMS::VLibSubject;
use XIMS::VLibSubjectMap;
use XIMS::VLibPublication;
use XIMS::VLibPublicationMap;
use XIMS::VLibMeta;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

#use Data::Dumper;

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
        qw(
          create
          edit
          store
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          cancel
          remove_mapping
          create_mapping
          )
        );
}


sub event_init {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator( 'XIMS::SAX::Generator::VLibraryItem' );
    $self->SUPER::event_init( $ctxt );
}

sub event_create {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator( 'XIMS::SAX::Generator::VLibrary' );
    $self->SUPER::event_create( $ctxt );
}

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );
    $ctxt->properties->content->escapebody( 1);
    my $vlibrary = XIMS::VLibrary->new( document_id => $ctxt->object->parent_id() );

    $ctxt->object->vlkeywords( $vlibrary->vlkeywords() );
    $ctxt->object->vlsubjects( $vlibrary->vlsubjects() );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_remove_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $property = $self->param('property');
    my $property_id = $self->param('property_id');
    if ( not ($property and $property_id) ) {
        return 0;
    }

    # look up mapping
    my $propmapclass = "XIMS::VLib" . ucfirst($property) . "Map";
    my $propid = $property . "_id";
    my $propmapobject = $propmapclass->new( document_id => $ctxt->object->document_id(), $propid => $property_id );
    if ( not( $propmapobject ) ) {
        $self->sendError( $ctxt, "No mapping found which could be deleted." );
        return 0;
    }

    # special case for property "subject", we will not delete the mapping if
    # it is the last one.
    if ( $property eq 'subject' ) {
        my $propmethod = "vl".$property."s";
        if ( scalar $ctxt->object->$propmethod() == 1 ) {
            $self->sendError( $ctxt, "Will not delete last associated subject." );
            return 0;
        }
    }

    # delete mapping and redirect to event edit
    if ( $propmapobject->delete() ) {
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
    }
    else {
        $self->sendError( $ctxt, "Mapping could not be deleted." );
    }

    return 0;
}

sub event_create_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $vlsubject = $self->param('vlsubject');
    my $vlkeyword = $self->param('vlkeyword');

    if ( $vlsubject or $vlkeyword ) {
        $self->_create_mapping_from_name( $ctxt->object(), 'Subject', $vlsubject ) if $vlsubject;
        $self->_create_mapping_from_name( $ctxt->object(), 'Keyword', $vlkeyword ) if $vlkeyword;
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
        #$ctxt->properties->application->style( "edit" );
    }

    return 0;
}

sub _create_mapping_from_name {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $object = shift;
    my $propertyname = shift;
    my $propertyvalue = shift;

    my @vlpropvalues = split(",", $self->_trim( XIMS::decode( $propertyvalue ) ) );
    foreach my $value ( @vlpropvalues ) {
        my $propclass = "XIMS::VLib" . $propertyname;
        my $propobject = $propclass->new( name => $value );
        if ( not (defined $propobject and $propobject->id() ) ) {
            XIMS::Debug( 3, "could not resolve '$value', skipping" );
            next;
        }
        my $propmapclass = $propclass . "Map";
        my $propid = lc $propertyname . "_id";
        my $propmapobject = $propmapclass->new( document_id => $object->document_id(), $propid => $propobject->id() );
        if ( not (defined $propmapobject ) ) {
            $propmapobject = $propmapclass->new();
            $propmapobject->document_id( $object->document_id() );
            $propmapobject->$propid( $propobject->id() );
            if ( $propmapobject->create() ) {
                XIMS::Debug( 6, "created mapping for '$value'" );
            }
            else {
                XIMS::Debug( 2, "could not create mapping for '$value'" );
            }
        }
        else {
            XIMS::Debug( 4, "mapping for '$value' already exists" );
        }
    }
}

sub _trim {
    my $self = shift;
    my $string = shift;

    return undef unless $string;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

1;
