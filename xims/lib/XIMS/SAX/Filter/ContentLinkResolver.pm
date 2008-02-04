
=head1 NAME

XIMS::SAX::Filter::ContentLinkResolver -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::SAX::Filter::ContentLinkResolver;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::SAX::Filter::ContentLinkResolver;


=head3 Description
:

This SAX Filter expands a content-id (major_id) to its corresponding
path-string.  Note: This version does not touch the element name and
therefore we got path-string in *_id elements!
=cut


use strict;
use base qw( XML::SAX::Base );
use XIMS;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{goximscontent} = XIMS::GOXIMS() . XIMS::CONTENTINTERFACE();

    return $self;
}

sub start_element {
    my ( $self, $element ) = @_;

    if ( defined $element->{LocalName} ) {
        my $goximscontent = $self->{goximscontent};
        if ( $element->{LocalName} eq 'a' ) {
            if ( $element->{Attributes}->{"{}href"}->{Value} ) {
                $element->{Attributes}->{"{}href"}->{Value}
                    =~ s/^$goximscontent\/[^\/]+//
                    ;    # leave the path relative to the site
            }
        }
        elsif ( $element->{LocalName} eq 'img' ) {
            if ( $element->{Attributes}->{"{}src"}->{Value} ) {
                $element->{Attributes}->{"{}src"}->{Value}
                    =~ s/^$goximscontent\/[^\/]+//
                    ;    # leave the path relative to the site
            }
        }
    }

    $self->SUPER::start_element($element);

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
