# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::XML;

use XIMS::Importer::FileSystem;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem);

use XML::LibXML 1.54; # We have to use 1.54 onward here because the DOM implementation changed from 1.52 to 1.54.
                      # With 1.52, node iteration is handled differently and we would call
                      # $doc->getDocumentElement() instead of $doc->documentElement() for example...
use XML::LibXML::Iterator;

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my $dontbody = shift;

    my $object = $self->SUPER::handle_data( $location );

    unless ( $dontbody ) {
        my $root = $self->get_rootelement( $location, $object, 1 );
        return undef unless $root;
        # uncomment the following depending on your XML::LibXML/libxml set up
        # and are experiencing double UTF-8 encoded values in your imported
        # data
        #
        #$object->body( XML::LibXML::decodeFromUTF8('ISO-8859-1',$root->toString()) );
        $object->body( $root->toString() );
    }

    return $object;
}

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my $object = shift;
    my $nochunk = shift;

    my %param = ();
    $param{nochunk} = 1 if $nochunk;

    my $data = $self->get_strref( $location );
    my $wbdata;
    if ( $object and not $object->balanced_string( $$data, %param ) ) {
        $wbdata = $object->balance_string( $$data, keephtmlheader => 1 );
    }
    else {
        $wbdata = $$data;
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

sub get_strref {
    my $self = shift;
    my $file = shift;
    local $/;
    open (INPUT, $file) || die "could not open $file: $!";
    my $contents = <INPUT>;
    close INPUT;
    return \$contents;
}
