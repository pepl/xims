# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$

package XIMS::QueryBuilder::OracleInterMedia;

use strict;
use vars qw($VERSION @ISA);

@ISA = ('XIMS::QueryBuilder');
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use XIMS::QueryBuilder;

##
#
# SYNOPSIS
#    $qb->build( $fieldstolookin );
#
# PARAMETER
#    $fieldstolookin : array-ref of SQL-field names to be explicitly be able to look in
#                      like field:value for example, which will results in an SQL-condition
#                      similar to 'AND field LIKE '%value%'
#
# RETURNS
#    hash-ref containing the following keys:
#    properties => list of content object properties to be retrieved
#    criteria => search criteria to be ANDed to a WHERE-clause:
#
# DESCRIPTION
#
#
sub build {
    XIMS::Debug( 5, "called" );

    my $self = shift;
    my $fieldstolookin = shift;
    my $search = $self->{search};
    my @IMsearch;
    my @search;
    my $bol;

    my %retval;

    # avoid too complex queries
    return unless ( scalar(@{$search}) < 10 );

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle fieldbased-searches first
        my $is_field;
        foreach my $field ( @{$fieldstolookin} ) {
            next if lc($field) eq 'body'; # no LIKE statements with CLOBS...

            if ( $search->[$i] =~ s/^$field://i ) {
                $bol = $self->search_boolean( $search, $i );
                $search[$i] = $bol . "LOWER($field) LIKE '%". lc($search->[$i]) . "%'" ;
                $is_field++;
            }
        }
        next if $is_field;

        if ( $search->[$i] =~ s/^M:(\d*)$/$1/ ) {
            # 'M:x'  was MODIFIED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . $search->[$i] + 1 . " > TRUNC(SYSDATE) - TRUNC(last_modification_timestamp)";
            $retval{order} = "last_modification_timestamp DESC";
        }
        elsif ( $search->[$i] =~ s/^m:(\d*)$/$1/ ) {
            # 'm:x'  was MODIFIED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . $search->[$i] + 1 . " > TRUNC(SYSDATE) - TRUNC(last_modification_timestamp) AND ci_content.marked_new = 1";
            $retval{order} = "last_modification_timestamp DESC";
        }
        elsif ( $search->[$i] =~ s/^N:(\d*)$/$1/ ) {
            # 'N:x'  was CREATED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . $search->[$i] + 1 . " > TRUNC(SYSDATE) - TRUNC(creation_timestamp)";
            $retval{order} = "creation_timestamp DESC";
        }
        elsif ( $search->[$i] =~ s/^n:(\d*)$/$1/ ) {
            # 'n:x'  was CREATED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol .  $search->[$i] + 1 . " > TRUNC(SYSDATE) - TRUNC(creation_timestamp) AND ci_content.marked_new = 1";
            $retval{order} = "creation_timestamp DESC";
        }
        elsif ( $search->[$i] =~ s/^i:(\d+)$/$1/ ) {
            # 'i:x' find object by ID
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.id = " . $search->[$i];
        }
        elsif ( $search->[$i] =~ s/^I:(\d+)$/$1/ ) {
            # 'i:x' find object by DOCUMENT_ID
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_documents.id = " . $search->[$i];
        }
        elsif ( $search->[$i] =~ s/^o:(\w+|\d+)$/$1/ ) {
            # 'o:x' find object by OWNER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.owned_by_id = " . $search->[$i];
        }
        elsif ( $search->[$i] =~ s/^c:(\w+|\d+)$/$1/ ) {
            # 'c:x' find object by CREATOR
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.created_by_id = " . $search->[$i];
        }
        elsif ( $search->[$i] =~ s/^u:(\w+|\d+)$/$1/ ) {
            # 'u:x' find object by CREATOR or MODIFIER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "(ci_content.created_by_id = " . $search->[$i] . " OR ci_content.last_modified_by_id = " . $search->[$i] . ")";
        }
        elsif ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            push @IMsearch, ( $bol, ( '{' . $search->[$i] . '}' ) );
        }
        else {
            push @IMsearch, ( $search->[$i] );
        }
    }

    # hard work done, compose search-condition-string
    if ( @IMsearch ) {
        $retval{criteria} = "( CONTAINS ( mci, \'( ( ( (" . join( ' ', @IMsearch ) . " ) within title ) * 2 )" .
                                               " OR ( ( (" . join( ' ', @IMsearch ) . " ) within author ) * 0.5 )" .
                                               " OR ( ( (" . join( ' ', @IMsearch ) . " ) within keywords ) * 0.5 )" .
                                               " OR ( ( (" . join( ' ', @IMsearch ) . " ) within body ) * 0.1 )" .
                                               " OR ( ("   . join( ' ', @IMsearch ) . " )  * 0.1) )\', 1 ) > 0 )";

        $retval{properties} = [ 'document_id', 'id', 'location', 'title', 'object_type_id', 'data_format_id', 'attributes',
                             'abstract', 'last_modification_timestamp', 'creation_timestamp', 'last_publication_timestamp', 'language_id', 'published',
                             'marked_new', 'locked_by_id', 'locked_time', 'lob_length', 'score(1) s' ];
        $retval{order} = "score(1) DESC";
    }
    else {
        $retval{criteria} = '(' . join(' ', @{$search}) . ')';
    }


    XIMS::Debug( 5, 'done' );
    return \%retval;
}

1;
