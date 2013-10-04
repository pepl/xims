
=head1 NAME

XIMS::QueryBuilder::Pg

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::QueryBuilder::Pg;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#$Id$
package XIMS::QueryBuilder::Pg;

use strict; # common::sense isn’t always best :)
use parent qw( XIMS::QueryBuilder );
use XIMS::User;
use Time::Piece;




=head2    $qb->_build();

=head3 Parameter

    none

=head3 Returns

    1 on success, undef on failure

=head3 Description


Helper method that fills up $self->{criteria}, $self->{properties},
and $self->{order} on success


=cut

sub _build {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $fieldstolookin = $self->{fieldstolookin};
    my $search = $self->{search};
    $self->{criteria} = [];
    my @values;

    my $bol;
    my $foundmacro = 0;

    my $now = localtime();

    my $allowedusernamechars = '-A-Za-z0-9öäüßàáâãåæèçéêëìíîïðñòóôõøùúûýÿ_';

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle fieldbased-searches first
        my $is_field;
        foreach my $field ( @{$fieldstolookin} ) {
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
            # Optimizer for Pg < 8 does not use an index even
            # for last_modification_timestamp > now() - interval '2 day' 
            # Therefore we provide the date literal here. 
            $search->[$i] ||= '1';
            $search->[$i] = $now - $search->[$i] * 86400;
            $search->[$i] = $search->[$i]->datetime();
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "last_modification_timestamp > ?";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^m:(\d*)$/$1/ ) {
            # 'm:x'  was MODIFIED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '1';
            $search->[$i] = $now - $search->[$i] * 86400;
            $search->[$i] = $search->[$i]->datetime();
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "last_modification_timestamp > ?"
                                 . " AND ci_content.marked_new = 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^N:(\d*)$/$1/ ) {
            # 'N:x'  was CREATED x days in the past
            $search->[$i] ||= '1';
            $search->[$i] = $now - $search->[$i] * 86400;
            $search->[$i] = $search->[$i]->datetime();
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "creation_timestamp > ?";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^n:(\d*)$/$1/ ) {
            # 'n:x'  was CREATED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '1';
            $search->[$i] = $now - $search->[$i] * 86400;
            $search->[$i] = $search->[$i]->datetime();
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "creation_timestamp > ?"
                                 . " AND ci_content.marked_new = 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^i:(\d+)$/$1/ ) {
            # 'i:x' find object by ID
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_content.id = ?";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^I:(\d+)$/$1/ ) {
            # 'i:x' find object by DOCUMENT_ID
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_documents.id = ?";
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
            $search->[$i] = $bol . "ci_content.owned_by_id = ?";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^c:([$allowedusernamechars ]+)$/$1/ ) {
            # 'c:x' find object by CREATOR
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user ? $user->id() : -1; # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_content.created_by_id = ?";
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
            if ( $search->[$i] ne "(" && $search->[$i] ne ")" ) {
                # $search->[$i] = $bol . "( (" . $search->[$i] . " within title) * 10 OR (" . $search->[$i] . " within author) * 2 OR (" . $search->[$i]  . " within keywords) * 6 OR (" . $search->[$i] . " * 0.1) )";
                my @temp;
                my @tempvalues;
                for ( @{$fieldstolookin} ) {
                    push (@temp, "LOWER($_) LIKE ? ");
                    push (@tempvalues, "%" . lc($search->[$i]) . "%");
                }
                $search->[$i] = $bol . "(" . join(" OR ", @temp) . ")";
                push( @values, @tempvalues);
            }
            elsif ( $search->[$i] eq "(" || $search->[$i] eq ")" ) {
               $search->[$i] = $bol . $search->[$i];
            }
        }
    }

    # hard work done, compose search-condition-string
    if ( $foundmacro > 0 or scalar @{$fieldstolookin} > 0 ) {
        $self->{criteria}->[0] = '(' . join(' ', @{$search}) . ')';
        $self->{criteria}->[0] .= ' AND ci_content.published = 1' if $self->{filterpublished};
        push( @{$self->{criteria}}, @values );
        return 1;
    }
    else {
        return;
    }
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

