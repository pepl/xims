# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::Document;

use XIMS::Importer::FileSystem::XMLChunk;
use XML::LibXML 1.54; # We have to use 1.54 onward here because the DOM implementation changed from 1.52 to 1.54.
                      # With 1.52, node iteration is handled differently and we would call
                      # $doc->getDocumentElement() instead of $doc->documentElement() for example...
use XML::LibXML::Iterator;
use XIMS::Object;

use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem::XMLChunk);

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location, 1 );
    my $root = $self->get_rootelement( $location, nochunk => 1 );
    return undef unless $root;

    my %importmap = (
        keywords   => "//*[local-name() = 'subject']|/html/head/meta[\@name='keywords']/\@content",
        title      => "//*[local-name() = 'title']",
        body       => "*[local-name() = 'body']",
        abstract   => '//*[local-name() = "description"]/*[local-name() = "description"]|/html/head/meta[@name="description"]/@content'
                    );

    foreach my $field ( keys %importmap ) {
        my ($n) = $root->findnodes( $importmap{$field} );
        if ( defined $n ) {
            $value = "";
            if ( $n->hasChildNodes() ) {
                map { $value .= $_->toString(0,1) } $n->childNodes;
            }
            else {
                $value = $n->textContent();
            }
            if ( length $value ) {
               $object->$field( $value );
            }
        }
    }

    return $object;
}

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my %args = @_;

    my $strref = $self->get_strref( $location );
    my $wbdata;
    my $object = XIMS::Object->new();
    my $doc;
    if ( not $doc = $object->balanced_string( $$strref, %args ) ) {
        $wbdata = $object->balance_string( $$strref, keephtmlheader => 1 );
        my $parser = XML::LibXML->new();
        eval {
            $doc = $parser->parse_string( $wbdata );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $@" );
            return undef;
        }
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
