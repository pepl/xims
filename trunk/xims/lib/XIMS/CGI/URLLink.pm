
=head1 NAME

XIMS::CGI::URLLink

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::URLLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::URLLink;

use common::sense;
use parent qw( XIMS::CGI XIMS::CGI::NewsItem2);
use Locale::TextDomain ('info.xims');

# #############################################################################
# GLOBAL SETTINGS

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw( create
            edit
            store:POST
            publish:POST
            publish_prompt
            unpublish:POST
            obj_acllist
            obj_acllight
            obj_aclgrant:POST
            obj_aclrevoke:POST
            )
    );
}


# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # this handles absolute URLs only for now
    $self->redirect( $ctxt->object->location() );

    return 0;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->handle_image_upload($ctxt);

    # check URL;
    $ctxt->object->check();
    $ctxt->properties->application->preservelocation(1);

    return 0
      unless $self->init_store_object($ctxt)
      and defined $ctxt->object();

    return $self->SUPER::event_store($ctxt);
}


sub event_edit {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    $self->resolve_content( $ctxt, [qw( IMAGE_ID )] );

    return $self->SUPER::event_edit($ctxt);
}


=head2 event_test_location()

=cut

sub event_test_location {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # check URL;
    $ctxt->object->check();
    $ctxt->properties->application->preservelocation(1);

    return $self->SUPER::event_test_location($ctxt);
}

=head2 event_publish_prompt()

=cut

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;

    $ctxt->session->warning_msg(__"URLLink objects are only FLAGGED published!");

    $self->SUPER::event_publish_prompt($ctxt);

    return 0;
}

=head2 event_exit()

=cut

sub event_exit {
    my ( $self, $ctxt ) = @_;

    $self->resolve_content( $ctxt, [qw( SYMNAME_TO_DOC_ID )] );

    return $self->SUPER::event_exit($ctxt);
}

# END RUNTIME EVENTS
# #############################################################################

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

Copyright (c) 2002-2015 The XIMS Project.

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

