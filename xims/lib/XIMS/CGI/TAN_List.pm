
=head1 NAME

XIMS::CGI::TAN_List -- A module used to create TAN lists for Questionnaire

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::TAN_List;

=head1 DESCRIPTION

This module handles the creation of TAN lists (for polls with a closed user
group.)

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::TAN_List;

use strict;
use base qw( XIMS::CGI );
use XIMS::DataFormat;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# (de)register events here

=head2 registerEvents()

=cut

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          obj_acllist
          obj_acllight
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          download
          )
        );
}

#
# override or add event handlers here
#

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    $self->expand_attributes( $ctxt );

    return 0;
}

=head2 event_download()

=cut

sub event_download {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $type = $self->param('download');

    if ( $type eq 'HTML' ) {
        $ctxt->properties->application->style( 'download_html' );
    }
    else {
        my $body;
        my $filename = $ctxt->object->location;
        $filename =~ s/\.[^\.]*$//;
        my $mime_type = "text/". lc $type;
        if ( $type =~ /Excel/i ) {
            # export each tan in a single row, therefore \n
            $body = join("\n",split(",",$ctxt->object->body()));
            my $df = XIMS::DataFormat->new( name => 'XLS' );
            $filename .= '.' . $df->suffix;
            $mime_type = $df->mime_type;
        }
        elsif ( $type =~ /TXT/i ) {
            # export each tan in a single row, therefore \n
            $body = join("\r\n",split(",",$ctxt->object->body()));
            $filename .= '.' . lc $type;
        }
        else {
            $filename .= '.' . lc $type;
        }

        # older browsers use the suffix of the URL for content-type sniffing,
        # so we have to supply a content-disposition header
        print $self->header( -type => $mime_type, '-Content-disposition' => "attachment; filename=$filename" );
        print $body;
        $self->skipSerialization(1);
    }
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

    if ( not $ctxt->parent() ) {
        XIMS::Debug( 6, "unlocking object" );
        $object->unlock();
        XIMS::Debug( 4, "updating existing object" );
        if ( not $object->update() ) {
            XIMS::Debug( 2, "update failed" );
            $self->sendError( $ctxt, __"Update of object failed." );
            return 0;
        }
        $self->redirect( $self->redirect_path( $ctxt ) );
        return 1;
    }
    else {
        XIMS::Debug( 4, "creating new object" );

        my $number = $self->param( 'number' );
        if ( not (defined $number and length $number) ) {
            $self->sendError( $ctxt, __"Number of TANs not set!" );
            return 0;
        }
        XIMS::Debug( 6, "Number of TANs: $number" );
        $object->number( $number );

        my $body = $object->create_TANs( $number );
        if ( length $body ) {
            if ( $object->body( $body ) ) {
                XIMS::Debug( 6, "TANs created: " . length( $body ) );
            }
            else {
                XIMS::Debug( 2, "could not create TANs" );
                $self->sendError( $ctxt, __"TAN-List could not be created." );
                return 0;
            }
        }

        if ( not $object->create() ) {
            XIMS::Debug( 2, "create failed" );
            $self->sendError( $ctxt, __"Creation of object failed." );
            return 0;
        }

        XIMS::Debug( 4, "copying privileges of parent" );
        my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $ctxt->data_provider->getObjectPriv( content_id => $ctxt->parent->id() );
        foreach my $priv ( @object_privs ) {
            $object->grant_user_privileges(
                                        grantee   => $priv->grantee_id(),
                                        grantor   => $ctxt->session->user(),
                                        privmask  => $priv->privilege_mask(),
                                    )
        }
    }

    XIMS::Debug( 4, "redirecting" );
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
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

