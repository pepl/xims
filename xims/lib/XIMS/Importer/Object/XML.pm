# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::XML;

use XIMS::Importer::Object;
use XIMS::Object;
use XML::LibXML 1.54; # We have to use 1.54 onward here because the DOM implementation changed from 1.52 to 1.54.
                      # With 1.52, node iteration is handled differently and we would call
                      # $doc->getDocumentElement() instead of $doc->documentElement() for example...
use XML::LibXML::Iterator;

use vars qw( @ISA );
@ISA = qw(XIMS::Importer::Object);

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $strref = shift;
    my %args = @_;

    my $wbdata;
    my $object = XIMS::Object->new();
    if ( not $object->balanced_string( $$strref, %args ) ) {
        $wbdata = $object->balance_string( $$strref, keephtmlheader => 1 );
    }
    else {
        $wbdata = $$strref;
    }

    my $parser = XML::LibXML->new();
    my $doc;
    eval {
        $doc = $parser->parse_string( $wbdata );
    };
    if ( $@ ) {
        XIMS::Debug( 3, "Could not parse: $location" );
        return undef;
    }

    # lowercase element and attribute names
    my $iter = XML::LibXML::Iterator->new( $doc );
    $iter->iterate( sub {
                        shift;
                        $_[0]->nodeType == XML_ELEMENT_NODE &&
                            map {
                                    $_->nodeType != XML_NAMESPACE_DECL &&
                                    $_->setNodeName( lc $_->nodeName )
                                }
                            $_[0], $_[0]->attributes;
                        } );
    return $doc->documentElement();
}


1;
