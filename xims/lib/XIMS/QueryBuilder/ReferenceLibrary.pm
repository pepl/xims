
=head1 NAME

XIMS::QueryBuilder::ReferenceLibrary

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::QueryBuilder::ReferenceLibrary;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#$Id$
package XIMS::QueryBuilder::ReferenceLibrary;

use common::sense;
use parent qw( XIMS::QueryBuilder );
use XIMS::User;




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
    my $reflib = $self->{extraargs}->{reflib};
    $self->{criteria} = [];
    my @values;

    my @property_list = $reflib->reference_properties();

    my $propsearchsubquery = ' c.id in (SELECT c.id FROM ci_content c, ci_documents d, cireflib_references r, cireflib_ref_propertyvalues pv WHERE c.document_id = d.id AND r.document_id = d.id AND d.parent_id = ? AND pv.reference_id = r.id ';
    my $serialsearchsubquery = ' c.id in (SELECT c.id FROM ci_content c, ci_documents d, cireflib_references r, cireflib_serials sr WHERE c.document_id = d.id AND r.document_id = d.id AND d.parent_id = ? AND r.serial_id = sr.id ';

    my $bol;
    my $foundmacro = 0;

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle property-searches first
        my $is_field;
        foreach my $property ( @property_list ) {
            my $propertyname = $property->name();
            if ( $search->[$i] =~ s/^$propertyname://i ) {
                $bol = $self->search_boolean( $search, $i );
                push( @values, $reflib->document_id(), $property->id(),  "%" . lc($search->[$i]) . "%");
                $search->[$i] = $bol . $propsearchsubquery . " AND pv.property_id = ? AND LOWER(pv.value) LIKE ?)";
                $is_field++;
            }
        }
        if ($search->[$i] =~ s/^serial://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, $reflib->document_id(), "%" . lc($search->[$i]) . "%");
            $search->[$i] = $bol . $serialsearchsubquery . " AND LOWER(sr.title) LIKE ?)";
            $is_field++;
        }
        elsif ($search->[$i] =~ s/^type://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, "%" . lc($search->[$i]) . "%");
            $search->[$i] = $bol . " r.reference_type_id IN (SELECT id FROM cireflib_reference_types WHERE LOWER(name) LIKE ?)";
            $is_field++;
        }
        elsif ($search->[$i] =~ s/^lastname://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, lc $search->[$i] );
            $search->[$i] = $bol . "(am.author_id in (SELECT id FROM cilib_authors WHERE lower(lastname) = ?))";
            $is_field++;
        }
        elsif ($search->[$i] =~ s/^firstname://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, lc $search->[$i] );
            $search->[$i] = $bol . "(am.author_id in (SELECT id FROM cilib_authors WHERE lower(firstname) = ?))";
            $is_field++;
        }
        elsif ($search->[$i] =~ s/^author_id://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . "(am.author_id = ?)";
            $is_field++;
        }

        next if $is_field;

        if ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            if ( $search->[$i] ne "(" && $search->[$i] ne ")" ) {
                push( @values, "%" . lc($search->[$i]) . "%");
                $search->[$i] = $bol . "(am.author_id in (SELECT id FROM cilib_authors WHERE lower(lastname) LIKE ?))";
            }
            elsif ( $search->[$i] eq "(" || $search->[$i] eq ")" ) {
               $search->[$i] = $bol . $search->[$i];
            }
        }
    }

    # hard work done, compose search-condition-string
    $self->{criteria}->[0] = '(' . join(' ', @{$search}) . ')';
    $self->{criteria}->[0] .= ' AND ci_content.published = 1' if $self->{filterpublished};
    push( @{$self->{criteria}}, @values );

    return 1;
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

Copyright (c) 2002-2015 The XIMS Project.

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

