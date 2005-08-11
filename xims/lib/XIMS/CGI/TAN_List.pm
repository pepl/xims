# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::TAN_List;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::CGI;

use XIMS::DataFormat;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

# (de)register events here
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
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
          download
          )
        );
}

#
# override or add event handlers here
#
sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $self->expand_attributes( $ctxt );

    return 0;
}

sub event_download {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $type = $self->param('download');

    my $body;
    my $filename = $ctxt->object->location;
    $filename =~ s/\.[^\.]*$//;
    my $mime_type = "text/". lc $type;
    if ( $type =~ /Excel/i ) {
        # export each tan in a single row, therefore \n
        $body = join("\n",split(",",$ctxt->object->body()));
        my $df = XIMS::DataFormat->new( name => 'XLS' );
        $filename .= '.' . $df->suffix;
        $mime_type = $df->mime_type;
    }
    elsif ( $type =~ /TXT/i ) {
        # export each tan in a single row, therefore \n
        $body = join("\r\n",split(",",$ctxt->object->body()));
        $filename .= '.' . lc $type;
    }
    else {
        $filename .= '.' . lc $type;
    }

    # older browsers use the suffix of the URL for content-type sniffing,
    # so we have to supply a content-disposition header
    print $self->header( -type => $mime_type, '-Content-disposition' => "attachment; filename=$filename" );
    print $body;
    $self->skipSerialization(1);

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    if ( not $ctxt->parent() ) {
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

        my $number = $self->param( 'number' );
        if ( not (defined $number and length $number) ) {
            $self->sendError( $ctxt, "Number of TANs not set!" );
            return 0;
        }
        XIMS::Debug( 6, "Number of TANs: $number" );
        $object->number( $number );

        my $body = $object->create_TANs( $number );
        if ( length $body ) {
            if ( $object->body( $body ) ) {
                XIMS::Debug( 6, "TANs created: " . length( $body ) );
            }
            else {
                XIMS::Debug( 2, "could not create TANs" );
                $self->sendError( $ctxt, "TAN-List could not be created." );
                return 0;
            }
        }

        if ( not $object->create() ) {
            XIMS::Debug( 2, "create failed" );
            $self->sendError( $ctxt, "Creation of object failed." );
            return 0;
        }

        XIMS::Debug( 4, "copying privileges of parent" );
        my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $ctxt->data_provider->getObjectPriv( content_id => $ctxt->parent->id() );
        foreach my $priv ( @object_privs ) {
            $object->grant_user_privileges(
                                        grantee   => $priv->grantee_id(),
                                        grantor   => $ctxt->session->user(),
                                        privmask  => $priv->privilege_mask(),
                                    )
        }
    }

    XIMS::Debug( 4, "redirecting" );
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}
1;
