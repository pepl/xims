# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Iterator::Object;

use vars qw( $VERSION @ISA );
use strict;
use XIMS::Iterator;
use XIMS::Object;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Iterator');

##
#
# SYNOPSIS
#    my $iterator = XIMS::Iterator::Object->new( $arryref [, $cttid ] );
#
# PARAMETER
#    $arryref                        :  Reference to an array of XIMS::Object ids
#                                       If $cttid is ommited, 'document_id' will be used for object lookup
#    $cttid               (optional) :  If given, content 'id' is used for XIMS::Object lookup instead of
#                                       'document_id'
#
# RETURNS
#    $iterator    : instance of XIMS::Iterator::Object
#
# DESCRIPTION
#    Returns an iterator instance to iterate over XIMS::Objects. XIMS::Iterator::Object
#    subclasses Array::Iterator, see it's module documentation for available iterator methods.
#
#    Example use:
#
#    my $iterator = XIMS::Iterator::Object->new(\@ids);
#    while (my $object = $iterator->getNext()) {
#        # do something with $object;
#    }
#
sub new {
    my ($class, $arryref, $cttid) = @_;

    ref($arryref) and ref($arryref) eq "ARRAY" ||
        die "Incorrect Type : First argument must be a reference to an array!\n";

    my $iterator = $class->SUPER::new( $arryref );

    if ( $cttid ) {
        $iterator->{lookup_key} = 'id';
    }
    else {
        $iterator->{lookup_key} = 'document_id';
    }

    return $iterator;
}

sub _getItem {
    my ($self, $iteratee, $index) = @_;
    my $id = $self->SUPER::_getItem( $iteratee, $index );
    return undef unless defined $id;
    my $o = XIMS::Object->new( $self->{lookup_key} => $id );
    defined $o ? $o : undef;
}

1;
