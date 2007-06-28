# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::VLibrary;

use strict;
use base qw(XIMS::CGI::Folder);

use Time::Piece;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub registerEvents {
    XIMS::Debug( 5, "called");
    my $self = shift;
    XIMS::CGI::registerEvents( $self,
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
          subject
          subject_store
          subject_edit
          subject_view
          keywords
          keyword
          authors
          author
          author_store
          author_edit
          publications
          publication
          vlsearch
          vlchronicle
          most_recent
          simile
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

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, "Copying VLibraries is not implemented." );
}

# jokar: Enable deletion of Vlibraries. Metadata is not deleted (Authors, Keywords, Subjects, ...)

# sub event_delete {
#    XIMS::Debug( 5, "called" );
#    my ( $self, $ctxt ) = @_;
#    return $self->sendError( $ctxt, "Deleting VLibraries is not implemented." );
#}
#
#sub event_delete_prompt {
#    XIMS::Debug( 5, "called" );
#    my ( $self, $ctxt ) = @_;
#    return $self->sendError( $ctxt, "Deleting VLibraries is not implemented." );
#}

sub event_subject {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $subjectid = $self->param('subject_id');

    unless ( $subjectid ) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new( name => $subjectname, document_id => $ctxt->object()->document_id() );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes( 1 );

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = 10;
    $offset = $offset * $rowlimit;

    my @objects = $ctxt->object->vlitems_bysubject_granted( subject_id => $subjectid,
                                                            limit => $rowlimit,
                                                            offset => $offset,
                                                            order => 'title'
                                                            );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

# store edited subject name and description
# call the library with the param subject_store=1
sub event_subject_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();

    my $subjectid = $self->param('subject_id');

    unless ( $subjectid ) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new( name => $subjectname, document_id => $object->document_id() );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    XIMS::Debug(5,"Updating subject");
    my $subject = XIMS::VLibSubject->new( id => $subjectid );
    $subject->name( $self->param('name') );
    $subject->description( $self->param('description') );
    if ( !$subject->update() ) {
        return $self->sendError( $ctxt, "Error updating Subject." );
    }
    XIMS::Debug(6,"Subject updated");
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) );
    return 0;
}

sub event_subject_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $subjectid = $self->param('subject_id');

    unless ( $subjectid ) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new( name => $subjectname, document_id => $ctxt->object()->document_id() );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }
    # View kind of intro page for the selected subject. Just for public use.
    # call the library with the param subject_view=1
    if ( $ctxt->apache()->dir_config('ximsPublicUserName') ) {
        XIMS::Debug(5,"Viewing subject");
        #$ctxt->properties->content->escapebody(1);
        $ctxt->properties->application->style( "subject_view" ) ;
    } else {
        $self->sendError( $ctxt, "Viewing of a subject is only available for public use." );
    }
    return 0;
}

sub event_subject_edit {
    # edit the subject name and description
    # call the library with the param subject_edit=1

    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # operation control section
    # whole VLibrary is locked if subject is edited
    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }
    $ctxt->properties->application->style( "subject_edit" ) ;

    if ( $self->object_locked( $ctxt ) ) {
        XIMS::Debug( 3, "Attempt to edit locked object" );
        $self->sendError( $ctxt,
                            "This object is locked by " .
                            $object->locker->firstname() .
                            " " . $object->locker->lastname() .
                            " since " . $object->locked_time() .
                            ". Please try again later." );
    }
    else {
        if ( $object->lock() ) {
            XIMS::Debug( 4, "lock set" );
            $ctxt->session->message( "Obtained lock. Please use 'Save' or 'Cancel' to release the lock!" );
        }
        else {
            XIMS::Debug( 3, "lock not set" );
        }
    }

    my $subjectid = $self->param('subject_id');
    unless ( $subjectid ) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new( name => $subjectname, document_id => $object->document_id() );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    XIMS::Debug(5,"Editing subject");
    return 0;
}

sub event_keywords {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( "keywords" );

    return 0;
}

sub event_keyword {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $keywordid = $self->param('keyword_id');
    unless ( $keywordid ) {
        my $keywordname = XIMS::decode( $self->param('keyword_name') );
        if ( defined $keywordname ) {
            my $keyword = XIMS::VLibKeyword->new( name => $keywordname );
            if ( $keyword and $keyword->id() ) {
                $keywordid = $keyword->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes( 1 );

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = 10;
    $offset = $offset * $rowlimit;

    my @objects = $ctxt->object->vlitems_bykeyword_granted( keyword_id => $keywordid,
                                                    limit => $rowlimit,
                                                    offset => $offset,
                                                    order => 'title'
                                                  );
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
    unless ( $authorid ) {
        my $authorfirstname  = XIMS::decode( $self->param('author_firstname') );
        my $authormiddlename = XIMS::decode( $self->param('author_middlename') );
        my $authorlastname   = XIMS::decode( $self->param('author_lastname') );

        my $author;
        my $author_type;
        if ( $authorlastname and $authorfirstname ) {
            XIMS::Debug( 4, "high chance for personal author" );
            $author = XIMS::VLibAuthor->new( firstname  => $authorfirstname,
                                             middlename => $authormiddlename,
                                             lastname   => $authorlastname );
            if ( $author and $author->id() ) {
                $author_type = "personal";
            }
        }

        unless ( $author_type ) {
            if ( $authorlastname ) {
                XIMS::Debug( 4, "high chance for corporate author" );
                $author = XIMS::VLibAuthor->new( lastname    => $authorlastname,
                                                 object_type => 1 );
                if ( $author and $author->id() ) {
                    $author_type = "corporate";
                }
            }
            else { return 0; }
        }

        if ( $author_type ) {
            $authorid = $author->id();
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes( 1 );

    my @objects = $ctxt->object->vlitems_byauthor_granted(  author_id => $authorid,
                                                            order => 'title'
                                                         );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

sub event_author_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # operation control section
    # whole VLibrary is locked if subject is edited
    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( "author_edit" );

    if ( $self->object_locked( $ctxt ) ) {
        XIMS::Debug( 3, "Attempt to edit locked object" );
        $self->sendError( $ctxt,
                          "This object is locked by " .
                          $object->locker->firstname() .
                          " " . $object->locker->lastname() .
                          " since " . $object->locked_time() .
                          ". Please try again later." );
    }
    else {
        if ( $object->lock() ) {
            XIMS::Debug( 4, "lock set" );
            $ctxt->session->message( "Obtained lock. Please use 'Save' or 'Cancel' to release the lock!" );
        }
        else {
            XIMS::Debug( 3, "lock not set" );
        }
    }


    my $authorid = $self->param('author_id');
    my $author;

    if (defined $authorid and $authorid) {
        $author = XIMS::VLibAuthor->new(id => $authorid, document_id => $object->document_id());
    }
    else {
         $author = XIMS::VLibAuthor->new();
    }
    $ctxt->objectlist( [$author] );
    return 0;
}

sub event_author_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();


    my $id = $self->param('vlauthor_id');
    my $firstname = XIMS::clean($self->param('vlauthor_firstname')) || '';
    my $middlename = XIMS::clean($self->param('vlauthor_middlename')) || '';
    my $lastname = XIMS::clean($self->param('vlauthor_lastname')) || '';
    my $suffix = XIMS::clean($self->param('vlauthor_suffix')) || '';
    my $objecttype = XIMS::clean($self->param('vlauthor_object_type'));
    my $url = XIMS::clean($self->param('vlauthor_url'));
    my $email = XIMS::clean($self->param('vlauthor_email'));
    my $vlibauthor;

    if (defined $id and $id) {
        $vlibauthor = XIMS::VLibAuthor->new( id => $id, document_id => $object->document_id() );
    }
    else {
        $vlibauthor = XIMS::VLibAuthor->new();
        $vlibauthor->document_id( $object->parent_id() );
    }

    if ( ref $vlibauthor ) {
        $vlibauthor->firstname( $firstname );
        $vlibauthor->middlename( $middlename );
        $vlibauthor->lastname( $lastname );
        $vlibauthor->suffix( $suffix );
        $vlibauthor->email( $email );
        $vlibauthor->url( $url );

        if (defined $objecttype and $objecttype ) {
            $vlibauthor->object_type(1);
        }
        else {
            $vlibauthor->object_type(0);
        }
        unless ( $vlibauthor->id() ) {
            if ( not $vlibauthor->create() ) {
                XIMS::Debug( 3, "could not create author" );
                next;
            }
        }
        else {
            if ($vlibauthor->update == 1) {
                XIMS::Debug(6, "Author: Update record successful.");
                $ctxt->properties->application->style( "objectlist" ) ;
            }
            else {
                XIMS::Debug(3, "Author: Update record failed.");
                return $self->sendError( $ctxt, "Author: Update record failed." );
            }
        }
    }
    else {
        XIMS::Debug(3, "Author: creation failed.");
        return $self->sendError( $ctxt, "Author: creation failed." );
    }

    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) );
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
    unless ( $publicationid ) {
        my $publicationname   = XIMS::decode( $self->param('publication_name') );
        my $publicationvolume = XIMS::decode( $self->param('publication_volume') );
        #XIMS::Debug( 6, "publicationname: $publicationname publicationvolume: $publicationvolume" );
        if ( $publicationname and $publicationvolume ) {
            my $publication = XIMS::VLibPublication->new( name   => $publicationname,
                                                          volume => $publicationvolume );
            #use Data::Dumper; XIMS::Debug( 1, Dumper( $publication ) );
            if ( $publication and $publication->id() ) {
                $publicationid = $publication->id();
                #XIMS::Debug( 6, "secondary lookup on publicationid returned: $publicationid" );
            }
            else { return 0; }
        }
        else { return 0; }
    }


    $ctxt->properties->content->getformatsandtypes( 1 );

    my @objects = $ctxt->object->vlitems_bypublication_granted(  publication_id => $publicationid,
                                                         order => 'title'
                                                      );
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

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        $self->SUPER::event_publish( $ctxt );
        return 0 if $ctxt->properties->application->style() eq 'error';

        $object->grant_user_privileges (  grantee         => XIMS::PUBLICUSERID(),
                                          privilege_mask  => ( XIMS::Privileges::VIEW ),
                                          grantor         => $user->id() );
    }
    else {
        return $self->event_access_denied( $ctxt );
    }

    return 0;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        $self->SUPER::event_unpublish( $ctxt );
        return 0 if $ctxt->properties->application->style() eq 'error';

        my $privs_object = XIMS::ObjectPriv->new( grantee_id => XIMS::PUBLICUSERID(), content_id => $object->id() );
        $privs_object->delete();
    }
    else {
        return $self->event_access_denied( $ctxt );
    }

    return 0;
}

sub event_vlsearch {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $search = $self->param('vls');
    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    $offset ||= 0;
    my $rowlimit = 10;
    $offset = $offset * $rowlimit;

    XIMS::Debug( 6, "param $search");
    # length within 2..30 chars
    if ( defined $search and length($search) >= 2 and length($search) <= 30 ) {
        my $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split(':',$qbdriver))[1];
        $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();

        eval "require $qbdriver"; #
        if ( $@ ) {
            XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
            $ctxt->send_error( "QueryBuilder-Driver could not be found!" );
            return 0;
        }

        use encoding "latin-1";
        my $allowed = XIMS::decode( q{\!a-zA-Z0-9��������%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~} ); ## just for emacs' font-lock... ;-)
        my $qb = $qbdriver->new( { search => $search, allowed => $allowed, fieldstolookin => [qw(title abstract body)] } );

        if ( defined $qb ) {
            my %param = (
                        criteria => $qb->criteria(),
                        limit => $rowlimit,
                        offset => $offset,
                        order => $qb->order(),
                        start_here => $ctxt->object(),
                        );
            my @objects = $ctxt->object->find_objects_granted( %param );

            if ( not @objects ) {
                $ctxt->session->warning_msg( "Query returned no objects!" );
            }
            else {
                %param = ( criteria => $qb->criteria(), start_here => $ctxt->object() );
                my $count = $ctxt->object->find_objects_granted_count( %param );
                my $message = "Query returned $count objects.";
                $message .= " Displaying objects " . ($offset+1) if $count >= $rowlimit;
                $message .= " to " . ($offset+$rowlimit) if ( $offset+$rowlimit <= $count );
                $ctxt->session->message( $message );
                $ctxt->session->searchresultcount( $count );
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

sub event_most_recent {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my %param = ( order => 'last_modification_timestamp DESC' );
    if ( $self->param('mn') ) {
        $param{marked_new} = 1;
    }
    else {
        $param{limit} = 10;
    }

    my @objects = $ctxt->object->children_granted( %param );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}


sub event_vlchronicle {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $date_from = $self->_heuristic_date_parser( $self->param('chronicle_from') );
    my $date_to = $self->_heuristic_date_parser( $self->param('chronicle_to') );

    XIMS::Debug( 6, "Chronicle from $date_from to $date_to.");

    my $onepage = $self->param('onepage');
    my %param;
    if ( not defined $onepage ) {
        my $offset = $self->param('page');
        $offset = $offset - 1 if $offset;
        my $rowlimit = 10; # TODO: remove hardcoded setting
        $offset = $offset * $rowlimit;

        $param{limit} = $rowlimit;
        $param{offset} = $offset;


        my $count = $ctxt->object->vlitems_bydate_granted_count( from => $date_from , to => $date_to, %param );
        my $message = "Query returned $count objects.";
        $message .= " Displaying objects " . ($offset+1) if $count >= $rowlimit;
        $message .= " to " . ($offset+$rowlimit) if ( $offset+$rowlimit <= $count );
        $ctxt->session->message( $message );
        $ctxt->session->searchresultcount( $count );
    }

    my @objects = $ctxt->object->vlitems_bydate_granted( from => $date_from , to => $date_to, %param );

    $ctxt->objectlist( \@objects );
    $ctxt->properties->content->objectlistpassthru( 1 );
    $ctxt->properties->content->getformatsandtypes( 1 );

    my $style = $self->param('style');
    if ( defined $style ) {
        $ctxt->properties->application->style( $style );
    }
    else {
        $ctxt->properties->application->style( "objectlist" ) ;
    }

    return 0;
}

sub event_simile {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $date_from = $self->_heuristic_date_parser( $self->param('chronicle_from') );
    my $date_to = $self->_heuristic_date_parser( $self->param('chronicle_to') );

    if ( not $date_from and not $date_to ) {
        $ctxt->session->message( 'Loading all chronicle data may take a lot of time. Consider providing a filter time span!' );
    }

    # Get first chronicle entry for positioning the chronicle starting point
    my @objects = $ctxt->object->vlitems_bydate_granted( from => $date_from, limit => 1 );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->content->objectlistpassthru( 1 );
    $ctxt->properties->content->getformatsandtypes( 1 );
    $ctxt->properties->application->style( 'simile' );

    return 0;
}

# sub event_publish_simile ?!

sub _heuristic_date_parser {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $date = shift;

    my @ts_formats = (
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d",
        "%d.%m.%Y",
        "%m/%d/%Y",
        "%m/%d/%y",
        "%m.%Y",
        "%m.%y",
        "%Y-%m",
        "%Y",
         );

    my $timestamp;
    foreach my $format ( @ts_formats ) {
        eval { $timestamp = Time::Piece->strptime( $date, $format ); };
        if ( not $@ and defined $timestamp ) {
            last;
        }
    }

    if ( defined $timestamp ) {
        return $timestamp->strftime("%Y-%m-%d %H:%M:%S");
    }
    else {
        # Let the DB date parser try its luck if the heuristics failed
        return $date;
    }
}

# END RUNTIME EVENTS
# #############################################################################
1;
