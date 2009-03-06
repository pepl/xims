
=head1 NAME

XIMS::SAX::Filter::Children -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::Children;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::Children;

#
# This is a SAX Filter. This will collect all children of a certain
# object and place them into the stream
#

use strict;
use base qw( XIMS::SAX::Filter::DataCollector );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    XIMS::SAX::Filter::DataCollector->new()

=head3 Parameter

    ?

=head3 Returns

    nothing (????)

=head3 Description

none yet

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    $self->set_tagname("children");

    return;
}



=head2    $filter->handle_data()

=head3 Parameter

    none

=head3 Returns

    nothing

=head3 Description

none yet

=cut

sub handle_data {
    my $self = shift;
    my $cols = $self->get_columns();

    my $provider = $self->get_provider();
    return unless defined $provider and defined $self->{Object};

    # fetch the objects
    my %param = ( -object => $self->{Object} );

    $param{-user}      = $self->get_user() if defined $self->get_user();
    $param{-published} = $self->export()   if defined $self->export();

    $param{-level} = $self->{Level} if defined $self->{Level};
    $param{-objecttypes} = $self->{ObjectTypes}
        if defined $self->{ObjectTypes};

    my $objects = $provider->getChildObjects(%param);
    $self->push_listobject( @{$objects} ) if defined $objects;

    $self->SUPER::handle_data();

    return;
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

Copyright (c) 2002-2009 The XIMS Project.

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
