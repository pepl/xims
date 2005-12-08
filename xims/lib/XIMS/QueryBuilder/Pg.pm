# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::QueryBuilder::Pg;

use strict;
use warnings;

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

    my $bol;
    my $foundmacro = 0;

    use encoding "latin-1";
    my $allowedusernamechars = XIMS::decode( '-A-Za-z0-9צהü‗אבגדוזטחיךכלםמןנסעףפץרשתû‎ÿ_' );

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
        elsif ( $search->[$i] =~ s/^o:([$allowedusernamechars ]+)$/$1/ ) {
            # 'o:x' find object by OWNER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.owned_by_id = " . $search->[$i];
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^c:([$allowedusernamechars ]+)$/$1/ ) {
            # 'c:x' find object by CREATOR
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            $search->[$i] = $bol . "ci_content.created_by_id = " . $search->[$i];
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^u:([$allowedusernamechars ]+)$/$1/ ) {
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
        $self->{criteria} = '(' . join(' ', @{$search}) . ')';
        $self->{criteria} .= ' AND ci_content.published = 1' if $self->{filterpublished};
        return 1;
    }
    else {
        return undef;
    }
}

1;
