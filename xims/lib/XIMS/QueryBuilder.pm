# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::QueryBuilder;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

##
#
# SYNOPSIS
#    $qb = XIMS::QueryBuilder->new( { search => $search, [ allowed => $to_be_qr-compiled_string_of_allowed_chars] );
#
# PARAMETERS
#    search: the search string
#    allowed: string of allowed chars that are filtered; chars like '/','(','-',... have to be escaped
#    because this string is to be compiled with qr// and used in a /[^$allowed ]/ regex construct
#
# RETURNS
#    returns the query-builder-instance
#
# DESCRIPTION
#
#
#
sub new {
    XIMS::Debug( 5, 'called');
    my $class = shift;
    my $args = shift;

    my $self;
    if ( ref $args and exists $args->{search} ) {
        my $search = _search_arrayref( _clean_search_string( $args->{search}, qr/$args->{allowed}/ ) );
        $self = bless { search => $search, }, $class;
    }

    return $self;
}

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

    my $retval; #return value

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

