# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package anondiscussionforumcontrib;

use strict;
use warnings;

use vars qw( $VERSION @ISA @MSG );

use XIMS::CGI;
use Data::Dumper;

use Digest::MD5 qw(md5_hex); # for location-setting (do we really need this?)

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::CGI );
 
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          )
        );
}

# error messages
@MSG = ( "Document body could not be converted to a well balanced string. Please consult the User's Reference for information on well-balanced document bodies." );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    # not yet reimplemented
    #$ctxt->properties->content->children->level( undef );

    $self->expand_attributes( $ctxt );

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
warn "ZEYA: ", Dumper(@_);

    my $author    = $self->param( 'author' );
    my $email     = $self->param( 'email' );
    my $coauthor  = $self->param( 'coauthor' );
    my $coemail   = $self->param( 'coemail' );
    my $title     = $self->param( 'title' );

    if ( defined $title and length $title ) {
	$self->param( name =>  md5_hex( $title .  $author . localtime() ) );
    }
    else {
	$self->sendError( $ctxt, "No title set!" );
	return 0;
    }

#    unless ( $object->location ) {
#        my $title  = $self->param( 'title' );
#	warn "ZEYA4", (Dumper \$title);
#        if ( defined $title and length $title ) {
#            $self->param( -name => 'location', -value => md5_hex( $title .  $author . localtime() ) );
#            #$object->location =  md5_hex( $title .  $author . localtime() );
#        }
#        else {
#            $self->sendError( $ctxt, "No title set!" );
#            return 0;
#        }
#    }

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object    = $ctxt->object();

    XIMS::Debug( 6, "author $author" );
    $object->author( $author );

    XIMS::Debug( 6, "email $email" );
    $object->email( $email );

    if ( length $coauthor ) {
        XIMS::Debug( 6, "coauthor $coauthor" );
        $object->coauthor( $coauthor );

        XIMS::Debug( 6, "email $coemail" );
        $object->coemail( $coemail, 1 );
    }

    XIMS::Debug( 6, "ip " . $ENV{REMOTE_ADDR} );
    $object->senderip( $ENV{REMOTE_ADDR} );

    my $trytobalance  = $self->param( 'trytobalance' );
    my $body = $self->param( 'body' );

    if ( length $body ) {
        my $object = $ctxt->object();
        if ( $trytobalance eq 'true' and $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        elsif ( $object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "could not convert to a well balanced string" );
            $self->sendError( $ctxt, $MSG[0] );
            return 0;
        }
    }

warn "ZEYA2: ", Dumper($ctxt);
    return $self->SUPER::event_store( $ctxt );
}

# override SUPER::events
sub event_publish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This event has not been implemented for this object type yet." );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

# #############################################################################
# HELPERS


# END HELPERS
# #############################################################################
1;
