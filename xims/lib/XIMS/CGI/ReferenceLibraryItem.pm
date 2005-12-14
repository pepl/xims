# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::ReferenceLibraryItem;

use strict;
use warnings;

our $VERSION;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use base qw(XIMS::CGI);
use XIMS::ReferenceLibrary;
use XIMS::RefLibReference;
use XIMS::RefLibReferenceType;
use XIMS::VLibAuthor;
use XIMS::RefLibSerial;
use XIMS::RefLibReferencePropertyValue;
use XIMS::Importer::Object::ReferenceLibraryItem;
use Encode;

#use Data::Dumper;

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
        qw(
          create
          edit
          store
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          remove_author_mapping
          remove_serial_mapping
          create_author_mapping
          create_editor_mapping
          create_serial_mapping
          reposition_author
          )
        );
}


sub event_init {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator( 'XIMS::SAX::Generator::ReferenceLibraryItem' );
    $self->SUPER::event_init( $ctxt );

    my $reftype = $self->param( 'reftype' );
    if ( defined $reftype ) {
        my $reference_type = XIMS::RefLibReferenceType->new( id => $reftype );
        if ( defined $reference_type ) {
            my $reference = XIMS::RefLibReference->new->data( reference_type_id => $reftype );
            $ctxt->object->reference( $reference );
        }
        else {
            $self->sendError( $ctxt, "Could not resolve reference type." );
            return 0;
        }
    }
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # check for author title, date here as minumum properties

    my $body;
    my $fh = $self->upload( 'file' );
    if ( defined $fh ) {
        my $buffer;
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }
    }
    if ( defined $body and length $body ) {
        if ( $ctxt->object->body( $body ) ) {
            XIMS::Debug( 6, "Body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "Could not set body." );
            $self->sendError( $ctxt, "Could not set body." );
            return 0;
        }
    }

    my $abstract = $self->param( 'abstract' );
    # check if a valid abstract is given
    if ( defined $abstract and (length $abstract and $abstract !~ /^\s+$/ or not length $abstract) ) {
        XIMS::Debug( 6, "abstract, len: " . length($abstract) );
        $ctxt->object->abstract( XIMS::xml_escape( $abstract ) );
    }

    if ( $ctxt->parent() ) {
        my $reference = $ctxt->object->reference();
        if ( not defined $reference ) {
            $self->sendError( $ctxt, "Missing Reference Type." );
            return 0
        }
        my $importer = XIMS::Importer::Object::ReferenceLibraryItem->new( User => $ctxt->session->user(), Parent => $ctxt->parent() );
        $ctxt->object->location( 'dummy.xml' );
        if ( $importer->import( $ctxt->object() ) ) {
            XIMS::Debug( 4, "Import of ReferenceLibraryItem successful." );
            $ctxt->object->location( $ctxt->object->document_id() . '.' . $ctxt->object->data_format->suffix());
            $reference->document_id( $ctxt->object->document_id() );
            if ( $reference->create() ) {
                XIMS::Debug( 4, "Successfully created reference object." );
            }
            else {
                XIMS::Debug( 2, "Could not create reference object." );
                $self->sendError( $ctxt , "Could not create reference object." );
                return 0;
            }
        }
        else {
            XIMS::Debug( 2, "Could not import ReferenceLibraryItem" );
            $self->sendError( $ctxt , "Could not import ReferenceLibraryItem" );
            return 0;
        }
    }
    else {
        unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
            return $self->event_access_denied( $ctxt );
        }
    }


    $self->create_author_mapping( $ctxt );
    $self->create_serial_mapping( $ctxt );
    $self->update_properties( $ctxt );
    $ctxt->object->update_title( $self->param('date'), $self->param('title') );

    if ( not $ctxt->parent() ) {
        XIMS::Debug( 6, "unlocking object" );
        $ctxt->object->unlock();
    }

    if ( not $ctxt->object->update() ) {
        XIMS::Debug( 2, "update failed" );
        $self->sendError( $ctxt, "Update of object failed." );
        return 0;
    }
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

sub create_author_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $vlauthor = $self->param('vlauthor');
    my $vleditor = $self->param('vleditor');

    if ( $vlauthor or $vleditor ) {
        $ctxt->object->create_author_mapping_from_name( 0, $vlauthor ) if $vlauthor;
        $ctxt->object->create_author_mapping_from_name( 1, $vleditor ) if $vleditor;
        if ( $vlauthor and $ctxt->object->update_title( $self->param('date'), $self->param('title') ) ) {
            if ( not $ctxt->object->update() ) {
                XIMS::Debug( 3, "Updating of object title failed" );
            }
        }
        return 1;
    }

    return 0;
}

sub create_serial_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $vlserial = $self->param('vlserial');

    if ( $vlserial ) {
        my $serial = XIMS::RefLibSerial->new( title => XIMS::escapewildcard( $vlserial ) );
        if ( not defined $serial ) {
            $serial = XIMS::RefLibSerial->new->data( title => $vlserial );
            if ( not $serial->create() ) {
                XIMS::Debug( 3, "Could not create serial $vlserial." );
                return 0;
            }
        }
        return $ctxt->object->vleserial( $serial );
    }

    return 0;
}

sub update_properties {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $reference = $ctxt->object->reference;

    foreach my $property ( $ctxt->object->property_list() ) {
        my $value = $self->param( $property->name() );
        next unless defined $value;
        $value = XIMS::trim( XIMS::decode( $value ) );

        my $reflibpropval = XIMS::RefLibReferencePropertyValue->new( property_id => $property->id(), reference_id => $reference->id() );
        if ( defined $reflibpropval ) {
            if ( defined $reflibpropval->value and defined $value and $reflibpropval->value ne $value
                or defined $reflibpropval->value and not defined $value
                or not defined $reflibpropval->value and defined $value ) {
                $reflibpropval->value( $value );
                if ( $reflibpropval->update() ) {
                    XIMS::Debug( 4, "Updated value of " . $property->name() );
                }
            }
        }
        else {
            $reflibpropval = XIMS::RefLibReferencePropertyValue->new->data( property_id => $property->id(),
                                                                       reference_id => $reference->id(),
                                                                       value => $value );
            if ( not $reflibpropval->create() ) {
                XIMS::Debug( 3, "Could not set value of " .  $property->name() );
            }
        }

        $ctxt->object->{_title} = $value if $property->name() eq 'title';
        $ctxt->object->{_date} = $value if $property->name() eq 'date';
    }

    return 1;
}

sub event_remove_author_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $property = $self->param('property');
    my $property_id = $self->param('property_id');
    my $role = $self->param('role');
    if ( not ($property and $property_id and defined $role) ) {
        return 0;
    }

    # look up mapping
    my $propmapclass = "XIMS::RefLib" . ucfirst($property) . "Map";
    my $propid = $property . "_id";
    my $propmapobject = $propmapclass->new( reference_id => $ctxt->object->reference->id(), $propid => $property_id, role => $role );
    if ( not( $propmapobject ) ) {
        $self->sendError( $ctxt, "No mapping found which could be deleted." );
        return 0;
    }

    # special case for property "author", we will not delete the mapping if
    # it is the last one.
    if ( $property eq 'author' and $role == 0 ) {
        my $propmethod = "vl".$property."s";
        if ( scalar $ctxt->object->$propmethod() == 1 ) {
            $self->sendError( $ctxt, "Will not delete last associated author." );
            return 0;
        }
    }

    # delete mapping and redirect to event edit
    if ( $propmapobject->delete() ) {
        if ( $role == 0 and $ctxt->object->update_title( $self->param('date'), $self->param('title') ) ) {
            if ( not $ctxt->object->update() ) {
                XIMS::Debug( 3, "Updating of object title failed" );
            }
        }
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
    }
    else {
        $self->sendError( $ctxt, "Mapping could not be deleted." );
    }

    return 0;
}

sub event_remove_serial_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $serial_id = $self->param('serial_id');

    if ( not defined $serial_id ) {
        $self->sendError( $ctxt, "Wrong Parameters." );
        return 0;
    }

    # look up mapping
    my $serial = XIMS::RefLibSerial->new( id => $serial_id );
    if ( not defined $serial ) {
        $self->sendError( $ctxt, "Serial not found." );
        return 0;
    }

    if ( $serial->id() eq $ctxt->object->reference->serial_id() ) {
        # delete mapping and redirect to event edit
        my $reference = $ctxt->object->reference;
        $reference->serial_id( undef );
        if ( $reference->update() ) {
            $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
            return 1;
        }
        else {
            $self->sendError( $ctxt, "Mapping could not be deleted." );
        }
    }
    else {
        $self->sendError( $ctxt, "Given Serial does not match currently assigned serial." );
    }

    return 0;
}

sub event_create_author_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $self->param('vleditor', undef);
    $self->create_author_mapping( $ctxt );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
    return 1;
}

sub event_create_editor_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $self->param('vlauthor', undef);
    $self->create_author_mapping( $ctxt );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
    return 1;
}

sub event_create_serial_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $self->create_serial_mapping( $ctxt );
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
    return 1;
}


sub event_reposition_author {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my %param;
    $param{old_position} = $self->param('old_position');
    $param{new_position} = $self->param('new_position');
    $param{author_id} = $self->param('author_id');
    $param{role} = $self->param('role');

    if ( scalar grep { !/^\d+$/ } values %param ) {
        $self->sendError( $ctxt, "Invalid parameters." );
        return 0;
    }

    if ( $ctxt->object->reposition_author( %param ) ) {
        if ( $param{role} == 0 and $ctxt->object->update_title( $self->param('date'), $self->param('title') ) ) {
            if ( not $ctxt->object->update() ) {
                XIMS::Debug( 3, "Updating of object title failed" );
            }
        }
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) . "?edit=1" );
        return 1;
    }
    else {
        $self->sendError( $ctxt, "Could not reposition author." );
        return 0;
    }
}

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        if ( not $object->publish() ) {
            XIMS::Debug( 2, "publishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Publishing object '" . $object->title() . "' failed." );
            return 0;
        }

        $object->grant_user_privileges (  grantee         => XIMS::PUBLICUSERID(),
                                          privilege_mask  => ( XIMS::Privileges::VIEW ),
                                          grantor         => $user->id() );
    }
    else {
        return $self->event_access_denied( $ctxt );
    }

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        if ( not $object->unpublish() ) {
            XIMS::Debug( 2, "unpublishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Unpublishing object '" . $object->title() . "' failed." );
            return 0;
        }

        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $object->id() );
        $privs_object->delete();
    }
    else {
        return $self->event_access_denied( $ctxt );
    }

    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}


1;
