# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::XSPScript;

use strict;
use vars qw($VERSION @ISA);
use XIMS::XML;
use XIMS::DataFormat;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::XML');

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

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XSP' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

1;
