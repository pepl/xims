# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Bookmark;

use strict;
use base qw( XIMS::AbstractClass );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields;

sub resource_type {
    return 'Bookmark';
}

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names( resource_type() )};
}

use Class::MethodMaker
        get_set       => \@Fields;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( ( defined( $args{id} ) ) || ( defined( $args{owner_id}) and defined( $args{stdhome} )) ) {
            my $real_bmk = $self->data_provider->getBookmark( %args );
            if ( defined( $real_bmk )) {
               $self->data( %{$real_bmk} );
            }
            else {
                return undef;
            }
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}

1;
