# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CSS;

use strict;
use vars qw( $VERSION @ISA );

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Text');

use XIMS::Text;
use XIMS::ObjectType;
use XIMS::DataFormat;

##
#
# SYNOPSIS
#    XIMS::CSS->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $css: XIMS:: instance
#
# DESCRIPTION
#    Constructor
#

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{object_type_id} = XIMS::ObjectType->new( name => ( split /::/, $class )[-1] )->id() unless defined $args{object_type_id};
        $args{data_format_id} = XIMS::DataFormat->new( name => ( split /::/, $class )[-1] )->id() unless defined $args{data_format_id};
    }
    return $class->SUPER::new( %args );
}

1;
