
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

use common::sense;
use parent qw(MIME::Lite::HTML);

use HTTP::Request;


=head2 new()

Derived constructor. The 'Url' parameter will be ignored, the new parameter
'Session' takes a XIMS session-id as value. Besides that, see
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

=head2 create_image_part()

Once more we need to mess with MIME::Lite::HTML's internals, as it sets the
mimetype using regex-matches on the suffix:

    elsif (lc($ur)=~/\.gif$/i) {$type= "image/gif";}
    elsif (lc($ur)=~/\.jpg$/i) {$type = "image/jpg";}
    elsif (lc($ur)=~/\.png$/i) {$type = "image/png";}
    else { $type = "application/x-shockwave-flash"; }

These break for image URLs with CGI parameters, i.e. our JPEGs (being
processed by Apache::Imagemagick) get marked as
'application/x-shockwave-flash' -- in turn rendering them unusable by many
MUAs.

We need to overwrite this method and try to get the mimetype from the
response's Content-Type header, if possible.

=cut

#-------------------------------------------------------------------------------
# create_image_part (Taken from MIME::Lite::HTML-1.22, reformatted, mod. marked)
#-------------------------------------------------------------------------------
sub create_image_part {
    my ( $self, $ur, $typ ) = @_;
    my ( $type, $buff1 );

    # Create MIME type
    if ($typ) { $type = $typ; }
    elsif ( lc($ur) =~ /\.gif$/i ) { $type = "image/gif"; }
    elsif ( lc($ur) =~ /\.jpg$/i ) { $type = "image/jpg"; }
    elsif ( lc($ur) =~ /\.png$/i ) { $type = "image/png"; }
    else                           { $type = "application/x-shockwave-flash"; }

    # Url is already in memory
    if ( $self->{_HASH_TEMPLATE}{$ur} ) {
        print "Using buffer on: ", $ur, "\n" if $self->{_DEBUG};
        $buff1 =
          ref( $self->{_HASH_TEMPLATE}{$ur} ) eq "ARRAY"
          ? join "", @{ $self->{_HASH_TEMPLATE}{$ur} }
          : $self->{_HASH_TEMPLATE}{$ur};
        delete $self->{_HASH_TEMPLATE}{$ur};
    }
    else {    # Get image
        print "Get img ", $ur, "\n" if $self->{_DEBUG};
        my $res2 =
          $self->{_AGENT}->request( new HTTP::Request( 'GET' => $ur ) );
        if ( !$res2->is_success ) { $self->set_err("Can't get $ur\n"); }
        $buff1 = $res2->content;

        # added
        $type = $res2->header('Content-Type')
          if length $res2->header('Content-Type');
        # End mod

    }

    # Create part
    my $mail = new MIME::Lite( Data => $buff1, Encoding => 'base64' );

    $mail->attr( "Content-type" => $type );

    # With cid configuration, add a Content-ID field
    if ( $self->{_include} eq 'cid' ) {
        $mail->attr( 'Content-ID' => '<' . $self->cid($ur) . '>' );
    }
    else {    # Else (location) put a Content-Location field
        $mail->attr( 'Content-Location' => $ur );
    }

    # Remove header for Eudora client
    $mail->replace( "X-Mailer"            => "" );
    $mail->replace( "MIME-Version"        => "" );
    $mail->replace( "Content-Disposition" => "" );
    return $mail;
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

