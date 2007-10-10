# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::XMLChunk;

use strict;
use base qw( XIMS::Importer::Object );
use XIMS::Object;
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $strref = shift;
    my %args = @_;

    my $wbdata;
    my $object = XIMS::Object->new();
    my $doc;
    if ( not $doc = $object->balanced_string( $$strref, %args ) ) {
        $wbdata = $object->balance_string( $$strref );
        my $parser = XML::LibXML->new();
        my $encoding ||= ( XIMS::DBENCODING() || 'UTF-8' );
        eval {
            $doc = $parser->parse_xml_chunk( $wbdata, $encoding );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $@" );
            return;
        }
    }

    return $doc;
}


1;
