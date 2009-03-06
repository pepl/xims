# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Exporter::VLibraryItem::DocBookXML;

use strict;
use XIMS::Exporter;
use XIMS::ObjectType;
use XIMS::SAX::Generator::VLibraryItem;

use Data::Dumper;

use vars qw( @ISA );
@ISA = qw( XIMS::Exporter::sDocBookXML );

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    return unless $self->SUPER::create( %param );

    # publish all image children
    my $image_ot_id = XIMS::ObjectType->new( name => 'Image' )->id();
    my @children = $self->{Object}->children_granted( User => $self->{User}, object_type_id => $image_ot_id );
    if ( @children and scalar @children ) {
        my $helper = XIMS::Exporter::Helper->new();
        my $location;
        foreach my $kind ( @children ) {
            my $reaper = $helper->exporterclass(
                                          Provider   => $self->{Provider},
                                          User       => $self->{User},
                                          Object     => $kind,
                                          exportfilename => $self->{Basedir} . '/' . $kind->location()
                                        );
            if ( $reaper and $reaper->create() ) {
                XIMS::Debug( 4, "published " .$kind->location() );
            }
            else {
                XIMS::Debug( 2, "could not publish " .$kind->location() );
            }
        }
    }

    return 1;
}

sub remove {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    # unpublish all published image children
    my $image_ot_id = XIMS::ObjectType->new( name => 'Image' )->id();
    my @children = $self->{Object}->children_granted( User => $self->{User}, object_type_id => $image_ot_id, published => 1 );
    if ( @children and scalar @children ) {
        my $helper = XIMS::Exporter::Helper->new();
        my $location;
        foreach my $kind ( @children ) {
            my $reaper = $helper->exporterclass(
                                          Provider   => $self->{Provider},
                                          User       => $self->{User},
                                          Object     => $kind,
                                          exportfilename => $self->{Basedir} . '/' . $kind->location()
                                        );
            if ( $reaper and $reaper->remove() ) {
                XIMS::Debug( 4, "unpublished " .$kind->location() );
            }
            else {
                XIMS::Debug( 2, "could not unpublish " .$kind->location() );
            }
        }
    }

    return $self->SUPER::remove( %param );
}

sub set_sax_generator {
    XIMS::Debug( 5, "called" );
    my $self  = shift;

    return XIMS::SAX::Generator::VLibraryItem->new();
}


1;
