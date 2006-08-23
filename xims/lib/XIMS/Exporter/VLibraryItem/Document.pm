# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Exporter::VLibraryItem::Document;

use strict;
use XIMS::Exporter;
use base qw( XIMS::Exporter::Document );
use XIMS::ObjectType;
use XIMS::SAX::Generator::Exporter::VLibraryItem;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub create {
    XIMS::Debug( 5, "called" );
    my ( $self, %param ) = @_;

    return unless $self->SUPER::create( %param );

    # publish the children to the same directory as the object itself
    my @children = $self->{Object}->children_granted( User => $self->{User} );
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

    # unpublish published children
    my @children = $self->{Object}->children_granted( User => $self->{User}, published => 1 );
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

    return XIMS::SAX::Generator::Exporter::VLibraryItem->new();
}

sub update_related { return undef }
sub update_parent_autoindex { return undef }

1;

