# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Folder;

use strict;
use base qw( XIMS::Object );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $folder = XIMS::Folder->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from XIMS::Object::new()
#
# RETURNS
#    $folder: instance of XIMS::Folder
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::Folder for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'Container' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
