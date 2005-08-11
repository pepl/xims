# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AxPointPresentation;

use vars qw($VERSION @ISA);
use strict;
use XIMS::Document;
use XIMS::DataFormat;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Document');

##
#
# SYNOPSIS
#    XIMS::AxPointPresentation->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $axpointpresentation: XIMS::AxPointPresentation instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'AXPML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
