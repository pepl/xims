
=head1 NAME

XIMS::QueryBuilder::OracleInterMedia -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::QueryBuilder::OracleInterMedia;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#$Id$
package XIMS::QueryBuilder::OracleInterMedia;

use common::sense;
use parent qw( XIMS::QueryBuilder );
use XIMS::User;

#use Data::Dumper;




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
    my $self           = shift;
    my $fieldstolookin = $self->{fieldstolookin};
    my $search         = $self->{search};
    $self->{criteria} = [];
    my @values;
    my $ORA_TEXT_RESERVED_CHARS = ',&=?{}\\\[\]-;~|$!>*_%';
    my @IMsearch;
    my @IMsearchVals;
    my $text_query = q{};
    my $bol;
    my $foundmacro = 0;

    my $allowedusernamechars = '-A-Za-z0-9öäüßàáâãåæèçéêëìíîïðñòóôõøùúûýÿ_';

    for ( my $i = 0; $i <= scalar( @{$search} ) - 1; $i++ ) {

        # handle fieldbased-searches first
        my $is_field;
        foreach my $field ( @{$fieldstolookin} ) {
            next if lc($field) eq 'body';   # no LIKE statements with CLOBS...
            if ( $search->[$i] =~ s/^$field://i ) {
                $bol = $self->search_boolean( $search, $i );
                push( @values, "%" . lc( $search->[$i] ) . "%" );
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
            $search->[$i] = $bol
                . "(TRUNC(SYSDATE) - TRUNC(last_modification_timestamp)) < ? + 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^m:(\d*)$/$1/ ) {

            # 'm:x'  was MODIFIED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol
                . "(TRUNC(SYSDATE) - TRUNC(last_modification_timestamp)) < ? + 1 AND ci_content.marked_new = 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^N:(\d*)$/$1/ ) {

            # 'N:x'  was CREATED x days in the past
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol
                . "(TRUNC(SYSDATE) - TRUNC(creation_timestamp)) < ? + 1";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^n:(\d*)$/$1/ ) {

            # 'n:x'  was CREATED x days in the past AND is MARKED_NEW
            $search->[$i] ||= '0';
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol
                . "(TRUNC(SYSDATE) - TRUNC(creation_timestamp)) < ? + 1 AND ci_content.marked_new = 1";
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

        # unfortunately, \w does not match the non-ascii-chars here on
        # most setups - therefore we resort to allow some lower-cased
        # non-ascii latin1 chars...
        elsif ( $search->[$i] =~ s/^o:([$allowedusernamechars ]+)$/$1/ ) {

            # 'o:x' find object by OWNER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user
                ? $user->id()
                : -1;    # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_content.owned_by_id = ? ";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^c:([$allowedusernamechars ]+)$/$1/ ) {

            # 'c:x' find object by CREATOR
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user
                ? $user->id()
                : -1;    # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "ci_content.created_by_id = ? ";
            $foundmacro++;
        }
        elsif ( $search->[$i] =~ s/^u:([$allowedusernamechars ]+)$/$1/ ) {

            # 'u:x' find object by CREATOR or MODIFIER
            my $user = XIMS::User->new( name => $search->[$i] );
            $search->[$i] = $user
                ? $user->id()
                : -1;    # if we cannot resolve the username use an invalid id
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i], $search->[$i] );
            $search->[$i] = $bol
                . "(ci_content.created_by_id = ? OR ci_content.last_modified_by_id = ?)";
            $foundmacro++;
        }

        # these are search operators, not terms:
        elsif ( $search->[$i] !~ /^(?:AND|OR|[()]$)/ ) {

            # search_boolean returns either 'AND ' or ''; For Oracle Text
            # we better use the ACCUMULATE (,) operator instread.
            if ( $self->search_boolean( $search, $i ) ) {
                $text_query .= ',';
            }

            # escape the term, but leave Oracle text's useful group 2
            # operators intact: (? -> fuzzy, $-> stem, ! -> soundex).
            $search->[$i] =~ s/^([\?\$\!])?(.+)$/$1\{$2\}/;
            $text_query .= ' ' . $search->[$i];
        }
        else {
            $text_query .= ' ' . $search->[$i];
        }
    }

    my $rv;

    # hard work done, compose search-condition-string
    if ( length $text_query ) {

        # The following query relies on a Oracle Text Index and a basic
        # section group to be configured for ci_content.

        $self->{criteria}->[0] = '( CONTAINS ( mci, ? , 1 ) > 0 )';

        push( @values, << "EOQ");
 ( ( ( ( $text_query ) within title    ) * 6 )
OR ( ( ( $text_query ) within keywords ) * 4 )
OR ( ( ( $text_query ) within abstract ) * 3 )
OR ( ( ( $text_query ) within author   ) * 2 )
OR (   ( $text_query ) within body     )
OR     ( $text_query ) )
EOQ

        $self->{properties} = [
            'document_id',                 'id',
            'location',                    'title',
            'object_type_id',              'data_format_id',
            'attributes',                  'abstract',
            'last_modification_timestamp', 'creation_timestamp',
            'last_publication_timestamp',  'language_id',
            'published',                   'marked_new',
            'locked_by_id',                'locked_time',
            'lob_length',                  'score(1) s'
        ];
        $self->{order} = "score(1) DESC";
        $rv = 1;
    }
    elsif ( $foundmacro > 0 or scalar @{$fieldstolookin} > 0 ) {
        $self->{criteria}->[0] .= '(' . join( ' ', @{$search} ) . ')';
        $rv = 1;
    }

    if ( $rv == 1 ) {
        $self->{criteria}->[0] .= ' AND ci_content.published = 1'
            if $self->{filterpublished};
        push( @{ $self->{criteria} }, @values );
    }
    return $rv;
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

