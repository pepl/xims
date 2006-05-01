# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::QueryBuilder;

use strict;
# use warnings;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    $qb = XIMS::QueryBuilder->new( { search => $search,
#                                   [ allowed => $to_be_qr-compiled_string_of_allowed_chars,]
#                                   [ fieldstolookin => [qw(title abstract body)] ] } );
#
# PARAMETERS
#    search                     : The search string
#    allowed        (optional   : String of allowed chars that are filtered; chars like '/','(','-',... have to be escaped
#                                 because this string is compiled with qr// and used in a /[^$allowed ]/ regex construct
#    fieldstolookin (optional)  : Array-ref of SQL-field names to be explicitly looked in (e.g. field:value) resulting
#                                 in a SQL-condition similar to 'AND field LIKE '%value%'
#    filterpublished (optional) : If true, filters published objects
#
#
# RETURNS
#    An instance of XIMS::QueryBuilder with a 'criteria' property on success, undef on failure
#
# DESCRIPTION
#
# Builds SQL search criteria out of a search string. Search syntax and search macros are described in the XIMS User's Reference
#
sub new {
    XIMS::Debug( 5, 'called');
    my $class = shift;
    my $args = shift;

    my $self;
    if ( ref $args and exists $args->{search} ) {
        my $search;
        if ( defined $args->{allowed} ) {
            $search = _search_arrayref( _clean_search_string( $args->{search}, qr/$args->{allowed}/ ) );
        }
        else {
            $search = _search_arrayref( _clean_search_string( $args->{search} ) );
        }
        $self = bless { search => $search, fieldstolookin => $args->{fieldstolookin}, filterpublished => $args->{filterpublished}, extraargs => $args->{extraargs} }, $class;
        $self->_build() ? return $self : return undef;
    }

    return $self;
}

sub criteria { $_[0]->{criteria} }
sub properties { $_[0]->{properties} }
sub order { $_[0]->{order} }
sub filterpublished { $_[0]->{filterpublished} }

##
#
# SYNOPSIS
#    search_boolean( $arryref, $arryindex );
#
# PARAMETER
#    $arryref, $arryindex:
#
# RETURNS
#    $retval: 'AND', if conditions fit
#
# DESCRIPTION
#
# helper for buildSearchConditions()
#
sub search_boolean {
    XIMS::Debug( 5, 'called');
    my $self = shift;
    my $search = shift;
    my $i = shift;

    my $retval = ''; #return value

    if ( $i > 0
            && $search->[$i-1] ne "("
            && $search->[$i-1] ne "AND"
            && $search->[$i-1] ne "OR"
            && $search->[$i-1] ne "AND ("
            && $search->[$i] ne ")" ) {

        $retval = "AND ";
    }

    return $retval;
}

##
#
# SYNOPSIS
#    _search_arrayref( $searchstring );
#
# PARAMETER
#    $searchstring:
#
# RETURNS
#    $retval: array-ref of search-tokens
#
# DESCRIPTION
#
#
#
sub _search_arrayref {
    XIMS::Debug( 5, 'called');
    my $search = shift;

    my $retval = [];

    my @blocks = split(/ *\" */, $search);

    # deal with quotes
    my $in_quote = 0;
    for my $part ( @blocks ) {
        if ( $in_quote == 0 ) {
            push(@{$retval}, split(' ', $part)) if $part;
        }
        else {
            push(@{$retval}, $part) if $part;
        }
        $in_quote = ++$in_quote % 2;
    }

    return $retval;
}


##
#
# SYNOPSIS
#    _clean_search_string( $searchstring, $allowedcharsregex );
#
# PARAMETER
#    $searchstring:
#    $allowedcharsregex: pre-compiled regex to filter allowed chars
#
# RETURNS
#    $retval: cleaned searchstring
#
# DESCRIPTION
#
#
#
sub _clean_search_string {
    XIMS::Debug( 5, 'called');
    my $retval = shift;
    my $allowed = shift;

    $retval =~ s/[^$allowed ]//g if defined $allowed;
    $retval =~ s/^\s+//;
    $retval =~ s/\s+$//;
    $retval =~ s/\*+/%/g;
    $retval =~ s/([a-zA-Z]+):"([^"]+)"/"$1:$2"/g;
    $retval =~ s/\(/( /g;
    $retval =~ s/\)/ )/g;

    return $retval;
}

1;

