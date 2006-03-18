# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::QueryBuilder::OracleInterMedia;

use strict;
# use warnings;

our $VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use base 'XIMS::QueryBuilder';
use XIMS::User;

##
#
# SYNOPSIS
#    $qb->_build();
#
# PARAMETER
#    none
#
# RETURNS
#    1 on success, undef on failure
#
# DESCRIPTION
#
# Helper method that fills up $self->{criteria}, $self->{properties}, and $self->{order} on success
#
#
sub _build {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $fieldstolookin = $self->{fieldstolookin};
    my $search = $self->{search};
    $self->{criteria} = [];
    my @values;

    my @IMsearch;
    my @IMsearchVals;

    my $bol;
    my $foundmacro = 0;

    use encoding "latin-1";
    my $allowedusernamechars = XIMS::decode( '-A-Za-z0-9צהü‗אבגדוזטחיךכלםמןנסעףפץרשתû‎ÿ_' );

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle fieldbased-searches first
        my $is_field;
        foreach my $field ( @{$fieldstolookin} ) {
            next if lc($field) eq 'body'; # no LIKE statements with CLOBS...
            if ( $search->[$i] =~ s/^$field://i ) {
                $bol = $self->search_boolean( $search, $i );
                push( @values, "%". lc($search->[$i]) . "%" );
                $search->[$i] = $bol . "LOWER($field) LIKE ?";
                $is_field++;
            }
        }
        next if $is_field;

        if ( $search->[$i] =~ s/^M:(\d*)$/$1/ ) {
            # 'M:x'  was MODIFIED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "(TRUNC(SYSDATE) - TRUNC(last_modification_timestamp)) < ? + 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^m:(\d*)$/$1/ ) {
            # 'm:x'  was MODIFIED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "(TRUNC(SYSDATE) - TRUNC(last_modification_timestamp)) < ? + 1 AND ci_content.marked_new = 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^N:(\d*)$/$1/ ) {
            # 'N:x'  was CREATED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "(TRUNC(SYSDATE) - TRUNC(creation_timestamp)) < ? + 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^n:(\d*)$/$1/ ) {
            # 'n:x'  was CREATED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "(TRUNC(SYSDATE) - TRUNC(creation_timestamp)) < ? + 1 AND ci_content.marked_new = 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^i:(\d+)$/$1/ ) {
            # 'i:x' find object by ID
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.id = " . $search->[$i];
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^I:(\d+)$/$1/ ) {
            # 'i:x' find object by DOCUMENT_ID
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_documents.id = ? ";
            $foundmacro++;
        }
        # unfortunately, \w does not match the non-ascii-chars here on most setups - therefore
        # we resort to allow some lower-cased non-ascii latin1 chars...
        elsif ( $search->[$i] =~ s/^o:([$allowedusernamechars ]+)$/$1/ ) {
            # 'o:x' find object by OWNER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_content.owned_by_id = ? ";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^c:([$allowedusernamechars ]+)$/$1/ ) {
            # 'c:x' find object by CREATOR
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_content.created_by_id = ? ";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^u:([$allowedusernamechars ]+)$/$1/ ) {
            # 'u:x' find object by CREATOR or MODIFIER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i], $search->[$i] );
            $search->[$i] = $bol . "(ci_content.created_by_id = ? OR ci_content.last_modified_by_id = ?)";
            $foundmacro++;
        }
        elsif ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            push( @IMsearch, ( $bol, '{?}' ) );
            push( @IMsearchVals, $search->[$i] );
        }
        else {
            push( @IMsearch, $search->[$i] );
        }
    }

    my $rv;
    # hard work done, compose search-condition-string
    if ( scalar @IMsearch > 0 ) {
        # The following query relies on a Oracle Text Index and a basic section group to be configured for ci_content.
        # Instructions on how to that can be found at $xims_home/sql/Oracle/OracleInterMedia.txt
        #
        my $IMsearchplaceholders = join(' ', @IMsearch);
        $self->{criteria}->[0] = "( CONTAINS ( mci, \'( ( ( (" . $IMsearchplaceholders . " ) within title ) * 6 )" .
                                               " OR ( ( (" . $IMsearchplaceholders . " ) within keywords ) * 4 )" .
                                               " OR ( ( (" . $IMsearchplaceholders . " ) within abstract ) * 3 )" .
                                               " OR ( ( (" . $IMsearchplaceholders . " ) within author ) * 2 )" .
                                               " OR ( ( " . $IMsearchplaceholders . " ) within body )" .
                                               " OR ( "   . $IMsearchplaceholders . " ) )\', 1 ) > 0 )";
        push( @values, (@IMsearchVals) x 6 );
        
        $self->{properties} = [ 'document_id', 'id', 'location', 'title', 'object_type_id', 'data_format_id', 'attributes',
                             'abstract', 'last_modification_timestamp', 'creation_timestamp', 'last_publication_timestamp', 'language_id', 'published',
                             'marked_new', 'locked_by_id', 'locked_time', 'lob_length', 'score(1) s' ];
        $self->{order} = "score(1) DESC";
        $rv = 1;
    }
    elsif ( $foundmacro > 0 or scalar @{$fieldstolookin} > 0 ) {
        $self->{criteria}->[0] .= '(' . join(' ', @{$search}) . ')';
        $rv = 1;
    }

    if ( $rv == 1 ) {
        $self->{criteria}->[0] .= ' AND ci_content.published = 1' if $self->{filterpublished};
        push( @{$self->{criteria}}, @values );
    }

    return $rv;
}

1;
