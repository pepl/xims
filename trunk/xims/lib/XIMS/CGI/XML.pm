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
          plain
          bxeconfig
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

sub event_default {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # the request method 'PUT' is only used by BXE to save XML-code
    if ( $self->request_method() eq 'PUT' ) {
        XIMS::Debug( 5, "BXE is putting XML-data for saving." );
        if ( $self->save_PUT_data($ctxt) ) {
            print $self->header(-status => '204');
        }
        else {
            print $self->header();
        }
        $self->skipSerialization(1);
        return 0;
    }
    else {
        $self->SUPER::event_default( $ctxt );
    }
}


sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # expand the attributes to XML-nodes
    $self->expand_attributes( $ctxt );

    # resolve document_ids to location_path after attributes have been expanded,
    # because bxeconfig_id is stored in the attributes
    $self->resolve_content( $ctxt, [ qw( STYLE_ID CSS_ID SCHEMA_ID BXECONFIG_ID ) ] );

    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    if ( XIMS::XMLEDITOR() eq 'bxe' ) {
        $self->param( -name=>"bxepresent", -value=>"1" );
    }

    if ( $self->param( "edit" ) eq "bxe" ) {
        $ctxt->properties->application->style( "edit_bxe" );
    }
    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    # BXE Config.xml template document_id is stored as an attribute
    my $bxeconfig = $self->param( 'bxeconfig' );
    if ( defined $bxeconfig and length $bxeconfig ) {
         XIMS::Debug( 6, "bxeconfig: $bxeconfig" );
        my $bxeconfigobj;
        if ( $bxeconfig =~ /^\d+$/
             and $bxeconfigobj = XIMS::Object->new( id => $bxeconfig )
             and ( $bxeconfigobj->object_type->name() eq 'XML' ) )
        {
            $object->attribute( bxeconfig_id => $bxeconfigobj->id() );
        }
        elsif ( $bxeconfigobj = XIMS::Object->new( path => $bxeconfig )
                and ( $bxeconfigobj->object_type->name() eq 'XML' ) )
        {
            $object->attribute( bxeconfig_id => $bxeconfigobj->id() );
        }
            else {
                XIMS::Debug( 3, "could not set attribute bxeconfig_id" );
              }
        }
    else {
        $object->attribute( bxeconfig_id => undef );
    }

    # The Node that is edited in BXE is stored as an attribute
    my $bxexpath = $self->param( 'bxexpath' );
    if ( defined $bxexpath and length $bxexpath ) {
        XIMS::Debug( 6, "bxexpath: $bxexpath" );
        $object->attribute( bxexpath => $bxexpath );
        }
    else {
        $object->attribute( bxexpath => undef );
    }

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


sub save_PUT_data {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    # Read PUT-request
    my $content_length = $ctxt->apache->header_in('Content-length');
    my $content;
    $ctxt->apache->read($content, $content_length);

    if ( XIMS::DBENCODING() ) {
        $content = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($content);
    }

    # we have to update the encoding attribute in the xml-decl to match
    # the encoding, the body will be saved in the db. that can't be done
    # parsing the body, doing a setEncoding() followed by a toString()
    # because we have to deal with the case that the body itself gets
    # send by the browser encoded in UTF-8 but still has different
    # encoding attributes from the user's document.
    #
    $content = update_decl_encoding( $content );

    $ctxt->object->body( $content );
    # Store in database
    if ( $ctxt->object->update() ) {
        return 1;
    }
    else {
        return 0;
    }
}

# creates the config file for BXE
sub event_bxeconfig {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # get body from config template
    my $config_template = XIMS::XML->new( id => $ctxt->object->attribute_by_key( 'bxeconfig_id' ));

    # replace placeholders
    my $config_body = $config_template->body();
    my $XML_File = "/goxims/content?id=".$ctxt->object->id().";plain=1";
    my $RNG_File = "/goxims/content?id=".$ctxt->object->schema_id().";plain=1";
    my $CSS_File = "/goxims/content?id=".$ctxt->object->css_id().";plain=1";
    my $Exit_dest = "/goxims/content?id=".$ctxt->object->id().";edit=1";
    $config_body =~ s/\[XML_FILE_BODY\]/$XML_File/;
    $config_body =~ s/\[RNG_FILE_BODY\]/$RNG_File/;
    $config_body =~ s/\[CSS_FILE_BODY\]/$CSS_File/;
    $config_body =~ s/\[XML_FILE_EDIT\]/$Exit_dest/;
    # return xml
    my $df = XIMS::DataFormat->new( id => $config_template->data_format_id() );
    my $mime_type = $df->mime_type;

    my $charset;
    if ( !($charset = XIMS::DBENCODING() )) { $charset = "UTF-8"; }
    print $self->header( -Content_type => $mime_type."; charset=".$charset );
    print $config_body;
    $self->skipSerialization(1);

    return 0;

}


1;
