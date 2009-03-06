# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibAuthorMap;

use strict;
use XIMS::AbstractClass;
use vars qw($VERSION @Fields @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::AbstractClass );

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
#    my $authormap = XIMS::VLibAuthorMap->new( [ %args ] );
#
# PARAMETER
#    $args{ id }                  (optional) :  id of an existing mapping.
#    $args{ document_id }         (optional) :  document_id of a VLibraryItem. To be used together with $args{author_id} to look up an existing mapping.
#    $args{ author_id }           (optional) :  id of a VLibAuthor. To be used together with $args{document_id} to look up an existing mapping.
#
# RETURNS
#    $authormap    : Instance of XIMS::VLibAuthorMap
#
# DESCRIPTION
#    Fetches existing mappings or creates a new instance of XIMS::VLibAuthorMap for VLibraryItem <-> VLibAuthor mapping.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;

    if ( scalar( keys(%args)) > 0 ) {
        if ( defined( $args{id} ) or ( defined( $args{document_id}) and defined( $args{author_id} ) ) ) {
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

1;