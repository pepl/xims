
=head1 NAME

XIMS::CGI::NewsLetter -- The CGI class for XIMS::NewsLetters.

=head1 VERSION

$Id: NewsLetter.pm 1947 2008-02-20 10:08:31Z haensel $

=head1 SYNOPSIS

    use XIMS::CGI::NewsLetter;

=head1 DESCRIPTION

At the moment, a NewsLetter is just a mailable document.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::NewsLetter;

use common::sense;
use parent qw( XIMS::CGI::Document XIMS::CGI::Mailable );


# #############################################################################
# GLOBAL SETTINGS

=head2 registerEvents()

=cut

sub registerEvents {
    my $self = shift;
    $self->SUPER::registerEvents( 'prepare_mail', 'send_as_mail:POST', @_ );
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

Copyright (c) 2002-2017 The XIMS Project.

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

