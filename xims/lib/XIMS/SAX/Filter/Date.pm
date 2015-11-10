
=head1 NAME

XIMS::SAX::Filter::Date -- A SAX Filter expanding datetime strings to nodesets.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::Date;

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::Date;

use common::sense;
use parent qw( XML::SAX::Base );
use DateTime;

=head2 new()

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    return $self;
}

=head2 start_element()

=cut

sub start_element {
    my ( $self, $element ) = @_;

    # how am i happy when we got the naming cleaned up...
    if (   $element->{LocalName} =~ /\_time$/i
        || $element->{LocalName} =~ /\_timestamp$/i
        || $element->{LocalName} =~ /^(?:dc_)?date$/i
        || $element->{LocalName} eq "lastaccess" )
    {
        $self->{got_date} = 1;
    }

    $self->SUPER::start_element($element);

    return;
}

=head2 end_element()

=cut

sub end_element {
    my $self = shift;

    if ( defined $self->{got_date}
             and defined $self->{date}
             and my $dt = XIMS::datetime($self->{date}) ) {

        $self->SUPER::start_element(
            {
                Name         => "day",
                LocalName    => "day",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => sprintf('%02d', $dt->day) } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {
                Name         => "month",
                LocalName    => "month",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => sprintf('%02d', $dt->month) } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {
                Name         => "year",
                LocalName    => "year",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => sprintf('%04d', $dt->year) } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {
                Name         => "hour",
                LocalName    => "hour",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => sprintf('%02d', $dt->hour) } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {
                Name         => "minute",
                LocalName    => "minute",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => sprintf('%02d', $dt->min) } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {
                Name         => "second",
                LocalName    => "second",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => sprintf('%02d', $dt->sec) } );
        $self->SUPER::end_element();


        # $self->SUPER::start_element(
        #     {
        #         Name         => "rfc_1123",
        #         LocalName    => "rfc_1123",
        #         Prefix       => "",
        #         NamespaceURI => undef,
        #         Attributes   => {}
        #     }
        # );
        # $self->SUPER::characters( { Data => XIMS::rfc1123_timestamp($dt) } );
        # $self->SUPER::end_element();


        $self->SUPER::start_element(
            {
                Name         => "iso",
                LocalName    => "iso",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data =>  XIMS::w3c_timestamp($dt) } );
        $self->SUPER::end_element();

        $self->{date} = undef;
    }

    $self->{got_date} = undef;
    $self->SUPER::end_element(@_);

    return;
}

=head2 charachters()

=cut

sub characters {
    my ( $self, $string ) = @_;

    if ( defined $string->{Data} and defined $self->{got_date} ) {
        $self->{date} .= $string->{Data};
    }
    else {
        $self->SUPER::characters($string);
    }

    return;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

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

