# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::XML;

use XIMS::Importer::FileSystem;
use XML::LibXML;

use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem);

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my $dontbody = shift;

    my $object = $self->SUPER::handle_data( $location );

    unless ( $dontbody ) {
        my $parser = XML::LibXML->new();
        my $doc;
        my $strref = $self->get_strref( $location );
        eval {
            $doc = $parser->parse_string( $$strref );
        };
        if ( $@ ) {
            XIMS::Debug( 3, "Could not parse: $location" );
            return undef;
        }
        $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' );
        $object->body( $doc->toString() );
    }

    return $object;
}
