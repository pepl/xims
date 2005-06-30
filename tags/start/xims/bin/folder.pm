# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package folder;

use strict;
use vars qw( $VERSION @ISA @params);

use XIMS::CGI;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

# the names of pushbuttons in forms or symbolic internal handler
# each application should register the events required, even if they are
# defined in XIMS::CGI. This should be, so a programmer has the chance to
# deny certain events for his script.
#
# only dbhpanic and access_denied are set by XIMS::CGI itself.
sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          del
          del_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          cancel
          test_wellformedness
          )
        );
}

# parameters recognized by the script
@params = qw( id parid name title depid symid delforce del);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getformatsandtypes( 1 );

    return $self->SUPER::event_default( $ctxt );
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
    if ( defined $autoindex ) {
        XIMS::Debug( 6, "autoindex: $autoindex" );
        if ( $autoindex eq 'true' ) {
            $object->attribute( autoindex => '1' );
        }
        elsif ( $autoindex eq 'false' ) {
            $object->attribute( autoindex => '0' );
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

1;
