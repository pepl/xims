# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::Object::ReferenceLibraryItem;

use strict;
use base qw( XIMS::Importer::Object );
use XIMS::RefLibReferenceProperty;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub check_duplicate_identifier {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $identifier = shift;
    
    my $identifier_property = XIMS::RefLibReferenceProperty->new( name => 'identifier' );
    my @data = $self->data_provider->getRefLibReferencePropertyValue( property_id => $identifier_property->id(), value => $identifier );
    if ( scalar @data ) {
        XIMS::Debug( 3, "ReferenceLibraryItem with same identifier already exists" );
        return;
    }
    else {
        return 1;
    }
}

1;
