# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::XSPScript;

use strict;
use vars qw( $VERSION @ISA );

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Document');

use XIMS::Document;

##
#
# SYNOPSIS
#    XIMS::XSPScript->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $XSPScript: XIMS::XSPScript instance
#
# DESCRIPTION
#    Constructor
#

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    $args{object_type_id} = 10 unless defined $args{object_type_id};
    $args{data_format_id} = 26 unless defined $args{data_format_id};

    return $class->SUPER::new( %args );
}

1;
