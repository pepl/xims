# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::VLibraryItem::DocBookXML;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::CGI::VLibraryItem;
use XIMS::CGI::XML;
use XIMS::Importer::Object::VLibraryItem::DocBookXML;
use Text::Iconv;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI::VLibraryItem );

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $body;
    my $fh = $self->upload( 'file' );
    if ( defined $fh ) {
        my $buffer;
        while ( read($fh, $buffer, 1024) ) {
            $body .= $buffer;
        }
    }
    else {
        $body = $self->param( 'body' );

        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }

        # The VLibraryItem::DocBookXML importer needs an XML::Document and not just
        # a fragment to get the metadata out of the Document

        # Substitute the possibly wrong encoding attribute in the XML declaration
        $body = XIMS::CGI::XML::update_decl_encoding( $body );

        # Add an XML declaration if it is not already there in the case of
        # a non UTF-8 database
        if ( XIMS::DBENCODING() and not $body =~ /^<\?xml/ ) {
            XIMS::Debug( 4, "Adding XML declaration" );
            $body = '<?xml version="1.0" encoding="' . XIMS::DBENCODING() . '"?>' . $body;
        }
    }

    if ( defined $body and length $body ) {
        if ( $ctxt->object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "not a well formed string" );
            $self->sendError( $ctxt, "Body is not a well formed string. Please consult the User's Reference for information on well-formed DocBookXML Documents." );
            return 0;
        }

        # Validate the body against a DocBook DTD
        if ( not $ctxt->object->validate( string => $body ) ) {
            XIMS::Debug( 2, "Body did not validate." );
            $self->sendError( $ctxt, "Body did not validate against the DocBook DTD 4.3." );
            return 0;
        }
    }

    if ( $ctxt->parent() ) {
        if ( defined $body and length $body ) {
            my $importer = XIMS::Importer::Object::VLibraryItem::DocBookXML->new( User => $ctxt->session->user(), Parent => $ctxt->parent() );
            if ( $importer->import( $ctxt->object() ) ) {
                XIMS::Debug( 4, "Import of VLibraryItem successful, redirecting" );
                $self->redirect( $self->redirect_path( $ctxt ) );
                return 1;
            }
            else {
                $self->sendError( $ctxt , "Could not import VLibraryItem" );
                XIMS::Debug( 2, "Could not import VLibraryItem" );
                return 0;
            }
        }
        else {
            XIMS::Debug( 2, "No body given" );
            $self->sendError( $ctxt, "A body is needed for the creation of a VLibraryItem::DocBookXML object." );
            return 0;
        }
    }
    else {
        return $self->SUPER::event_store( $ctxt );
    }
}


1;
