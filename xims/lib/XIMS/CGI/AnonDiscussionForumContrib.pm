
=head1 NAME

XIMS::CGI::AnonDiscussionForumContrib -- A class used for single AnonDiscussionForum
contributions

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::AnonDiscussionForumContrib;

=head1 DESCRIPTION

It is based on XIMS::CGI.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::AnonDiscussionForumContrib;

use strict;
use base qw( XIMS::CGI );
use Text::Iconv;
use URI::Escape ();

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          create
          edit
          store
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          mt
          )
        );
}

# #############################################################################
# RUNTIME EVENTS

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );
    $ctxt->properties->content->getchildren->level( 0 );

    my $object = $ctxt->object();
    my @descendants = $object->descendants_granted();

    $ctxt->objectlist( \@descendants );
    $self->expand_attributes( $ctxt );

    return 0;
}

=head2 event_store()

=cut

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $author    = $self->param( 'author' );
    my $email     = $self->param( 'email' );
    my $coauthor  = $self->param( 'coauthor' );
    my $coemail   = $self->param( 'coemail' );
    my $title     = $self->param( 'title' );

    my $converter;
    if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
        $converter = Text::Iconv->new("UTF-8", XIMS::DBENCODING());
        $author = $converter->convert($author) if defined $author;
        $coauthor = $converter->convert($coauthor) if defined $coauthor;
        $title = $converter->convert($title) if defined $title;
    }

    if ( defined $title and length $title ) {
        $self->param( name => localtime() );
    }
    else {
        $self->sendError( $ctxt, "No title set!" );
        return 0;
    }

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $object = $ctxt->object();

    XIMS::Debug( 6, "author $author" );
    $object->author( $author );

    XIMS::Debug( 6, "email $email" );
    $object->email( $email );

    if ( defined $coauthor and length $coauthor ) {
        XIMS::Debug( 6, "coauthor $coauthor" );
        $object->coauthor( $coauthor );

        XIMS::Debug( 6, "email $coemail" );
        $object->coemail( $coemail, 1 );
    }

    XIMS::Debug( 6, "ip " . $ctxt->apache->connection->remote_ip() );
    $object->senderip( $ctxt->apache->connection->remote_ip() );

    my $trytobalance  = $self->param( 'trytobalance' );
    my $body = $self->param( 'body' );

    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = $converter->convert($body);
        }

        my $object = $ctxt->object();
        if ( $trytobalance and $trytobalance eq 'true' and $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        elsif ( $object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "could not convert to a well balanced string" );
            $self->sendError( $ctxt, "Document body could not be converted to a well balanced string. Please consult the User's Reference for information on well-balanced document bodies." );
            return 0;
        }
    }

    if ( not $ctxt->parent() ) {
        XIMS::Debug( 6, "unlocking object" );
        $object->unlock();
        XIMS::Debug( 4, "updating existing object" );
        if ( not $object->update() ) {
            XIMS::Debug( 2, "update failed" );
            $self->sendError( $ctxt, "Update of object failed." );
            return 0;
        }
        $self->redirect( $self->redirect_path( $ctxt ) );
        return 1;
    }
    else {
        XIMS::Debug( 4, "creating new object" );
        if ( not $object->create() ) {
            XIMS::Debug( 2, "create failed" );
            $self->sendError( $ctxt, "Creation of object failed." );
            return 0;
        }
        else {
            $object->location( $object->document_id() . '.' . $object->data_format->suffix());
            $object->publish();
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

=head2 event_mt()

Server side mailto redirect for SPAM prevention 

=cut

sub event_mt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $email = $ctxt->object->email();
    $email = $ctxt->object->coemail() if $self->param('coemail');
    
    my $subject = URI::Escape::uri_escape( $self->param('subject') );

    XIMS::Debug( 4, "redirecting to mailto" );
    $self->redirect( sprintf('mailto:%s?subject=%s', $email, $subject) );
    return 1;
}


# override SUPER::events

=head2 event_delete()

=cut

sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::DELETE();

    my $object = $ctxt->object();
    
    # delete must fail otherwise...
    $object->unpublish();
    $self->SUPER::event_delete( $ctxt );
  
    return 0;
}


=head2 event_publish()

=cut

sub event_publish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This object can not be published directly, please publish the related forum." );
    return 0;
}

=head2 event_publish_prompt()

=cut

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This object can not be published directly, please publish the related forum." );
    return 0;
}

=head2 event_unpublish()

=cut

sub event_unpublish {
    my ( $self, $ctxt ) = @_;
    $self->sendError( $ctxt, "This object can not be published directly, please publish the related forum." );
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

# #############################################################################
# HELPERS


# END HELPERS
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

Copyright (c) 2002-2009 The XIMS Project.

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

