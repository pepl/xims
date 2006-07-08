# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::XML;

use strict;
use base qw(XIMS::Importer::FileSystem XIMS::Importer::Object::XML);
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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

sub get_rootelement {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    my %args = @_;

    my $strref = $self->get_strref( $location );
    return $self->SUPER::get_rootelement( $strref, @_ );
}

