# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$

package XIMS::Portal;

use warnings;
use strict;

use vars qw( @ISA );
use XIMS;
use XIMS::Object;

@ISA = ('XIMS::Object');

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    $args{object_type_id} = 18 unless defined $args{object_type_id};
    $args{data_format_id} = 4 unless defined $args{data_format_id}; 

    return $class->SUPER::new( %args );
}

1;
