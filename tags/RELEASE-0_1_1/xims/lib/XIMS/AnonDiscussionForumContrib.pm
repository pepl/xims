# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::AnonDiscussionForumContrib;

use vars qw( $VERSION @ISA );
use strict;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
use XIMS::Document;

@ISA = ('XIMS::Document');


sub new {
    my $class   = shift;
    my %args = @_;

    $args{object_type_id} = 14 unless defined( $args{object_type_id} );

    my $self = $class->SUPER::new( %args );
    return $self;
}

sub author {
    my $self= shift;
    my $author = shift;
    my $retval;

    if ( length $author ) {
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

    if ( length $email ) {
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

    if ( length $author ) {
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

    if ( length $email ) {
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

    if ( length $ip ) {
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
