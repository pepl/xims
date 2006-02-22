# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::Folder;

use strict;
use vars qw( $VERSION @ISA @params);

use XIMS::CGI;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    return $self->SUPER::registerEvents(
        (
          'create',
          'edit',
          'store',
          'obj_acllist',
          'obj_aclgrant',
          'obj_aclrevoke',
          'publish',
          'publish_prompt',
          'unpublish',
          'test_wellformedness',
          @_
          )
        );
}

# parameters recognized by the script
@params = qw( id name title depid symid delforce del);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $ctxt->properties->content->getformatsandtypes( 1 );

    my $defaultsortby = $ctxt->object->attribute_by_key( 'defaultsortby' );
    my $defaultsort = $ctxt->object->attribute_by_key( 'defaultsort' );

    # maybe put that into config values
    $defaultsortby ||= 'position';
    $defaultsort ||= 'asc';

    unless ( $self->param('sb') and $self->param('order') ) {
        $self->param( 'sb', $defaultsortby );
        $self->param( 'order', $defaultsort );
        $self->param( 'defsorting', 1 ); # tell stylesheets not to
                                         # pass 'sb' and 'order' params
                                         # when linking to children
    }
    # The params override attribute and default values
    else {
        $defaultsortby = $self->param('sb');
        $defaultsort = $self->param('order');
    }

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = XIMS::SEARCHRESULTROWLIMIT(); # Create XIMS::CHILDRENROWLIMIT for that?
    $offset = $offset * $rowlimit;

    my %sortbymap = ( date => 'last_modification_timestamp', position => 'position', title => 'title' );
    my $order = $sortbymap{$defaultsortby} . ' ' . $defaultsort;

    $ctxt->properties->content->getchildren->limit( $rowlimit );
    $ctxt->properties->content->getchildren->offset( $offset );
    $ctxt->properties->content->getchildren->order( $order );

    # This prevents the loading of XML::Filter::CharacterChunk and thus saving some ms...
    $ctxt->properties->content->escapebody( 1 );

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    my $autoindex  = $self->param( 'autoindex' );
    if ( defined $autoindex and $autoindex eq 'false') {
        XIMS::Debug( 6, "autoindex: $autoindex" );
        $object->attribute( autoindex => '0' );
    }
    else {
        $object->attribute( autoindex => '1' );
    }

    my $defaultsortby = $self->param( 'defaultsortby' );
    if ( defined $defaultsortby ) {
        XIMS::Debug( 6, "defaultsortby: $defaultsortby" );
        my $currentvalue = $object->attribute_by_key( 'defaultsortby' );
        if ( $defaultsortby ne 'position' or defined $currentvalue ) {
            $object->attribute( defaultsortby => $defaultsortby );
        }
    }

    my $defaultsort = $self->param( 'defaultsort' );
    if ( defined $defaultsort ) {
        XIMS::Debug( 6, "defaultsort: $defaultsort" );
        my $currentvalue = $object->attribute_by_key( 'defaultsort' );
        if ( $defaultsort ne 'asc' or defined $currentvalue ) {
            $object->attribute( defaultsort => $defaultsort );
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

1;
