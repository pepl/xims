
=head1 NAME

XIMS::CGI::CSS -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::CSS;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::CSS;

use strict;
use base qw( XIMS::CGI::Text );
use CSS::Tiny;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

sub registerEvents {
    $_[0]->SUPER::registerEvents( qw( parse_css ) );
}

=head2 event_parse_css()

=cut

sub event_parse_css {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    my $body = $ctxt->object->body();
    my $css = CSS::Tiny->read_string( $body );
    if ( $CSS::Tiny::errstr ) {
        $ctxt->session->error_msg( __"Parse failure" );
        $ctxt->session->verbose_msg( $CSS::Tiny::errstr );
    }
    else {
        $ctxt->session->message( __"Parse ok. Parsed CSS:" );
        $ctxt->session->verbose_msg( $css->write_string() );
    }

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "message_window_plain" );

    return 0;
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

