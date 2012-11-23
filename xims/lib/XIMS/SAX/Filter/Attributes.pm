
=head1 NAME

XIMS::SAX::Filter::Attributes

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::Attributes;

=head1 DESCRIPTION

This SAX Filter expands semicolon-separated key=value pairs to a nodeset.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::Attributes;

use strict;
use parent qw( XML::SAX::Base );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );



=head2    XIMS::SAX::Filter::Attributes->new();

=head3 Returns

    $self : a XIMS::SAX::Filter::Attributes instance

=head3 Description

Constructor

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    return $self;
}



=head2    $filter->start_element( $element );

=head3 Parameter

    $element : hashref

=head3 Returns

    undef

=cut

sub start_element {
    my ( $self, $element ) = @_;

    if ( defined $element->{LocalName}
        and $element->{LocalName} eq 'attributes' )
    {
        $self->{got_attributes} = 1;
    }

    $self->SUPER::start_element($element);

    return;
}



=head2    $filter->end_element( $element );

=head3 Parameter

    $element : hashref

=head3 Returns

    undef

=cut

sub end_element {
    my $self = shift;

    if ( defined $self->{got_attributes} and defined $self->{attributes} ) {
        my %attribs = ( $self->{attributes} =~ /([^;\=]+)\=([^\;]+)/g );
        foreach ( keys %attribs ) {
            $self->SUPER::start_element(
                {   Name         => $_,
                    LocalName    => $_,
                    Prefix       => "",
                    NamespaceURI => undef,
                    Attributes   => {}
                }
            );
            $self->SUPER::characters( { Data => $attribs{$_} } );
            $self->SUPER::end_element();
        }

        $self->{attributes} = undef;
    }

    $self->{got_attributes} = undef;
    $self->SUPER::end_element(@_);

    return;
}



=head2    $filter->characters( $string );

=head3 Parameter

    $string : hashref

=head3 Returns

    undef

=cut

sub characters {
    my ( $self, $string ) = @_;

    if ( defined $string->{Data} and defined $self->{got_attributes} ) {
        $self->{attributes} .= $string->{Data};
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

Copyright (c) 2002-2011 The XIMS Project.

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

