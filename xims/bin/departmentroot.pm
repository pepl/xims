# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package departmentroot;

use strict;
use vars qw( $VERSION @params @ISA);

use folder;
use XIMS::Object;
use XML::LibXML;

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
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          add_portlet
          rem_portlet
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

    return 0 if $self->SUPER::event_default( $ctxt );

    $ctxt->properties->content->getformatsandtypes( 1 );

    return 0;
}

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $self->expand_attributes( $ctxt );
    $self->expand_bodydeptinfo( $ctxt );
    $self->resolve_content( $ctxt, [ qw( STYLE_ID IMAGE_ID ) ] );

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

# hmmm, really needed?
sub event_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return $self->event_edit( $ctxt );
}

sub event_add_portlet {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $body   = $object->body();

    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    my $id = 0;
    my $path = $self->param( "portlet" );

    if ( defined $path ) {
        my $pobject = XIMS::Object->new( language_id => $object->language_id(), path => $path );
        if ( $pobject ) {
            $id = $pobject->id;
            XIMS::Debug( "found portlet id = $id ");
            if ( defined $body ) {
                my $parser = XML::LibXML->new();
                my $fragment;
                if ( length $body ) {
                    XIMS::Debug( 4, "got existing department info" );
                    eval {
                        $fragment = $parser->parse_xml_chunk( $body );
                    };
                }
                else {
                    XIMS::Debug( 4, "got new department info " );
                    $fragment = XML::LibXML::DocumentFragment->new();
                }

                if ( $@ ) {
                    XIMS::Debug( 2, "problem with the stored data ($@)"  );
                }
                else {
                    # 2. step: check if id is already there
                    my ( $node ) = grep {$_->string_value() == $id} $fragment->childNodes;
                    if ( defined $node ) {
                        XIMS::Debug( 3, "portlet ($id) already exists here" );
                    }
                    else {
                        XIMS::Debug( 4, "3. step: insert the entry" );
                        $node = XML::LibXML::Element->new("portlet");
                        $node->appendText( $id );
                        $fragment->appendChild( $node );

                        XIMS::Debug( 4, "4. step: store body back." );
                        $object->body( $fragment->toString());
                        if ( not $object->update() ) {
                            XIMS::Debug( 2, "update failed" );
                            $self->sendError( $ctxt, "Update of object failed." );
                            return 0;
                        }
                    }
                }
            }
            else {
                $object->body( "<portlet>$id</portlet>" );
                if ( not $object->update() ) {
                    XIMS::Debug( 2, "update failed" );
                    $self->sendError( $ctxt, "Update of object failed." );
                    return 0;
                }
            }
        }
        else {
            XIMS::Debug( "portlet not found for $path!");
        }
    }


    return $self->event_edit( $ctxt );
}

sub event_rem_portlet {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $body   = $object->body();

    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    if ( defined $body ) {
        my $parser = XML::LibXML->new();

        my $id = $self->param( "portlet_id" );
        if ( defined $id and $id > 0 ) {
            # 2. step: check if id is there
            my $fragment;
            eval {
                $fragment = $parser->parse_xml_chunk( $body );
            };

            if ( $@ ) {
                XIMS::Debug( 6, "serious problem with the stored data ($@)"  );
            }
            else {
                # 3. step: remove the entry
                my ( $node ) = grep {$_->string_value() == $id} $fragment->childNodes;
                if ( defined $node ) {
                    XIMS::Debug( 6, "found node" );
                    $node->unbindNode; # remove node from its context.

                    # 4. step: store the body back.
                    $object->body( $fragment->toString() );
                    if ( not $object->update() ) {
                        XIMS::Debug( 2, "update failed" );
                        $self->sendError( $ctxt, "Update of object failed." );
                        return 0;
                    }
                }
            }
        }
        else {
            XIMS::Debug( 2, "no such id" );
        }
    }

    return $self->event_edit( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

sub expand_bodydeptinfo {
    my $self = shift;
    my $ctxt = shift;

    eval "require XIMS::SAX::Filter::DepartmentExpander;";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load department-expander: $@" );
        return 0;
    }
    my $filter = XIMS::SAX::Filter::DepartmentExpander->new( Object   => $ctxt->object(),
                                                             User     => $ctxt->session->user(), );
    $ctxt->sax_filter( [$filter] );
}

1;
