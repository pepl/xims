# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::ReferenceLibraryItem;

use strict;
use warnings;

use base qw( XIMS::Importer::Object );

our $VERSION;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub default_grants {
    XIMS::Debug( 5, "called" );
    my $self           = shift;

    my $retval  = undef;

    # grant the object to the current user
    if ( $self->object->grant_user_privileges(
                                         grantee  => $self->user(),
                                         grantor  => $self->user(),
                                         privmask => XIMS::Privileges::MODIFY()|XIMS::Privileges::PUBLISH()
                                       )
       ) {
        XIMS::Debug( 6, "granted user " . $self->user->name . " default privs on " . $self->object->id() );
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "failed to grant default rights!" );
        return 0;
    }

    # Copy the grants of the parent with a privmask greater than VIEW|CREATE
    # Through this, each user will only see the references he created by himself.
    # Besides that, all users who have more privileges set to the ReferenceLibrary than VIEW|CREATE
    # will get a copy of the privileges for every child.
    my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $self->data_provider->getObjectPriv( content_id => $self->parent->id() );
    foreach my $priv ( @object_privs ) {
        if ( $priv->privilege_mask() > (XIMS::Privileges::VIEW()|XIMS::Privileges::CREATE()) ) {
            $self->object->grant_user_privileges(
                                    grantee   => $priv->grantee_id(),
                                    grantor   => $self->user(),
                                    privmask  => $priv->privilege_mask(),
                                );
        }
    }

    return $retval;
}
1;
