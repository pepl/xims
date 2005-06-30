# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
package XIMS::File;
# $Id$

use vars qw($VERSION @ISA);
use strict;
use XIMS::Object;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Object');

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    $args{object_type_id} = 4 unless defined $args{object_type_id};
    $args{data_format_id} = 14 unless defined $args{data_format_id};

    return $class->SUPER::new( %args );
}

1;
