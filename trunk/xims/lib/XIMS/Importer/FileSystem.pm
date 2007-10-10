# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem;

use strict;
use base qw( XIMS::Importer );
use XIMS::DataFormat;
use XIMS::ObjectType;
use XIMS::Object;
use File::Basename;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub import {
    my $self = shift;
    my $location = shift;
    my $updateexisting = shift;
    return unless $location;

    my $importer = $self->resolve_importer( $location );
    return unless $importer;

    my $object = $importer->handle_data( $location );

    return $self->SUPER::import( $object, $updateexisting );
}

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->object();
    $object->location( $location );
    $object->parent_id( $self->parent_by_location( $location )->document_id() );
    $object->data_format_id( $self->data_format->id() );

    return $object;
}

sub parent_by_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $dirname = dirname($location);
    my $plocation = $self->parent->location_path();
    $plocation .= '/' . $dirname if ( length $dirname and $dirname ne '.' );
    $plocation = '/root' unless (defined $plocation and $plocation);

    return XIMS::Object->new( path => lc($plocation) );
}

sub resolve_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    XIMS::Debug( 6, "location: $location" );

    if ( -l $location ) {
        return ( XIMS::ObjectType->new( name => 'SymbolicLink' ), XIMS::DataFormat->new( name => 'SymbolicLink' ) );
    }
    elsif ( -f $location ) {
        return $self->resolve_filename( basename($location) );
    }
    elsif ( -d $location ) {
        return ( XIMS::ObjectType->new( name => 'Folder' ), XIMS::DataFormat->new( name => 'Container' ) );
    }
    else {
        die "could not resolve location '$location'. (we should not get there)";
    }
}

sub resolve_importer {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    return unless $location;

    my ($object_type, $data_format) = $self->resolve_location( $location );
    my $impclass = "XIMS::Importer::FileSystem::" . $object_type->fullname();
    eval "require $impclass;";
    if ( $@ ) {
        XIMS::Debug( 3 , "Could not load importer class: $@" );
        return;
    }
    my $importer = $impclass->new( Provider => $self->data_provider(),
                                   Parent => $self->parent(),
                                   User => $self->user(),
                                   ObjectType => $object_type,
                                   DataFormat => $data_format,
                                   );

    return $importer;
}

sub get_strref {
    my $self = shift;
    my $file = shift;
    local $/;
    die "could not open $file: $!" unless -R $file and open (INPUT, $file);
    my $contents = <INPUT>;
    close INPUT;
    return \$contents;
}

1;
