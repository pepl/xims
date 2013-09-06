
=head1 NAME

XIMS::QueryBuilder -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::QueryBuilder;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::QueryBuilder;

use common::sense;

# use warnings;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2    $qb = XIMS::QueryBuilder->new( { search => $search,
                      [ allowed => $to_be_qr-compiled_string_of_allowed_chars,]
                      [ fieldstolookin => [qw(title abstract body)] ] } );

=head3 Parameter

    search                     : The search string
    allowed        (optional   : String of allowed chars that are filtered;
                                 chars like '/','(','-',... have to be escaped
                                 because this string is compiled with qr//
                                 and used in a /[^$allowed ]/ regex construct
    fieldstolookin (optional)  : Array-ref of SQL-field names to be explicitly
                                looked in (e.g. field:value) resulting
                                 in a SQL-condition similar to 'AND field LIKE '%value%'
    filterpublished (optional) : If true, filters published objects


=head3 Returns

    An instance of XIMS::QueryBuilder with a 'criteria' property on success,
    undef on failure

=head3 Description


Builds SQL search criteria out of a search string. Search syntax and search
macros are described in the XIMS User's Reference

=cut

sub new {
    XIMS::Debug( 5, 'called' );
    my $class = shift;
    my $args  = shift;

    my $self;
    if ( ref $args and exists $args->{search} ) {
        my $search;
        if ( defined $args->{allowed} ) {
            $search =
              XIMS::tokenize_string(
                _clean_search_string( $args->{search}, qr/$args->{allowed}/ ) );
        }
        else {
            $search =
              XIMS::tokenize_string( _clean_search_string( $args->{search} ) );
        }
        $self = bless {
            search          => $search,
            fieldstolookin  => $args->{fieldstolookin},
            filterpublished => $args->{filterpublished},
            extraargs       => $args->{extraargs}
        }, $class;
        $self->_build() ? return $self : return;
    }

    return $self;
}

=head2 criteria()

=cut

sub criteria        { $_[0]->{criteria} }

=head2 properties()

=cut

sub properties      { $_[0]->{properties} }

=head2 order()

=cut

sub order           { $_[0]->{order} }

=head2 filterpublished()

=cut

sub filterpublished { $_[0]->{filterpublished} }

=head2    search_boolean( $arryref, $arryindex );

=head3 Parameter

    $arryref, $arryindex:

=head3 Returns

    $retval: 'AND', if conditions fit

=head3 Description


helper for buildSearchConditions()

=cut

sub search_boolean {
    XIMS::Debug( 5, 'called' );
    my $self   = shift;
    my $search = shift;
    my $i      = shift;

    my $retval = '';    #return value

    if (   $i > 0
        && $search->[ $i - 1 ] ne "("
        && $search->[ $i - 1 ] ne "AND"
        && $search->[ $i - 1 ] ne "OR"
        && $search->[ $i - 1 ] ne "AND ("
        && $search->[$i]       ne ")" )
    {

        $retval = "AND ";
    }

    return $retval;
}

=head2    _clean_search_string( $searchstring, $allowedcharsregex );

=head3 Parameter

    $searchstring:
    $allowedcharsregex: pre-compiled regex to filter allowed chars

=head3 Returns

    $retval: cleaned searchstring

=head3 Description




=cut

sub _clean_search_string {
    XIMS::Debug( 5, 'called' );
    my $retval  = shift;
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

