# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

#$Id$
package XIMS::QueryBuilder::Pg;

use strict;
use vars qw($VERSION @ISA);

@ISA = ('XIMS::QueryBuilder');
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use XIMS::QueryBuilder;
use XIMS::User;

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
    my %retval;

    my $bol;
    my $foundmacro = 0;
    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle fieldbased-searches first
        my $is_field;
        foreach my $field ( @{$fieldstolookin} ) {
            if ( $search->[$i] =~ s/^$field://i ) {
                $bol = $self->search_boolean( $search, $i );
                $search->[$i] = $bol . "LOWER($field) LIKE '%". lc($search->[$i]) . "%'";
                $is_field++;
            }
        }
        next if $is_field;

        if ( $search->[$i] =~ s/^M:(\d*)$/$1/ ) {
            # 'M:x'  was MODIFIED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "date(now()) - date(last_modification_timestamp) < " . $search->[$i] . "+1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^m:(\d*)$/$1/ ) {
            # 'm:x'  was MODIFIED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "date(now()) - date(last_modification_timestamp) < " . $search->[$i] . "+1"
                                 . " AND ci_content.marked_new = 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^N:(\d*)$/$1/ ) {
            # 'N:x'  was CREATED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "date(now()) - date(creation_timestamp) < " . $search->[$i] . "+1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^n:(\d*)$/$1/ ) {
            # 'n:x'  was CREATED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "date(now()) - date(creation_timestamp) < " . $search->[$i] . "+1"
                                 . " AND ci_content.marked_new = 1";
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
            $search->[$i] = $bol . "ci_documents.id = " . $search->[$i];
            $foundmacro++;
        }
        # unfortunately, \w does not match the non-ascii-chars here on most setups - therefore
        # we resort to allow some lower-cased non-ascii latin1 chars...
        elsif ( $search->[$i] =~ s/^o:([-A-Za-z0-9�������������������������������_]+)$/$1/ ) {
            # 'o:x' find object by OWNER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.owned_by_id = " . $search->[$i];
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^c:([-A-Za-z0-9�������������������������������_]+)$/$1/ ) {
            # 'c:x' find object by CREATOR
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.created_by_id = " . $search->[$i];
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^u:([-A-Za-z0-9�������������������������������_]+)$/$1/ ) {
            # 'u:x' find object by CREATOR or MODIFIER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "(ci_content.created_by_id = " . $search->[$i] . " OR ci_content.last_modified_by_id = " . $search->[$i] . ")";
            $foundmacro++;
        }

        elsif ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            if ( $search->[$i] ne "(" && $search->[$i] ne ")" ) {
                # $search->[$i] = $bol . "( (" . $search->[$i] . " within title) * 10 OR (" . $search->[$i] . " within author) * 2 OR (" . $search->[$i]  . " within keywords) * 6 OR (" . $search->[$i] . " * 0.1) )";
                my @temp;
                for ( @{$fieldstolookin} ) {
                    push (@temp, "LOWER($_) LIKE '%" . lc($search->[$i]) . "%'");
                }
                $search->[$i] = $bol . "(" . join(" OR ", @temp) . ")";
            }
            elsif ( $search->[$i] eq "(" || $search->[$i] eq ")" ) {
               $search->[$i] = $bol . $search->[$i];
            }
        }
    }

    # hard work done, compose search-condition-string
    if ( $foundmacro > 0 or scalar @{$fieldstolookin} > 0 ) {
        $retval{criteria} = '(' . join(' ', @{$search}) . ')';
    }
    else {
        return undef;
    }

    return \%retval;
}

1;
