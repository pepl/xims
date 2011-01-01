
=head1 NAME

XIMS::CGI::SimpleDB -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::SimpleDB;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::SimpleDB;

use strict;
use base qw(XIMS::CGI::Folder);
use XIMS::SimpleDBItem;
use XIMS::SimpleDBMemberPropertyValue;
use XIMS::SimpleDBMemberProperty;
use XIMS::QueryBuilder::SimpleDB;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
        qw(
          create
          edit
          store
          obj_acllist
          obj_acllight
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

=head2 event_init()

=cut

sub event_init {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # let X:S:G:S handle all events beside search
    $ctxt->sax_generator( 'XIMS::SAX::Generator::SimpleDB' ) unless $self->testEvent($ctxt) eq 'search';
    return $self->SUPER::event_init( $ctxt );
}

=head2 event_default()

=cut

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
        $childrenargs{published} = 1;
    }
    my @properties = $ctxt->object->mapped_member_properties( %propargs, part_of_title => 1, limit => 1, offset => 0 );
    if ( scalar @properties and $properties[0]->type() eq 'datetime' ) {
        $order = 'title DESC';
    }
    else {
        $order = 'title ASC';
    }

    # May come in as latin1 via gopublic
    my $search = XIMS::utf8_sanitize($self->param('searchstring'));
    if ( defined $search ) {
        $self->param( 'searchstring', $search ); # update CGI param, so that stylesheets get the right one
    }
    $search ||= XIMS::decode($self->param('searchstring')); # fallback

    if ( defined $search and length($search) >= 2 and length($search) <= 128 ) {
        use encoding "latin-1";
        my $allowed = q{\!=a-zA-Z0-9ÀÁÂÃÅÆÇÈÉÊËÐÑÒÓÔÕØÙÚÛàáâãåæçèéêëìíîïðñòóôõøùúûüýöäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~};
        my $qb = XIMS::QueryBuilder::SimpleDB->new( { search => $search,
                                                      allowed => $allowed,
                                                      extraargs => { simpledb => $ctxt->object() } } );
        return $self->sendError( $ctxt, __"Querybuilder could not be instantiated." ) unless defined $qb;
        $childrenargs{criteria} = $qb->criteria();
    }

    my ( $child_count, $children ) = $ctxt->object->items_granted( limit => $limit, offset => $offset, order => $order, %childrenargs );
    $ctxt->objectlist( [ $child_count, $children ] );

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving some ms...
    $ctxt->properties->content->escapebody( 1 );

    return 0;
}

=head2 event_edit

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    my $rv = $self->SUPER::event_edit( $ctxt );

    # We do not want to see the default "Obtained Lock..." message here, so set it to the empty string
    $ctxt->session->message( '' );

    return $rv;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # report error that at least one property must be set to be
    # part of the title ( would cause violation of NOT NULL constraint
    # of DB-table when storing SimpleDBItems )
    my @title_props = $object->mapped_member_properties( part_of_title => 1 );
    my $is_event_create = $self->param("sdb_is_new");
    if ( $is_event_create != 1 and not @title_props ) {
        XIMS::Debug( 3, "No property set to be part of title!
                            Check at least one property!" );
        return $self->sendError( $ctxt, __"At least one property must be specified to be part of the title!" );
    }

    my $pagerowlimit = $self->param( 'pagerowlimit' );
    if ( defined $pagerowlimit and (length $pagerowlimit and $pagerowlimit !~ /^\s+$/ or not length $pagerowlimit) ) {
        XIMS::Debug( 6, "pagerowlimit: $pagerowlimit" );
        my $currentvalue = $object->attribute_by_key( 'pagerowlimit' );
        $object->attribute( pagerowlimit => $pagerowlimit );
    }

    return $self->SUPER::event_store( $ctxt );
}

=head2 event_create_property_mapping()

=cut

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
        return $self->sendError( $ctxt, __"At least a name for the property is needed." );
    }

    # TODO check property regex

    $property = XIMS::SimpleDBMemberProperty->new()->data( %values );
    if ( not $property->create() ) {
        XIMS::Debug( 3, "Could not create property " . $property->name() . "." );
        return $self->sendError( $ctxt, __"Could not create property " . $property->name() . "." );
    }

    if ( $ctxt->object->map_member_property( $property ) ) {
        $self->redirect( $self->redirect_path( $ctxt ) . '?edit=1;message=Mapping%20created' );
        return 1;
    }
    else {
        XIMS::Debug( 3, "Could not create propertymapping for  " . $property->name() . "." );
        return $self->sendError( $ctxt, __"Could not create propertymapping for " . $property->name() . "." );
    }
}

=head2 event_update_property_mapping()

=cut

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
        return $self->sendError( $ctxt, __"Valid property_id needed." );
    }

    my $property = XIMS::SimpleDBMemberProperty->new( id => $property_id );
    if ( not defined $property ) {
        XIMS::Debug( 3, "Valid property_id needed" );
        return $self->sendError( $ctxt, __"Valid property_id needed." );
    }

    my $old_position = $property->position();

    my %values;
    foreach my $name ( $property->fields() ) {
        next if ( $name eq 'id' or $name eq 'type' ); # skip fields that cannot be updated
        my $value = XIMS::clean( XIMS::decode( $self->param( "sdbp_" . $name ) ) );
        next if ( $name eq 'name' and not defined $value ); # name is mandatory
        # TODO check property regex
        $property->$name( $value );
    }

    my $new_position = $property->position();

    eval { $property->update(); };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not update property " . $property->name() . ": $@." );
        return $self->sendError( $ctxt, __"Could not update property " . $property->name() . "." );
    }
    else {
        if ( $old_position != $new_position and not $ctxt->object->reposition_property( old_position => $old_position,
                                                                                        new_position => $new_position,
                                                                                        property_id => $property_id ) ) {
            XIMS::Debug( 3, __"Could not reposition property " . $property->name() . "." );
        }
    }

    $self->redirect( $self->redirect_path( $ctxt ) . '?edit=1;property_id=' . $property_id . ';message=Property%20updated' );
    return 1;
}

=head2 event_delete_property_mapping()

=cut

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
        return $self->sendError( $ctxt, __"Valid property_id needed." );
    }

    my $property = XIMS::SimpleDBMemberProperty->new( id => $property_id );
    if ( not defined $property ) {
        XIMS::Debug( 3, "Valid property_id needed" );
        return $self->sendError( $ctxt, __"Valid property_id needed." );
    }

    my $property_name = $property->name();

    # Close the position gap resulting from the deletion
    eval { $ctxt->object->close_property_position_gap( position => $property->position() ); };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not close position gap " . $property_name . " $@." );
        return $self->sendError( $ctxt, __"Could not delete property " . $property_name . "." );
    }

    # Actually delete the property. This will cascade to the mapping and value tables!
    eval { $property->delete(); };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not delete property " . $property_name . " $@." );
        return $self->sendError( $ctxt, __"Could not delete property " . $property_name . "." );
    }

    $self->redirect( $self->redirect_path( $ctxt ) . '?edit=1;message=Property%20%22' . $property_name . '%22%20deleted' );
    return 1;
}

=head2 event_copy()

=cut

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Copying SimpleDBs is not implemented." );
}

=head2 event_delete()

=cut

sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Deleting SimpleDBs is not implemented." );
}

=head2 event_delete_prompt()

=cut

sub event_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Deleting SimpleDBs is not implemented." );
}

=head2 event_publish_prompt()

=cut

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

=head2 event_publish()

=cut

sub event_publish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->publish_gopublic( @_ );
}

=head2 event_unpublish()

=cut

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->unpublish_gopublic( @_ );
}

# END RUNTIME EVENTS
# #############################################################################
1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

