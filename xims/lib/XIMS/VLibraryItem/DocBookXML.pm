# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibraryItem::DocBookXML;

use strict;
use vars qw( $VERSION @ISA );
use XIMS::VLibraryItem;
use XIMS::sDocBookXML;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::VLibraryItem', 'XIMS::sDocBookXML');

##
#
# SYNOPSIS
#    my $vlibitem = XIMS::VLibraryItem::sDocBookXML->new( [ %args ] )
#
# PARAMETER
#    %args                  (optional) :  Takes the same arguments as its super class XIMS::VLibrayItem
#
# RETURNS
#    $vlibitem    : instance of XIMS::VLibraryItem::sDocBookXML
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::VLibraryItem::sDocBookXML for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'sDocBookXML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
