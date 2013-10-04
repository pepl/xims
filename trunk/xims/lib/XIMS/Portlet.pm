
=head1 NAME

XIMS::Portlet -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Portlet;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

#$Id$
package XIMS::Portlet;

use common::sense;
use parent qw( XIMS::SymbolicLink );


=pod

The following functions are dummy functions, so we have an interface
for filters in the future :)

=head2 testCondition()

=cut

sub testCondition {
    my ( $self, $condition ) = @_;
    my $retval = 0;

    return $retval unless defined $condition and length $condition;

    # This function should test a condition to be valid. the algorithm
    # may get used to implement the filter itself. the function should
    # parse the condition and if the condition is ok, it should return
    # TRUE! (1)

    return $retval;
}

=pod 

The following three functions place/remove a filter into the body.

=head2 applyFilter()

=cut

sub applyFilter {
    my ( $self, $name, $condition ) = @_;
    my $retval = 0;

    return $retval unless $self->body;

    if ( defined $name and defined $condition ) {

    }
    else {
        XIMS::Debug( 4, "incomplete parameter" );
    }

    return $retval;
}

=head2 removeFilter()

=cut

sub removeFilter {
    my ( $self, $name ) = @_;
    my $retval = 0;

    return $retval unless $self->body;

    if ( defined $name ) {

    }
    else {
        XIMS::Debug( 4, "incomplete parameter" );
    }

    return $retval
}

=head2 updateFilter()

=cut

sub updateFilter {
    my ( $self, $name, $condition ) = @_;
    my $retval = 0;

    return $retval unless $self->body;

    if ( defined $name and defined $condition ) {

    }
    else {
        XIMS::Debug( 4, "incomplete parameter" );
    }

    return $retval
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

