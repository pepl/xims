
=head1 NAME

XIMS::SAX::Filter::Date -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::Date;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::Date;


=head3 Description
:
This SAX Filter expands a datetime string to a nodeset.
=cut


use strict;
use base qw( XML::SAX::Base );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    # this has to be adapted to the current format we get the datetime in
    $self->{timestamp_regex}
        = qr/^(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)$/;
    return $self;
}

sub start_element {
    my ( $self, $element ) = @_;

    # how am i happy when we got the naming cleaned up...
    if (   $element->{LocalName} =~ /\_time$/i
        || $element->{LocalName} =~ /\_timestamp$/i
        || $element->{LocalName} eq "date"
        || $element->{LocalName} eq "lastaccess" )
    {
        $self->{got_date} = 1;
    }

    $self->SUPER::start_element($element);

    return;
}

sub end_element {
    my $self = shift;

    if ( defined $self->{got_date} and defined $self->{date} ) {
        my ( $year, $month, $day, $hour, $min, $sec )
            = ( $self->{date} =~ $self->{timestamp_regex} );

        $self->SUPER::start_element(
            {   Name         => "day",
                LocalName    => "day",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => $day } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {   Name         => "month",
                LocalName    => "month",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => $month } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {   Name         => "year",
                LocalName    => "year",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => $year } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {   Name         => "hour",
                LocalName    => "hour",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => $hour } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {   Name         => "minute",
                LocalName    => "minute",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => $min } );
        $self->SUPER::end_element();

        $self->SUPER::start_element(
            {   Name         => "second",
                LocalName    => "second",
                Prefix       => "",
                NamespaceURI => undef,
                Attributes   => {}
            }
        );
        $self->SUPER::characters( { Data => $sec } );
        $self->SUPER::end_element();

        $self->{date} = undef;
    }

    $self->{got_date} = undef;
    $self->SUPER::end_element(@_);

    return;
}

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

Copyright (c) 2002-2007 The XIMS Project.

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

