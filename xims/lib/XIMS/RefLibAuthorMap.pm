# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::RefLibAuthorMap;

use strict;
# use warnings;

use base qw( XIMS::AbstractClass );

our $VERSION;
our @Fields;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

sub fields {
    return @Fields;
}

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names( resource_type() )};
}

use Class::MethodMaker
        get_set       => \@Fields;

##
#
# SYNOPSIS
#    my $authormap = XIMS::RefLibAuthorMap->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id of an existing mapping.
#    $args{ reference_id }        (optional) :  reference_id of a RefLibReference. To be used together with $args{author_id} and $args{role} to look up an existing mapping.
#    $args{ author_id }           (optional) :  id of a VLibAuthor. To be used together with $args{reference_id} and $args{role} to look up an existing mapping.
#    $args{ role }                (optional) :  Role (integer) of the author in the mapping. To be used together with $args{reference_id} and $args{author_id} to look up an existing mapping.
#
# RETURNS
#    $authormap    : Instance of XIMS::RefLibAuthorMap
#
# DESCRIPTION
#    Fetches existing mappings or creates a new instance of XIMS::RefLibAuthorMap for ReferenceLibrary <-> VLibAuthor mapping.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{reference_id}) and defined( $args{author_id} ) and defined( $args{role} ) ) ) {
            my $rt = ref($self);
            $rt =~ s/.*://;
            my $method = 'get'.$rt;
            my $data = $self->data_provider->$method( %args );
            if ( defined( $data )) {
               $self->data( %{$data} );
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

sub delete {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # Store values
    my $position = $self->position();
    my $reference_id = $self->reference_id();
    my $role = $self->role();

    # Delete the mapping
    my $retval = $self->SUPER::delete( @_ );

    # Close position gap
    my $data = $self->data_provider->dbh->do_update( sql => [ qq{UPDATE cireflib_authormap
                                                  SET
                                                    position = position - 1
                                                  WHERE
                                                    position > ?
                                                    AND reference_id = ?
                                                    AND role = ?
                                                    }
                                                , $position
                                                , $reference_id
                                                , $role
                                           ]);
    unless ( defined $data ) {
        XIMS::Debug( 3, "Could not close position gap");
    }

    return $retval;
}

1;
