
=head1 NAME

XIMS::CGI::SymbolicLink

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::SymbolicLink;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::SymbolicLink;

use common::sense;
use parent qw( XIMS::CGI );
use XIMS::Object;
use Locale::TextDomain ('info.xims');

# #############################################################################
# GLOBAL SETTINGS

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called");
    $_[0]->SUPER::registerEvents(
        qw(
          create
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
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    my $object = $ctxt->object();
    my $symlinkobj = XIMS::Object->new( document_id => $object->symname_to_doc_id, language => $object->language_id );

    $object->title( $symlinkobj->title() );
    $object->data_format_id( $symlinkobj->data_format_id );
    # other properties missing

    $ctxt->properties->application->styleprefix( lc( $symlinkobj->object_type->name() ) );

    if ( $symlinkobj->object_type->is_fs_container ) {
        $ctxt->properties->content->getchildren->objectid( $symlinkobj->id() );
        # $ctxt->properties->content->getformatsandtypes( 1 ); currently, its not possible to create stuff in symlinks on containers
    }
    else {
        $object->body( $symlinkobj->body() );
    }

    return 0;
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    $self->resolve_content( $ctxt, [ qw( SYMNAME_TO_DOC_ID ) ] );

    # since TITLE should not be set with OT Symbolic Link we can
    # safely override it here with the title of the target
    $ctxt->object->title( XIMS::Object->new( document_id => $ctxt->object->symname_to_doc_id, language => $ctxt->object->language_id )->title() );

    return 0;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();
    my $target = $self->param( 'target' );

    if ( defined $target and length $target ) {
        XIMS::Debug( 6, "target: $target" );
        my $targetobj;
        if ( $target =~ /^\d+$/ and $target ne '1'
                and $targetobj = XIMS::Object->new( document_id => $target, language => $object->language_id ) ) {
            $object->symname_to_doc_id( $targetobj->document_id() );
        }
        elsif ( $target ne '/' and $target ne '/root'
               and $targetobj = XIMS::Object->new( path => $target, language => $object->language_id ) ) {
            $object->symname_to_doc_id( $targetobj->document_id() );
        }
        else {
            XIMS::Debug( 2, "Could not find or set target (SYMNAME_TO_DOC_ID)" );
            $self->sendError( $ctxt, __"Could not find or set target" );
            return 0;
        }

        if ( $object->document_id and $object->document_id == $object->symname_to_doc_id ) {
            XIMS::Debug( 2, "Will not store a self-referencing link" );
            $self->sendError( $ctxt, __"Will not store a self-referencing link" );
            return 0;
        }
    }
    else {
        XIMS::Debug( 2, "No target specified!" );
        $self->sendError( $ctxt, __"No target specified!" );
        return 0;
    }

    return $self->SUPER::event_store( $ctxt );
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

