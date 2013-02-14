
=head1 NAME

Apache::AxKit::Language::Passthru -- A non-transforming AxKit
transformation language module.

=head1 VERSION

$Id: $

=head1 SYNOPSIS

     AxResetOutputTransformers
     AxAddStyleMap text/xsl Apache::AxKit::Language::Passthru

=head1 SUBROUTINES/METHODS

Implements methods as outlined in L<Apache::AxKit::Language>.

=cut

package Apache::AxKit::Language::Passthru;

use common::sense;
use Apache;
use parent qw( Apache::AxKit::Language );

our $VERSION = 1.0;

=head2 stylesheet_exists()

=cut

sub stylesheet_exists { return 0; }

=head2 get_mtime()

=cut

sub get_mtime {
    return 3000;    # TODO: sane value
}

=head2 handler()

=cut

sub handler {
    my $self = shift;
    my ( $r, $xml, $style, $last_in_chain ) = @_;

    # actually fetch the DOM and store it for later AxKit handlers
    $r->pnotes( 'dom_tree', $xml->get_dom() );

    return Apache::Constants::OK;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

see L<Apache::AxKit::Provider::XIMSGoPublic>

=head1 DEPENDENCIES

mod_perl, XIMS and AxKit, obviously.

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

