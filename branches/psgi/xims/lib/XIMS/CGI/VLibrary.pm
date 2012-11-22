
=head1 NAME

XIMS::CGI::VLibrary

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::VLibrary;

=head1 DESCRIPTION

The VLibrary CGI methods

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::VLibrary;

use strict;
use base qw(XIMS::CGI::Folder);

use Time::Piece;
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

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
          obj_acllight
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          subject
          subject_view
          keywords
          keyword
          authors
          author
          publications
          publication
          property_edit
          property_show
          property_store
          property_delete_prompt
          property_delete
          list_properties_items
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

=head2 event_init()

=cut

sub event_init {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->sax_generator('XIMS::SAX::Generator::VLibrary');
    return $self->SUPER::event_init($ctxt);
}

=head2 event_default()

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default($ctxt);
}

=head2 event_edit()

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->resolve_content( $ctxt, [qw( STYLE_ID )] );

    return $self->SUPER::event_edit($ctxt);
}

=head2 event_copy()

=cut

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    return $self->sendError( $ctxt, __"Copying VLibraries is not implemented." );
}


##############################################################################
# begin subjects
##############################################################################

=head2 event_subject()

=cut

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

    my $display_params = $self->get_display_params($ctxt);

    my @objects = $ctxt->object->vlitems_bysubject_granted(
        subject_id => $subjectid,
        limit      => $display_params->{limit},
        offset     => $display_params->{offset},
        order      => $display_params->{order},
    );

    $ctxt->objectlist( \@objects );
    $ctxt->objectlist_info(
        $ctxt->object->this_propertyinfo( 'subject' => $subjectid ) );

    $ctxt->properties->application->style("objectlist");

    return 0;
}

=head2 event_subject_view()

=cut

sub event_subject_view {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $subjectid = $self->param('subject_id');
    if ( defined $subjectid ) {
        my $subject = XIMS::VLibSubject->new( id => $subjectid, );
        if ( defined $subject  ) {
            $ctxt->objectlist( $subject ); # abuse objectlist
        }
        else {
             return 0;
        }
    }
    else {
        return 0;
    }

    # View kind of intro page for the selected subject. Just for public use.
    # call the library with the param subject_view=1
    if ( $self->session->auth_module() eq 'XIMS::Auth::Public' ) {
        XIMS::Debug( 5, "Viewing subject" );

        #$ctxt->properties->content->escapebody(1);
        $ctxt->properties->application->style("subject_view");
    }
    else {
        $self->sendError( $ctxt,
            __"Viewing of a subject is only available for public use." );
    }
    return 0;
}

##############################################################################
# end subjects, begin keywords
##############################################################################

=head2 event_keywords()

=cut

sub event_keywords {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getformatsandtypes(1);

    $ctxt->properties->application->style("keywords");

    return 0;
}

=head2 event_keyword()

=cut

sub event_keyword {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $keywordid = $self->param('keyword_id');
    unless ($keywordid) {
        my $keywordname = XIMS::decode( $self->param('keyword_name') );
        if ( defined $keywordname ) {
            my $keyword = XIMS::VLibKeyword->new(
                name        => $keywordname,
                document_id => $ctxt->object()->document_id(),
            );
            if ( $keyword and $keyword->id() ) {
                $keywordid = $keyword->id();
            }
            else { return 0; }
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes(1);

    my $display_params = $self->get_display_params($ctxt);

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = XIMS::SEARCHRESULTROWLIMIT();
    $offset = $offset * $rowlimit;

    my @objects = $ctxt->object->vlitems_bykeyword_granted(
        keyword_id => $keywordid,
        limit      => $display_params->{limit},
        offset     => $display_params->{offset},
        order      => $display_params->{order},
    );
    $ctxt->objectlist( \@objects );
    $ctxt->objectlist_info(
        $ctxt->object->this_propertyinfo( 'keyword' => $keywordid ) );
    $ctxt->properties->application->style("objectlist");

    return 0;
}


##############################################################################
# end keywords, begin authors
##############################################################################

=head2 event_authors()

=cut

sub event_authors {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getformatsandtypes(1);

    $ctxt->properties->application->style("authors");

    return 0;
}

=head2 event_author()

=cut

sub event_author {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $authorid = $self->param('author_id');

    unless ($authorid) {
        my $authorfirstname = XIMS::decode( $self->param('author_firstname') );
        my $authormiddlename =
          XIMS::decode( $self->param('author_middlename') );
        my $authorlastname = XIMS::decode( $self->param('author_lastname') );

        my $author;
        my $author_type;
        if ( $authorlastname and $authorfirstname ) {
            XIMS::Debug( 4, "high chance for personal author" );
            $author = XIMS::VLibAuthor->new(
                firstname   => $authorfirstname,
                middlename  => $authormiddlename,
                lastname    => $authorlastname,
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

    my $display_params = $self->get_display_params($ctxt);

    my @objects = $ctxt->object->vlitems_byauthor_granted(

        author_id => $authorid,
        limit     => $display_params->{limit},
        offset    => $display_params->{offset},
        order     => $display_params->{order},
    );

    $ctxt->objectlist( \@objects );
    $ctxt->objectlist_info(
        $ctxt->object->this_propertyinfo( 'author' => $authorid ) );

    $ctxt->properties->application->style("objectlist");

    return 0;
}


##############################################################################
# end authors, begin publications
##############################################################################

=head2 event_publications()

=cut

sub event_publications {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->content->getformatsandtypes(1);

    $ctxt->properties->application->style("publications");

    return 0;
}

=head2 event_publication()

=cut

sub event_publication {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $publicationid = $self->param('publication_id');
    unless ($publicationid) {
        my $publicationname = XIMS::decode( $self->param('publication_name') );
        my $publicationvolume =
          XIMS::decode( $self->param('publication_volume') );

        #XIMS::Debug( 6, "publicationname: $publicationname publicationvolume:
        #$publicationvolume" );
        if ( $publicationname and $publicationvolume ) {
            my $publication = XIMS::VLibPublication->new(
                name        => $publicationname,
                volume      => $publicationvolume,
                document_id => $ctxt->object()->document_id(),
            );

            #use Data::Dumper; XIMS::Debug( 1, Dumper( $publication ) );
            if ( $publication and $publication->id() ) {
                $publicationid = $publication->id();

                #XIMS::Debug( 6, "secondary lookup on publicationid returned:
                #$publicationid" );
            }
            else { return 0; }
        }
        else { return 0; }
    }

    $ctxt->properties->content->getformatsandtypes(1);

    my $display_params = $self->get_display_params($ctxt);

    my @objects = $ctxt->object->vlitems_bypublication_granted(
        publication_id => $publicationid,
        limit          => $display_params->{limit},
        offset         => $display_params->{offset},
        order          => $display_params->{order},
    );
    $ctxt->objectlist( \@objects );
    $ctxt->objectlist_info(
        $ctxt->object->this_propertyinfo( 'publication' => $publicationid ) );
    $ctxt->properties->application->style("objectlist");

    return 0;
}



##############################################################################
# end publications
##############################################################################

=head2 event_property_edit()

=cut

sub event_property_edit {
	XIMS::Debug( 5, "called" );
	#warn "\n\n property_edit \n\n";
    my ( $self, $ctxt ) = @_;

    unless ( $self->_privcheck_lock($ctxt) ) {
        return $self->event_access_denied($ctxt);
    }

    my $property = $self->param('property');

    if ( $property !~ /^(subject|author|publication|keyword)$/ ) {
        return $self->simple_response(
            '400 BAD REQUEST',
"ERROR: Property must be one of: subject, author, publication, or keyword!"
        );
    }

    my $class  = "XIMS::VLib" . ucfirst($property);
    my $id     = $self->param('property_id');
    my $vlibproperty;

    if ( defined $id and $id ) {
        $vlibproperty = $class->new(
            id          => $id,
            document_id => $ctxt->object()->document_id(),
        );
    }
    else {
        $vlibproperty = $class->new();
    }

    $ctxt->objectlist( [$vlibproperty] );

    # Hacked-on TinyMCE editable subjects description, an »Extrawurst« for
    # ZIS.
    my $ed = '';

    if ($property eq 'subject') {
        # XXX calling foreign internal methods is certainly not not ugly...
        $ed = XIMS::CGI::Document::_set_wysiwyg_editor($self, $ctxt);
        # either Plain or HTMLArea
        if (length($ed)) {$ed = '_tinymce';}
    }

    $ctxt->properties->application->style("${property}_edit${ed}");
    return 0;

}

=head2 event_property_show()

=cut

sub event_property_show {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $property = $self->param('property');

    if ( $property !~ /^(subject|author|publication|keyword)$/ ) {
        return $self->simple_response(
            '400 BAD REQUEST',
"ERROR: Property must be one of: subject, author, publication, or keyword!"
        );
    }

    my $class = "XIMS::VLib" . ucfirst( $self->param('property') );
    my $id = $self->param('property_id');
    my $vlproperty;

    if ( defined $id and $id ) {
        $vlproperty = $class->new(
            id          => $id,
            document_id => $ctxt->object()->document_id()
        );
    }
    else {
        return $self->sendError( $ctxt, __"Missing property_id" );
    }

    $ctxt->objectlist( [$vlproperty] );

    $ctxt->properties->application->style("${property}_show");

    return 0;
}

=head2 event_property_store()

=cut

sub event_property_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $property = $self->param('property');
    my $objid = $self->param('objid');

    if ( $property !~ /^(subject|author|publication|keyword)$/ ) {
        return $self->simple_response(
            '400 BAD REQUEST',
"ERROR: Property must be one of: subject, author, publication, or keyword!"
        );
    }

    unless ( $ctxt->session->user->object_privmask($object) &
        XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();

    my %fields;
    my $vlibpublication;
    my $class = "XIMS::VLib" . ucfirst($property);

    my $vlibproperty = $class->new();

    foreach ( $vlibproperty->fields() ) {
        if ( $_ eq 'document_id' ) {
            $fields{$_} = $object->document_id();
        }
        else {
            $fields{$_} =  XIMS::clean( $self->param("vl${property}_${_}") );
        }
    }

    #use Data::Dumper;
    #warn Dumper(\%fields);

    if ( $fields{'id'} ) {
        # create new object by id if set
        $vlibproperty = $class->new(
            id          => $fields{'id'},
        );
    }
#    if ( $fields{'property_id'} ) {
#        # create new object by id if set
#        $vlibproperty = $class->new(
#            id          => $fields{'property_id'},
#        );
#    }
    if ( ref $vlibproperty ) {
        foreach ($vlibproperty->fields()) {
            next if $_ eq 'id';
            $vlibproperty->$_( $fields{$_} );
        }
warn "\n\nproperty_id: ".$vlibproperty->id();
        if ( $vlibproperty->id() ) {    # update property
            if ( $vlibproperty->update == 1 ) {
                _update_or_publish($ctxt);    # update the VLibrary's timestamps
                XIMS::Debug( 6, "$class: Update record successful." );
			$self->redirect( $self->redirect_path($ctxt)."?".$property."s=1");
            }
            else {
                XIMS::Debug( 3, "$class: Update record failed." );
                return $self->sendError( $ctxt,
                    __"Property: Update record failed." );
            }
        }
        else {                                # create property
            if ( $vlibproperty->create() ) {
                _update_or_publish($ctxt);    # update the VLibrary's timestamps
                XIMS::Debug( 6, "$class: Update record successful." );
                #warn "\n\n".$objid." - ".$self->redirect_path( $ctxt, $objid )."\n\n";
                $self->redirect( $self->redirect_path( $ctxt, $objid )."?edit=1" );
            }
            else {
                XIMS::Debug( 3, "could not create $class" );
                next;
            }
        }
    }
    else {
        XIMS::Debug( 3, "$class: creation failed." );
        return $self->sendError( $ctxt, "$class: " . __"Creation failed." );
    }

    return 0;
}

=head2 event_property_delete_prompt()

=cut

sub event_property_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $self->_privcheck_lock($ctxt) ) {
        return $self->event_access_denied($ctxt);
    }

    $ctxt->properties->application->style('property_delete_prompt');

    return 0;
}

=head2 event_property_delete()

=cut

sub event_property_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    unless ( $ctxt->session->user->object_privmask($object) &
        XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    XIMS::Debug( 6, "unlocking object" );
    $object->unlock();

    my $id = $self->param('property_id');

    if ( $self->param('property') !~ /^(subject|author|publication|keyword)$/ )
    {
        return $self->simple_response(
            '400 BAD REQUEST',
"ERROR: Property must be one of: subject, author, publication, or keyword!"
        );
    }

    my $class = "XIMS::VLib" . ucfirst( $self->param('property') );

    my $vlibproperty;

    if ( defined $id and $id ) {
        $vlibproperty = $class->new(
            id          => $id,
            document_id => $object->document_id(),
        );
    }

    if ( defined $vlibproperty and $vlibproperty->delete ) {
        _update_or_publish($ctxt);    # update the VLibrary's timestamps
        XIMS::Debug( 6, "$class $id: deleted!" );
        #return $self->simple_response( '200 OK', "$class deleted." );
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) );
    }
    else {
        XIMS::Debug( 3, "$class $id: deletion failed!" );
        #return $self->simple_response( '409 CONFLICT',
         #   "ERROR: $class $ctxt, "ERROR: $class $id: deletion failed!");
    }
    return 0;
}

=head2 event_publish_prompt()

=cut

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv =
      $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied($ctxt)
      unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    return 0;
}

=head2 event_list_properties_items()

=cut

sub event_list_properties_items {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $property = $self->param('property');

    if ( $property !~ /^(subject|author|publication|keyword)$/ ) {
        return $self->simple_response(
            '400 BAD REQUEST',
"ERROR: Property must be one of: subject, author, publication, or keyword!"
        );
    }

    unless ( $ctxt->session->user->object_privmask($object) &
        XIMS::Privileges::WRITE )
    {
        return $self->event_access_denied($ctxt);
    }

    # we need this information in XIMS::SAX::Generator::VLibrary;
    $ctxt->objectlist_info($property);

    $ctxt->properties->application->style('list_properties_items');

    return 0;

}

=head2 event_publish()

=cut

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

=head2 event_unpublish()

=cut

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
        $privs_object->delete() if $privs_object;
    }
    else {
        return $self->event_access_denied($ctxt);
    }

    return 0;
}

=head2 event_vlsearch()

=cut

sub event_vlsearch {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user   = $ctxt->session->user();
    my $search = $self->param('vls');
    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    $offset ||= 0;
    my $rowlimit = XIMS::SEARCHRESULTROWLIMIT();
    $offset = $offset * $rowlimit;

    XIMS::Debug( 6, "param $search" );

    # length within 2..30 chars
    if ( defined $search and length($search) >= 2 and length($search) <= 30 ) {
        my $qbdriver = XIMS::DBDSN();
        $qbdriver = ( split( ':', $qbdriver ) )[1];
        $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();
        ## no critic (ProhibitStringyEval)
        eval "require $qbdriver";
        if ($@) {
            XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
            $ctxt->send_error(__"QueryBuilder-Driver could not be found!");
            return 0;
        }
        ## use critic
        use encoding "latin-1";
        my $allowed =
          XIMS::decode(
            q{\!a-zA-Z0-9öäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~})
          ;    ## just for emacs' font-lock... ;-)
        my $qb = $qbdriver->new(
            {
                search         => $search,
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
                $ctxt->session->warning_msg(__"Query returned no objects!");
            }
            else {
                %param = (
                    criteria   => $qb->criteria(),
                    start_here => $ctxt->object()
                );
                my $count   = $ctxt->object->find_objects_granted_count(%param);
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
            $self->sendError( $ctxt, __"Please specify a valid query!" );
        }
    }
    else {
        XIMS::Debug( 3, "catched improper query length" );
        $self->sendError( $ctxt,
            __"Please keep your queries between 2 and 30 characters!" );
    }

    return 0;
}


=head2 event_filter_create()

opens a windows where the URL for a filtered objectlist is created

=cut

sub event_filter_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    $ctxt->properties->application->style("filter_create");

    return 0;
}


=head2 event_filter()

Supported Parameters:

=head3 filter criteria

=over

=item sid, kid, aid, pid

vlsubjects (sid), vlkeywords (kid), vlauthors (aid) and vlpublications (pid):

multiple ids comma separated get ORed  (e.g.: ...sid=1,2;...)

multiple parameters get ANDed (e.g.: ...sid=1;sid=2;...)

=item mt

mediatype as text, just one type possible

=item pbl

publisher

=item cf, ct

chronicle (chronicle_from - chronicle_to)

=item sto

status operator

=item vls

fulltext (with querybuilder)

=back

=head3 Order and pagination

=over

=item order

Change the default sort order by putting I<asc> or I<desc> after the keyword.
Comma separate keywords to sort by more than one attribute.

Example:

    order=dc.date,alpha+desc

=over

=item chrono

chronicle date from (default asc)

=item alpha

Title (default asc)

=item loctn

Location (default desc)

=item create

creation date (default desc)

=item modify

 modification date (default desc)

=item dc.date

meta.dc_date (default desc)

=back

=item page

Display page number page

=item rowlimit

How much results to display on one page

=item pagerowlimit

Added later for consistency with other parts of the system. Used only if
rowlimit is unset; thence rowlimit overrides pagerowlimit. Some things depend
on this behavior, so please don't change it.

=back

=head3 Trivia (old comments from the code)

This event could replace the events: subject, author, keyword, vlsearch,
vlchronicle, keyword

In the %criteria-hash are the SQL-Conditions as a string. Only date, fulltext
and mediatype conditions are with parameters in the %params-list are the
values for parameters for the date and fulltext conditions

still half-baked, would be nice to move the whole SQL into Vlibrary-object and
just call vlitems_byfilter_granted which does the SQL-things.

Ugly.

=cut


sub event_filter {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();

    my $order = $self->param('order');

    # Build filter criteria
    my %criteria = ();
    my %params   = ();

    # properties: vlsubject, vlauthor, vlkeyword, vlpublication
    foreach ( ['sid', 'subject'],
              ['aid', 'author'],
              ['kid', 'keyword'],
              ['pid', 'publication'] ) {
        my ( $par, $p ) = @{$_};

        foreach my $prop_ids ( $self->param($par) ) {
            next unless defined $prop_ids and length $prop_ids;

            XIMS::Debug( 6, "$p param '$prop_ids'" );

            my @prop_ids = split( ',', $prop_ids );
            $criteria{vlprop}
                .= " AND EXISTS (SELECT 1 FROM cilib_${p}map "
                    ."WHERE cilib_${p}map.document_id = d.id AND cilib_${p}map.${p}_id IN ("
                    . join( ',', map {'?'} @prop_ids ) . '))';

            push @{ $params{vlprop} }, @prop_ids;
        }
    }

    # object_type
    my $object_type_ids = $self->param('otid');
    if ( defined $object_type_ids and length $object_type_ids ) {
        XIMS::Debug( 6, "object_type_id param '$object_type_ids'" );
        my @object_type_ids = split(',',$object_type_ids);
        $criteria{object_type_id} =
          " d.object_type_id IN (" . join( ',', map { '?' } @object_type_ids ) . ')';
        $params{object_type_id} = \@object_type_ids;
    }

    # mediatype
    my $mediatype = $self->param('mt');
    if ( defined $mediatype and length $mediatype ) {
        XIMS::Debug( 6, "mediatype param '$mediatype'" );
        $criteria{mediatype} = " m.mediatype = ? ";
        $params{mediatype}   = $mediatype;
    }

    # publisher
    my $publisher = $self->param('pbl');
    if ( defined $publisher and length $publisher ) {
        XIMS::Debug( 6, "publisher param '$publisher'" );
        $criteria{publisher} = " m.publisher LIKE ? ";
        $params{publisher}   = "\%$publisher\%";
    }

    # status operator
    my $statusoperator = $self->param('sto');
    $statusoperator ||= '=';
    if ( defined $statusoperator and $statusoperator =~ /^(=|>|<)$/ ) {
        XIMS::Debug( 6, "statusoperator param '$statusoperator'" );

        # status
        my $status = $self->param('status');
        if ( defined $status and $status =~ /^\d+$/ ) {
            XIMS::Debug( 6, "status param '$status'" );
            $criteria{status} = " c.status $statusoperator ? ";
            $params{status}   = $status;
        }
    }

    # chronicle dates
    my $date_from = $self->_heuristic_date_parser( $self->param('cf') );
    my $date_to   = $self->_heuristic_date_parser( $self->param('ct') );
    if ( defined $date_from ) {
        XIMS::Debug( 6, "date_from param '$date_from'" );
    }
    if ( defined $date_to ) {
        XIMS::Debug( 6, "date_to param '$date_to'" );
    }
    if ( ( defined $date_from ) or ( defined $date_to ) ) {
        my %date_conditions_values =
          $ctxt->object->_date_conditions_values( $date_from, $date_to );
        $criteria{chronicle} = $date_conditions_values{conditions};
        $params{chronicle}   = $date_conditions_values{values};
        $order ||= 'chrono';
    }

    # fulltext search
    my $text = $self->param('vls');

    if ( defined $text and length $text ) {
        XIMS::Debug( 6, "fulltext param $text" );

        # length within 2..30 chars
        if ( length($text) >= 2 and length($text) <= 30 ) {
            my $qbdriver = XIMS::DBDSN();
            $qbdriver = ( split( ':', $qbdriver ) )[1];
            $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();
            ## no critic (ProhibitStringyEval)
            eval "require $qbdriver";
            if ($@) {
                XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
                $ctxt->send_error(__"QueryBuilder-Driver could not be found!");
                return 0;
            }
            ## use critic
            use encoding "latin-1";
            my $allowed =
              XIMS::decode(
                q{\!a-zA-Z0-9öäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~});
            my $qb = $qbdriver->new(
                {
                    search         => $text,
                    allowed        => $allowed,
                    fieldstolookin => [qw(title abstract body)]
                }
            );
            if ( defined $qb ) {
                my $textcriteria = $qb->criteria();
                $criteria{text} = shift( @{$textcriteria} );
                $params{text}   = $textcriteria;
            }
            else {
                XIMS::Debug( 3, "please specify a valid query" );
                $self->sendError( $ctxt, __"Please specify a valid query!" );
                return 0;
            }
        }
        else {
            XIMS::Debug( 3, "catched improper query length" );
            $self->sendError( $ctxt,
                __"Please keep your queries between 2 and 30 characters!" );
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

    # for consistency...
    $rowlimit ||= $self->param('pagerowlimit');

    # rowlimit = 0 means no limit (display all results)
    $rowlimit ||= XIMS::SEARCHRESULTROWLIMIT();
    $offset = $offset * $rowlimit;

    # order of the result
    #   chrono: chronicle date from
    #   alpha: Title
    #   loctn: Location
    #   create: creation date
    #   modify: modification date
    #   dc.date: meta.dc_date
    $order ||= 'modify';

    #XIMS::Debug( 6, "Filter criteria:" . Dumper(%criteria) );
    #XIMS::Debug( 6, "Filter params:" . Dumper(%params) );

    # define parameters for query
    my %param = (
        criteria   => \%criteria,
        params     => \%params,
        limit      => $rowlimit,
        offset     => $offset,
        order      => $order,
        start_here => $ctxt->object(),
    );

    my @objects = $ctxt->object->vlitems_byfilter_granted(%param);

    if ( not @objects ) {
        $ctxt->session->warning_msg(__"Query returned no objects!");
    }
    else {
        %param = (
            criteria   => \%criteria,
            params     => \%params,
            start_here => $ctxt->object()
        );
        my $count   = $ctxt->object->vlitems_byfilter_granted_count(%param);
        my $message = "Query returned $count objects.";
        $message .= " Displaying objects " . ( $offset + 1 )
          if $count >= $rowlimit;
        $message .= " to " . ( $offset + $rowlimit )
          if ( $offset + $rowlimit <= $count );
        $ctxt->session->message($message);
        $ctxt->session->searchresultcount($count);
    }

    $ctxt->objectlist( \@objects );

    my $style = $self->param('style');
    if ( defined $style ) {
        $ctxt->properties->application->style($style);
        $ctxt->properties->content->objectlistpassthru(1);
        $ctxt->properties->content->getformatsandtypes(1);
    }
    else {
        $ctxt->properties->application->style("objectlist");
    }

    return 0;
}

=head2 event_most_recent()

=cut

sub event_most_recent {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my %param = ( order => 'last_modification_timestamp DESC' );
    if ( $self->param('mn') ) {
        $param{marked_new} = 1;
    }
    else {
        $param{limit} =
          ( $self->param('pagerowlimit') > 0 )
          ? $self->param('pagerowlimit')
          : 10;
    }

    $ctxt->properties->content->getformatsandtypes(1);

    my @objects = $ctxt->object->children_granted(%param);
    $ctxt->objectlist( \@objects );
    $ctxt->properties->application->style("objectlist");

    return 0;
}

=head2 event_vlchronicle()

=cut

sub event_vlchronicle {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $date_from =
      $self->_heuristic_date_parser( $self->param('chronicle_from') );
    my $date_to = $self->_heuristic_date_parser( $self->param('chronicle_to') );

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

=head2 event_simile()

=cut

sub event_simile {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $date_from =
      $self->_heuristic_date_parser( $self->param('chronicle_from') );
    my $date_to = $self->_heuristic_date_parser( $self->param('chronicle_to') );

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

=head2 private functions/methods

=over

=item _heuristic_date_parser()

=item _update_or_publish()

=item _privcheck_lock()

=back

=cut

sub _heuristic_date_parser {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $date = shift;

    return undef unless length($date);

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

sub _privcheck_lock {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    # operation control section
    # whole VLibrary is locked if keyword is edited
    return
        unless ( $ctxt->session->user->object_privmask($object)
        & XIMS::Privileges::WRITE );

    if ( $self->object_locked($ctxt) ) {
        XIMS::Debug( 3, "Attempt to edit locked object" );
        $self->sendError(
            $ctxt,
            __x("This object is locked by {firstname} {lastname} since {locked_time}. Please try again later.",
                firstname   => $object->locker->firstname(),
                lastname    => $object->locker->lastname(),
                locked_time => $object->locked_time()
            )
        );
    }
    else {
        if ( $object->lock() ) {
            XIMS::Debug( 4, "lock set" );
            $ctxt->session->message(
                __"Obtained lock. Please use 'Save' or 'Cancel' to release the lock!"
            );
        }
        else {
            XIMS::Debug( 3, "lock not set" );
        }
    }
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

