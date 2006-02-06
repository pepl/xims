# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::XMLChunk;

use XIMS::Importer::FileSystem;
use XIMS::Importer::Object::XMLChunk;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem XIMS::Importer::Object::XMLChunk);

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my $dontbody = shift;

    my $object = $self->SUPER::handle_data( $location );

    unless ( $dontbody ) {
        my $root = $self->get_rootelement( $location, nochunk => 1 );
        return undef unless $root;
        $object->body( XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(),$root->toString()) : $root->toString() );
    }

    return $object;
}

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my %args = @_;

    my $strref = $self->get_strref( $location );
    return $self->SUPER::get_rootelement( $strref, @_ );
}

