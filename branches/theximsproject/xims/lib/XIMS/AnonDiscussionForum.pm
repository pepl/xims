# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AnonDiscussionForum;

use vars qw( $VERSION @ISA );
use strict;
use XIMS::Folder;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Folder');

##
#
# SYNOPSIS
#    XIMS::AnonDiscussionForum->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $adforum: XIMS::AnonDiscussionForum instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $class = shift;
    my %args = @_;

    $args{object_type_id} = 13 unless defined( $args{object_type_id} );
    $args{data_format_id} = 28 unless defined $args{data_format_id}; 

    return $class->SUPER::new( %args );
}

1;

