# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::Annotation;

##
#
# DESCRITION
#
# This annotation class inherits XIMS::Document. It should provide the
# well forming api for commentors as well.
#
use strict;
use vars qw( $VERSION @ISA );
use XIMS::Document;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::Document );

##
#
# DESCRIPTION
#
# The only thing this class does itself is to correct it's object
# type, so it can be distingueshed from XIMS::Documents :)
#
sub new {
    my ( $class, %args ) = @_;

    $args{object_type_id} = 16 unless defined $args{object_type_id};

    my $self = $class->SUPER::new( %args );
    return $self;
}

1;
