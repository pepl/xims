# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AnonDiscussionForumContrib;

use strict;
use base qw( XIMS::Document );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub author {
    my $self= shift;
    my $author = shift;
    my $retval;

    if ( defined $author and length $author ) {
        $self->attribute( author => __limit_string_length( $author ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('author');
    }

    return $retval;
}

sub email {
    my $self= shift;
    my $email = shift;
    my $dontcheck = shift;
    my $retval;

    if ( defined $email and length $email ) {
        $self->attribute( email =>  __limit_string_length( $email ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('email');
    }

    return $retval;
}

sub coauthor {
    my $self= shift;
    my $author = shift;
    my $retval;

    if ( defined $author and length $author ) {
        $self->attribute( coauthor =>  __limit_string_length( $author ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('coauthor');
    }

    return $retval;
}

sub coemail {
    my $self= shift;
    my $email = shift;
    my $dontcheck = shift;
    my $retval;

    if ( defined $email and length $email ) {
        $self->attribute( coemail =>  __limit_string_length( $email ) );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('coemail');
    }

    return $retval;
}

sub senderip {
    my $self= shift;
    my $ip = shift;
    my $retval;

    if ( defined $ip and length $ip ) {
        $self->attribute( senderip => $ip );
        $retval = 1;
    }
    else {
        return $self->attribute_by_key('senderip');
    }

    return $retval;
}

# "static" function
# SYNOPSIS:
#
# __limit_string_length( $string, $length );
#
# PARAMETER:
#
# "$string" is the only obligatory paramenter
#
# DESCRIPTION:
#
# the default behaviour is to take a string, strip leading and
# trailing multiple whitespace, returning the first 30 characters as scalar.
# optionally give the wanted stringlength as second argument.
#
sub __limit_string_length {
    my ( $string, $length ) = @_;
    $length = 30 unless defined $length;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    $string = substr($string, 0, $length);

    return $string;
}

1;
