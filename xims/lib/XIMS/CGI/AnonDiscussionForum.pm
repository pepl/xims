
=head1 NAME

XIMS::CGI::AnonDiscussionForum -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::CGI::AnonDiscussionForum;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::AnonDiscussionForum;

use strict;
use base qw( XIMS::CGI::Folder );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getchildren->level( 1 );
    $ctxt->properties->content->getchildren->addinfo( 1 );
    $self->expand_attributes( $ctxt );

    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = ( XIMS::Privileges::VIEW | XIMS::Privileges::CREATE );
    $self->publish_gopublic( $ctxt, {PRIVILEGE_MASK => $privmask}  );
    return 0 if $ctxt->properties->application->style() eq 'error';
    
    # grant privileges to descendants
    my @descendants = $ctxt->object->descendants();
    return unless scalar @descendants;

    XIMS::Debug( 4, "starting descendant-recursion public user grant" );
    my $granted = 0;
    foreach my $descendant ( @descendants ) {
        my $boolean = ( $descendant->grant_user_privileges( grantee         => XIMS::PUBLICUSERID(),
                                                          privilege_mask  => $privmask,
                                                          grantor         => $ctxt->session->user->id() ) and $descendant->publish( User => $ctxt->session->user ) );
        unless ( $boolean ) {
            XIMS::Debug( 3, "could not grant to descendant with doc_id " . $descendant->document_id() );
        }
        else {
            $granted++;
        }
    }
    
    if ( $granted == scalar @descendants ) {
        $ctxt->session->message("Object '" .  $ctxt->object->title() . "' together with $granted related objects published.");
    }
}

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->unpublish_gopublic( $ctxt, @_ );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # revoke privileges from descendants
    my @descendants = $ctxt->object->descendants();
    return unless scalar @descendants;

    XIMS::Debug( 4, "starting descendant-recursion public user revoke" );
    foreach my $descendant ( @descendants ) {
        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $descendant->id() );
        unless ( $privs_object and $privs_object->delete() and $descendant->unpublish( User => $ctxt->session->user ) ) {
            XIMS::Debug( 3, "could not revoke/unpublish from descendant with doc_id " . $descendant->document_id() );
        }
    }
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

Copyright (c) 2002-2007 The XIMS Project.

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

