# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::TAN_List;

use strict;
use vars qw( $VERSION @ISA );

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = ('XIMS::Text');

use XIMS::Text;

##
#
# SYNOPSIS
#    XIMS::TAN_List->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $tan_list: XIMS::TAN_List instance
#
# DESCRIPTION
#    Constructor
#

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'TAN_List' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    XIMS::TAN_List->number()
#
# PARAMETER
#    none
#
# RETURNS
#    Number of TANs in List
#
# DESCRIPTION
#
#
sub number {
    my $self = shift;
    my $number = shift;
    my $retval;

    if ( defined $number and length $number ) {
        $self->attribute( number => $number );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('number');
    }

    return $retval;
}

##
#
# SYNOPSIS
#    XIMS::TAN_List->create_TANs()
#
# PARAMETER
#    number of TANs to create
#
# RETURNS
#
#    coma seperated string of TANs
#
# DESCRIPTION
#
#
sub create_TANs {
    XIMS::Debug ( 5, "called" );
    my $self = shift;
    my $number = shift;

    my %tanlist;
    my $tanlist;
    my $key;
    my $TAN_length = 8; # Length of created TANs
    my @TAN_charpool = qw( 1 2 3 4 5 6 7 8 9 ); # Characters/Numbers which the TAN is build of
    my $TAN;
    my $i;
    srand();

    while ( $number ) {
        $TAN = '';
        for ($i = $TAN_length; $i > 0; $i--) {
            $TAN .= $TAN_charpool[ rand( @TAN_charpool ) ];
        }
        redo if $tanlist{$TAN}; # if TAN already exists redo creation of TAN
        $tanlist{$TAN} = 1;
        $number--;
    }

    foreach $key ( keys( %tanlist ) ) {
        if ( $tanlist ) {
            $tanlist .= ",$key";
        }
        else {
            $tanlist = $key;
        }
    }

    return $tanlist;
}

##
#
# SYNOPSIS
#    XIMS::TAN_List->verify()
#
# PARAMETER
#    TAN
#
# RETURNS
#    true if TAN is in the list
#    false if TAN is not in the list
#
# DESCRIPTION
#
#
sub verify {
    my $self = shift;
    my $TAN_to_verify = shift;

}

1;
