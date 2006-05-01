# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibraryItem::URLLink;

use strict;
use base qw( XIMS::VLibraryItem XIMS::URLLink );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $vlibitem = XIMS::VLibraryItem::URLLink>new( [ %args ] )
#
# PARAMETER
#    %args                  (optional) :  Takes the same arguments as its super class XIMS::VLibrayItem
#
# RETURNS
#    $vlibitem    : instance of XIMS::VLibraryItem::URLLink
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::VLibraryItem::URLLink for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'URL' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
