# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package portlet;

use strict;
use vars qw( $VERSION @params @ISA);

use XIMS::CGI;
use XIMS::Portlet;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
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
          publish
          publish_prompt
          unpublish
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          cancel
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
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $self->expand_portletinfo( $ctxt );

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    $self->resolve_content( $ctxt, [ qw( SYMNAME_TO_DOC_ID ) ] );
    $ctxt->properties->content->getformatsandtypes( 1 );

    return 0;
}

sub event_create {
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getformatsandtypes( 1 );

    return $self->SUPER::event_create( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();
    my $target = $self->param( 'target' );

    if ( defined $target ) {
        XIMS::Debug( 6, "target: $target" );
        my $targetobj;
        if ( $target =~ /^\d+$/
                and $targetobj = XIMS::Object->new( document_id => $target, language => $object->language_id ) ) {
            $object->symname_to_doc_id( $targetobj->document_id() );
        }
        elsif ( $targetobj = XIMS::Object->new( path => $target, language => $object->language_id ) ) {
            $object->symname_to_doc_id( $targetobj->document_id() );
        }
        else {
            XIMS::Debug( 2, "Could not find or set target (SYMNAME_TO_DOC_ID)" );
            $self->sendError( $ctxt, "Could not find or set target" );
            return 0;
        }
    }
    else {
        XIMS::Debug( 2, "No target specified!" );
        $self->sendError( $ctxt, "No target specified!" );
        return 0;
    }

    my $body = $self->generate_body( $ctxt );
    $ctxt->object->body( $body );

    return $self->SUPER::event_store( $ctxt );
}

##
#
# SYNOPSIS
#    event_test_filter( $app, $ctxt );
#
# PARAMETER
#    $ctxt: The applocation context
#
# RETURNS
#    allways 0
#
# DESCRIPTION
#    this littly event tests the wellformedness of the extra data filter
#    information. ( not used yet )
#
sub event_test_filter {
    my $self = shift;
    my $ctxt = shift;

    if ( $self->param( "extra-filters" ) ) {
        require XML::LibXML;

        my $filter = $self->param( "extra-filters" );
        eval {
            my $chunk  = XML::LibXML->new->parse_xml_chunk( $filter );
        };
        if ( $@ ) {
            $ctxt->session->error_msg( "bad formed filter conditions : $@" );
        }
        else {
            $ctxt->session->message( "filter xml looks ok" );
        }
    }

    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

sub expand_portletinfo {
    my $self = shift;
    my $ctxt = shift;

    $ctxt->properties->content->childrenbybodyfilter( 1 );

    eval "require XIMS::SAX::Filter::PortletCollector;";
    if ( $@ ) {
        XIMS::Debug( 3, "could not require portletcollector : $@" );
        return undef;
    }

    my $filter = XIMS::SAX::Filter::PortletCollector->new( Provider => $ctxt->data_provider(),
                                                           Object   => $ctxt->object(),
                                                           User     => $ctxt->session->user(),);
    $ctxt->sax_filter( [$filter] );
}

sub generate_body {
    my $self = shift;
    my $ctxt = shift;
    my $body = "";

    # code to be rewritten follows

    $body = "<content>";
    # pepl: *ouch*; this should not be HERE!
    foreach my $p ( qw( created_by_fullname creation_timestamp
                        last_modified_by_fullname
                        owned_by_fullname last_modification_timestamp
                        last_publication_timestamp owned_by_fullname
                        minor_status attributes marked_new abstract image_id
                        body ) ) {
        if ( defined $self->param( 'col_' . $p ) ) {
            if ( $p =~ /(.+)fullname/ ) {
                my ( $p1, $p2, $p3 ) = map { $1 . $_ } qw(firstname middlename lastname);
                $body .= qq{<column name="$p1"/>};
                $body .= qq{<column name="$p3"/>};
                $body .= qq{<column name="$p3"/>};
            }
            else {
                $body .= qq{<column name="$p"/>};
            }
        }

    }

    if ( $self->param( "levels" ) ) {
        $body .= '\n<depth level="'. $self->param( "levels" ) . '"/>\n';
    }

    foreach my $type ( map { $_->name() } $ctxt->data_provider->object_types() ) {
        next unless defined $type;
        my $name = "ot_$type";
        my $v    = $self->param( $name );
        next unless defined $v;
        $body .= '<object-type name="' . $type . '"/>';
    }

    $body .= "</content>\n";
    $body .= "<filter>\n";
    if ( $self->param( "filternews" ) ) {
        $body .= qq{<new>1</new>\n};
    }

    if ( $self->param( "extra_filters" ) ) {
        XIMS::Debug( 5, "add additional xims filter!" );
        require XML::LibXML;

        my $filter = $self->param( "extra_filters" );
        XIMS::Debug( 5, "filter is $filter" );
        eval {
            my $chunk  = XML::LibXML->new->parse_xml_chunk( $filter );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "bad formed filter conditions : $@" );
        }
        else {
            $body .= $filter . "\n";
        }
    }

    $body .= "</filter>\n";

    return $body;
}


1;
