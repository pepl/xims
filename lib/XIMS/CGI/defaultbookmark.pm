
=head1 NAME

XIMS::CGI::defaultbookmark

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::defaultbookmark;

=head1 DESCRIPTION

This is basically like an NPH script in that it returns no data
to the client, but rather just redirects them to their default
bookmark.

We might consider moving this to a more generic
redir-to-bookmark-and-fallback-to-default script

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::defaultbookmark;

use strict;
use base qw( XIMS::CGI );
use XIMS::Object;
use Apache::URI();

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# GLOBAL SETTINGS

=head2 selectStylesheet()

=cut

sub selectStylesheet { return 1; }

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

=head2 event_init()

=cut

sub event_init {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    # important! otherwise redirect will not work!
    $self->skipSerialization(1);

    $self->redirToDefault($ctxt);

    XIMS::Debug( 5, "done" );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

=head2    redirToDefault($ctxt);

=head3 Parameter

    $ctxt : appcontext object

=head3 Returns

    none

=head3 Description

redirect to the user's defaultbookmark unless a specific path is requested via
path_info

=head2 redirToDefault()

=cut

sub redirToDefault {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $uri  = Apache::URI->parse( $ctxt->apache );
    my $path = $uri->path();

    my $contentinterface = XIMS::CONTENTINTERFACE();
    if ( $path =~ 'defaultbookmark' or $path !~ /\Q$contentinterface\E/ ) {
        my $bookmark = $ctxt->session->user->default_bookmark();
        if ( $ctxt->session->user->default_bookmark ) {
            XIMS::Debug( 6, "bookmarked path: $bookmark" );
            $bookmark =
              XIMS::Object->new( id => $bookmark->content_id() )->location_path();
        }
        else {

            # use fallback start path if user has got no bookmark set
            XIMS::Debug( 6, "using fallback start path" );
            $bookmark = XIMS::FALLBACKSTARTPATH();
        }

        $path = XIMS::GOXIMS() . $contentinterface . $bookmark;
        $uri->path($path);
    }

    # get rid of user login information in the querystring
    my $query = $uri->query();
    $query =~ s/userid|password//;
    $uri->query($query);

    my $frontend_uri = Apache::URI->parse( $ctxt->apache, $ctxt->session->serverurl() );
    $uri->scheme( $frontend_uri->scheme() );
    $uri->hostname( $frontend_uri->hostname() );
    $uri->port( $frontend_uri->port() );

    XIMS::Debug( 6, "redirecting to " . $uri->unparse() );
    $self->redirect( $uri->unparse() );
    return 0;
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

