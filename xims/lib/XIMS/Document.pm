# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Document;

use strict;
use vars qw( $VERSION @ISA );

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
use XIMS;
use XIMS::Object;
use XIMS::Entities qw(decode);
@ISA = ('XIMS::Object');


sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    $args{object_type_id} = 2 unless defined $args{object_type_id};
    $args{data_format_id} = 2 unless defined $args{data_format_id};

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    $document->body( [ $body ] )
#
# PARAMETER
#    $body: scalar value of body-string
#    %args: hash, recognized keys:
#         'dontbalance' if set, there will be no attempt to convert the body to a well-balanced string, this may be neccessary
#                       if users don't want their whitespace info munged by tidy.
#
# RETURNS
#    :
#
# DESCRIPTION
#    none yet
#
sub body {
    XIMS::Debug( 5, "called");
    my $self = shift;
    my $body = shift;
    my %args = @_;

    my $retval;

    return $self->SUPER::body() unless $body;

    if ( length $body ) {
        # we only want the default XML-entities to be present
        # this requires a patched version of HTML::Entities %entity2char :-/
#warn "BODY - before entity decoding ", $body;
        $body = XIMS::Entities::decode( $body );
#warn "BODY - after entity decoding ", $body;
        if ( $self->balanced_string( $body ) ) {
            $self->SUPER::body( $body );
            $retval = 1;
        }
        elsif ( not exists $args{dontbalance} ) {
            XIMS::Debug( 3, "not well balanced; trying to balance it" );
            $body = $self->balance_string( $body );
            if ( $self->balanced_string( $body ) ) {
#warn "BODY - after balancing: ", $body;
                $self->SUPER::body( $body );
                $retval = 1;
            }
            else {
                XIMS::Debug( 2, "well balancing failed" );
            }
        }
        else {
            XIMS::Debug( 2, "not well balanced; not trying to due to args" );
        }
    }
    else {
        XIMS::Debug( 3, "wrong args" );
    }

    return $retval;
}


1;
