# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package questionnaire;

use strict;
use vars qw( $VERSION @ISA @MSG);
use XIMS::CGI;
use XIMS::QuestionnaireResult;
use Text::Iconv;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI );

# (de)register events here
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
            default
            create
            edit
            store
            trashcan
            trashcan_prompt
            delete
            delete_prompt
            obj_acllist
            obj_aclgrant
            obj_aclrevoke
            publish
            publish_prompt
            unpublish
            cancel
            answer
            download_results
            )
        );
}

#
# override or add event handlers here
#
# override SUPER::events
sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    my $user = $ctxt->session->user;
    if ($user->name eq 'public') {
        $self->_default_public( $ctxt );
    }
    else {
        $object->body( _encode( $object->body() ) );
        $object->set_statistics();
        $object->body( _decode( $object->body() ) );
    }
    $self->SUPER::event_default( $ctxt );
}

sub _default_public {
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    my $user = $ctxt->session->user;
    $object->body( _encode( $object->body() ) );
    my $tan_needed = $object->tan_needed();
    XIMS::Debug(6, "User ".$user->name." is answering the questionnaire" );
    # If a public users is starting to answer the questionnaire
    # some extra data has to be stored in the xml-body
    my %params = $self->Vars;
    my $tan = $self->param('tan');
    if ( $tan_needed && ( ! $object->tan_ok( $tan ) ) && $params{'q'} ) {
        XIMS::Debug(5, "Start: TAN not valid!");
        $object->set_answer_error( "Your TAN is not valid!" );
        # Set current_question back
        $params{'q'} = 0;
    }
    # if no TAN is submitted set session id as TAN (unique value for
    # identifying answers
    $tan = $ctxt->session->id() unless $tan;
    $params{'tan'} = $tan;
    $object->set_answer_data( %params );
    $object->body( _decode( $object->body() ) );
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    # if called from editing the edit parameter is always true
    # because edit is a hidden field in the html-form.
    # So if the Save-button is clicked this event has to be handled manually.
    if ( $self->param('store') ) {
      $self->event_store( $ctxt );
      return 0;
    }
    my $object = $ctxt->object();
    $object->body( _encode( $object->body() ) ) if defined $object->body();
    # a published questionnaire or a questionnaire which allready
    # has been answered must not be edited
    if ( $object->has_answers() ) {
        XIMS::Debug( 5, "cannot edit answered questionnaire" );
        $self->sendError( $ctxt, 'Allready answered questionnaires cannot be edited! You can copy the questionnaire and edit the copy.' );
        return 0;
    }
    if ( $object->published() ) {
        XIMS::Debug( 5, "cannot edit published questionnaire" );
        $self->sendError( $ctxt, 'Published Questionnaire cannot be edited! Unpublish first' );
        return 0;
    }
    my $method = $self->param('edit');
    my $edit_id = $self->param('qid');
    my %params = $self->Vars;
    my $parsed_object = $object->form_to_xml( %params );
    # replace x between ids with ., except a tanlist is added
    # tanlists are added by path not id
    $edit_id =~ s/x/\./g unless $method eq 'add_tanlist';
    # after the form has been processed to xml we don't need the
    # form-params anymore, to avoid problems with later serialization
    foreach ( $self->param() ) {
        $self->delete( $_ ) if /^[question|answer]/ ;
    }
    $object->$method( $edit_id, $parsed_object );
    $object->body( _decode( $object->body() ) ) if defined $object->body();
    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );
    $self->SUPER::event_edit( $ctxt );
}

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    $self->SUPER::event_create( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    my $body = $object->body();
    return 0 unless $self->init_store_object( $ctxt ) and defined $ctxt->object();
    if ( $body =~ /questionnaire/ ) {
        #build xml from HTML-Form. This is done before init_store,
    #because params have to be UTF-8, init_store converts all
    #parameters to XIMS::DBENCODING
    my %params = $self->Vars;
    my $parsed_object = $object->form_to_xml( %params );
    $body = _decode( $parsed_object->documentElement()->toString() );
    }
    else {
    $ctxt->object()->body( "<questionnaire><title>".$self->param( 'questionnaire_title' )."</title><comment>".$self->param( 'questionnaire_comment' ). "</comment></questionnaire>" );
        $body = $ctxt->object()->body();
    }
      $object->body( $body , dontbalance => 1 );
    XIMS::Debug( 6, "body set, len: " . length($body) );
    $ctxt->object()->title( $self->param( 'questionnaire_title' ) );
    return $self->SUPER::event_store( $ctxt );
}

sub event_answer {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    $object->body( _encode( $object->body() ) ) if defined $object->body();
    my $question_id = $self->param('qid');
    my $tan = $self->param( 'tan' );
    my $questionnaire_id = $object->document_id() ;
    my $tan_needed = $object->tan_needed();
    $question_id =~ s/x/\./g;
    # if no TAN is submitted check if one is needed
    if (! $tan ) {
        XIMS::Debug(6, "Result: no TAN submitted");
        if ( $tan_needed ) {
            #if TAN is needed display message and restart questionnaire
            XIMS::Debug(5, "Result: TAN needed");
        }
        else {
            #if no TAN is needed take current session-id as unique number
            XIMS::Debug(6, "Result: no TAN needed");
            $tan = $ctxt->session->id();
        }
    }
    XIMS::Debug(6, "Result: TAN = $tan");
    # if TAN is submitted and TAN is needed check in TAN_List
    if ( $tan_needed && $object->tan_ok( $tan ) ) {
        if (! $object->tan_ok( $tan ) ) {
            #if TAN does not match display message and restart questionnaire
            XIMS::Debug( 6, "Result: TAN does not match" );

        }
    }
    # if question_id (top-level) and TAN are
    # allready in the questionnaire check if all needed answers are given
        # if not all answers are stored, display the question
        # if all answers are stored redirect to next question

    # Check if all necessary answers are given (to do)

    # Store answer in Database
    my %params = $self->Vars;
    $params{'tan'} = $tan;
    $object->store_result ( %params );
    $object->set_answer_data( %params );

    # after the form has been processed to xml we don't need the
    # form-params anymore, to avoid problems with later serialization
    foreach ( $self->param() ) {
        $self->delete( $_ ) if /^[question|answer]/ ;
    }
    $object->body( _decode( $object->body() ) ) if defined $object->body();
    $self->SUPER::event_default( $ctxt );
}

sub event_download_results {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    my $questionnaire_id = $object->document_id();
    #get count of answers for each Question from the Questionnaire
    $object->body( _encode( $object->body() ) ) if defined $object->body();
    $object->set_results();
    $object->body( _decode( $object->body() ) ) if defined $object->body();
    $ctxt->properties->application->style( 'download_results' );
    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    $ctxt->properties->application->style( 'error' );

    if ( $objprivs & XIMS::Privileges::PUBLISH()
         || $objprivs & XIMS::Privileges::PUBLISH_ALL() ) {

        if ( not $object->publish() ) {
            XIMS::Debug( 2, "publishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Publishing object '" . $object->title() . "' failed." );
            return 0;
        }

        # The questionnaire is published through a grant to the public user
        my $boolean = $object->grant_user_privileges (  grantee         => XIMS::PUBLICUSERID(),
                                                        privilege_mask  => ( XIMS::Privileges::VIEW | XIMS::Privileges::CREATE ),
                                                        grantor         => $user->id() );

        if ( $boolean ) {
            XIMS::Debug( 6, "questionnaire " . $object->title() . " published." );
            $ctxt->properties->application->styleprefix( 'questionnaire_publish' );
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message( "Questionnaire '" . $object->title() . "' published." );
        }
        else {
            XIMS::Debug( 2, "could not publish questionnaire " . $object->document_id() );
        }
    }
    else {
        XIMS::Debug( 3, "User has no publishing privileges on this object!" );
    }

    return 0;
}

sub event_publish_prompt {
    my ( $self, $ctxt ) = @_;

    $self->SUPER::event_publish_prompt( $ctxt );
    $ctxt->properties->application->styleprefix( 'questionnaire_publish' );

    return 0;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    $ctxt->properties->application->style( 'error' );

    if ( $objprivs & XIMS::Privileges::PUBLISH()
         || $objprivs & XIMS::Privileges::PUBLISH_ALL() ) {

        if ( not $object->unpublish() ) {
            XIMS::Debug( 2, "unpublishing object '" . $object->title() . "' failed" );
            $self->sendError( $ctxt, "Unpublishing object '" . $object->title() . "' failed." );
            return 0;
        }

        # revoke the privs
        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $object->id() );

        if ( $privs_object and $privs_object->delete() ) {
            XIMS::Debug( 6, "questionnaire " . $object->title() . " unpublished." );
            $ctxt->properties->application->styleprefix( 'questionnaire_publish' );
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message( "Questionnaire '" . $object->title() . "' unpublished." );
        }
        else {
            XIMS::Debug( 2, "could not unpublish questionnaire " . $object->document_id() );
        }
    }
    else {
        XIMS::Debug( 3, "User has no publishing privileges on this object!" );
    }

    return 0;
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    $self->SUPER::event_exit( $ctxt );
    $ctxt->properties->content->escapebody( 0 ); # do not escape body
    return 0;
}

sub _encode {
    my $string = shift;
    return $string unless XIMS::DBENCODING();
    my $converter = Text::Iconv->new( XIMS::DBENCODING(), "UTF-8" );
    $string = $converter->convert($string) if defined $string;
    return $string;
}

sub _decode {
    my $string = shift;
    return $string unless XIMS::DBENCODING();
    my $converter = Text::Iconv->new( "UTF-8", XIMS::DBENCODING() );
    $string = $converter->convert($string) if defined $string;
    return $string;
}

1;
