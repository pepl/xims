
=head1 NAME

XIMS::QueryBuilder::SimpleDB -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::QueryBuilder::SimpleDB;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#$Id$
package XIMS::QueryBuilder::SimpleDB;

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
    my $simpledb = $self->{extraargs}->{simpledb};
    $self->{criteria} = [];
    my @values;

    my @property_list = $simpledb->mapped_member_properties();

    my $propsearchsubquery = ' c.id in (SELECT c.id FROM ci_content c, ci_documents d, cisimpledb_members m, cisimpledb_mempropertyvalues pv WHERE c.document_id = d.id AND m.document_id = d.id AND d.parent_id = ? AND pv.member_id = m.id ';

    my $bol;
    my $foundmacro = 0;

    for ( my $i = 0; $i <= scalar(@{$search})-1; $i++ ) {
        # handle property-searches first
        my $is_field;
        foreach my $property ( @property_list ) {
            my $propertyname = $property->name();
            if ( $search->[$i] =~ s/^$propertyname://i ) {
                $bol = $self->search_boolean( $search, $i );
                push( @values, $simpledb->document_id(), $property->id(),  "%" . lc($search->[$i]) . "%");
                $search->[$i] = $bol . $propsearchsubquery . " AND pv.property_id = ? AND LOWER(pv.value) LIKE ?)";
                $is_field++;
            }
        }
        if ( $search->[$i] =~ s/^id://i ) {
            $bol = $self->search_boolean( $search, $i );
            push( @values, $search->[$i] );
            $search->[$i] = $bol . " d.id = ?";
            $is_field++;
        }
        next if $is_field;

        if ( $search->[$i] ne "AND" && $search->[$i] ne "OR" ) {
            $bol = $self->search_boolean( $search, $i );
            if ( $search->[$i] ne "(" && $search->[$i] ne ")" ) {
                push( @values, "%" . lc($search->[$i]) . "%");
                $search->[$i] = $bol . "pv.property_id IN (SELECT id FROM cisimpledb_member_properties WHERE mandatory = 1) AND lower(pv.value) LIKE lower(?)";
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

