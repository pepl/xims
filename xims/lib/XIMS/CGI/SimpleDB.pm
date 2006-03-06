# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::SimpleDB;

use strict;
# use warnings;

our $VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use base qw(XIMS::CGI::Folder);
use XIMS::SimpleDBItem;
use XIMS::SimpleDBMemberPropertyValue;
use XIMS::SimpleDBMemberProperty;

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
          create_property_mapping
          update_property_mapping
          delete_property_mapping
          )
        );
}


# #############################################################################
# RUNTIME EVENTS

sub event_init {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->sax_generator( 'XIMS::SAX::Generator::SimpleDB' );
    return $self->SUPER::event_init( $ctxt );
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    my $style = $self->param('style');
    if ( defined $style ) {
        $ctxt->properties->application->style( $style );
    }

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $limit;
    if ( defined $self->param('onepage') or defined $style ) {
        $limit = undef;
    }
    else {
        $limit = $ctxt->object->attribute_by_key( 'pagerowlimit' );
        $limit ||= XIMS::SEARCHRESULTROWLIMIT();
        $offset ||= 0;
        $offset = $offset * $limit;
    }

    my $order;
    my %propargs;
    my %childrenargs;
    if ( defined $ctxt->apache()->dir_config('ximsPublicUserName') or $ctxt->session->user->id() == XIMS::PUBLICUSERID() ) {
        $propargs{gopublic} = 1;
        $childrenargs{gopublic} = 1;
    }
    my @properties = $ctxt->object->mapped_member_properties( %propargs, part_of_title => 1, limit => 1, offset => 0 );
    if ( scalar @properties and $properties[0]->type() eq 'datetime' ) {
        $order = 'title DESC';
    }
    else {
        $order = 'title ASC';
    }

    # May come in as latin1 via gopublic
    my $searchstring = XIMS::utf8_sanitize($self->param('searchstring'));
    if ( defined $searchstring ) {
        $self->param( 'searchstring', $searchstring ); # update CGI param, so that stylesheets get the right one
    }
    $searchstring ||= XIMS::decode($self->param('searchstring')); # fallback

    if ( defined $searchstring and $searchstring =~ /^[^?_^`´%*]+/ ) {
        $childrenargs{searchstring} = "%$searchstring%";
    }

    my ( $child_count, $children ) = $ctxt->object->items_granted( limit => $limit, offset => $offset, order => $order, %childrenargs );
    $ctxt->objectlist( [ $child_count, $children ] );

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving some ms...
    $ctxt->properties->content->escapebody( 1 );

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    my $rv = $self->SUPER::event_edit( $ctxt );

    # We do not want to see the default "Obtained Lock..." message here, so set it to the empty string
    $ctxt->session->message( '' );

    return $rv;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $pagerowlimit = $self->param( 'pagerowlimit' );
    if ( defined $pagerowlimit and (length $pagerowlimit and $pagerowlimit !~ /^\s+$/ or not length $pagerowlimit) ) {
        XIMS::Debug( 6, "pagerowlimit: $pagerowlimit" );
        my $currentvalue = $object->attribute_by_key( 'pagerowlimit' );
        $object->attribute( pagerowlimit => $pagerowlimit );
    }

    return $self->SUPER::event_store( $ctxt );
}

sub event_create_property_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # operation control section
    unless ( $ctxt->session->user->object_privmask( $ctxt->object() ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $property = XIMS::SimpleDBMemberProperty->new();

    my %values;
    foreach my $name ( $property->fields() ) {
        next if $name eq 'id';
        my $value = XIMS::clean( XIMS::decode( $self->param( "sdbp_" . $name ) ) );
        $values{$name} = $value if defined $value;
    }

    if ( not defined $values{name} ) {
        XIMS::Debug( 3, "At least Name needed" );
        return $self->sendError( $ctxt, "At least a name for the property is needed." );
    }

    $property = XIMS::SimpleDBMemberProperty->new()->data( %values );
    if ( not $property->create() ) {
        XIMS::Debug( 3, "Could not create property " . $property->name() . "." );
        return $self->sendError( $ctxt, "Could not create property " . $property->name() . "." );
    }

    if ( $ctxt->object->map_member_property( $property ) ) {
        $self->redirect( $self->redirect_path( $ctxt ) . '?edit=1;message=Mapping%20created' );
        return 1;
    }
    else {
        XIMS::Debug( 3, "Could not create propertymapping for  " . $property->name() . "." );
        return $self->sendError( $ctxt, "Could not create propertymapping for " . $property->name() . "." );
    }
}

sub event_update_property_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # operation control section
    unless ( $ctxt->session->user->object_privmask( $ctxt->object() ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $property_id = $self->param('property_id');
    if ( not defined $property_id or $property_id !~ /^\d+$/ ) {
        XIMS::Debug( 3, "Valid property_id needed" );
        return $self->sendError( $ctxt, "Valid property_id needed." );
    }

    my $property = XIMS::SimpleDBMemberProperty->new( id => $property_id );
    if ( not defined $property ) {
        XIMS::Debug( 3, "Valid property_id needed" );
        return $self->sendError( $ctxt, "Valid property_id needed." );
    }

    my $old_position = $property->position();

    my %values;
    foreach my $name ( $property->fields() ) {
        next if ( $name eq 'id' or $name eq 'type' ); # skip fields that cannot be updated
        my $value = XIMS::clean( XIMS::decode( $self->param( "sdbp_" . $name ) ) );
        next if ( $name eq 'name' and not defined $value ); # name is mandatory
        $property->$name( $value );
    }

    my $new_position = $property->position();

    eval { $property->update(); };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not update property " . $property->name() . ": $@." );
        return $self->sendError( $ctxt, "Could not update property " . $property->name() . "." );
    }
    else {
        if ( $old_position != $new_position and not $ctxt->object->reposition_property( old_position => $old_position,
                                                                                        new_position => $new_position,
                                                                                        property_id => $property_id ) ) {
            XIMS::Debug( 3, "Could not reposition property " . $property->name() . "." );
        }
    }

    $self->redirect( $self->redirect_path( $ctxt ) . '?edit=1;property_id=' . $property_id . ';message=Property%20updated' );
    return 1;
}

sub event_delete_property_mapping {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # operation control section
    unless ( $ctxt->session->user->object_privmask( $ctxt->object() ) & XIMS::Privileges::DELETE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $property_id = $self->param('property_id');
    if ( not defined $property_id or $property_id !~ /^\d+$/ ) {
        XIMS::Debug( 3, "Valid property_id needed" );
        return $self->sendError( $ctxt, "Valid property_id needed." );
    }

    my $property = XIMS::SimpleDBMemberProperty->new( id => $property_id );
    if ( not defined $property ) {
        XIMS::Debug( 3, "Valid property_id needed" );
        return $self->sendError( $ctxt, "Valid property_id needed." );
    }

    my $property_name = $property->name();

    # Close the position gap resulting from the deletion
    eval { $ctxt->object->close_property_position_gap( position => $property->position() ); };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not close position gap " . $property_name . " $@." );
        return $self->sendError( $ctxt, "Could not delete property " . $property_name . "." );
    }

    # Actually delete the property. This will cascade to the mapping and value tables!
    eval { $property->delete(); };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not delete property " . $property_name . " $@." );
        return $self->sendError( $ctxt, "Could not delete property " . $property_name . "." );
    }

    $self->redirect( $self->redirect_path( $ctxt ) . '?edit=1;message=Property%20%22' . $property_name . '%22%20deleted' );
    return 1;
}

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, "Copying SimpleDBs is not implemented." );
}

sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, "Deleting SimpleDBs is not implemented." );
}

sub event_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, "Deleting SimpleDBs is not implemented." );
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

# END RUNTIME EVENTS
# #############################################################################
1;
