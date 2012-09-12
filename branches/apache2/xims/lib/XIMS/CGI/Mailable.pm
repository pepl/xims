
=head1 NAME

XIMS::CGI::Mailable - implements the cgi events needed to make a XIMS class
mailable.

=head1 VERSION

$Id:$

=head1 SYNOPSIS

=head1 DESCRIPTION

This Class implements the cgi events needed to make a XIMS class mailable. It
should be easy to extend different object types with this functionality by
simply using multiple inheritance and marking the object `mailable' in the
ci_object_types table.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::Mailable;
use strict;

use XIMS::Mailer;
use Email::Valid;
use HTTP::Headers::Util ();
use Locale::TextDomain ('info.xims');

=head2 registerEvents()

This might not work in every situation, you might need to add the events
`prepare_mail' and `send_as_mail' to list in the to-be-mailable class.

=cut

sub registerEvents {
    my $self = shift;
    $self->SUPER::registerEvents( 'prepare_mail', 'send_as_mail', @_ );
}

=head2 event_prepare_mail()

=cut

sub event_prepare_mail {

    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $object->published() ) {
        $self->sendError( $ctxt, __"Object must be published!" );
        return 0;
    }

    unless ( $ctxt->session->user->object_privmask( $ctxt->object ) &
        XIMS::Privileges::SEND_AS_MAIL() )
    {
        return $self->event_access_denied($ctxt);
    }

    if ( $self->object_locked($ctxt) ) {
        XIMS::Debug( 3, "Attempt to send locked object" );
        $self->sendError( $ctxt,
             __x("This object is locked by {firstname} {lastname} since {locked_time}. Please try again later.",
                firstname   => $object->locker->firstname(),
                lastname    => $object->locker->lastname(),
                locked_time => $object->locked_time()
            )
         );
    }

    $ctxt->properties->application->styleprefix('common');
    $ctxt->properties->application->style('prepare_mail');
    return 0;
}

=head2  event_send_as_mail()

=cut

sub event_send_as_mail {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    my $from = '"'
               . Encode::encode( "MIME-Header", 
                                 XIMS::encode( $object->User->fullname ) 
                 )
               . '" <' . $object->User->email . '>';

    unless ( $object->published() ) {
        $self->sendError( $ctxt, __"Object must be published!" );
        return 0;
    }

    unless ( $ctxt->session->user->object_privmask($object) &
        XIMS::Privileges::SEND_AS_MAIL() )
    {
        return $self->event_access_denied($ctxt);
    }

    if ( $self->object_locked($ctxt) ) {
        XIMS::Debug( 3, "Attempt to send locked object" );
        $self->sendError( $ctxt,
                          __x("This object is locked by {firstname} {lastname} since {locked_time}. Please try again later.",
                              firstname   => $object->locker->firstname(),
                              lastname    => $object->locker->lastname(),
                              locked_time => $object->locked_time()
                          )
                      );
    }

    my $to = Email::Valid->address( $self->param('to') );

    # my $bcc    = Email::Valid->address($self->param('bcc')) or q();

    unless ( length $to ) {
        $self->sendError( $ctxt, __"No valid email address supplied!" );
        return 0;
    }

    my $subject = $self->param('subject');

    if ( length $subject < 3 ) {
        $self->sendError( $ctxt, __"Please supply a meaningful subject" );
        return 0;
    }
    if ( length $subject > 60 ) {
        $self->sendError( $ctxt,
            __"Please keep the subject below 60 characters" );
        return 0;
    }

    $subject = Encode::encode( "MIME-Header", XIMS::utf8_sanitize( $subject ) );

    my $reply_to = Email::Valid->address( $self->param('reply-to') );

    my $include_type = 'extern';
    if ( $self->param('mailer_include_images') eq 'true' ) {
        $include_type = 'location';
    }

    # XXX XIMS::RESOLVERELTOSITEROOTS() et al. ignored for now...
    my $path =
        $object->siteroot->url() =~ m#/#
      ? $object->siteroot->url()
      : XIMS::PUBROOT_URL();
    $path .= $object->location_path_relative();

    XIMS::Debug( 6, "Published URL to be fetched: $path" );

    my $user_id = $object->User->id();
    my $tmpSession = XIMS::Session->new(
        user_id => $user_id,
        host    => XIMS::REQUESTAGENTSOURCEIP()
    );

    my $mailer = XIMS::Mailer->new(
        From         => $from,
        To           => $to,
        Subject      => $subject,
        'Reply-To'   => $reply_to,
        HTMLCharset  => 'iso-8859-1',
        HTMLEncoding => 'base64',
        IncludeType  => $include_type,
        Session      => $tmpSession->session_id()
    );

    # Default encoding of XIMS::Mailer (MIME::Lite::HTML) is iso-8859-1
    # Per HTTP 1.1 spec, iso-8859-1 is also the default encoding unless a charset is 
    # specified in the Content-Type header.
    # Check here if the page to be sent is encoded differently
    my $response = $mailer->get_agent->request( HTTP::Request->new( 'HEAD' => $path ) );
    if ( $response->is_success() ) {
        my @values = HTTP::Headers::Util::split_header_words($response->header("Content-Type"));
        my $charset = $values[0]->[3]; # charset value
        if ( defined $charset and $charset !~ /iso-8859-1/i ) {
            XIMS::Debug( 6, "Setting mail charset to $charset" );
            # MIME::Lite::HTML does not provide an interface to set the charset... 
            # ...therefore, we have to be unfriendly here
            $mailer->{_htmlcharset} = $charset;
        }
    }
    else {
        XIMS::Debug( 2, "HEAD request to $path failed" );
    }

    my $MIMEmail;
    eval { $MIMEmail = $mailer->parse($path); };

    $tmpSession->delete();

    if ( $mailer->errstr() ) {
        XIMS::Debug( 2, join( '; ', $mailer->errstr() ) );
        $self->sendError( $ctxt, join( '\n', $mailer->errstr() ) );
        return 0;

    }

    my $size = $mailer->size();

    if ( $size > XIMS::MAILSIZELIMIT() ) {
        XIMS::Debug( 2,
                "Mail size $size exceeds hard limit of "
              . XIMS::MAILSIZELIMIT()
              . '.' );
        $self->sendError( $ctxt,
                __x("Mail size {size} exceeds hard limit of {limit}.",
                    size => $size,
                    limit => XIMS::MAILSIZELIMIT()
                )
            );
        return 0;
    }

    if ( $MIMEmail->send() ) {
        $ctxt->session->message("Mail sent");
    }
    else {
        XIMS::Debug( 2, 'Mail-sending failed!' );
        $self->sendError( $ctxt, __"Mail-sending failed!" );
        return 0;
    }

    return 0;
}

1;

__END__


=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

... and it's not finished yet!

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
