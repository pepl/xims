# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::XML;

use strict;
use vars qw( $VERSION @ISA @MSG @params );

use XIMS::CGI;
use Text::Iconv;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( XIMS::CGI );

# the names of pushbuttons in forms or symbolic internal handler
# each application should register the events required, even if they are
# defined in XIMS::CGI. This is for having a chance to
# deny certain events for the script.
#
# only dbhpanic and access_denied are set by XIMS::CGI itself.
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          default
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
          pub_preview
          )
        );
}

# error messages
@MSG = ( "Document body is not well-formed. Please consult the User's Reference for information on well-formed document bodies." );

# parameters recognized by the script
@params = qw( id name title depid symid delforce del plain trytobalance);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $body = $self->param( 'body' );
    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }

        # we have to update the encoding attribute in the xml-decl to match
        # the encoding, the body will be saved in the db. that can't be done
        # parsing the body, doing a setEncoding() followed by a toString()
        # because we have to deal with the case that the body itself gets
        # send by the browser encoded in UTF-8 but still has different
        # encoding attributes from the user's document.
        #
        $body = update_decl_encoding( $body );

        my $object = $ctxt->object();
        if ( $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "body is not well-formed" );
            $self->sendError( $ctxt, $MSG[0] );
            return 0;
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->escapebody( 1 );

    return $self->SUPER::event_exit( $ctxt );
}


sub update_decl_encoding {
    XIMS::Debug( 5, "called" );
    my $body = shift;

    my ( $encoding ) = ( $body =~ /^<\?xml[^>]+encoding="([^"]*)"/ );
    if ( $encoding ) {
        my $newencoding = ( XIMS::DBENCODING() || 'UTF-8' );
        XIMS::Debug( 6, "switching encoding attribute from '$encoding' to '$newencoding'");
        $body =~ s/^(<\?xml[^>]+)encoding="[^"]*"/$1encoding="$newencoding"/;
    }

    return $body;
}

1;

