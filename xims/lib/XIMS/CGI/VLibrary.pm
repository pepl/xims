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
          keywords
          keyword
          authors
          author
          publications
          publication
          vlsearch
          most_recent
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

sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, "Deleting VLibraries is not implemented." );
}

sub event_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, "Deleting VLibraries is not implemented." );
}

sub event_subject {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $subjectid = $self->param('subject_id');
    unless ( $subjectid ) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new( name => $subjectname );
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
    my $rowlimit = 5;
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
    my $rowlimit = 5;
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
    my $rowlimit = 5;
    $offset = $offset * $rowlimit;

    XIMS::Debug( 6, "param $search");
    # length within 2..30 chars
    if (( length($search) >= 2 ) && ( length($search) <= 30 )) {
        my $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split(':',$qbdriver))[1];
        $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();

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

    my %param = ( limit => 5, order => 'last_modification_timestamp DESC' );
    if ( $self->param('mn') ) {
        $param{marked_new} = 1;
    }

    my @objects = $ctxt->object->children_granted( %param );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style( "objectlist" ) ;

    return 0;
}

# END RUNTIME EVENTS
# #############################################################################
1;
