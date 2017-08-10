
=head1 NAME

XIMS::CGI::VLibraryItem::NewsItem

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibraryItem::NewsItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::VLibraryItem::NewsItem;

use common::sense;
use parent qw( XIMS::CGI::VLibraryItem::Document XIMS::CGI::NewsItem2 );
use XIMS::VLibMeta;
use Locale::TextDomain ('info.xims');

sub event_default {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    # replace image id with image path
    $self->resolve_content( $ctxt, [qw( IMAGE_ID )] );

    return $self->SUPER::event_default($ctxt);
}

=head2 event_edit()

=cut

sub event_edit {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    $self->resolve_content( $ctxt, [qw( IMAGE_ID )] );

    return $self->SUPER::event_edit($ctxt);
}


=head2 event_store()

=cut

sub event_store {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    $self->handle_image_upload($ctxt);

    my $rc = $self->SUPER::event_store($ctxt);
    if ( not $rc ) {
        return 0;
    }
    else {
        return 1;
    }
}


1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

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

