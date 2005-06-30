# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package document;

use strict;
use vars qw( $VERSION @ISA @MSG @params );

use XIMS::CGI;

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
@MSG = ( "Document body could not be converted to a well balanced string. Please consult the User's Reference for information on well-balanced document bodies." );

# parameters recognized by the script
@params = qw( id parid name title depid symid delforce del plain trytobalance);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $ctxt->properties->content->escapebody( 1 );

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # ewebeditpro extension, uncomment to activate
    # check if the OS is M\$ and the user wants the wysiwyg editor
    #return 0 unless $ENV{HTTP_USER_AGENT} =~ /Windows/i
    #                and not $self->param( 'plain' )
    #                and $ENV{HTTP_USER_AGENT} =~ /IE|Mozilla\/(?:3|4|6\.2)/;
    #$ctxt->properties->application->style( "edit_wepro" );

    return 0;
}

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    # ewebeditpro extension, uncomment to activate
    #return 0 unless $ENV{HTTP_USER_AGENT} =~ /Windows/i
    #                and not $self->param( 'plain' )
    #                and $ENV{HTTP_USER_AGENT} =~ /IE|Mozilla\/(?:3|4|6\.2)/;
    #$ctxt->properties->application->style( "create_wepro" );

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

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

    return $self->SUPER::event_store( $ctxt );
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_exit( $ctxt );
}

#
# the following events extend the edit mode. in browse mode this
# information should be displayed by default.
#
# may be inserted into event_default ...

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # redirect to full path in case document is called via id
    if ( $self->path_info() eq XIMS::CONTENTINTERFACE()
         and not $ctxt->object->marked_deleted() ) {

        # not needed anymore
        $self->delete('id');

        XIMS::Debug( 4, "redirecting to full path" );
        $self->redirect( $self->redirect_path( $ctxt ) );

        return 0;
    }

    # pepl: why do we need two ways to load links and annotations? if
    # annotations would have the privs/grants of the owner document
    # copied "by definition", this would not be neccessary

    # pepl/ phish: this is strictly related to the general privilege
    # system we have to discuss more intense.

    # the following still has to be implemented with the new system
    
    $ctxt->properties->content->getchildren->objecttypes( [ qw( URLLink SymbolicLink ) ] );

    # temporarily deactivated until privilege inheritation of annotations is dicussed and clear
    #$self->resolve_annotations( $ctxt );

    return $self->SUPER::event_default( $ctxt );
}

sub event_pub_preview {
    my ( $self, $ctxt ) = @_;

    $self->SUPER::event_default( $ctxt );

    $ctxt->properties->application->style("pub_preview");
    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

# #############################################################################
# Local Helper functions

sub resolve_annotations {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
    require XIMS::SAX::Filter::AnnotationCollector;
    push ( @{$ctxt->sax_filter()},
           XIMS::SAX::Filter::AnnotationCollector->new( Object => $ctxt->object() )
         );
}

1;
