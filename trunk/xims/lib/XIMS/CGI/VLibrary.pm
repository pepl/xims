# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::VLibrary;

use strict;
use vars qw($VERSION @ISA);

use XIMS::CGI::Folder;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
@ISA = qw( XIMS::CGI::Folder );

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
        qw(
          create
          edit
          store
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          cancel
          subject
          authors
          author
          publications
          publication
          vlsearch
          )
        );
}


# #############################################################################
# RUNTIME EVENTS

sub event_init {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->sax_generator( 'XIMS::SAX::Generator::VLibrary' );
    return $self->SUPER::event_init( $ctxt );
}


sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );
}

sub event_subject {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $subjectid = $self->param('subject_id');
    return 0 unless $subjectid;

    $ctxt->properties->content->getformatsandtypes( 1 );

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = 5;
    $offset = $offset * $rowlimit;

    my @objects = $ctxt->object->vlitems_bysubject( subject_id => $subjectid,
                                                    limit => $rowlimit,
                                                    offset => $offset,
                                                    order => 'title'
                                                  );

    #hmmm, not sure about that
    for ( @objects ) {
        $_->{authorgroup} = { author => [$_->vleauthors()] };
    }

    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

sub event_authors {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( "authors" );

    return 0;
}

sub event_author {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $authorid = $self->param('author_id');
    return 0 unless $authorid;

    $ctxt->properties->content->getformatsandtypes( 1 );

    my @objects = $ctxt->object->vlitems_byauthor(  author_id => $authorid,
                                                    order => 'title'
                                                 );

    #hmmm, not sure about that
    for ( @objects ) {
        $_->{authorgroup} = { author => [$_->vleauthors()] };
    }

    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

sub event_publications {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( "publications" );

    return 0;
}


sub event_publication {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $publicationid = $self->param('publication_id');
    return 0 unless $publicationid;

    $ctxt->properties->content->getformatsandtypes( 1 );

    my @objects = $ctxt->object->vlitems_bypublication(  publication_id => $publicationid,
                                                         order => 'title'
                                                      );

    #hmmm, not sure about that
    for ( @objects ) {
        $_->{authorgroup} = { author => [$_->vleauthors()] };
    }

    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    # check for body references in (X)HTML and XML documents
    my $dfmime_type = $ctxt->object->data_format->mime_type();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}


sub event_vlsearch {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $search = $self->param('vls');
    my $offset = $self->param('page');
    my $rowlimit = 5;
    $offset = $offset * $rowlimit;

    XIMS::Debug( 6, "param $search");
    # length within 2..30 chars
    if (( length($search) >= 2 ) && ( length($search) <= 30 )) {
        my $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split(':',$qbdriver))[1];
        $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . 'InterMedia'; # XIMS::QBDRIVER()

        eval "require $qbdriver"; #
        if ( $@ ) {
            XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
            $ctxt->send_error( "QueryBuilder-Driver could not be found!" );
            return 0;
        }

        my $qb = $qbdriver->new( { search => $search, allowed => q{\!a-zA-Z0-9öäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~} } );

        # refactor! build() should not be needed and only $qb should be passed

        #'# just for emacs' font-lock...
        my $qbr = $qb->build( [qw(title abstract body)] );
        if ( defined $qbr->{criteria} and length $qbr->{criteria} ) {
            my %param = (
                        criteria => $qbr->{criteria},
                        limit => $rowlimit,
                        offset => $offset,
                        order => $qbr->{order},
                        start_here => $ctxt->object(),
                        );
            my @objects = $ctxt->object->find_objects_granted( %param );

            if ( not @objects ) {
                 $ctxt->session->warning_msg( "Query returned no objects!" );
            }
            else {
                %param = ( criteria => $qbr->{criteria}, start_here => $ctxt->object() );
                my $count = $ctxt->object->find_objects_granted_count( %param );
                my $message = "Query returned $count objects.";
                $message .= " Displaying objects " . ($offset+1) if $count >= $rowlimit;
                $message .= " to " . ($offset+$rowlimit) if ( $offset+$rowlimit <= $count );
                $ctxt->session->message( $message );
                $ctxt->session->searchresultcount( $count );
            }

            for ( @objects ) {
                bless $_, "XIMS::VLibraryItem";
                $_->{authorgroup} = { author => [$_->vleauthors()] };
            }

            $ctxt->objectlist( \@objects );
            $ctxt->properties->application->style( "objectlist" ) ;
        }
        else {
            XIMS::Debug( 3, "please specify a valid query" );
            $self->sendError( $ctxt, "Please specify a valid query!" );
        }
    }
    else {
        XIMS::Debug( 3, "catched improper query length" );
        $self->sendError( $ctxt, "Please keep your queries between 2 and 30 characters!" );
    }

    return 0;
}

# END RUNTIME EVENTS
# #############################################################################
1;
