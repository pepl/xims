

=head1 NAME

XIMS::Mailer - XIMS wrapper class for MIME::Lite::HTML.

=head1 VERSION

$Id: AuthXIMS.pm 1887 2008-01-11 12:01:11Z haensel $

=head1 SYNOPSIS

    my $mailer = XIMS::Mailer->new(
        From         => $from,
        To           => $to,
        Subject      => $subject,
        Session      => $tmpSession->session_id() );

    my $MIMEmail = $mailer->parse($path);

    $MIMEmail->send();

=head1 DESCRIPTION

This is wrapper class for MIME::Lite::HTML, mainly in order to allow the
module's RequestAgent to open connections using a XIMS session.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Mailer;

use strict;
use base qw(MIME::Lite::HTML);

our ($VERSION) = ( q$Revision:  $ =~ /\s+(\d+)\s*$/ );

=head2 new()

Derived constructor. The `Url' parameter will be ignored, the new parameter
`Session' takes a XIMS session-id as value. Beside that, see
L<MIME::Lite::HTML>.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %param = @_;

    # never parse and send from constructor!
    delete $param{'Url'};
    my $self = $class->SUPER::new(%param);

    if ( $param{'Session'} ) {
        $self->get_agent->default_headers->push_header(
            'Cookie' => 'session=' . $param{'Session'} );
    }

    return $self;
}

=head2 get_agent()

Returns MIME::Lite::HTML's RequestAgent object. We have to access internals
here, unfortunately.

=cut

sub get_agent {
    my $self = shift;
    # XXX using ancestor module's internals
    return $self->{_AGENT};
}

1;

__END__


=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

See L<MIME::Lite::HTML> and L<MIME::Lite>.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2008 The XIMS Project.

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

