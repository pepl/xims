# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::Document;

use XIMS::Importer::FileSystem::XML;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem::XML);

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location, 1 );
    my $root = $self->get_rootelement( $location, $object, nochunk => 1 );
    return undef unless $root;

    my %importmap = (
        keywords   => "//*[local-name() = 'subject']|/html/head/meta[\@name='keywords']/\@content",
        title      => "//*[local-name() = 'title']",
        body       => "*[local-name() = 'body']",
        abstract   => "//*[local-name() = 'description']/*[local-name() = 'description']|/html/head/meta[\@name='description']/\@content"
                    );

    foreach my $field ( keys %importmap ) {
        my ($n) = $root->findnodes( $importmap{$field} );
        if ( defined $n ) {
            $value = "";
            if ( $n->hasChildNodes() ) {
                map { $value .= $_->toString(0,1) } $n->childNodes;
            }
            if ( length $value ) {
                $object->$field( XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(),$value) : $value );
            }
        }
    }

    return $object;
}

1;
