# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::XML;

use strict;
use base qw( XIMS::Importer::Object );
use XIMS::Object;
use XML::LibXML 1.54; # We have to use 1.54 onward here because the DOM implementation changed from 1.52 to 1.54.
                      # With 1.52, node iteration is handled differently and we would call
                      # $doc->getDocumentElement() instead of $doc->documentElement() for example...

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
        $wbdata = $object->balance_string( $$strref, keephtmlheader => 1 );
        my $parser = XML::LibXML->new();
        my $doc;
        eval {
            $doc = $parser->parse_string( $wbdata );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $@" );
            return undef;
        }
    }

    $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );
    return $doc->documentElement();
}


1;
