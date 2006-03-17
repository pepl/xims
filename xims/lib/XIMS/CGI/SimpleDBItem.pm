# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::SimpleDBItem;

use strict;
# use warnings;

our $VERSION;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use base qw(XIMS::CGI);
use XIMS::SimpleDB;
use XIMS::SimpleDBMember;
use XIMS::SimpleDBMemberPropertyValue;
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
          )
        );
}


sub event_init {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->sax_generator( 'XIMS::SAX::Generator::SimpleDBItem' );
    return $self->SUPER::event_init( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $abstract = $self->param( 'abstract' );
    # check if a valid abstract is given
    if ( defined $abstract and (length $abstract and $abstract !~ /^\s+$/ or not length $abstract) ) {
        XIMS::Debug( 6, "abstract, len: " . length($abstract) );
        $ctxt->object->abstract( XIMS::xml_escape( $abstract ) );
    }

    if ( $ctxt->parent() ) {
        my $importer = XIMS::Importer::Object->new( User => $ctxt->session->user(), Parent => $ctxt->parent() );
        $ctxt->object->location( 'dummy.xml' );
        if ( $importer->import( $ctxt->object() ) ) {
            XIMS::Debug( 4, "Import of SimpleDBItem successful." );
            $ctxt->object->location( $ctxt->object->document_id() . '.' . $ctxt->object->data_format->suffix());
            my $member = XIMS::SimpleDBMember->new();
            $member->document_id( $ctxt->object->document_id() );
            if ( $member->create() ) {
                $ctxt->object->member( $member );
                XIMS::Debug( 4, "Successfully created member object." );
            }
            else {
                XIMS::Debug( 2, "Could not create member object." );
                $self->sendError( $ctxt , "Could not create member object." );
                return 0;
            }
        }
        else {
            XIMS::Debug( 2, "Could not import SimpleDBItem" );
            $self->sendError( $ctxt , "Could not import SimpleDBItem" );
            return 0;
        }
    }
    else {
        unless ( $ctxt->session->user->object_privmask( $ctxt->object ) & XIMS::Privileges::WRITE ) {
            return $self->event_access_denied( $ctxt );
        }
    }

    my $up = $self->update_properties( $ctxt );
    unless ( $up ) {
        # If there was an error during saving the properties, delete 
        # new entries
        if ( $ctxt->parent() ) {
            if ( $ctxt->object->delete() ) {
                XIMS::Debug( 4, "Deleted newly created item because of bad property values" );
                my $uri = Apache::URI->parse( $ctxt->apache() );
                $uri->path( $ctxt->apache->parsed_uri->rpath() . $ctxt->parent->location_path() );
                $uri->query( $uri->query . ';create=1;objtype=SimpleDBItem;error_msg=' . $ctxt->session->error_msg() );
                $self->redirect( $uri->unparse() );
                return 1;
            }
            return 0;
        }
        else {
            return $up;
        }
    };

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

sub update_properties {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    my $member = $ctxt->object->member;

    foreach my $property ( $ctxt->object->property_list() ) {
        my $propertyname = $property->name();
        $propertyname = Encode::encode_utf8( $propertyname ) if Encode::is_utf8( $propertyname );
        my $value = XIMS::utf8_sanitize( $self->param( 'simpledb_' . $propertyname ) );
        next unless defined $value;
        $value = substr(XIMS::trim( XIMS::decode( $value )),0,2000); # play safe with the DB field length

        # check for mandatory properties
        #if ( $property->mandatory() and not (defined $value and length $value) ) {
        #    XIMS::Debug( 2, "mandatory value missing" );
        #    return $self->sendError( $ctxt, "'" . $property->name() . "' needs to be filled out." );
        #}
        
        # check property regex
        my $regex = $property->regex();
        if ( defined $value and length $value and defined $regex and length $regex ) {
            my $qregex;
            eval { $qregex = qr/$regex/; };
            if ( not $qregex ) {
                XIMS::Debug( 2, "regex did not compile" );
                return $self->sendError( $ctxt, "Test regex did not compile. Please update SimpleDB field definition." );
            }
            if ( not $value =~ $qregex ) {
                XIMS::Debug( 2, "value does not match regex" );
                return $self->sendError( $ctxt, "Value '$value' of '" . $property->name() . "' does not match input pattern '" . $regex . "'" );
            }
        }


        my $simpledbpropval = XIMS::SimpleDBMemberPropertyValue->new( property_id => $property->id(), member_id => $member->id() );
        if ( defined $simpledbpropval ) {
            if ( not defined $value or defined $value and $simpledbpropval->value ne $value ) {
                $simpledbpropval->value( $value );
                if ( $simpledbpropval->update() ) {
                    XIMS::Debug( 4, "Updated value of " . $property->name() );
                }
            }
        }
        else {
            $simpledbpropval = XIMS::SimpleDBMemberPropertyValue->new->data( property_id => $property->id(),
                                                                           member_id => $member->id(),
                                                                           value => $value );
            if ( not $simpledbpropval->create() ) {
                XIMS::Debug( 3, "Could not set value of " .  $property->name() );
            }
        }
    }

    return 1;
}

1;
