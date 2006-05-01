# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibraryItem::DocBookXML;

use strict;
use base qw( XIMS::VLibraryItem XIMS::DocBookXML );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $vlibitem = XIMS::VLibraryItem::DocBookXML->new( [ %args ] )
#
# PARAMETER
#    %args                  (optional) :  Takes the same arguments as its super class XIMS::VLibrayItem
#
# RETURNS
#    $vlibitem    : instance of XIMS::VLibraryItem::DocBookXML
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::VLibraryItem::DocBookXML for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'DocBookXML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
