# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SymbolicLink;

use vars qw($VERSION @ISA);
use strict;
use XIMS::Object;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Object');


##
# SYNOPSIS
#    my $target = $symlink->target( [ $object ] );
#
# PARAMETER
#    $object    (optional) :  XIMS::Object instance of new target
#
# RETURNS
#    $target : XIMS::Object where "symname_to_doc_id" property points to
#
# DESCRIPTION
#    Sets/Gets target of symbolic link
#
sub target {
    my $self = shift;
    my $target = shift;

    if ( $target ) {
        $self->symname_to_doc_id( $target->document_id() );
        return $target;
    }
    else {
        return XIMS::Object->new( document_id => $self->symname_to_doc_id() );
    }
}

1;
