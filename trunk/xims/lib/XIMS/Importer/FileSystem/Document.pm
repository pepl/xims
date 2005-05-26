# Copyright (c) 2002-2005 The XIMS Project.
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

use Encode;

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
            my @cnodes = $n->childNodes;
            if ( scalar @cnodes > 1 ) {
                map { $value .= $_->toString(0,1) } $n->childNodes;
            }
            else {
                $value = $n->textContent();
            }
            if ( length $value ) {
                # $doc->setEncoding() does not work depending on the libxml version :-/
                # Using encode_utf8() here to make sure we get utf-8
                $value = Encode::encode_utf8( $value ) unless XIMS::DBENCODING;
                $object->$field( XIMS::Entities::decode( $value ) );
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

    # Most users will not have their legacy HTML documents encoded
    # in UTF-8. Therefore, we try to encode the documents to UTF-8 for them.
    my $data = utf8_sanitize( $$strref );

    my $wbdata;
    my $object = XIMS::Object->new();
    my $doc;
    if ( not $doc = $object->balanced_string( $data, %args ) ) {
        $wbdata = $object->balance_string( $data, keephtmlheader => 1 );
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

    $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );
    return $doc->documentElement();
}

sub utf8_sanitize {
    my $string = shift;
    if ( is_notutf8( $string ) ) {
        return Encode::encode_utf8($string);
    }
    else {
        return $string;
    }
}

# poor man's check
sub is_notutf8 {
    # <yarg/>
    if ( $] == 5.008004 ) {
        eval { Encode::decode_utf8(Encode::decode_utf8(shift)); };
        return 1 if $@;
        return 0;
    }
    else {
        return 0 if defined Encode::decode_utf8(shift);
        return 1;
    }
}


1;
