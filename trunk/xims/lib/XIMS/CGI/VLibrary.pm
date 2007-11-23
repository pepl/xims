
=head1 NAME

XIMS::CGI::VLibrary -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibrary;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::VLibrary;

use strict;
use base qw(XIMS::CGI::Folder);
use Data::Dumper;

use Time::Piece;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub registerEvents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    XIMS::CGI::registerEvents(
        $self,
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
            author_delete_prompt
            author_delete
            publications
            publication
            vlsearch
            vlchronicle
            most_recent
            simile
            filter
            filter_create
            )
    );
}

# #############################################################################
# RUNTIME EVENTS

sub event_init {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->sax_generator('XIMS::SAX::Generator::VLibrary');
    return $self->SUPER::event_init($ctxt);
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default($ctxt);
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->resolve_content( $ctxt, [qw( STYLE_ID )] );

    return $self->SUPER::event_edit($ctxt);
}

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt,
        "Copying VLibraries is not implemented." );
}

# jokar: Enable deletion of Vlibraries. Metadata is not deleted
# (Authors, Keywords, Subjects, ...)

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

    unless ($subjectid) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new(
                name        => $subjectname,
                document_id => $ctxt->object()->document_id()
            );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes(1);

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = 10;
    $offset = $offset * $rowlimit;

    my @objects = $ctxt->object->vlitems_bysubject_granted(
        subject_id => $subjectid,
        limit      => $rowlimit,
        offset     => $offset,
        order      => 'title'
    );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

    return 0;
}

# store edited subject name and description
# call the library with the param subject_store=1
sub event_subject_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();

    my $subjectid = $self->param('subject_id');

    unless ($subjectid) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new(
                name        => $subjectname,
                document_id => $object->document_id()
            );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    XIMS::Debug( 5, "Updating subject" );
    my $subject = XIMS::VLibSubject->new( id => $subjectid );
    $subject->name( $self->param('name') );
    $subject->description( $self->param('description') );
    if ( !$subject->update() ) {
        return $self->sendError( $ctxt, "Error updating Subject." );
    }
    XIMS::Debug( 6, "Subject updated" );
    _update_or_publish($ctxt); # update the VLibrary's timestamps
    $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) );
    return 0;
}

sub event_subject_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $subjectid = $self->param('subject_id');

    unless ($subjectid) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new(
                name        => $subjectname,
                document_id => $ctxt->object()->document_id()
            );
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
        XIMS::Debug( 5, "Viewing subject" );

        #$ctxt->properties->content->escapebody(1);
        $ctxt->properties->application->style("subject_view");
    }
    else {
        $self->sendError( $ctxt,
            "Viewing of a subject is only available for public use." );
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
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }
    $ctxt->properties->application->style("subject_edit");

    if ( $self->object_locked($ctxt) ) {
        XIMS::Debug( 3, "Attempt to edit locked object" );
        $self->sendError( $ctxt,
                  "This object is locked by "
                . $object->locker->firstname() . " "
                . $object->locker->lastname()
                . " since "
                . $object->locked_time()
                . ". Please try again later." );
    }
    else {
        if ( $object->lock() ) {
            XIMS::Debug( 4, "lock set" );
            $ctxt->session->message(
                "Obtained lock. Please use 'Save' or 'Cancel' to release the lock!"
            );
        }
        else {
            XIMS::Debug( 3, "lock not set" );
        }
    }

    my $subjectid = $self->param('subject_id');
    unless ($subjectid) {
        my $subjectname = XIMS::decode( $self->param('subject_name') );
        if ( defined $subjectname ) {
            my $subject = XIMS::VLibSubject->new(
                name        => $subjectname,
                document_id => $object->document_id()
            );
            if ( $subject and $subject->id() ) {
                $subjectid = $subject->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    XIMS::Debug( 5, "Editing subject" );
    return 0;
}

sub event_keywords {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style("keywords");

    return 0;
}

sub event_keyword {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $keywordid = $self->param('keyword_id');
    unless ($keywordid) {
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

    $ctxt->properties->content->getformatsandtypes(1);

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = 10;
    $offset = $offset * $rowlimit;

    my @objects = $ctxt->object->vlitems_bykeyword_granted(
        keyword_id => $keywordid,
        limit      => $rowlimit,
        offset     => $offset,
        order      => 'title'
    );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

    return 0;
}

sub event_authors {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style("authors");

    return 0;
}

sub event_author {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $authorid = $self->param('author_id');
    unless ($authorid) {
        my $authorfirstname
            = XIMS::decode( $self->param('author_firstname') );
        my $authormiddlename
            = XIMS::decode( $self->param('author_middlename') );
        my $authorlastname = XIMS::decode( $self->param('author_lastname') );

        my $author;
        my $author_type;
        if ( $authorlastname and $authorfirstname ) {
            XIMS::Debug( 4, "high chance for personal author" );
            $author = XIMS::VLibAuthor->new(
                firstname  => $authorfirstname,
                middlename => $authormiddlename,
                lastname   => $authorlastname,
                document_id => $ctxt->object->document_id(),
            );
            if ( $author and $author->id() ) {
                $author_type = "personal";
            }
        }

        unless ($author_type) {
            if ($authorlastname) {
                XIMS::Debug( 4, "high chance for corporate author" );
                $author = XIMS::VLibAuthor->new(
                    lastname    => $authorlastname,
                    object_type => 1,
                    document_id => $ctxt->object->document_id(),
                );
                if ( $author and $author->id() ) {
                    $author_type = "corporate";
                }
            }
            else { return 0; }
        }

        if ($author_type) {
            $authorid = $author->id();
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes(1);

    my @objects = $ctxt->object->vlitems_byauthor_granted(
        author_id => $authorid,
        order     => 'title'
    );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

    return 0;
}

sub event_author_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # operation control section
    # whole VLibrary is locked if author is edited
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    $ctxt->properties->application->style("author_edit");

    if ( $self->object_locked($ctxt) ) {
        XIMS::Debug( 3, "Attempt to edit locked object" );
        $self->sendError( $ctxt,
                  "This object is locked by "
                . $object->locker->firstname() . " "
                . $object->locker->lastname()
                . " since "
                . $object->locked_time()
                . ". Please try again later." );
    }
    else {
        if ( $object->lock() ) {
            XIMS::Debug( 4, "lock set" );
            $ctxt->session->message(
                "Obtained lock. Please use 'Save' or 'Cancel' to release the lock!"
            );
        }
        else {
            XIMS::Debug( 3, "lock not set" );
        }
    }

    my $authorid = $self->param('author_id');
    my $author;

    if ( defined $authorid and $authorid ) {
        $author = XIMS::VLibAuthor->new(
            id          => $authorid,
            document_id => $object->document_id()
        );
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
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();

    my $id         = $self->param('vlauthor_id');
    my $firstname  = XIMS::clean( $self->param('vlauthor_firstname') )  || '';
    my $middlename = XIMS::clean( $self->param('vlauthor_middlename') ) || '';
    my $lastname   = XIMS::clean( $self->param('vlauthor_lastname') )   || '';
    my $suffix     = XIMS::clean( $self->param('vlauthor_suffix') )     || '';
    my $objecttype = XIMS::clean( $self->param('vlauthor_object_type')  || '');
    my $url        = XIMS::clean( $self->param('vlauthor_url')          || '');
    my $image_url  = XIMS::clean( $self->param('vlauthor_image_url')    || '');
    my $email      = XIMS::clean( $self->param('vlauthor_email')        || '');
    my $vlibauthor;

    XIMS::Debug( 6, "id: $id firstname: $firstname middlename: $middlename "
                  . "lastname: $lastname suffix: $suffix "
                  . "objecttype: $objecttype url: $url image_url: $image_url"
                  . "email: $email" );

    if ( defined $id and $id ) {
        $vlibauthor = XIMS::VLibAuthor->new(
            id          => $id,
            document_id => $object->document_id()
        );
    }
    else {
        # create new VLibAuthor
        $vlibauthor = XIMS::VLibAuthor->new();
        $vlibauthor->document_id( $object->document_id() );
    }

    if ( ref $vlibauthor ) {
        $vlibauthor->firstname($firstname);
        $vlibauthor->middlename($middlename);
        $vlibauthor->lastname($lastname);
        $vlibauthor->suffix($suffix);
        $vlibauthor->email($email);
        $vlibauthor->url($url);
        $vlibauthor->image_url($image_url);

        if ( defined $objecttype and $objecttype ) {
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
            if ( $vlibauthor->update == 1 ) {
                _update_or_publish($ctxt); # update the VLibrary's timestamps
                XIMS::Debug( 6, "VLibAuthor: Update record successful." );
                $ctxt->properties->application->style("objectlist");
            }
            else {
                XIMS::Debug( 3, "VLibAuthor: Update record failed." );
                return $self->sendError( $ctxt,
                    "Author: Update record failed." );
            }
        }
    }
    else {
        XIMS::Debug( 3, "Author: creation failed." );
        return $self->sendError( $ctxt, "Author: creation failed." );
    }

    return 0;
}

sub event_author_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # operation control section
    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    $ctxt->properties->application->style('author_delete_prompt');

    if ( $self->object_locked($ctxt) ) {
        XIMS::Debug( 3, "Attempt to edit locked object" );
        $self->sendError( $ctxt,
                  "This object is locked by "
                . $object->locker->firstname() . " "
                . $object->locker->lastname()
                . " since "
                . $object->locked_time()
                . ". Please try again later." );
    }
    else {
        if ( $object->lock() ) {
            XIMS::Debug( 4, "lock set" );
            $ctxt->session->message(
                "Obtained lock. Please use 'Save' or 'Cancel' to release the lock!"
            );
        }
        else {
            XIMS::Debug( 3, "lock not set" );
        }
    }

    return 0;
}

sub event_author_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();

    my $id = $self->param('vlauthor_id');
    my $vlibauthor;

    if ( defined $id and $id ) {
        $vlibauthor = XIMS::VLibAuthor->new(
            id          => $id,
            document_id => $object->document_id(),
        );
    }

    if ( defined $vlibauthor and $vlibauthor->delete ) {
        _update_or_publish($ctxt); # update the VLibrary's timestamps
        XIMS::Debug( 6, "VLibAuthor $id: deleted!" );
    }
    else {
        XIMS::Debug( 3, "VLibAuthor $id: deletion failed!" );
    }

    return 0;
}

sub event_publications {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style("publications");

    return 0;
}

sub event_publication {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $publicationid = $self->param('publication_id');
    unless ($publicationid) {
        my $publicationname
            = XIMS::decode( $self->param('publication_name') );
        my $publicationvolume
            = XIMS::decode( $self->param('publication_volume') );

        #XIMS::Debug( 6, "publicationname: $publicationname publicationvolume: $publicationvolume" );
        if ( $publicationname and $publicationvolume ) {
            my $publication = XIMS::VLibPublication->new(
                name   => $publicationname,
                volume => $publicationvolume
            );

            #use Data::Dumper; XIMS::Debug( 1, Dumper( $publication ) );
            if ( $publication and $publication->id() ) {
                $publicationid = $publication->id();

                #XIMS::Debug( 6, "secondary lookup on publicationid returned: $publicationid" );
            }
            else { return 0; }
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes(1);

    my @objects = $ctxt->object->vlitems_bypublication_granted(
        publication_id => $publicationid,
        order          => 'title'
    );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

    return 0;
}

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv
        = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied($ctxt)
        unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user     = $ctxt->session->user();
    my $object   = $ctxt->object();
    my $objprivs = $user->object_privmask($object);

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        $self->SUPER::event_publish($ctxt);
        return 0 if $ctxt->properties->application->style() eq 'error';

        $object->grant_user_privileges(
            grantee        => XIMS::PUBLICUSERID(),
            privilege_mask => (XIMS::Privileges::VIEW),
            grantor        => $user->id()
        );
    }
    else {
        return $self->event_access_denied($ctxt);
    }

    return 0;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user     = $ctxt->session->user();
    my $object   = $ctxt->object();
    my $objprivs = $user->object_privmask($object);

    if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
        $self->SUPER::event_unpublish($ctxt);
        return 0 if $ctxt->properties->application->style() eq 'error';

        my $privs_object = XIMS::ObjectPriv->new(
            grantee_id => XIMS::PUBLICUSERID(),
            content_id => $object->id()
        );
        $privs_object->delete();
    }
    else {
        return $self->event_access_denied($ctxt);
    }

    return 0;
}

sub event_vlsearch {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user   = $ctxt->session->user();
    my $search = $self->param('vls');
    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    $offset ||= 0;
    my $rowlimit = 10;
    $offset = $offset * $rowlimit;

    XIMS::Debug( 6, "param $search" );

    # length within 2..30 chars
    if ( defined $search and length($search) >= 2 and length($search) <= 30 )
    {
        my $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split( ':', $qbdriver ) )[1];
        $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();

        eval "require $qbdriver";    #
        if ($@) {
            XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
            $ctxt->send_error("QueryBuilder-Driver could not be found!");
            return 0;
        }

        use encoding "latin-1";
        my $allowed = XIMS::decode(
            q{\!a-zA-Z0-9öäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~})
            ;                        ## just for emacs' font-lock... ;-)
        my $qb = $qbdriver->new(
            {   search         => $search,
                allowed        => $allowed,
                fieldstolookin => [qw(title abstract body)]
            }
        );

        if ( defined $qb ) {
            my %param = (
                criteria   => $qb->criteria(),
                limit      => $rowlimit,
                offset     => $offset,
                order      => $qb->order(),
                start_here => $ctxt->object(),
            );

            my @objects = $ctxt->object->find_objects_granted(%param);

            if ( not @objects ) {
                $ctxt->session->warning_msg("Query returned no objects!");
            }
            else {
                %param = (
                    criteria   => $qb->criteria(),
                    start_here => $ctxt->object()
                );
                my $count = $ctxt->object->find_objects_granted_count(%param);
                my $message = "Query returned $count objects.";
                $message .= " Displaying objects " . ( $offset + 1 )
                    if $count >= $rowlimit;
                $message .= " to " . ( $offset + $rowlimit )
                    if ( $offset + $rowlimit <= $count );
                $ctxt->session->message($message);
                $ctxt->session->searchresultcount($count);
            }

            $ctxt->objectlist( \@objects );
            $ctxt->properties->application->style("objectlist");
        }
        else {
            XIMS::Debug( 3, "please specify a valid query" );
            $self->sendError( $ctxt, "Please specify a valid query!" );
        }
    }
    else {
        XIMS::Debug( 3, "catched improper query length" );
        $self->sendError( $ctxt,
            "Please keep your queries between 2 and 30 characters!" );
    }

    return 0;
}


#
# event filter_create
#
# opens a windows where the URL for a filtered objectlist 
# is created
#
sub event_filter_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    $ctxt->properties->application->style("filter_create");

    return 0;
}

#
# event filter
#
# The following criteria can be filtered:
#     subjects (by subject_ids coma seperated)
#     keywords (by keyword_id coma seperated)
#     authors (by author_ids coma seperated)
#     mediatype (as text, just one type possible)
#     chronicle (chronicle_from - chronicle_to)
#     fulltext (with querybuilder)
#
# this event could replace the events: subject, author, keyword, vlsearch, vlchronicle, keyword
#
# in the %criteria-hash are the SQL-Conditions as a string. 
# Only date, fulltext and mediatype conditions are with parameters
# in the %params-list are the values for parameters for the date 
# and fulltext conditions
#
# still half-baked, would be nice to move the whole SQL into
# Vlibrary-object and just call vlitems_byfilter_granted which does
# the SQL-things. Quick and dirty, I know :-/
#
sub event_filter {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user   = $ctxt->session->user();

    # Build filter criteria
    my %criteria = ();
    my %params = ();
    
    # subjects
    my $subject_ids = $self->param('sid');
    if ( defined $subject_ids ) {
        XIMS::Debug( 6, "subject param '$subject_ids'" );
        $criteria{subjects} = " sm.document_id = d.id AND sm.subject_id IN ( $subject_ids ) ";
    }
    # keywords
    my $keyword_ids = $self->param('kid');
    if ( defined $keyword_ids ) {
        XIMS::Debug( 6, "keyword param '$keyword_ids'" );
        $criteria{keywords} = " km.document_id = d.id AND km.keyword_id IN ( $keyword_ids ) ";
    }
    
    # authors
    # not implemented yet
    
    # mediatype
    my $mediatype = $self->param('mt');
    if ( defined $mediatype ) {
        XIMS::Debug( 6, "mediatype param '$mediatype'" );
        $criteria{mediatype} = " m.mediatype = ? ";
        $params{mediatype} = $mediatype;
    }

    # chronicle dates
    my $date_from = $self->_heuristic_date_parser( $self->param('cf') );
    my $date_to = $self->_heuristic_date_parser( $self->param('ct') );
    if ( defined $date_from ) {
        XIMS::Debug( 6, "date_from param '$date_from'" );
    }
    if ( defined $date_to ) {
        XIMS::Debug( 6, "date_to param '$date_to'" );
    }
    if ( ( defined $date_from ) or ( defined $date_to ) ) {
        my %date_conditions_values = $ctxt->object->_date_conditions_values( $date_from, $date_to );
        $criteria{chronicle} = $date_conditions_values{conditions};
        $params{chronicle} = $date_conditions_values{values};
    }

    # fulltext search
    my $text = $self->param('vls') ;

    if ( defined $text ) {
        XIMS::Debug( 6, "fulltext param $text" );
        # length within 2..30 chars
        if ( length($text) >= 2 and length($text) <= 30 )
        {
            my $qbdriver = XIMS::DBDSN();
            $qbdriver = ( split( ':', $qbdriver ) )[1];
            $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();

            eval "require $qbdriver";    #
            if ($@) {
                XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
                $ctxt->send_error("QueryBuilder-Driver could not be found!");
                return 0;
            }

            use encoding "latin-1";
            my $allowed = XIMS::decode(
                q{\!a-zA-Z0-9öäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~});
            my $qb = $qbdriver->new(
                {   search         => $text,
                    allowed        => $allowed,
                    fieldstolookin => [qw(title abstract body)]
                }
            );
            if ( defined $qb ) {
                my $textcriteria = $qb->criteria();
                $criteria{text} = shift( @{$textcriteria} );
                $params{text} = $textcriteria;
            }
            else {
                XIMS::Debug( 3, "please specify a valid query" );
                $self->sendError( $ctxt, "Please specify a valid query!" );
                return 0;
            }
        }
        else {
            XIMS::Debug( 3, "catched improper query length" );
            $self->sendError( $ctxt, "Please keep your queries between 2 and 30 characters!" );
            return 0;
        }
    }
    # end of building filter criteria

    # parameters for diplaying result 
    
    # pagination
    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    $offset ||= 0;
    
    my $rowlimit = $self->param('rowlimit');
    # rowlimit = 0 means no limit (display all results)
    if ( ( !defined $rowlimit ) or ( $rowlimit != 0 ) ) {
        $rowlimit = 10;
    }
    $offset = $offset * $rowlimit;
    
    # order of the result 
    #   chrono: chronicle date from
    #   alpha: Title
    #   create: creation date 
    #   modify: modification date
    my $order = $self->param('order');
    if ( ( !defined $order ) or ( $order eq '' ) ) {
        $order = 'alpha';
    }

    XIMS::Debug(6,"Filter criteria:" . Dumper(%criteria));
    XIMS::Debug(6,"Filter params:" . Dumper(%params));
    
    #define parameters for query
    my %param = (
        criteria   => \%criteria,
        params     => \%params,
        limit      => $rowlimit,
        offset     => $offset,
        order      => $order,
        start_here => $ctxt->object(),
    );

    my @objects = $ctxt->object->vlitems_byfilter_granted( %param );

    if ( not @objects ) {
        $ctxt->session->warning_msg("Query returned no objects!");
    }
    else {
        %param = (
            criteria   => \%criteria,
            params     => \%params,
            start_here => $ctxt->object()
        );
        my $count = $ctxt->object->vlitems_byfilter_granted_count( %param );
        my $message = "Query returned $count objects.";
        $message .= " Displaying objects " . ( $offset + 1 ) if $count >= $rowlimit;
        $message .= " to " . ( $offset + $rowlimit ) if ( $offset + $rowlimit <= $count );
        $ctxt->session->message($message);
        $ctxt->session->searchresultcount($count);
    }

    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

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

    my @objects = $ctxt->object->children_granted(%param);
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

    return 0;
}

sub event_vlchronicle {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $date_from
        = $self->_heuristic_date_parser( $self->param('chronicle_from') );
    my $date_to
        = $self->_heuristic_date_parser( $self->param('chronicle_to') );

    XIMS::Debug( 6, "Chronicle from $date_from to $date_to." );

    my $onepage = $self->param('onepage');
    my %param;
    if ( not defined $onepage ) {
        my $offset = $self->param('page');
        $offset = $offset - 1 if $offset;
        my $rowlimit = 10;    # TODO: remove hardcoded setting
        $offset = $offset * $rowlimit;

        $param{limit}  = $rowlimit;
        $param{offset} = $offset;

        my $count = $ctxt->object->vlitems_bydate_granted_count(
            from => $date_from,
            to   => $date_to,
            %param
        );
        my $message = "Query returned $count objects.";
        $message .= " Displaying objects " . ( $offset + 1 )
            if $count >= $rowlimit;
        $message .= " to " . ( $offset + $rowlimit )
            if ( $offset + $rowlimit <= $count );
        $ctxt->session->message($message);
        $ctxt->session->searchresultcount($count);
    }

    my @objects = $ctxt->object->vlitems_bydate_granted(
        from => $date_from,
        to   => $date_to,
        %param
    );

    $ctxt->objectlist( \@objects );
    $ctxt->properties->content->objectlistpassthru(1);
    $ctxt->properties->content->getformatsandtypes(1);

    my $style = $self->param('style');
    if ( defined $style ) {
        $ctxt->properties->application->style($style);
    }
    else {
        $ctxt->properties->application->style("objectlist");
    }

    return 0;
}

sub event_simile {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $date_from
        = $self->_heuristic_date_parser( $self->param('chronicle_from') );
    my $date_to
        = $self->_heuristic_date_parser( $self->param('chronicle_to') );

    if ( not $date_from and not $date_to ) {
        $ctxt->session->message(
            'Loading all chronicle data may take a lot of time. Consider providing a filter time span!'
        );
    }

    # Get first chronicle entry for positioning the chronicle starting point
    my @objects = $ctxt->object->vlitems_bydate_granted(
        from  => $date_from,
        limit => 1
    );
    $ctxt->objectlist( \@objects );
    $ctxt->properties->content->objectlistpassthru(1);
    $ctxt->properties->content->getformatsandtypes(1);
    $ctxt->properties->application->style('simile');

    return 0;
}

# sub event_publish_simile ?!

# END RUNTIME EVENTS
# #############################################################################

sub _heuristic_date_parser {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $date = shift;

    my @ts_formats = (
        "%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%d.%m.%Y", "%m/%d/%Y",
        "%m/%d/%y",          "%m.%Y",    "%m.%y",    "%Y-%m",
        "%Y",
    );

    my $timestamp;
    foreach my $format (@ts_formats) {
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

# call update or publish on the VLibrary itself to set the timestamps and void
# the cache for AxKit::AxKit::Provider::XIMSGoPublic.
sub _update_or_publish {
    my $ctxt = shift;
    if ( $ctxt->object->published() == 1 ) {
        $ctxt->object->publish();
    }
    else {
        $ctxt->object->update();
    }
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

