# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package siteroot;

use strict;
use vars qw($VERSION @ISA);

use departmentroot;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( departmentroot );

# #############################################################################
# RUNTIME EVENTS

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

    my $creating;
    my $objtype = $self->param( 'objtype' );

    $creating = 1 if ($self->param( 'parid' ) and $objtype);
    if ( not defined $creating ) {
        XIMS::Debug( 6, "unlocking object" );
        $object->unlock();
        XIMS::Debug( 4, "updating existing object" );
        if ( not $object->update() ) {
            XIMS::Debug( 2, "update failed" );
            $self->sendError( $ctxt, "Update of object failed." );
            return 0;
        }
        $self->redirect( $self->redirect_path( $ctxt ) );
        return 1;
    }
    else {
        XIMS::Debug( 4, "creating new object" );
        if ( not $object->create() ) {
            XIMS::Debug( 2, "create failed" );
            $self->sendError( $ctxt, "Creation of object failed." );
            return 0;
        }

        XIMS::Debug( 4, "granting privileges" );

        my $owneronly = $self->param( 'owneronly' );
        if ( defined $owneronly and ( $owneronly eq 'true' or $owneronly == 1 ) ) {
            $owneronly = 1;
        }
        else {
            $owneronly = 0;
        }

        if ( $self->default_grants( $ctxt, $owneronly ) ) {
            XIMS::Debug( 4, "updated user privileges" );
        }
        else {
            $self->sendError( $ctxt , "failed to set default grants" );
            XIMS::Debug( 2, "failed to set default grants" );
            return 0;
        }
    }

    XIMS::Debug( 4, "redirecting" );
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

# END RUNTIME EVENTS
# #############################################################################
1;
