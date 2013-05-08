
=head1 NAME

XIMS::CGI -- the XIMS CGI baseclass

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI;

=head1 DESCRIPTION

This module derives from CGI::XMLApplication. Most common events and helper
methods used in XIMS' CGI classes are implemented here.

=head1 EVENT METHODS

=cut

package XIMS::CGI;

use common::sense;
use parent qw(XIMS::XMLApplication);

use XIMS;
use XIMS::DataFormat;
use XIMS::ObjectType;
use XIMS::SAX;
use XIMS::ObjectPriv;
use XIMS::Importer;
use XML::LibXML::SAX::Builder;
use URI;
use Text::Iconv;
use Time::Piece;
use Locale::TextDomain ('info.xims');
use POSIX qw(LC_ALL setlocale);
use JSON::XS;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=head3 Parameter

A list of events to be added to the list of events implemented here.

=head3 Returns

A list of event_names.

=head3 Description

    $self->registerEvents( qw(some additional events) )

Derived classes may use this to register their own events.

=cut

sub registerEvents {
	my $self = shift;
	return (
		'dbhpanic',        'access_denied',  'move_browse',
		'move',            'copy',           'cancel',
		'contentbrowse',   'search',         'sitemap',
		'reposition',      'posview',        'plain',
		'trashcan_prompt', 'trashcan',       'delete',
		'delete_prompt',   'undelete',       'trashcan_content',
		'error',           'prettyprintxml', 'htmltidy',
		'aclgrantmultiple', 'aclrevokemultiple',
		'test_location',   @_
	);
}

=head2 event_init()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_init(...)

=cut

sub event_init {
	my $self = shift;
	my $ctxt = shift;

	$self->SUPER::event_init($ctxt);

	return $self->sendEvent('access_denied') unless $ctxt->session->user();
	return
	  unless $ctxt->object()
	  ;    # no object-ACL-check needed if we do not have a content object

	# ACL check
	if (
		length $self->checkPush('create')
		|| (    length $self->checkPush('store')
			and length $self->param('objtype') )
		|| (    length $self->checkPush('test_location')
			and length $self->param('objtype') )
	  )
	{

		my $objtype = $self->param('objtype');
		if ( not $objtype ) {
			$self->sendError( $ctxt,
				__ "Specify an object type to create an object!" );
			return $self->sendEvent('error');
		}

		my $parent = $ctxt->object();
		$ctxt->parent($parent)
		  ;    # used later in the app chain and for serialization

		my $privmask = $ctxt->session->user->object_privmask( $ctxt->object() );
		return $self->event_access_denied($ctxt)
		  unless $privmask & XIMS::Privileges::CREATE();

		my %obj = (
			parent_id   => $parent->document_id(),
			language_id => $parent->language_id(),
		);
		## no critic (ProhibitStringyEval)
		my $class = 'XIMS::' . $objtype;
		eval "require $class";
		if ($@) {
			XIMS::Debug( 2, "Can't find the object class: " . $@ );
			$self->sendError( $ctxt, __ "Can't find the object class: " . $@ );
			return $self->sendEvent('error');
		}
		## use critic
		$ctxt->object( $class->new( %obj, User => $ctxt->session->user ) );
	}
	else {
		my $privmask = $ctxt->session->user->object_privmask( $ctxt->object() );
		return $self->sendEvent('access_denied')
		  unless $privmask & XIMS::Privileges::VIEW();
	}
}

=head2 event_test_location()

=head3 Description

Runtime event which creates a valid location.

Event 'test_title' is called via AJAX.
It takes and returns a JSON-Objects. The JSON-Object sent contains the 
object-type and title. 
The returned object contains 
- a status code, 
- a human readable reason, 
- the generated location, 
- the chars valid for a location,
- maximum length of the location and
- a trimmed location (max length)

For now, there are four different response codes:
    0 =E<gt> Location (is) OK
    1 =E<gt> Location already exists (in container)
    2 =E<gt> No location provided (or location is not convertible)
    3 =E<gt> Dirty (no sane) location (location contains hilarious characters)

The test calls 'init_store_object' and traverses routines for cleaning/testing
the location.

=cut

sub event_test_location {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my ( $retval, $location );
	if ( defined $ctxt->object() ) {
		( $retval, $location ) = $self->init_store_object($ctxt);
	}

    $self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            -type    => 'application/json',
            -charset => ( XIMS::DBENCODING() ? XIMS::DBENCODING() : 'UTF-8' )
        )
    );
	$self->skipSerialization(1);

	XIMS::Debug( 4, "retval is: '$retval'; location is: '$location'" );

	# fill $response_blurb according to $retval
	my $response_blurb;
	if ( defined $retval and $retval != 0 ) {
		if ( $retval == 1 ) {
			$response_blurb = "Location '$location' already exists!";
		}
		elsif ( $retval == 2 ) {
			$response_blurb = "NO or BAD location provided!";
		}
		elsif ( $retval == 3 ) {
			$response_blurb = "Location '$location' NOT valid!";
		}
		else {
			XIMS::Debug( 4, "Return value, '$retval',  not known!" );
			$response_blurb = "Return value not known!";
		}
	}
	else {
		$response_blurb = "Location '$location' 0K!";
	}

	my $suggLocation = $location;

	my $json = JSON::XS->new->encode(
		{
			'status'   => $retval,
			'location' => $location,
			'reason'   => $response_blurb,

			#'valChars' => XIMS::CONFIG->LocationValidChars(),
			#'suggLength' => $suggLength,
			'suggLocation' => $suggLocation
		}
	);
	$self->{RES}->body($json);

	return 0;
}

=head2 event_dbhpanic()

=head3 Parameter

=head3 Returns

=head3 Description

     $self->event_dbhpanic(...)

=cut

sub event_dbhpanic {
	my $self = shift;
	$self->setPanicMsg( __ "Can not connect to database server." );
	return -4;
}

=head2 event_access_denied()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_access_denied(...)

=cut

sub event_access_denied {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$self->sendError( $ctxt, __ "Access Denied" );

	return 0;
}

=head2 event_default()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_default(...)

=cut

sub event_default {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

    my $goxims =  XIMS::CONTENTINTERFACE();
	# redirect to full path in case object is called via id
	if ( $self->path_info() eq ''
         and     $self->script_name() =~ /$goxims$/
         and not $ctxt->object->marked_deleted() )
	{

		# not needed anymore
		$self->delete('id');

		XIMS::Debug( 4, "redirecting to full path" );
		$self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) );

		return 1;
	}

	if ( $self->param('bodyonly') ) {
		$ctxt->properties->application->styleprefix('common');
		$ctxt->properties->application->style('bodyonly');
	}

	$ctxt->properties->content->getchildren->level(1);

	return 0;
}

=head2 event_edit()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_edit(...)

=cut

sub event_edit {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $r_type = $self->resource_type($ctxt);
	return $self->event_access_denied($ctxt) unless defined($r_type);

	$ctxt->properties->application->style("edit");

	#$ctxt->properties->content->dontescapestringprops( 1 );

	my $object = $ctxt->object();

	# operation control section
	unless ( $ctxt->session->user->object_privmask($object) &
		XIMS::Privileges::WRITE )
	{
		return $self->event_access_denied($ctxt);
	}

	if ( $self->object_locked($ctxt) ) {
		XIMS::Debug( 3, "Attempt to edit locked object" );
		$self->sendError(
			$ctxt,
			__x(
"This object is locked by {firstname} {lastname} since {locked_time}. Please try again later.",
				firstname   => $object->locker->firstname(),
				lastname    => $object->locker->lastname(),
				locked_time => $object->locked_time()
			)
		);
	}
	else {
		if ( $object->lock() ) {
			XIMS::Debug( 4, "lock set" );
			$ctxt->session->message( __
"Obtained lock. Please use 'Save' or 'Cancel' to release the lock!"
			);
		}
		else {
			XIMS::Debug( 3, "lock not set" );
		}
	}

	return 0;
}

=head2 event_create()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_create(...)

=cut

sub event_create {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	# check for CREATE privilege is done in event_init

	my $r_type = $self->resource_type($ctxt);
	return $self->event_access_denied($ctxt) unless defined($r_type);

	$ctxt->properties->application->style("create");

	return 0;
}

=head2 event_store()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_store(...)

=cut

sub event_store {
	XIMS::Debug( 5, "called" );
	my $self = shift;
	my $ctxt = shift;

	my $r_type = $self->resource_type($ctxt);
	return $self->event_access_denied($ctxt) unless defined($r_type);

	my $object = $ctxt->object();
	
	my $markednew = $self->param('markednew');
    if ( defined $markednew and $markednew eq 'on' ) {
        $object->data( marked_new => '1' );
    }
    else {
        $object->data( marked_new => '0' );
    }

	

	if ( not $ctxt->parent() ) {

		# Make sure to catch potential manually constructed requests...
		unless ( $ctxt->session->user->object_privmask($object) &
			XIMS::Privileges::WRITE )
		{
			return $self->event_access_denied($ctxt);
		}

		XIMS::Debug( 6, "unlocking object" );
		$object->unlock();
		XIMS::Debug( 4, "updating existing object" );
		if ( not $object->update() ) {
			XIMS::Debug( 2, "update failed" );
			$self->sendError( $ctxt, __ "Update of object failed." );
			return 0;
		}
		else {

			#publish on save option
			if ( $self->param('pubonsave') eq 'on' ) {

				#TODO: check user rights (usertype)
				$self->event_publish($ctxt);
			}
		}
		$self->redirect( $self->redirect_uri($ctxt) );
		return 1;
	}
	else {
		XIMS::Debug( 4, "creating new object" );
		if ( not $object->create() ) {
			XIMS::Debug( 2, "create failed" );
			$self->sendError( $ctxt, __ "Creation of object failed." );
			return 0;
		}

		XIMS::Debug( 4, "granting privileges" );

		my $owneronly = $self->param('owneronly');
		if ( defined $owneronly
			and ( $owneronly eq 'true' or $owneronly == 1 ) )
		{
			$owneronly = 1;
		}
		else {
			$owneronly = 0;
		}
		my $defaultroles = $self->param('defaultroles');
		if ( defined $defaultroles
			and ( $defaultroles eq 'true' or $defaultroles == 1 ) )
		{
			$defaultroles = 1;
		}
		else {
			$defaultroles = 0;
		}

		if ( $self->default_grants( $ctxt, $owneronly, $defaultroles, ) ) {
			XIMS::Debug( 4, "updated user privileges" );
		}
		else {
			$self->sendError( $ctxt, __ "failed to set default grants" );
			XIMS::Debug( 2, "failed to set default grants" );
			return 0;
		}
	}

	#publish on save option
	if ( $self->param('pubonsave') eq 'on' ) {

		#TODO: check user rights (usertype)
		$self->event_publish($ctxt);
	}
	XIMS::Debug( 4, "redirecting" );
	$self->redirect( $self->redirect_uri($ctxt) );
	return 1;
}

=head2 event_exit()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_exit(...)

=cut

sub event_exit {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	return 0;
}

=head2 event_trashcan_prompt()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_trashcan_prompt(...)

=cut

sub event_trashcan_prompt {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('trashcan_confirm');
}

=head2 event_delete_prompt()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_delete_prompt(...)

=cut

sub event_delete_prompt {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('delete_confirm');
}

=head2 event_cancel()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_cancel(...)

=cut

sub event_cancel {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $r_type = $self->resource_type($ctxt);
	return $self->event_access_denied($ctxt) unless defined($r_type);

	if ( $r_type eq 'object' ) {
		my $object = $ctxt->object();
		if ( $object->unlock() ) {
			XIMS::Debug( 4, "object has been un-locked" );
		}
		else {
			XIMS::Debug( 2, "object could not be unlocked!" );
			$self->sendError( $ctxt, __ "Object could not be unlocked!" );
			return 0;
		}
		XIMS::Debug( 4, "redirecting" );
		$self->redirect( $self->redirect_uri($ctxt) );
	}

	return 0;
}

=head2 event_plain()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_plain(...)

=cut

sub event_plain {

	# Give back only and really only the body of the object with its
	# content-type and the DB-Encoding
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $body = $ctxt->object->body();
	my $df   = XIMS::DataFormat->new( id => $ctxt->object->data_format_id() );

	# Since the body of Text and CSS objects is stored XML escaped, we want to
	# unescape it here again
	if ( $df->name() eq 'Text' or $df->name() eq 'CSS' ) {
		$body = XIMS::xml_unescape($body);
	}

	my $charset;
	if ( !( $charset = XIMS::DBENCODING ) ) { $charset = "UTF-8"; }

	$self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            -type => $df->mime_type,
            -charset => $charset,
        ),
        Encode::encode("UTF-8", $body)
    );
	$self->skipSerialization(1);

	return 0;
}

=head1 CGI::XMLApplication METHODS

Methods called directly by (or override to methods in) CGI::XMLApplication

=cut

=head2 selectStylesheet()

=head3 Parameter

    $ctxt : Application context object instance

=head3 Returns

File system path to selected XSL stylesheet to be used for request response
rendering.

=head3 Description

Selects stylesheet based on application context property settings, object type
of the current object, availability of language specific stylesheets and request
parameters. 

If the current request handle a content object, it's object type fullname
will be used as the first part of the stylesheet name (style prefix) unless 
$ctxt->properties->application->styleprefix() has a value and thus overrides.

The second part of the stylesheet name (style suffix) defaults to 'default' and
can be overriden via $ctxt->properties->application->style(). The style suffix 
will be set depending on the current event. Therefore, for Document object 
default event requests, the chosen stylesheet name will be 'document_default.xsl'

Based on current language, skin and public user requests different stylesheet paths
will be selected.

The base stylesheet path is 

XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/'

If the current request is served for the public user and the current object has
a stylesheet directory assigned, the presence of a corresponding stylesheet file
under that path is checked and used in case. The stylesheet base path for such cases
will be

XIMS::PUBROOT() . $stylesheet->location_path() . '/';

For publich user requests there the current object does not have a stylesheet 
directory assigned, the following stylesheet base path will be used:

XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/public/'

In both public and non-public user cases, the presence of a stylesheet file in a
language specific subdirectory of the stylesheet base path will be checked and
used in case. E.g. if a './en-us/document_default.xsl' file exists it will be used
in favor of './document_default.xsl' relative to the stylesheet base path.

Stylesheets in language specific subdirectories should only be used if it is not
possible to provide a complete I18N implementation via the stylesheets in the 
stylesheet base path. Because of historic reasons, there currently are still a lot
of stylesheets in the language specific subdirectories, which actually should be 
migrated into it's parent directories to keep the total number of stylesheet files
low.

=cut

sub selectStylesheet {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;
	my $retval = undef;

	my $stylesuffix = $ctxt->properties->application->style() || 'default';
	my $styleprefix = $ctxt->properties->application->styleprefix();
	if ( not defined $styleprefix ) {
		if ( $stylesuffix ne 'error' ) {
			$styleprefix = lc( $ctxt->object->object_type->fullname() );
			$styleprefix =~ s/::/_/g;
		}
	}
	$styleprefix ||= 'common';

	my $stylefilename = $styleprefix . '_' . $stylesuffix . '.xsl';

	# Buy easier stylesheet maintenance at the cost of one additional
	# stat call...
	my $stylepath =
	  XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/';

	# Emulate request.uri CGI param, set by
	# Apache::AxKit::Plugin::AddXSLParams::Request ($request.uri is
	# used by public/*.xsl stylesheets)
	if ( defined $ctxt->object ) {
		$self->param( 'request.uri', $ctxt->object->location_path_relative() );
	}
    # $self->query_string() is slow for some reason (says NYTProf);
	# $self->param( 'request.uri.query', $self->query_string() );
    # XXX reach down to Plack, pbly not sanitized...
    $self->param( 'request.uri.query', $self->{REQ}->env->{QUERY_STRING});

	my $gotpubuilangstylesheet;

    if ( $ctxt->session->auth_module eq 'XIMS::Auth::Public'
      or $ctxt->properties->application->usepubui() )
	{

		my $stylesheet = $ctxt->object->stylesheet();

		my $pubstylepath;
		my $filepath;
		my $filepathuilang;
		my $foundstylesheet;
		if ( defined $stylesheet and $stylesheet->published() ) {

			# check here if the stylesheet is not a directory but a
			# single XSLStylesheet?

			XIMS::Debug( 4,
				"trying public-user-stylesheet from assigned directory" );
			$pubstylepath =
			  XIMS::PUBROOT() . $stylesheet->location_path() . '/';
			$filepath       = $pubstylepath . $stylefilename;
			$filepathuilang =
			    $pubstylepath
			  . $ctxt->session->uilanguage() . '/'
			  . $stylefilename;
			if ( -f $filepathuilang and -r $filepathuilang ) {
				$stylepath              = $pubstylepath;
				$gotpubuilangstylesheet = 1;
				$foundstylesheet        = 1;
			}
			elsif ( -f $filepath and -r $filepath ) {
				$stylepath       = $pubstylepath;
				$foundstylesheet = 1;
			}
		}
		unless ($foundstylesheet) {
			XIMS::Debug( 4, "trying fallback public-user-stylesheet" );
			$pubstylepath =
			    XIMS::XIMSROOT()
			  . '/skins/'
			  . $ctxt->session->skin
			  . '/stylesheets/public/';
			$filepath       = $pubstylepath . $stylefilename;
			$filepathuilang =
			    $pubstylepath
			  . $ctxt->session->uilanguage() . '/'
			  . $stylefilename;
			if ( -f $filepathuilang and -r $filepathuilang ) {
				$stylepath              = $pubstylepath;
				$gotpubuilangstylesheet = 1;
			}
			elsif ( -f $filepath and -r $filepath ) {
				$stylepath = $pubstylepath;
			}
			else {
				XIMS::Debug( 4,
					"no public-user-stylesheet found, using default stylesheet"
				);
			}
		}
	}

	my $stylepathuilang =
	    $ctxt->session->uilanguage()
	  ? $stylepath . $ctxt->session->uilanguage() . '/'
	  : $stylepath;

	# Use a lang-specific stylesheet if there is one
	if ( -r ( $stylepathuilang . $stylefilename ) or $gotpubuilangstylesheet ) {
		$stylepath = $stylepathuilang;
	}

	$retval = $stylepath . $stylefilename;
	XIMS::Debug( 6, "stylesheet is '$retval'\n" );

	return $retval;
}

=head2 getDom()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->getDom(...)

=cut

sub getDOM {
	XIMS::Debug( 5, "called" );
	my $self = shift;
	my $ctxt = shift;
	my %handlerargs;

	my $generator =
	  defined $ctxt->sax_generator() ? $ctxt->sax_generator() : undef;
	my $filter = defined $ctxt->sax_filter() ? $ctxt->sax_filter() : [];
	my $handler = XML::LibXML::SAX::Builder->new();
	$handler->{Encoding} = XIMS::DBENCODING() if XIMS::DBENCODING();
	my $controller = XIMS::SAX->new(
		Handler    => $handler,
		Generator  => $generator,
		FilterList => $filter,
	);
	return unless $controller;
	return $controller->parse($ctxt);
}

=head2 setHttpHeader()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->setHttpHeader(...)

=cut

sub setHttpHeader {
	my $self       = shift;
	my $ctxt       = shift;
	my %my_headers = ();
	$my_headers{-cookie} = $ctxt->properties->application->cookie()
	  if defined $ctxt->properties->application->cookie();

	return %my_headers;
}

=head2 getXSLParameter()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->getXSLParameter(...)

=cut

sub getXSLParameter {
	my ( $self, $ctxt ) = @_;
	return %{ $self->Vars() };
}

=head2 sendError()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->sendError(...)

=cut

sub sendError {
	my $self        = shift;
	my $ctxt        = shift;
	my $msg         = shift;
	my $verbose_msg = shift;
    XIMS::Debug(5, "called '$msg', '$verbose_msg'");
	$ctxt->session->error_msg($msg);
	$ctxt->session->verbose_msg($verbose_msg) if defined $verbose_msg;
	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style("error");

    # use Data::Dumper;
    # warn Dumper ($ctxt);

	return 0;
}

=head2 simple_response()

=head3 Parameter

    $status: The status header's contents

    $msg: the message (body)

    $type: (optional) mimetype; defaults to 'text/plain'

=head3 Returns

    0.

=head3 Description

    $self->simple_response( '409 CONFLICT'
                          , 'Des darfst' nicht thun, Fisch!');

    $self->simple_response( '400 BAD REQUEST',
                          , '<error>You're gonking me.</error>'
                          , 'application/xml');

This is a simple method to send little custom responses. The message is
printed out literally. (No XSLT transformation.)

=cut


sub simple_response {
	my $self   = shift;
	my $status = shift;
	my $msg    = shift;
	my $type   = shift;

	$type = ( defined $type ) ? $type : 'text/plain';

	$self->{RES} = $self->{REQ}->new_response( 
        $self->psgi_header(
            -status  => $status,
            -type    => $type,
            -charset => ( XIMS::DBENCODING() ? XIMS::DBENCODING() : 'UTF-8' )
        ),
        "$msg\n"
    );

	$self->skipSerialization(1);

	return 0;
}

=head2 event_error()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_error(...)

=cut

sub event_error {
	return 0;
}

=head1 HELPER METHODS

Helper methods available to all event subs.

=head2 object_locked()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->object_locked(...)

=cut

sub object_locked {
	my $self = shift;
	my $ctxt = shift;
	if (    $ctxt->object->locked()
		and $ctxt->object->locked_by_id() ne $ctxt->session->user->id() )
	{
		return 1;
	}
	return;
}

=head2 redirect()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->redirect(...)

=cut

sub redirect {
	my ($self, $uri) = @_;
	XIMS::Debug( 6, "called " . join( ", ", @_ ) );

    (ref $uri and $uri->isa('URI')) ? $self->redirectToURI($uri->as_string()) : $self->redirectToURI($uri);
}

=head2 resource_type()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->resource_type(...)

Small helper to determine what sort of 'thingie' we are operating on (user,
content object, whatever we might add later)

=cut

sub resource_type {
	my $self = shift;
	my $ctxt = shift;

	if ( $ctxt->object() ) {
		return 'object';
	}
	elsif ( $ctxt->session->user() ) {
		return 'user';
	}
	else {
		return;
	}
}

=head2 expand_attributes()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->expand_attributes(...)

=cut

sub expand_attributes {
	my ( $self, $ctxt ) = @_;

	$ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
	push @{ $ctxt->sax_filter() }, "XIMS::SAX::Filter::Attributes";
}

=head2 resolve_content()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->resolve_content(...)

=cut

sub resolve_content {
	my $self      = shift;
	my $ctxt      = shift;
	my $list      = shift;
	my $reltosite = shift;

	return unless defined $list and scalar @$list;

	$ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();

	## no critic (ProhibitStringyEval)
	eval "require XIMS::SAX::Filter::ContentIDPathResolver;";
	if ($@) {
		XIMS::Debug( 2, "could not load ContentIDPathResolver: $@" );
		return 0;
	}
	## use critic
	my %args = (
		Provider       => $ctxt->data_provider(),
		ResolveContent => $list,
		NonExport      => 1,
	);

	push(
		@{ $ctxt->sax_filter() },
		XIMS::SAX::Filter::ContentIDPathResolver->new(%args)
	);
}

=head2 resolve_user()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->resolve_user(...)

=cut

sub resolve_user {
	my $self = shift;
	my $ctxt = shift;
	my $list = shift;

	return unless defined $list and scalar @$list;

	$ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
	## no critic (ProhibitStringyEval)
	eval "require XIMS::SAX::Filter::UserIDNameResolver;";
	if ($@) {
		XIMS::Debug( 2, "could not load UserIDNameResolver: $@" );
		return 0;
	}
	## use critic
	push(
		@{ $ctxt->sax_filter() },
		XIMS::SAX::Filter::UserIDNameResolver->new(
			Provider    => $ctxt->data_provider(),
			ResolveUser => $list,
		)
	);
}

=head2 redirect_uri()

=head3 Parameter
$ctxt, $id

=head3 Returns

    URI object

=head3 Description

    $self->redirect_uri(...)

=cut

sub redirect_uri {
	my ( $self, $ctxt, $id ) = @_;

	my $object = $ctxt->object();
	my $dp     = $ctxt->data_provider();

	my $redirectpath;
	my $r = $self->param('r');
	my $uri;
	if ( defined $r ) {
		if ( $r =~ /^\d+$/ ) {
			$redirectpath = $dp->location_path( id => $r );
			#warn "\nredirectpath: ".$redirectpath;
		}
		else {
			$uri = URI->new( $self->url(-absolute => 1) );
		}
	}
	elsif ( defined $id ) {
		$redirectpath = $dp->location_path( id => $id );
	}
	else {
		my $objtype = $object->object_type();
		if ( $objtype->redir_to_self() == 0 ) {
			$redirectpath =
			  $dp->location_path( document_id => $object->parent_id() );
		}
		else {
			$redirectpath =
			  $dp->location_path( document_id => $object->document_id() );
		}
	}

	# special case for '/root' which got an undefined location_path
	$redirectpath ||= '/root';

	my $sb           = $self->param("sb");
	my $order        = $self->param("order");
	my $m            = $self->param("m");
	my $hd           = $self->param("hd");
	my $hls          = $self->param("hls");
	my $bodyonly     = $self->param("bodyonly");
	my $plain        = $self->param("plain");
	my $page         = $self->param("page");
	my $showtrashcan = $self->param("showtrashcan");
	my $params;

	# preserve some selected params
	$params .= "sb=$sb" if defined $sb;
	if ( defined $m ) {
		$params .= ";" if length $params;
		$params .= "m=$m";
	}
	if ( defined $order ) {
		$params .= ";" if length $params;
		$params .= "order=$order";
	}
	if ( defined $hd ) {
		$params .= ";" if length $params;
		$params .= "hd=$hd";
	}
	if ( defined $hls ) {
		$params .= ";" if length $params;
		$params .= "hls=$hls";
	}

	if ( defined $bodyonly ) {
		$params .= ";" if length $params;
		$params .= "bodyonly=$bodyonly";
	}
	if ( defined $plain ) {
		$params .= ";" if length $params;
		$params .= "plain=$plain";
	}
	if ( defined $page ) {
		$params .= ";" if length $page;
		$params .= "page=$page";
	}
	if ( defined $showtrashcan ) {
		$params .= ";" if length $showtrashcan;
		$params .= "showtrashcan=$showtrashcan";
	}

	if ( not defined $uri ) {
		$uri = URI->new();
		$uri->path( $self->script_name() . $redirectpath );
		$uri->query($params);
	}

    # vermutlich PROXY-bezogen, schaumer später…
	# my $frontend_uri =
	#   URI->new( $ctxt->apache, $ctxt->session->serverurl() );
	# $uri->scheme( $frontend_uri->scheme() );
	# $uri->hostname( $frontend_uri->hostname() );
	# $uri->port( $frontend_uri->port() );

	XIMS::Debug( 4, "redirecting to " . $uri->as_string() );
	return $uri
}

=head2 clean_userquery()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->clean_userquery(...)

=cut

sub clean_userquery {
	XIMS::Debug( 5, "called" );
	my $self      = shift;
	my $userquery = shift;

	# convert wildcard, clean up a bit
	$userquery =~ s/\*+/%/g;
	$userquery =~ s/%+/%/g;
	$userquery =~ s/^\s+//;
	$userquery =~ s/\s+$//;
	$userquery =~ s/[ ;,<>`´|?]+//g;

	return $userquery;
}

=head2 set_wysiwyg_editor())=

=head3 Parameter

=head3 Returns

=head3 Description

    $self->set_wysiwyg_editor();

=cut
sub set_wysiwyg_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_wysiwygeditor';
    my $editor = $self->cookie($cookiename);
    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        $editor = undef;
    }
    elsif ($editor eq 'wepro') { 
        # we just dumped eWebEditPro, now change the remaining cookies
        $editor = 'tinymce';
    }
    elsif ( not(length $editor) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        $editor = lc( XIMS::DEFAULTXHTMLEDITOR() );
        
        my $cookie = $self->cookie( -name    => $cookiename,
                                    -value   => $editor,
                                    -expires => "+2160h"); # 90 days
        $ctxt->properties->application->cookie( $cookie );
    }
    my $ed = '';
    $ed = "_" . $editor if defined $editor;
    return $ed;
}

=head2 set_code_editor())=

=head3 Parameter

=head3 Returns

=head3 Description

    $self->set_code_editor();

=cut

sub set_code_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_codeeditor';
    my $editor = $self->cookie($cookiename);

    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        $editor = undef;
    }
    elsif ($editor eq 'codemirror') {
        # apply codemirror for syntax highlighting
        $editor = 'codemirror';
    }
    elsif ( not(length $editor) and length XIMS::DEFAULTXHTMLEDITOR() ) {
        $editor = 'codemirror';
        my $cookie = $self->cookie( -name    => $cookiename,
                                    -value   => $editor,
                                    -expires => "+2160h"); # 90 days
        $ctxt->properties->application->cookie( $cookie );
    }
    my $ed = '';
    $ed = "_" . $editor if defined $editor;
    return $ed;
}

=head2 init_store_object()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->init_store_object(...)

Returns status code and location for 'test_location' events (see event_test_location):
    0 => all OK
    1 => location already exists
    2 => no location provided
    3 => dirty location
    Otherwise, nothing meaningful ;-)

=cut

sub init_store_object {
	XIMS::Debug( 5, "called" );
	my $self = shift;
	my $ctxt = shift;

	my $object = $ctxt->object();
	my $parent;
	my $location = $self->param('name');    # is somehow xml-escaped magically
	                                        # by libxml2 (???)
    # do we have a 'test_location' AJAX event?
    my $is_event_test_location = $self->param('test_location');

	# $location will be part of the URI, converting to iso-8859-1 is a first
	# step before clean_location() to ensure browser compatibility
	my $converter = Text::Iconv->new( "UTF-8", "ISO-8859-1" );

	# will be undef if string can not be converted to iso-8859-1
	$location = $converter->convert($location) if defined $location;

	my $title    = $self->param('title');
	my $keywords = $self->param('keywords');
	my $abstract = $self->param('abstract');
	my $notes    = $self->param('notes');

	if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
		$title = XIMS::decode($title) if ( defined $title and length $title );
		$keywords = XIMS::decode($keywords)
		  if ( defined $keywords and length $keywords );
		$abstract = XIMS::decode($abstract)
		  if ( defined $abstract and length $abstract );
		$notes = XIMS::decode($notes) if ( defined $notes and length $notes );
	}

	if ( $object and $object->id() and length $self->param('id') ) {
		unless ( $ctxt->session->user->object_privmask($object) &
			XIMS::Privileges::WRITE )
		{
			return $self->event_access_denied($ctxt);
		}
		XIMS::Debug( 4, "storing existing object" );
		$parent = XIMS::Object->new( document_id => $object->parent_id );
	}
	else {
		$parent = $ctxt->parent();
	}

	if ( defined $location and length $location ) {
		if ( not $ctxt->properties->application->preservelocation ) {

			# some object types, like URLLink for example need the
			# location to be untouched
			$location = ( split /[\\|\/]/, $location )[-1]; # should always work
			XIMS::Debug( 4, "will now clean location: '$location'" );
			$location = XIMS::Importer::clean_location( $self, $location );
			XIMS::Debug( 4, "location is now: $location" );
			unless ( $ctxt->properties->application->keepsuffix ) {

				# some object type, like File or Image for example
				# don't want filesuffixes to be overridden by our data
				# format's default value
				my $suffix = $object->data_format->suffix();
				XIMS::Debug( 5, "suffix is: $suffix" );

				# temp. hack until multi-language support is implemented to
				# allow simple content-negotiation using .lang suffixes
				if ( defined $suffix and length $suffix ) {
					my $langpattern = join(
						'|',
						(
							map { $_->code() } $ctxt->data_provider->languages()
						),
						$suffix
					);
					unless ( $location =~ /.*\.$suffix(\.($langpattern))?$/ ) {

						# the following snippet homogenizes doc-suffixes:
						# eg. location 'test' becomes 'test.html' and
						#     location 'test.html' REMAINS 'test.html'!
						$location =~ s/\.(?:$suffix|$langpattern)\b//g;
						$location .= ".$suffix";
						XIMS::Debug( 6,
							"exchange done, location is now $location" );
					}

#                    else {
#                        # for transition, set language_id according to location
#                        # set language if known suffix
#                        if ( my @lg =grep { $_->{code} eq $1 } $ctxt->data_provider->languages()) {
#                            #$ctxt->object->{Language} = $lg[0]; # needed?
#                            $object->language_id( $lg[0]->id() );
#                        }
#                    }#end else
				}
			}

			# be more restrictive for valid locations (\w is too resilient)
			# only characters in char-class(es) are allowed explicitly
			unless (
				   ( $location =~ /^[-\[\]_.()0-9a-zA-Z]+\.[A-Za-z]+$/ )
				|| ( $location =~ /^[-\[\]_.()0-9a-zA-Z]+$/ )
				|| ( $location =~
					/^[-\[\]_.()0-9a-zA-Z]+\.[A-Za-z]+\.[A-Za-z]{2,4}$/ )
			  )
			{
				XIMS::Debug( 2, "dirty location" );

				# only send error for events other than 'test_location'
				# return 3 (dirty location) otherwise
				if ( not defined $is_event_test_location ) {
					$self->sendError( $ctxt,
						__
"Failed to clean the location / filename. Please supply a sane filename!"
					);
					return 0;
				}
				else {
					return ( 3, "$location" );
				}
			}
		}    #end do not preserve location

		XIMS::Debug( 4, "check for published object" );
		if (    ( $location ne $object->location() )
			and $object->published()
			and not $object->object_type->publish_gopublic()
			and $object->object_type->name() ne 'URLLink' )
		{    # URLLink is a special case for now.  Maybe we set
			    # publish_gopublic to 1 for it, or we will be adding an
			    # object-type property at the point when similar
			    # object-types will be added that do not have
			    # publish_gopublic set but are not published to the
			    # filesystem either
			$self->sendError( $ctxt,
				__
"Cannot rename this published object, please unpublish it first!"
			);
			return 0;
		}

		# check if the same location already exists in the current container
		# (and its a different object)
		if ( defined $parent ) {
			XIMS::Debug( 4, "check for existing location" );
			my @children = $parent->children(
				location       => $location,
				marked_deleted => 0
			);
			if (
				(
					    $object->id()
					and scalar @children == 1
					and $children[0]
					and $children[0]->id() != $self->param('id')
				)
				or ( not $object->id() and defined $children[0] )
			  )
			{
				XIMS::Debug( 2, "location already exists" );

				# only send error for events other than 'test_location'
				# return 1 (location already exists) otherwise
				if ( not defined $is_event_test_location ) {
					$self->sendError(
						$ctxt,
						__x(
"Location '{location}' already exists in container.",
							location => $location
						)
					);
					return 0;
				}
				else {
					return ( 1, $location );
				}
			}
		}    #end if(defined $parent)

		XIMS::Debug( 5, "got location: $location " );

		# positively exit for 'test_location' events, here
		if ( defined $is_event_test_location ) {
			return ( 0, $location );
		}
		$object->location($location);
	}
	else {
		XIMS::Debug( 3, "no location" );

		# only send error for events other than 'test_location'
		# return 2 (no location) otherwise
		if ( not defined $is_event_test_location ) {
			$self->sendError( $ctxt, __ "Please supply a valid location!" );
			return 0;
		}
		else {
			XIMS::Debug( 4, "exit" );
			return ( 2, "" );
		}
	}

	my $location_nosuffix = $location;
	$location_nosuffix =~ s/\.[^\.]+$//
	  unless $ctxt->properties->application->preservelocation();
	$object->title( $title || $location_nosuffix );

	my $markednew = $self->param('markednew');
	if ( defined $markednew ) {
		XIMS::Debug( 6, "markednew: $markednew" );
		if ( $markednew eq 'true' ) {
			$object->marked_new(1);
		}
		elsif ( $markednew eq 'false' ) {
			$object->marked_new(0);
		}
	}

	if ( defined $keywords ) {
		XIMS::Debug( 6, "keywords: $keywords" );
		$object->keywords($keywords);
	}

	# check if a valid abstract is given
	if ( defined $abstract
		and
		( length $abstract and $abstract !~ /^\s+$/ or not length $abstract ) )
	{
		XIMS::Debug( 6, "abstract, len: " . length($abstract) );
		$object->abstract($abstract);
	}

	# check if valid notes are given
	if ( defined $notes
		and ( length $notes and $notes !~ /^\s+$/ or not length $notes ) )
	{
		XIMS::Debug( 6, "notes, len: " . length($notes) );
		$object->notes($notes);
	}

	my $image = $self->param('image');
	if ( defined $image ) {
		XIMS::Debug( 6, "image: $image" );
		if ( length $image ) {
			my $imageobj;
			if (    $image =~ /^\d+$/
				and $imageobj = XIMS::Object->new( id => $image )
				and $imageobj->object_type->name() eq 'Image' )
			{
				$object->image_id( $imageobj->id() );
			}
			elsif ( $imageobj = XIMS::Object->new( path => $image )
				and $imageobj->object_type->name() eq 'Image' )
			{
				$object->image_id( $imageobj->id() );
			}
			else {
				XIMS::Debug( 3, "could not set image_id" );
			}
		}
		else {
			$object->image_id(undef);
		}
	}

	my $stylesheet = $self->param('stylesheet');
	if ( defined $stylesheet ) {
		XIMS::Debug( 6, "stylesheet: $stylesheet" );
		if ( length $stylesheet ) {
			my $styleobj;
			if (
				    $stylesheet =~ /^\d+$/
				and $styleobj = XIMS::Object->new( id => $stylesheet )
				and (  $styleobj->object_type->name() eq 'XSLStylesheet'
					or $styleobj->object_type->name() eq 'Folder' )
			  )
			{
				$object->style_id( $styleobj->id() );
			}
			elsif (
				$styleobj = XIMS::Object->new( path => $stylesheet )
				and (  $styleobj->object_type->name() eq 'XSLStylesheet'
					or $styleobj->object_type->name() eq 'Folder' )
			  )
			{
				$object->style_id( $styleobj->id() );
			}
			else {
				XIMS::Debug( 3, "could not set style_id" );
			}
		}
		else {
			$object->style_id(undef);
		}
	}

	my $schema = $self->param('schema');
	if ( defined $schema ) {
		XIMS::Debug( 6, "schema: $schema" );
		if ( length $schema ) {
			my $schemaobj;
			if (    $schema =~ /^\d+$/
				and $schemaobj = XIMS::Object->new( id => $schema )
				and ( $schemaobj->object_type->name() eq 'XML' ) )
			{
				$object->schema_id( $schemaobj->id() );
			}
			elsif ( $schemaobj = XIMS::Object->new( path => $schema )
				and ( $schemaobj->object_type->name() eq 'XML' ) )
			{
				$object->schema_id( $schemaobj->id() );
			}
			else {
				XIMS::Debug( 3, "could not set schema_id" );
			}
		}
		else {
			$object->schema_id(undef);
		}
	}

	my $css = $self->param('css');
	if ( defined $css ) {
		XIMS::Debug( 6, "css: $css" );
		if ( length $css ) {
			my $cssobj;
			if (    $css =~ /^\d+$/
				and $cssobj = XIMS::Object->new( id => $css )
				and ( $cssobj->object_type->name() eq 'CSS' ) )
			{
				$object->css_id( $cssobj->id() );
			}
			elsif ( $cssobj = XIMS::Object->new( path => $css )
				and ( $cssobj->object_type->name() eq 'CSS' ) )
			{
				$object->css_id( $cssobj->id() );
			}
			else {
				XIMS::Debug( 3, "Could not set css_id" );
			}
		}
		else {
			$object->css_id(undef);
		}
	}

	my $script = $self->param('script');
	if ( defined $script ) {
		XIMS::Debug( 6, "script: $script" );
		if ( length $script ) {
			my $scriptobj;
			if (    $script =~ /^\d+$/
				and $scriptobj = XIMS::Object->new( id => $script )
				and ( $scriptobj->object_type->name() eq 'JavaScript' ) )
			{
				$object->script_id( $scriptobj->id() );
			}
			elsif ( $scriptobj = XIMS::Object->new( path => $script )
				and ( $scriptobj->object_type->name() eq 'JavaScript' ) )
			{
				$object->script_id( $scriptobj->id() );
			}
			else {
				XIMS::Debug( 3, "Could not set script_id" );
			}
		}
		else {
			$object->script_id(undef);
		}
	}

	my $feed = $self->param('feed');
	if ( defined $feed ) {
		XIMS::Debug( 6, "feed: $feed" );
		if ( length $feed ) {
			my $feedobj;
			if (    $feed =~ /^\d+$/
				and $feedobj = XIMS::Object->new( id => $feed )
				and ( $feedobj->object_type->name() eq 'Portlet' ) )
			{
				$object->feed_id( $feedobj->id() );
			}
			elsif ( $feedobj = XIMS::Object->new( path => $feed )
				and ( $feedobj->object_type->name() eq 'Portlet' ) )
			{
				$object->feed_id( $feedobj->id() );
			}
			else {
				XIMS::Debug( 3, "Could not set feed_id" );
			}
		}
		else {
			$object->feed_id(undef);
		}
	}

	my $valid_from = $self->param('valid_from_timestamp');
	if ( defined $valid_from ) {
		XIMS::Debug( 6, "valid_from: $valid_from" );
		if ( length $valid_from ) {
			eval {
				$valid_from =
				  Time::Piece->strptime( $valid_from, "%Y-%m-%d %H:%M" );
			};
			if ( not $@ ) {
				$valid_from = $valid_from->ymd() . ' ' . $valid_from->hms();
				$object->valid_from_timestamp($valid_from);
			}
			else {
				XIMS::Debug( 3,
"Invalid timestamp for valid_from '$valid_from', need a ISO8601 string"
				);
			}
		}
		else {
			$object->valid_from_timestamp(undef);
		}
	}

	my $valid_to = $self->param('valid_to_timestamp');
	if ( defined $valid_to ) {
		XIMS::Debug( 6, "valid_to: $valid_to" );
		if ( length $valid_to ) {
			eval {
				$valid_to =
				  Time::Piece->strptime( $valid_to, "%Y-%m-%d %H:%M" );
			};
			if ( not $@ ) {
				$valid_to = $valid_to->ymd() . ' ' . $valid_to->hms();
				$object->valid_to_timestamp($valid_to);
			}
			else {
				XIMS::Debug( 3,
"Invalid timestamp for valid_to '$valid_to', need a ISO8601 string"
				);
			}
		}
		else {
			$object->valid_to_timestamp(undef);
		}
	}

	# valid_to must not be before valid_from
	if (
		   defined $object->valid_to_timestamp()
		&& defined $object->valid_from_timestamp()
		&& Time::Piece->strptime(
			$object->valid_to_timestamp(), "%Y-%m-%d %H:%M"
		) < Time::Piece->strptime(
			$object->valid_from_timestamp(),
			"%Y-%m-%d %H:%M"
		)
	  )
	{
		$object->valid_to_timestamp( $object->valid_from_timestamp() );
	}

	return 1;
}

=head2 default_grants()

=head3 Parameter

    $ctxt:              context object

    $grantowneronly:    if 1, grant the current user only; otherwise the parent
                        objects grants are copied

    $grantdefaultroles: if this and grantowneronly are 1, additionally grant
                        current users default roles

    $dontgrantpublic:   if 1, skip the public user while copying the parents grants

=head3 Returns

=head3 Description

    $self->default_grants( $ctxt, $grantowneronly, $grantdefaultroles, $dontgrantpublic );

    Typically called on storing a new object to set the initial state of its
    ACL.

=cut

sub default_grants {
	XIMS::Debug( 5, "called" );
	my $self              = shift;
	my $ctxt              = shift;
	my $grantowneronly    = shift;
	my $grantdefaultroles = shift;
	my $dontgrantpublic   = shift;

	my $retval = undef;

	# grant the object to the current user
	if (
		$ctxt->object->grant_user_privileges(
			grantee  => $ctxt->session->user(),
			grantor  => $ctxt->session->user(),
			privmask => XIMS::Privileges::MODIFY | XIMS::Privileges::PUBLISH
		)
	  )
	{
		XIMS::Debug( 6,
			    "granted user "
			  . $ctxt->session->user->name
			  . " default privs on "
			  . $ctxt->object->id() );
		$retval = 1;
	}
	else {
		XIMS::Debug( 2, "failed to grant default rights!" );
		return 0;
	}

	# TODO: through the user-interface the user should be able to decide
	# if all the roles he is member of (and not only his default roles)
	# should get read-access or not
	if ( defined $retval and $grantowneronly != 1 ) {

		# copy the grants of the parent
		my @object_privs =
		  map { XIMS::ObjectPriv->new->data( %{$_} ) }
		  $ctxt->data_provider->getObjectPriv(
			content_id => $ctxt->parent->id() );
		foreach my $priv (@object_privs) {

			# conditionally skip the public user
			next
			  if defined $dontgrantpublic
			  and $dontgrantpublic == 1
			  and $priv->grantee_id() == XIMS::PUBLICUSERID();

			$ctxt->object->grant_user_privileges(
				grantee  => $priv->grantee_id(),
				grantor  => $ctxt->session->user(),
				privmask => $priv->privilege_mask(),
			);
		}

		if ( defined $grantdefaultroles and $grantdefaultroles == 1 ) {
			my @roles =
			  $ctxt->session->user->roles_granted( default_role => 1 )
			  ;    # get granted default roles
			foreach my $role (@roles) {
				$ctxt->object->grant_user_privileges(
					grantee  => $role,
					grantor  => $ctxt->session->user(),
					privmask => XIMS::Privileges::VIEW
				);
				XIMS::Debug( 6,
					    "granted role "
					  . $role->name
					  . " view privs on "
					  . $ctxt->object->id() );
			}
		}
	}

	return $retval;
}

=head2 event_undelete()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_undelete(...)

=cut

sub event_undelete {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::DELETE();

	my $object = $ctxt->object();

	# test for a non deleted object in the current container with the
	# same location
	my $parent = XIMS::Object->new(
		document_id => $object->parent_id(),
		User        => $ctxt->session->user()
	);
	my @children = $parent->children( location => $object->location() );
	my $gotactive;
	foreach my $child (@children) {
		$gotactive++ unless $child->marked_deleted();
	}

	if ($gotactive) {

		# If there is already an active (non deleted) object with the
		# same location we'll reject for now. Later, we should implement
		# a dialogue which asks for a new location for the undeleted
		# object.
		$self->sendError(
			$ctxt,
			__x(
"An object with the location '{location}' already exists in container. Please rename or move that object before undeleting this one.",
				location => $object->location()
			)
		);

		return 0;
	}

	if ( $object->undelete() ) {
		XIMS::Debug( 4, "object has been undeleted" );
	}
	else {
		XIMS::Debug( 2, "object could not be undeleted!" );
		$self->sendError( $ctxt, __ "Object could not be undeleted!" );
		return 0;
	}

	XIMS::Debug( 4, "redirecting" );
	$self->redirect( $self->redirect_uri($ctxt) );
	return 0;
}

=head2 event_trashcan()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_trashcan(...)

=cut

sub event_trashcan {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::DELETE();

	my $object = $ctxt->object();

	if ( $object->published() ) {
		XIMS::Debug( 3, "attempt to trash pub'd object" );
		$self->sendError( $ctxt,__"Can't move a published object to the trashcan, please unpublish first");
		return 0;
	}

	my $force_trash;
	$force_trash = 1 if $self->param('forcetrash');
	my @chldinfo   = $object->descendant_count();
	my $diffobject = XIMS::Object->new(
		location  => '.diff_to_second_last',
		parent_id => $object->document_id()
	);

	if ( $force_trash == 1 ) {
		if ( $object->trashcan() ) {
			XIMS::Debug( 4, "object trashed" );
		}
		else {
			XIMS::Debug( 2, "object could not be trashed" );
			$self->sendError( $ctxt, __ "Moving to the trashcan failed." );
			return 0;
		}
	}
	elsif (( defined $diffobject and $chldinfo[0] > 1 )
		or ( not defined $diffobject and $chldinfo[0] > 0 ) )
	{

		# In case the object is a container and has remaining children besided
		# an automatically created .diff_to_second_last object, we are asking
		# for confirmation of recursion
		XIMS::Debug( 4,
			"container has got children, ask for confirmation of recursion" );

		# pepl: should not DELETE_ALL be test for in case of deleting
		# all the language version of an object?
		#
		# zeya: DELETE_ALL() cannot be granted via the WebUI, thence
		# check DELETE() for the moment.
		#
		# if ( $current_user_object_priv & XIMS::Privileges::DELETE_ALL() ) {
		if ( $current_user_object_priv & XIMS::Privileges::DELETE() ) {
			$ctxt->session->warning_msg( "This Container has "
				  . $chldinfo[0]
				  . " child(ren) over "
				  . $chldinfo[1]
				  . " level(s) in the hierarchy " );
			$ctxt->properties->application->styleprefix("common");
			$ctxt->properties->application->style("recursive_trashcan_confirm");
			return 0;
		}
		else {
			$self->sendError( $ctxt, "Privilege mismatch." );
			return 0;
		}
	}
	else {
		XIMS::Debug( 4, "object has no children?" );
		if ( $object->trashcan() ) {
			XIMS::Debug( 4, "object trashed" );
		}
		else {
			XIMS::Debug( 2, "object could not be trashed" );
			$self->sendError( $ctxt, __ "Moving to the trashcan failed." );
			return 0;
		}
	}

	XIMS::Debug( 4, "redirecting to the parent" );
	$self->redirect( $self->redirect_uri( $ctxt, $object->parent->id ) );
	return 0;
}

=head2 event_delete()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_delete(...)

=cut

sub event_delete {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::DELETE();

	my $object = $ctxt->object();

	#needed for redirection after deletion
	my $parent_content_id =
	  XIMS::Object->new( document_id => $object->parent_id() )->id();
	if ( $object->published() ) {
		XIMS::Debug( 3, "attempt to delete pub'd object" );
		$self->sendError( $ctxt,
			__ "Can't delete a published object, please unpublish first" );
		return 0;
	}

	my $force_delete;
	$force_delete = 1 if $self->param('forcedelete');
	my @chldinfo   = $object->descendant_count();
	my $diffobject = XIMS::Object->new(
		location  => '.diff_to_second_last',
		parent_id => $object->document_id()
	);

	if ( $force_delete == 1 ) {
		if ( $object->delete() ) {
			XIMS::Debug( 4, "object deleted" );
		}
		else {
			XIMS::Debug( 2, "object could not be deleted" );
			$self->sendError( $ctxt, __ "Delete failed." );
			return 0;
		}
	}
	elsif (( defined $diffobject and $chldinfo[0] > 1 )
		or ( not defined $diffobject and $chldinfo[0] > 0 ) )
	{

		# In case the object is a container and has remaining children
		# besided an automatically created .diff_to_second_last object,
		# we are asking for confirmation of recursion
		XIMS::Debug( 4,	"container has got children, ask for confirmation of recursion" );

		# pepl: should not DELETE_ALL be test for in case of deleting
		# all the language version of an object?
		#
		# zeya: DELETE_ALL() cannot be granted via the WebUI, thence
		# check DELETE() for the moment.
		#
		# if ( $current_user_object_priv & XIMS::Privileges::DELETE_ALL() ) {
		if ( $current_user_object_priv & XIMS::Privileges::DELETE() ) {
			$ctxt->session->warning_msg(
				__npx(
"This Container has x children over y level(s) in the hierarchy",
					"This Container has 1 child",
					"This Container has {number} children",
					$chldinfo[0],
					number => $chldinfo[0]
				  )
				  . q{ }
				  . __npx(
"This Container has x children over y level(s) in the hierarchy",
					"over one level in the hierarchy",
					"over {number} levels in the hierarchy",
					$chldinfo[1],
					number => $chldinfo[1]
				  )
			);
			$ctxt->properties->application->styleprefix("common");
			$ctxt->properties->application->style("recursive_delete_confirm");
			return 0;
		}
		else {
			$self->sendError( $ctxt, __ "Privilege mismatch." );
			return 0;
		}
	}
	else {
		XIMS::Debug( 4, "object has no children?" );
		if ( $object->delete() ) {
			XIMS::Debug( 4, "object deleted" );
		}
		else {
			XIMS::Debug( 2, "object could not be deleted" );
			$self->sendError( $ctxt, __ "Delete failed." );
			return 0;
		}
	}

	XIMS::Debug( 4, "redirecting to the parent" );
	$self->redirect( $self->redirect_uri( $ctxt, $parent_content_id ) );
	return 0;
}

=head2 event_contentbrowse()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_contentbrowse(...)

=cut

sub event_contentbrowse {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $display_params = $self->get_display_params($ctxt);
	my $to          = $self->param("to");
	my $otfilter    = $self->param("otfilter");
	my $notfilter   = $self->param("notfilter");    # negative otfilter :P
	my $objecttypes = [];

	$ctxt->properties->application->styleprefix("common");
	$ctxt->properties->application->style("error");

	$ctxt->properties->content->getchildren->level(1);

	$to = $ctxt->object->id() unless $to =~ /^\d+$/;
	$ctxt->properties->content->getchildren->objectid($to);
	$self->expand_attributes($ctxt);

	if ( defined $otfilter and length $otfilter > 0 ) {
		my @otherot = split '\s*,\s*', $otfilter;    # in case we want to filter
		                                             # a comma separated list of
		                                             # object types
		push @{$objecttypes},
		  ( 'Folder', 'DepartmentRoot', 'VLibrary', 'Gallery', @otherot );
	}
	elsif ( defined $notfilter and length $notfilter > 0 ) {
		my @otherot = split '\s*,\s*', $notfilter;
		my %fh = ();
		@fh{@otherot} = map { 1; } @otherot;

		# fetch all objecttypes and filter the listed types
		foreach my $ot ( $ctxt->data_provider->object_types() ) {
			next if exists $fh{ $ot->name() };
			push @{$objecttypes}, $ot->name();
		}
	}

	$ctxt->properties->content->getchildren->objecttypes($objecttypes);
	# pagination
    $ctxt->properties->content->getchildren->limit( $display_params->{limit} );
    $ctxt->properties->content->getchildren->offset($display_params->{offset} );
    $ctxt->properties->content->getchildren->order( $display_params->{order} );
    
	$ctxt->properties->application->style("contentbrowse");

	my $style;
	if ( $style = $self->param("style") and length $style ) {
		$ctxt->properties->application->style(
			$ctxt->properties->application->style . "_" . $style );
	}

	return 0;
}

=head3 Description
    
    my $display_params = $self->get_display_params($ctxt);

A common method to get the values for display-styles (ordering, pagination,
custom stylesheet names) merged from defaults, container attributes, and
CGI-parameters.

=cut

sub get_display_params {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $defaultsortby = $ctxt->object->attribute_by_key('defaultsortby');
    my $defaultsort   = $ctxt->object->attribute_by_key('defaultsort');

    # only sort by title 
    if($defaultsortby eq 'titlelocation') {
        $defaultsortby = $ctxt->session->user->userprefs->containerview_show() || '';
    }

    # maybe put that into config values
    $defaultsortby ||= 'position';
    $defaultsort   ||= 'asc';

    unless ( $self->param('sb') and $self->param('order') ) {
        $self->param( 'sb',    $defaultsortby );
        $self->param( 'order', $defaultsort );
        $self->param( 'defsorting', 1 );    # tell stylesheets not to pass
                                            # 'sb' and 'order' params when
                                            # linking to children
    }

    # The params override attribute and default values
    else {
        $defaultsortby = $self->param('sb');
        $defaultsort   = $self->param('order');
    }

    my %sortbymap = (
        cdate    => 'creation_timestamp',
        mdate    => 'last_modification_timestamp',
        date     => 'last_modification_timestamp',
        position => 'position',
        title    => 'title',
        location    => 'location'
    );
    XIMS::Debug(5,"defaultsortby: ".$defaultsortby.", defaultsort: ".$defaultsort);
    my $order = $sortbymap{$defaultsortby} . ' ' . $defaultsort;

    my $style = $self->param('style');

    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;

    my $limit;
    if ( defined $self->param('onepage') ) {
        $limit = undef;
    }
    else {
        $limit = $self->param('pagerowlimit');
        unless ($limit) {
            $limit ||= $ctxt->object->attribute_by_key('pagerowlimit');
            $limit ||= XIMS::SEARCHRESULTROWLIMIT();

            # set for stylesheet consumation;
            $self->param( 'searchresultrowlimit', $limit );
        }
        $offset ||= 0;
        $offset = $offset * $limit;
    }
    my $showtrashcan = $self->param('showtrashcan');
    $showtrashcan ||= 0;
    
    my $otfilter = $self->param('otfilter');
    my $notfilter = $self->param('notfilter');

    XIMS::Debug(5,"offset: ".$offset.", limit: ".$limit.", order: ".$order.", showtrashcan: ".$showtrashcan);
    return (
        {
            offset => $offset,
            limit  => $limit,
            order  => $order,
            style  => $style,
            showtrashcan => $showtrashcan,
            otfilter => $otfilter,
            notfilter => $notfilter
        }
    );
}

=head2 event_move_browse()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_move_browse(...)

=cut

sub event_move_browse {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$ctxt->properties->application->styleprefix("common");
	$ctxt->properties->application->style("error");

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::MOVE();

	if ( not $ctxt->object->published() ) {
		my $to = $self->param("to");
		if ( not( $to =~ /^\d+$/ ) ) {
			XIMS::Debug( 3, "Where to move?" );
			$ctxt->session->error_msg( __ "Where to move?" );
			return 0;
		}

		$ctxt->properties->content->getchildren->level(1);
		$ctxt->properties->content->getchildren->objecttypes(
			[qw(Folder DepartmentRoot Gallery)] );
		$ctxt->properties->content->getchildren->objectid($to);
		$ctxt->properties->application->style("move_browse");
	}
	else {
		XIMS::Debug( 3, "attempt to move published object" );
		$ctxt->session->error_msg(
			__ "Moving published objects has not been implemented yet." );
		return 0;
	}

	return 0;
}

=head2 event_move()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_move(...)

=cut

sub event_move {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $object = $ctxt->object();

	$ctxt->properties->application->styleprefix("common");
	$ctxt->properties->application->style("error");

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask($object);
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::MOVE();

	if ( not $object->published() ) {
		my $to = $self->param("to");
		if ( not( length $to ) ) {
			XIMS::Debug( 3, "Where to move?" );
			$ctxt->session->error_msg( __ "Where to move?" );
			return 0;
		}

		my $target;
		if (
			not(
				$target = XIMS::Object->new(
					path => $to,
					User => $ctxt->session->user
				)
				and $target->id()
			)
		  )
		{
			$ctxt->session->error_msg( __ "Invalid target path!" );
			return 0;
		}

		if ( $object->document_id() == $target->document_id() ) {
			XIMS::Debug( 2, "target and source are the same" );
			$ctxt->session->error_msg( __
"Target and source are the same. (Why would you want doing that?)"
			);
			return 0;
		}

		if ( $target->object_type->is_fs_container() ) {
			XIMS::Debug( 4, "we got a valid target" );
		}
		else {
			XIMS::Debug( 3, "Target is not a valid container" );
			$ctxt->session->error_msg( __ "Target is not a valid container" );
			return 0;
		}

        my $target_user_object_priv
            = $ctxt->session->user->object_privmask($target);
        return $self->event_access_denied($ctxt)
            unless $target_user_object_priv & XIMS::Privileges::CREATE();

		my @children = $target->children(
			location       => $object->location(),
			marked_deleted => 0
		);
		if ( scalar @children > 0 and defined $children[0] ) {
			XIMS::Debug( 2,
"object with same location already exists in the target container"
			);
			$self->sendError(
				$ctxt,
				__x(
"Location '{location}' already exists in the target container.",
					location => $object->location()
				)
			);
			return 0;
		}

		if ( not $object->move( target => $target->document_id ) ) {
			$ctxt->session->error_msg("move failed!");
			return 0;
		}
		else {
			XIMS::Debug( 4, "move ok, redirecting to the parent" );
			$self->redirect(
				$self->redirect_uri( $ctxt, $object->parent->id() ) );
			return 0;
		}
	}
	else {
		XIMS::Debug( 3, "attempt to move published object" );
		$ctxt->session->error_msg(
			__ "Moving published objects has not been implemented yet." );
		return 0;
	}

	return 0;
}

=head2 event_copy()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_copy(...)

=cut

sub event_copy {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;
	my $object = $ctxt->object();

	$ctxt->properties->application->styleprefix("common");
	$ctxt->properties->application->style("error");

	my $parent = XIMS::Object->new(
		document_id => $object->parent_id,
		User        => $ctxt->session->user()
	);
	my $parent_user_object_priv =
	  $ctxt->session->user->object_privmask($parent);
	return $self->event_access_denied($ctxt)
	  unless $parent_user_object_priv & XIMS::Privileges::CREATE();

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask($object);
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::COPY();

	my $recursivecopy;
	$recursivecopy = 1 if $self->param('recursivecopy');
	my $confirmcopy;
	$confirmcopy = 1 if $self->param('confirmcopy');
	my @chldinfo = $object->descendant_count();

	if (
		   $confirmcopy == 1
		or $chldinfo[0] == 0
		or $chldinfo[0] == 1 and $object->children(
			location       => '.diff_to_second_last',
			marked_deleted => 0
		)
	  )
	{

		if ( not $object->clone( scope_subtree => $recursivecopy ) ) {
			$ctxt->session->error_msg( __ "copy failed!" );
			return 0;
		}
		else {
			XIMS::Debug( 4, "copy ok, redirecting to the parent" );

			# be sure to show the user the new copy at the first page
			$self->param( 'sb',    'date' );
			$self->param( 'order', 'desc' );
			$self->redirect( $self->redirect_uri( $ctxt, $parent->id() ) );
			return 0;
		}
	}
	else {
		$ctxt->session->warning_msg( "This Container has "
			  . $chldinfo[0]
			  . " child(ren) over "
			  . $chldinfo[1]
			  . " level(s) in the hierarchy " );
		$ctxt->properties->application->styleprefix("common");
		$ctxt->properties->application->style("recursive_copy_confirm");
		return 0;
	}

}

=head2 event_publish_prompt()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_publish_promt(...)

=cut

sub event_publish_prompt {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$self->expand_attributes($ctxt);

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

	my @objects;
	my $dfmime_type = $ctxt->object->data_format->mime_type();
	if ( $dfmime_type eq 'text/html' ) {

		# check for body references in (X)HTML documents
		XIMS::Debug( 4, "checking body refs" );
		@objects = $self->body_ref_objects($ctxt);

		# look for document links
		my $urllinkid = XIMS::ObjectType->new( fullname => 'URLLink' )->id();
		my @doclinks = $ctxt->object->children_granted(
			object_type_id => $urllinkid,
			marked_deleted => 0
		);
		push( @objects, @doclinks ) if scalar @doclinks > 0;

		for (@objects) {
			$_->{location_path} =
			    $_->object_type_id == $urllinkid
			  ? $_->location()
			  : $_->location_path();
		}
	}
	elsif ( $dfmime_type eq 'application/x-container' ) {
		@objects =
		  $ctxt->object->children_granted( marked_deleted => 0 )
		  ;    # get even non-container objects
	}

	if ( scalar @objects ) {
		$ctxt->objectlist( \@objects );

		# check for publish privileges on referenced objects
		my $user = $ctxt->session->user;
		if ( $user->admin() ) {
			XIMS::Debug( 4, "user is admin, publish all referenced objects." );
		}
		else {
			my @locations_ungranted;
			my @role_ids = ( $user->role_ids(), $user->id() );
			foreach my $object (@objects) {
				next
				  unless ( defined $object and $object->id() )
				  ;    # skip unresolved references
				my $objectpriv = XIMS::ObjectPriv->new(
					content_id => $object->id(),
					grantee_id => \@role_ids
				);
				push( @locations_ungranted, $object->location )
				  unless $objectpriv
				  && ( $objectpriv->privilege_mask() &
					XIMS::Privileges::PUBLISH() );
			}

			if ( scalar(@locations_ungranted) > 0 ) {
				$ctxt->session->message( join ",", @locations_ungranted );
			}
		}
	}
	$ctxt->properties->content->getformatsandtypes(1);
	$ctxt->properties->application->styleprefix('common_publish');
	$ctxt->properties->application->style('prompt');

	return 0;
}

=head2 event_publish()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_publish(...)

=cut

sub event_publish {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	$self->expand_attributes($ctxt);

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

	require XIMS::Exporter;
	my $exporter = XIMS::Exporter->new(
		Provider => $ctxt->data_provider,
		Basedir  => XIMS::PUBROOT(),
		User     => $ctxt->session->user
	);

	my $no_dependencies_update = 1;
	if ( defined $self->param("update_dependencies")
		and $self->param("update_dependencies") == 1 )
	{
		$no_dependencies_update = undef;
	}

	my $published = 0;
	if ( defined $self->param("autopublish")
		and $self->param("autopublish") == 1 )
	{
		XIMS::Debug( 4, "going to publish references" );
		my @objids = $self->param("objids");
		$published =
		  $self->autopublish( $ctxt, $exporter, 'publish', \@objids,
			$no_dependencies_update, $self->param("recpublish") );
	}

	if (
		$exporter->publish(
			Object                 => $ctxt->object,
			no_dependencies_update => $no_dependencies_update
		)
	  )
	{
		XIMS::Debug( 6, "object published!" );
		if ( defined $self->param("verbose_result")
			and $self->param("verbose_result") == 1 )
		{
			if ( $published > 0 ) {
				$ctxt->session->message(
					__nx("Object '{title}' together with one related object published.","Object '{title}' together with {published} related object published.",
						title     => $ctxt->object->title(),
						published => $published,
					)
				);
			}
			else {
				$ctxt->session->message(
					__x("Object '{title}' published.",title => $ctxt->object->title(),)
				);
			}
			$ctxt->properties->application->styleprefix('common_publish');
			$ctxt->properties->application->style('update');
		}
		else {
			$self->redirect( $self->redirect_uri($ctxt) );
			return 1;
		}
	}
	else {
		XIMS::Debug( 3, "object could not be published!" );
		$ctxt->session->error_msg(
			__x(
				"Object '{title}' not published.",
				title => $ctxt->object->title(),
			)
		);

		$ctxt->properties->application->styleprefix('common');
		$ctxt->properties->application->style('error');
	}

	return 0;
}

=head2 publish_gopublic()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->publish_gopublic(...)

=cut

sub publish_gopublic {
	XIMS::Debug( 5, "called" );
	my $self    = shift;
	my $ctxt    = shift;
	my $options = shift;

	$options->{PRIVILEGE_MASK} ||= XIMS::Privileges::VIEW;

	my $user     = $ctxt->session->user();
	my $object   = $ctxt->object();
	my $objprivs = $user->object_privmask($object);

	if ( $objprivs & XIMS::Privileges::PUBLISH() ) {
		if ( not( $object->publish() and $object->parent->publish() ) ) {
			XIMS::Debug( 2,
				"publishing object '" . $object->title() . "' failed" );
			return $self->sendError(
				$ctxt,
				__x(
					"Publishing object '{title}' failed.",
					title => $object->title(),
				)
			);
		}
		else {
			my $privs_object = XIMS::ObjectPriv->new(
				grantee_id => XIMS::PUBLICUSERID(),
				content_id => $object->id()
			);

			# Add to existing privileges if there are any
			$options->{PRIVILEGE_MASK} |= $privs_object->privilege_mask()
			  if defined $privs_object;
			$object->grant_user_privileges(
				grantee        => XIMS::PUBLICUSERID(),
				privilege_mask => $options->{PRIVILEGE_MASK},
				grantor        => $user->id()
			);

			if ( defined $self->param("verbose_result")
				and $self->param("verbose_result") == 1 )
			{
				$ctxt->session->message(
					__x(
						"Object '{title}' published.",
						title => $object->title(),
					)
				);
				$ctxt->properties->application->styleprefix('common_publish');
				$ctxt->properties->application->style('update');
			}
			else {
				$self->redirect( $self->redirect_uri($ctxt) );
				return 1;
			}
		}
	}
	else {
		return $self->event_access_denied($ctxt);
	}
}

=head2 event_unpublish()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_unpuplish(...)

=cut

sub event_unpublish {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask( $ctxt->object );
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

	require XIMS::Exporter;
	my $exporter = XIMS::Exporter->new(
		Provider => $ctxt->data_provider,
		Basedir  => XIMS::PUBROOT(),
		User     => $ctxt->session->user
	);

my $no_dependencies_update = 1;
	if ( defined $self->param("update_dependencies")
		and $self->param("update_dependencies") == 1 )
	{
		$no_dependencies_update = undef;
	}
	my $unpublished = 0;
	if ( defined $self->param("autopublish")
		and $self->param("autopublish") == 1 )
	{
		XIMS::Debug( 4, "going to unpublish references" );
		my @objids = $self->param("objids");
		$unpublished =
		  $self->autopublish( $ctxt, $exporter, 'unpublish', \@objids,
			$no_dependencies_update, $self->param("recpublish") );
	}	
	
	if (
		$exporter->unpublish(
			Object                 => $ctxt->object,
			no_dependencies_update => $no_dependencies_update
		)
	  )
	{
		XIMS::Debug( 6, "object unpublished!" );
		if ( defined $self->param("verbose_result")
			and $self->param("verbose_result") == 1 )
		{
			$ctxt->session->message(
				__x(
					"Object '{title}' unpublished.",
					title => $ctxt->object->title(),
				)
			);
			$ctxt->properties->application->styleprefix('common_publish');
			$ctxt->properties->application->style('update');
		}
		else {
			$self->redirect( $self->redirect_uri($ctxt) );
			return 1;
		}
	}
	else {
		XIMS::Debug( 3, "object could not be unpublished!" );
		$ctxt->session->error_msg(
			__x(
				"Object '{title}' not unpublished.",
				title => $ctxt->object->title(),
			)
		);
		$ctxt->properties->application->styleprefix('common');
		$ctxt->properties->application->style('error');
	}

	return 0;
}

=head2 unpublish_gopublic()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->unpublish_gopublic(...)

=cut

sub unpublish_gopublic {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $user     = $ctxt->session->user();
	my $object   = $ctxt->object();
	my $objprivs = $user->object_privmask($object);

	if ( $objprivs & XIMS::Privileges::PUBLISH() ) {

		# Republishing of the parent invalidates any caches
		if ( not( $object->unpublish() and $object->parent->publish() ) ) {
			XIMS::Debug( 2,
				"unpublishing object '" . $object->title() . "' failed" );
			return $self->sendError(
				$ctxt,
				__x(
					"Object '{title}' not unpublished.",
					title => $ctxt->object->title(),
				)
			);
		}
		else {
			my $privs_object = XIMS::ObjectPriv->new(
				grantee_id => XIMS::PUBLICUSERID(),
				content_id => $object->id()
			);
			$privs_object->delete();

			if ( defined $self->param("verbose_result")
				and $self->param("verbose_result") == 1 )
			{
				$ctxt->session->message(
					__x(
						"Object '{title}' unpublished.",
						title => $ctxt->object->title(),
					)
				);
				$ctxt->properties->application->styleprefix('common_publish');
				$ctxt->properties->application->style('update');
			}
			else {
				$self->redirect( $self->redirect_uri($ctxt) );
				return 1;
			}
		}
	}
	else {
		return $self->event_access_denied($ctxt);
	}
}

=head2 event_test_wellformedness()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_test_wellformedness(...)

=cut

sub event_test_wellformedness {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $body = XIMS::decode( $self->param('body') );

	# if we got no body param, use $object->body
	my $string = defined $body ? $body : $ctxt->object->body();

	$self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header( -type => 'text/plain',
                            -charset => 'UTF-8' )
    );
	$self->skipSerialization(1);

	my $test = $ctxt->object->balanced_string( $string, verbose_msg => 1 );

	if ( $test->isa('XML::LibXML::DocumentFragment') ) {
		$self->{RES}->body("Parse ok\n");
	}
	else {
		$test = XIMS::encode($test);
		$test ||= "Cowardly refusing to fill an errorstring";
        $self->{RES}->body( "$test\n" );
	}

	return 0;
}

=head2 event_htmltidy()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_htmltidy(...)

=cut

sub event_htmltidy {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $body = XIMS::decode( $self->param('body') );

	# if we got no body param, use $object->body
	my $string = defined $body ? $body : $ctxt->object->body();

	my $tidiedstring = $ctxt->object->balance_string($string);

	# set back to body if tidy was unsuccessful
	$tidiedstring = defined $tidiedstring ? $tidiedstring : $body;

	# and if we did not get a body, set to $object->body()
	$tidiedstring = defined $tidiedstring ? $tidiedstring : $string;

	# deindent one level
	$tidiedstring =~ s/^[ ]{4}//mg;

	# encode back to utf-8 in case
	$tidiedstring = XIMS::encode($tidiedstring);

	$self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header( -type => 'text/plain',
                            -charset => 'UTF-8'
        )
    );
	$self->skipSerialization(1);

	if ( $self->param('hti') ) {
		my $jsstring;
		foreach my $line ( split '\n', $tidiedstring ) {
			$line =~ s/'/\\'/g;
			$jsstring .= "ns += '$line\\n';\n";
		}
		$self->{RES}->body( "var ns='';$jsstring editor.setHTML(ns);" );
	}
	else {
		$self->{RES}->body( "$tidiedstring\n" );
	}

	return 0;
}

=head2 event_prettyprintxml()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_prettyprintxml(...)

=cut

sub event_prettyprintxml {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $body = XIMS::decode( $self->param('body') );

	# if we got no body param, use $object->body
	my $string = defined $body ? $body : $ctxt->object->body();

    $self->{RES} = $self->{REQ}->new_response(
        $self->psgi_header(
            -type    => 'text/plain',
            -charset => ( XIMS::DBENCODING() ? XIMS::DBENCODING() : 'UTF-8' )
        )
    );
	$self->skipSerialization(1);

	my $doc = $ctxt->object->balanced_string($string);
	if ( defined $doc and $doc->isa('XML::LibXML::DocumentFragment') ) {

	   # $doc->setEncoding( XIMS::DBENCODING() || 'UTF-8' ); does not work
	   # correctly for whatever reasons - we have to manually decode again then.

		# Format 1 does not work as documented :-/
		# Format 2 deals better with the one-line fragment produced by
		# HTMLArea's serializer with Gecko
		my $pprinted =
		  XIMS::Entities::decode( XIMS::decode( $doc->toString(2) ) );
		$pprinted =~
		  s/\n\s*\n/\n/g;    # remove duplicate linebreaks added by toString(2)
		$self->{RES}->body($pprinted);
	}
	else {

		# set back to body if parsing was unsuccessful
		$self->{RES}->body($body);
		$ctxt->session->message( __ "Parse Failure. Could not prettyprint." );
	}
	return 0;
}

=head2 event_obj_acllist()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_obj_acllist(...)

=cut

sub event_obj_acllist {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $user     = $ctxt->session->user();
	my $object   = $ctxt->object();
	my $objprivs = $user->object_privmask($object);
	my $dp       = $ctxt->data_provider();
	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('error');
	if ( $user and $objprivs and $object ) {

		# The acllist event will work only if there is a user, an object, and
		# a minimal privilege mask found.
		#
		# Before one can really see the privileges for an object, he has to
		# have a grant privilege (XIMS::Privilege::GRANT or
		# XIMS::Privilege::GRANT_ALL) for it. (Optionally, a system privilege
		# may do the same trick.)

		if (   $objprivs & XIMS::Privileges::GRANT()
			|| $objprivs & XIMS::Privileges::GRANT_ALL() )
		{
			XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

			# get the existing grants on the object
			my @object_privs =
			  map { XIMS::ObjectPriv->new->data( %{$_} ) }
			  $dp->getObjectPriv( content_id => $object->id() );

			if ( my $user_id = $self->param("userid") ) {
				if ( my $context_user = XIMS::User->new( id => $user_id ) ) {

					# second parameter to object_privileges forces check for
					# explicit grants to user only
					my %oprivs = $context_user->object_privileges( $object, 1 );

					# xml serialization does not like undefined values
					if ( grep { defined $_ } values %oprivs ) {
						$context_user->{object_privileges} = {%oprivs};
					}
					$ctxt->user($context_user);
					$ctxt->properties->application->style('obj_user');
				}
				else {
					XIMS::Debug( 3, "No such user!" );
					$self->sendError( $ctxt,
						__ "Sorry, there is no such user!" );
				}
			}
			elsif ( my $userquery = $self->param('userquery') ) {
				my %args;
				if ( $self->param('usertype') eq 'user' ) {
					$args{object_type} = 0;
				}
				else {
					$args{object_type} = 1;
				}
				$userquery = $self->clean_userquery($userquery);
				$args{name} = $userquery
				  if ( defined $userquery and length $userquery );
				my @big_user_data_list = $dp->getUser(%args);
				my @granted_user_ids   = map { $_->grantee_id() } @object_privs;
				my @user_data_list     = ();
				foreach my $record (@big_user_data_list) {
					next
					  if grep { $_ == $record->{'user.id'} } @granted_user_ids;
					push @user_data_list, $record;
				}
				my @user_list =
				  map { XIMS::User->new->data( %{$_} ) } @user_data_list;
				$ctxt->userlist( \@user_list );
				$ctxt->properties->application->style('obj_userlist');
				XIMS::Debug( 6, "Search for user/role returned  @user_list" );
			}
			else {

				# this will fetch only the users that have one or more grants
				# on the current obj.
				my @granted_user_ids = map { $_->grantee_id() } @object_privs;
				my @granted_users =
				  map { XIMS::User->new( id => $_ ) } @granted_user_ids;

				$ctxt->userlist( \@granted_users );

				foreach my $user_id (@granted_user_ids) {
					if ( my $context_user = XIMS::User->new( id => $user_id ) )
					{

						# second parameter to object_privileges forces check for
						# explicit grants to user only
						my %oprivs =
						  $context_user->object_privileges( $object, 1 );

						# xml serialization does not like undefined values
						if ( grep { defined $_ } values %oprivs ) {
							$context_user->{object_privileges} = {%oprivs};
						}
						$ctxt->user($context_user);
					}
				}
				$ctxt->properties->application->style('obj_userlist');
			}

		}
		else {
			XIMS::Debug( 2,
				    "user "
				  . $user->name()
				  . " denied to list privileges on object" );
			$self->sendError(
				$ctxt,
				__x(
					"user {name} denied to list privileges on object",
					name => $user->name(),
				)
			);
		}
	}
	else {
		XIMS::Debug( 3, "anonymous granting rejected" );
	}

	return 0;
}

=head2 event_obj_acllight()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_obj_acllight(...)

=cut

sub event_obj_acllight {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $user     = $ctxt->session->user();
	my $object   = $ctxt->object();
	my $objprivs = $user->object_privmask($object);
	my $dp       = $ctxt->data_provider();
	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('error');
	if ( $user and $objprivs and $object ) {

		# The acllist event will work only if there is a user, an object, and
		# a minimal privilege mask found.
		#
		# Before one can really see the privileges for an object, he has to
		# have a grant privilege (XIMS::Privilege::GRANT or
		# XIMS::Privilege::GRANT_ALL) for it. (Optionally, a system privilege
		# may do the same trick.)

		if (   $objprivs & XIMS::Privileges::GRANT()
			|| $objprivs & XIMS::Privileges::GRANT_ALL() )
		{
			XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

			# get the existing grants on the object
			my @object_privs =
			  map { XIMS::ObjectPriv->new->data( %{$_} ) }
			  $dp->getObjectPriv( content_id => $object->id() );

			if ( my $user_id = $self->param("userid") ) {
				if ( my $context_user = XIMS::User->new( id => $user_id ) ) {

					# second parameter to object_privileges forces check for
					# explicit grants to user only
					my %oprivs = $context_user->object_privileges( $object, 1 );

					# xml serialization does not like undefined values
					if ( grep { defined $_ } values %oprivs ) {
						$context_user->{object_privileges} = {%oprivs};
					}
					$ctxt->user($context_user);
					$ctxt->properties->application->style('obj_acl_light');
				}
				else {
					XIMS::Debug( 3, "No such user!" );
					$self->sendError( $ctxt,
						__ "Sorry, there is no such user!" );
				}
			}
			elsif ( my $userquery = $self->param('userquery') ) {
				my %args;
				if ( $self->param('usertype') eq 'user' ) {
					$args{object_type} = 0;
				}
				else {
					$args{object_type} = 1;
				}
				$userquery = $self->clean_userquery($userquery);
				$args{name} = $userquery
				  if ( defined $userquery and length $userquery );
				my @big_user_data_list = $dp->getUser(%args);
				my @granted_user_ids   = map { $_->grantee_id() } @object_privs;
				my @user_data_list     = ();
				foreach my $record (@big_user_data_list) {
					next
					  if grep { $_ == $record->{'user.id'} } @granted_user_ids;
					push @user_data_list, $record;
				}
				my @user_list =
				  map { XIMS::User->new->data( %{$_} ) } @user_data_list;
				$ctxt->userlist( \@user_list );
				$ctxt->properties->application->style('obj_acl');
				XIMS::Debug( 6, "Search for user/role returned  @user_list" );
			}
			else {

				# this will fetch only the users that have one or more grants
				# on the current obj.
				my @granted_user_ids = map { $_->grantee_id() } @object_privs;
				my @granted_users =
				  map { XIMS::User->new( id => $_ ) } @granted_user_ids;

				#$ctxt->userlist( \@granted_users );

				foreach my $user_id (@granted_user_ids) {
					if ( my $context_user = XIMS::User->new( id => $user_id ) )
					{
						# second parameter to object_privileges forces check for
						# explicit grants to user only
						my %oprivs =
						  $context_user->object_privileges( $object, 1 );

						# xml serialization does not like undefined values
						if ( grep { defined $_ } values %oprivs ) {
							$context_user->{object_privileges} = {%oprivs};
						}

						#$ctxt->user($context_user);
					}
				}
				$ctxt->userobjectlist( \@granted_users );
				$ctxt->userlist( \@granted_users );
				$ctxt->properties->application->style('obj_acl_light');
			}

		}
		else {
			XIMS::Debug( 2,
				    "user "
				  . $user->name()
				  . " denied to list privileges on object" );
			$self->sendError(
				$ctxt,
				__x(
					"user {name} denied to list privileges on object",
					name => $user->name(),
				)
			);
		}
	}
	else {
		XIMS::Debug( 3, "anonymous granting rejected" );
	}

	return 0;
}

=head2 event_obj_aclgrant()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_obj_aclgrant(...)

=cut

sub event_obj_aclgrant {
	my ( $self, $ctxt ) = @_;
	XIMS::Debug( 5, "called" );

	my $user     = $ctxt->session->user();
	my $object   = $ctxt->object();
	my $objprivs = $user->object_privmask($object);

	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('error');

	if ( $user and $objprivs and $object ) {

		# the aclist event will only work if there can be an user, object
		# found, plus a minimal privilege mask is found.
		#
		# before one can really see the privileges on an object, one
		# needs one or the other grant privilege (XIMS::Privilege::GRANT
		# or XIMS::Privilege::GRANT_ALL) for his own. Optional a system
		# privilege may does the same trick.

		if (   $objprivs & XIMS::Privileges::GRANT()
			|| $objprivs & XIMS::Privileges::GRANT_ALL() )
		{
			XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

			# get the other userid
			my $uid = $self->param('userid');

			# build the privilege mask
			my $bitmask = 0;
			foreach my $priv ( XIMS::Privileges::list() ) {
				my $lcname = 'acl_' . lc($priv);
				if ( $self->param($lcname) ) {					
						## no critic (ProhibitNoStrict)
						no strict 'refs';
						$bitmask += &{"XIMS::Privileges::$priv"}();
						## use strict
				}				
			}
			unless ($bitmask){
				$ctxt->properties->application->styleprefix('common');
				$ctxt->properties->application->style('error');
				XIMS::Debug( 2, "No privileges provides" );
				$self->sendError( $ctxt, __ "Please provide at least one privilege." );
				return 0;
			}

			# store the set to the database
			my $boolean = $object->grant_user_privileges(
				grantee        => $uid,
				privilege_mask => $bitmask,
				grantor        => $user->id()
			);

			if ($boolean) {
				XIMS::Debug( 6,
					"ACL privs changed for (" . $user->name() . ")" );
				$ctxt->properties->application->style('obj_user_update');
				my $granted = XIMS::User->new( id => $uid );
				$ctxt->session->message(
					__x(
"Privileges changed successfully for user/role '{name}'.",
						name => $granted->name(),
					)
				);
			}
			else {
				XIMS::Debug( 2,
					    "ACL grant failure on "
					  . $object->document_id . " for "
					  . $user->name() );
			}
		}
		else {
			XIMS::Debug( 2, "ACL check failed (" . $user->name . ")" );
		}
	}
	else {
		XIMS::Debug( 3, "anonymous granting rejected" );
	}

	return 0;
}

=head2 event_aclgrantmultiple()

=cut

sub event_aclgrantmultiple {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
	
	if($self->param('grantees')){
		my @grantees;
		foreach ( split( /\s*,\s*/, $self->param('grantees') ) ) {
		    my $grantee = XIMS::User->new( name => $_ );
			#unless $grantee and $grantee->id();
			if($grantee and $grantee->id()){	
				push @grantees, $grantee;
			}
			else{
				XIMS::Debug( 4, "Grantee '" . $_ . "' could not be found.\n");
			}
		}
		unless (scalar @grantees){
			$ctxt->properties->application->styleprefix('common');
			$ctxt->properties->application->style('error');
			XIMS::Debug( 2, "none of provided grantees found" );
			$self->sendError( $ctxt, __ "None of your provided grantees could befound." );
			return 0;
		}
		
		# build the privilege mask
		my $bitmask = 0;
		foreach my $priv ( XIMS::Privileges::list() ) {
			my $lcname = 'acl_' . lc($priv);
			if ( $self->param($lcname) ) {
				{
					## no critic (ProhibitNoStrict)
					no strict 'refs';
					$bitmask += &{"XIMS::Privileges::$priv"}();
					## use strict
				}
			}
		}
		unless ($bitmask){
			$ctxt->properties->application->styleprefix('common');
			$ctxt->properties->application->style('error');
			XIMS::Debug( 2, "No privileges provides" );
			$self->sendError( $ctxt, __ "Please provide at least one privilege." );
			return 0;
		}
		
		my $recgrant = $self->param('recacl');
	    my @ids = $self->param('multiselect');
	    my $user = $ctxt->session->user();
	    #my @objects;
	    
	    my $obj;
	    #recursive
		if ( $recgrant ) {
			my @org_ids = @ids;
			foreach(@org_ids){
				$obj = new XIMS::Object('id' => $_);
			    my @descendants = $obj->descendants_granted(
			        User           => $user,
			        marked_deleted => 0
			    );
			    XIMS::Debug( 4, "Number of objects: ".(scalar @descendants + scalar @ids));
			    if((scalar @descendants + scalar @ids) < XIMS::RECMAXOBJECTS()){
				    foreach my $desc (@descendants) {
				    	if($user->object_privmask( $obj )& (XIMS::Privileges::GRANT() || XIMS::Privileges::GRANT_ALL())){
							push(@ids, $desc->id());
				    	}
					}
			    }
			    else{
			    	$ctxt->properties->application->styleprefix('common');
					$ctxt->properties->application->style('error');
					XIMS::Debug( 2, "to many objects in recursion" );
					$self->sendError( $ctxt, __x "Current limit is {rec_max_obj}. Please select fewer objects or disable recursion.", rec_max_obj => XIMS::RECMAXOBJECTS() );
					return 0;
			    }
			}
		}
	    #end recursive
	    
	    
	
		my $id_iterator = XIMS::Iterator::Object->new( \@ids, 1 );
		while ( my $obj = $id_iterator->getNext() ) {
			#warn "\n object : ".obj->location();
			# store the set to the database
			foreach(@grantees){
				my $gid = $_->id();
				#my $gid = $_;
				my $boolean = $obj->grant_user_privileges(
					grantee        => $gid,
					privilege_mask => $bitmask,
					grantor        => $user
				);
				if ($boolean) {
					XIMS::Debug( 6, "ACL privs changed for (" . $_->name() . ")" );
					#XIMS::Debug( 6, "ACL privs changed for user ( id: " . $_ . ")" );
	#					#$ctxt->properties->application->style('obj_user_update');
	##					my $granted = XIMS::User->new( id => $uid );
	##					$ctxt->session->message(
	##						__x("Privileges changed successfully for user/role '{name}'.",
	##							name => $granted->name(),
	##						)
	##					);
	#				}
	#				else {
	#					XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for ". $_->name() );
	#					#XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for user with id ". $_ );
	#				}
				}
				else {
					XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for ". $_->name() );
					#XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for user with id ". $_ );
				}
			}
		}
	    XIMS::Debug( 3, "all privileges granted." );
		XIMS::Debug( 4, "redirecting to the container" );
	    $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id ) );
	    return 0;
	}
	else{
		$ctxt->properties->application->styleprefix('common');
		$ctxt->properties->application->style('error');
		XIMS::Debug( 2, "no grantee(s) provided" );
		$self->sendError( $ctxt, __ "Please provide at least one grantee." );
		return 0;
	}
}

sub event_aclrevokemultiple {
	XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

	if($self->param('grantees')){
	my @grantees;
	foreach ( split( /\s*,\s*/, $self->param('grantees') ) ) {
	    my $grantee = XIMS::User->new( name => $_ );
	    #warn "\n\ngrantee : ".$grantee->name();
#	    XIMS::Debug( 4, "Grantee '" . $_ . "' could not be found.\n")
#	        unless $grantee and $grantee->id();
#	    push @grantees, $grantee;
		if($grantee and $grantee->id()){	
				push @grantees, $grantee;
			}
			else{
				XIMS::Debug( 4, "Grantee '" . $_ . "' could not be found.\n");
			}
		}
		unless (scalar @grantees){
			$ctxt->properties->application->styleprefix('common');
			$ctxt->properties->application->style('error');
			XIMS::Debug( 2, "none of provided grantees found" );
			$self->sendError( $ctxt, __ "None of your provided grantees could befound." );
			return 0;
		}
	my $recgrant = $self->param('recacl');
	my @ids = $self->param('multiselect');
	my $user = $ctxt->session->user();
	
	my $obj;
	#recursive
	if ( $recgrant ) {
		my @org_ids = @ids;
		foreach(@org_ids){
			$obj = new XIMS::Object('id' => $_);
		    my @descendants = $obj->descendants_granted(
		        User           => $user,
		        marked_deleted => 0
		    );
		    XIMS::Debug( 4, "Number of objects: ".(scalar @descendants + scalar @ids));
			if((scalar @descendants + scalar @ids) < XIMS::RECMAXOBJECTS()){
			    foreach my $desc (@descendants) {
			    	if($user->object_privmask( $obj )& (XIMS::Privileges::GRANT() || XIMS::Privileges::GRANT_ALL())){
						push(@ids, $desc->id());
			    	}
				}
			}
		    else{
		    	$ctxt->properties->application->styleprefix('common');
				$ctxt->properties->application->style('error');
				XIMS::Debug( 2, "to many objects in recursion" );
				$self->sendError( $ctxt, __x "Current limit is {rec_max_obj}. Please select fewer objects or disable recursion.", rec_max_obj => XIMS::RECMAXOBJECTS() );
				return 0;
		    }
		}
		#warn "\n\norg_ids: ".scalar @org_ids." -- ids: ".scalar @ids."\n";
	}
    #end recursive

	my $id_iterator = XIMS::Iterator::Object->new( \@ids, 1 );
	while ( my $obj = $id_iterator->getNext() ) {
		foreach(@grantees){
				my $gid = $_->id();
				
				# revoke the privs
				my $privs_object = XIMS::ObjectPriv->new(
					grantee_id => $gid,
					content_id => $obj->id()
				);
				
				my $boolean = ($privs_object and $privs_object->delete());
				if ($boolean) {
					XIMS::Debug( 5, "ACL privs changed for (" . $_->name() . ")" );
					#$ctxt->properties->application->style('obj_user_update');
#					my $granted = XIMS::User->new( id => $uid );
#					$ctxt->session->message(
#						__x("Privileges changed successfully for user/role '{name}'.",
#							name => $granted->name(),
#						)
#					);
				}
				else {
					XIMS::Debug( 2, "ACL grant failure on ". $obj->document_id . " for ". $_->name() );
				}
			}
			#$ctxt->properties->application->style('obj_user_update');
    }
	XIMS::Debug( 4, "redirecting to the container" );
    $self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id ) );
    return 0;
    }
	else{
		$ctxt->properties->application->styleprefix('common');
		$ctxt->properties->application->style('error');
		XIMS::Debug( 2, "no grantee(s) provided" );
		$self->sendError( $ctxt, __ "Please provide at least one grantee." );
		return 0;
	}
}

=head2 event_obj_aclrevoke()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_obj_aclrevoke(...)

=cut

sub event_obj_aclrevoke {
	my ( $self, $ctxt ) = @_;
	XIMS::Debug( 5, "called" );

	my $user     = $ctxt->session->user();
	my $object   = $ctxt->object();
	my $objprivs = $user->object_privmask($object);

	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('error');

	if ( $user and $objprivs and $object ) {

		# the aclist event will only work if there can be an user, object
		# found, plus a minimal privilege mask is found.
		#
		# before one can really see the privileges on an object, one needs one
		# or the other grant privilege (XIMS::Privilege::GRANT or
		# XIMS::Privilege::GRANT_ALL) for his own. Optional a system privilege
		# may does the same trick.

		if (   $objprivs & XIMS::Privileges::GRANT()
			|| $objprivs & XIMS::Privileges::GRANT_ALL() )
		{
			XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

			# get the other userid
			my $uid = $self->param('userid');

			# revoke the privs
			my $privs_object = XIMS::ObjectPriv->new(
				grantee_id => $uid,
				content_id => $object->id()
			);

			if ( $privs_object and $privs_object->delete() ) {
				XIMS::Debug( 6,
					"ACL privs changed for (" . $user->name() . ")" );
				$ctxt->properties->application->style('obj_user_update');
				my $revoked = XIMS::User->new( id => $uid );
				$ctxt->session->message(
					__x(
"Privileges successfully revoked for user/role '{name}'.",
						name => $revoked->name(),
					)
				);
			}
			else {
				XIMS::Debug( 2,
					    "ACL grant failure on "
					  . $object->document_id . " for "
					  . $user->name() );
			}

		}
		else {
			XIMS::Debug( 2, "ACL check failed (" . $user->name() . ")" );
		}
	}
	else {
		XIMS::Debug( 3, "anonymous granting rejected" );
	}

	return 0;
}

=head2 event_posview()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_posview(...)

=cut

sub event_posview {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $object = $ctxt->object();
	my $parent = XIMS::Object->new(
		document_id => $object->parent_id,
		language_id => $object->language_id
	);

	$ctxt->properties->content->siblingscount(
		$parent->child_count( marked_deleted => 0 ) );
	$ctxt->properties->application->styleprefix("container");
	$ctxt->properties->application->style("posview");

	return 0;
}

=head2 event_reposition()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_reposition(...)

=cut

sub event_reposition {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $object = $ctxt->object;

	my $current_user_object_priv =
	  $ctxt->session->user->object_privmask($object);
	return $self->event_access_denied($ctxt)
	  unless $current_user_object_priv & XIMS::Privileges::WRITE();

	my $new_position = $self->param("new_position");

	if ( $new_position > 0 and $object->position != $new_position ) {
		if ( $object->reposition( position => $new_position ) ) {
			XIMS::Debug( 4, "object repositioned" );
		}
		else {
			XIMS::Debug( 2, "repositioning failed" );
		}
	}

	# be sure the users get's to see the newly positioned object
	$self->param( 'sb',    'position' );
	$self->param( 'order', 'asc' );
	my $c = $new_position / XIMS::SEARCHRESULTROWLIMIT();
	my @size = split( /\./, $c );
	my $page = int($c) + ( scalar(@size) > 1 ? 1 : 0 );   # poor man's ceiling()
	$self->param( 'page', $page );

	XIMS::Debug( 4, "redirecting to parent" );
	$self->redirect( $self->redirect_uri( $ctxt, $object->parent->id() ) );
	return 0;
}

=head2 handle_bang_commands();

=head3 Parameter

    $ctxt            : Application context
    $search          : Searchstring

=head3 Returns

    undef on error, 1 on succes

=head3 Description

   $self->handle_bang_commands( $ctxt, $search );

this one exists to avoid spaghetti- and nested-if-uglyness in
event_search; commands that start with a bang get processed here.

=cut

sub handle_bang_commands {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt, $search ) = @_;
	my $user = $ctxt->session->user();
	my $object;
	my $retval = undef;

	# did user give an id?
	if ( $search =~ s/\!U:(\d+)$/$1/ ) {
		XIMS::Debug( 6, "unlock per id: $search" );
		$object = XIMS::Object->new( id => $1, User => $user );
	}
	elsif ( $search =~ s/\!U:(\/.+)/$1/ ) {
		XIMS::Debug( 6, "unlock per path: $search" );
		$object = XIMS::Object->new( path => $1, User => $user );
	}
	else {
		XIMS::Debug( 2, "invalid command: $search" );
		$self->sendError( $ctxt,
			__x( "{search} is an invalid command!", search => $search, ) );
		return;
	}

	if ( $object and $object->locked ) {
		my $objprivs = $user->object_privmask($object);
		if ( defined $objprivs and ( $objprivs & XIMS::Privileges::WRITE() ) ) {
			if ( $object->unlock() ) {
				$retval = 1;
			}
			else {
				$self->sendError( $ctxt, __ "unlock failed" );
			}
		}
		else {
			XIMS::Debug( 4,
				"insufficient privileges, user cannot remove lock" );
			$self->sendError( $ctxt,
				__ "Insufficient privileges, you cannot remove the lock" );
		}

	}
	else {
		XIMS::Debug( 4, "no locked object found" );
		$self->sendError( $ctxt,
			__ "Could not find a locked object with that search string" );
	}

	return $retval;
}

=head2 body_ref_objects();

=head3 Description

    $self->body_ref_objects( $ctxt );

Checks links stored within an object's body. If local references are
found the function will test if the object is stored in XIMS. The
function will return a hash that has the local URI as the key and the
object as value.

=cut

sub body_ref_objects {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my @objects;
	my $object = $ctxt->object();

	# load the objects body
	my $body = $object->body();
	return () unless defined $body;

	my $parser = XML::LibXML->new();
	my $chunk;
	eval {
		my $data = XIMS::encode($body);
		$chunk = $parser->parse_xml_chunk($data);
	};
	if ($@) {
		XIMS::Debug( 4, "cannot parse the body. reason: $@" );
		return ();
	}

	# pseudo code for XML::LibXML 1.52 and libxml2 < 2.4.25
	my $doc = XML::LibXML->createDocument();
	$doc->setDocumentElement( $doc->createElement("foo") );
	$doc->documentElement->appendChild($chunk);
	$chunk = $doc->documentElement;

	# end pseudo code

	# now get all the items that are referred
	my @data = $chunk->findnodes('.//@href | .//@src');

	my @paths = map { $_->nodeValue(); } @data;

	# resolve path for relative references
	my $parent = XIMS::Object->new(
		document_id => $object->parent_id(),
		language_id => $object->language_id
	);
	my $parent_path = $parent->location_path();
	my @ancestors   = @{ $object->ancestors() };

	# lets see if the objects exist in our system.
	my %paths_seen;
	my %ximspaths_seen;
	foreach my $p (@paths) {
		$p =~ s/\?.*$//;    # strip querystring
		next unless length $p;
		next if $paths_seen{$p};
		if (
			$p =~ m/^[a-z][-+.a-z1-9]+:/    # uri schema part
			or $p =~ m|^#| or $p =~ m|\{[^\}]*\}|
		  )
		{
			XIMS::Debug( 4, "real URI or anchor" );
			next;
		}
		my $exp = $p;
		if ( $exp =~ m|^\.\./| ) {
			my @size = split( '\.\./', $exp );
			my $anclevel = scalar(@size) - 1;
			my $i = scalar @ancestors - 1 - $anclevel;  # ancestors include root
			my $relparent;
			$relparent = $ancestors[$i] if $i >= 0;
			next unless $relparent;
			$exp =~ s|\.\./||g;
			$exp = $relparent->location_path() . "/" . $exp;
		}
		elsif ( $exp =~ m|^\./| ) {
			$exp =~ s/^\.\///;
			$exp = "$parent_path/$exp";
		}
		elsif ( $exp !~ m|^/| ) {
			$exp = "$parent_path/$exp";
		}
		elsif ( $exp =~ m|^/| and XIMS::RESOLVERELTOSITEROOTS() ) {
			$exp = '/' . $object->siteroot->location() . $exp;
		}

		next if $ximspaths_seen{$exp};
		$ximspaths_seen{$exp}++;

		XIMS::Debug( 6, "resolving path $p ($exp)" );
		my $object = XIMS::Object->new(
			path        => $exp,
			language_id => $object->language_id()
		);
		$paths_seen{$p}++;
		next unless $object;
		$object->{location_path} = $p;   # we want to preserve the original link
		                                 # for the users
		push @objects, $object;
	}

	return @objects;
}

=head2 autopublish()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->autopublish(...)

=cut

sub autopublish {
	XIMS::Debug( 5, "called" );
	my $self                   = shift;
	my $ctxt                   = shift;
	my $exporter               = shift;
	my $method                 = shift;
	my $objids                 = shift;
	my $no_dependencies_update = shift;
	my $recpublish             = shift;

	my $published = 0;
	my $user = $ctxt->session->user();
	# foreach ( @{$objids} ) {
	# 	warn $_;
	# }
	foreach my $id ( @{$objids} ) {
		next unless defined $id;
		my $object =
		  XIMS::Object->new( id => $id, User => $ctxt->session->user() );
		if ($object) {
			if ( $ctxt->session->user->object_privmask($object) & XIMS::Privileges::PUBLISH() ){
				#if we publish: publish parent first 
				if($method eq 'publish'){
					if (
						$exporter->$method(
							Object                 => $object,
							no_dependencies_update => $no_dependencies_update
						)
					  )
					{
						XIMS::Debug( 4, $method . "ed object with id $id" );
						$published++;
					}
					else {
					XIMS::Debug( 3, "could not $method object with id $id" );
					next;
					}
				}
				#recursive publishing
				if ( ($object->data_format->mime_type() eq 'application/x-container') and ($recpublish or ($method eq 'unpublish'))){
					my %options;
					my $privmask;
					my %param = ( User => $user, marked_deleted => 0 );
					my @descendants = reverse sort { $a->{level} <=> $b->{level} } $object->descendants_granted(%param);
					
					$options{no_dependencies_update} = 1 if scalar @descendants > 0;
					my $path;
					my %seencontainers;

					foreach my $child (@descendants) {
						next if $child->location() eq '.diff_to_second_last';    # an -exception- :-|
						$child    = rebless($child);
						$privmask = $user->object_privmask($child);
						$path     = $child->location_path();

						my ($dir) = ( $path =~ m#(.*)/(.*)$# );

						if ( $privmask & XIMS::Privileges::PUBLISH() ) {
							if (
								$exporter->$method(
									Object => $child,
									User   => $user,
									%options
								)
							  )
							{
								#warn "\nObject '$path' " . $method. "ed successfully.\n";
								$seencontainers{$dir}++;
								$published++;
							}
							else {
								XIMS::Debug(3, "could not $method object '$path'.");
							}
						}
						else {
							XIMS::Debug(4, "no privileges to $method object '$path'." );
						}
					}    #end foreach child
				}    #end if container
				#if we unpublish: unpublish children first 
				if($method eq 'unpublish'){
					if (
						$exporter->$method(
							Object                 => $object,
							no_dependencies_update => $no_dependencies_update
						)
					  )
					{
						XIMS::Debug( 4, $method . "ed object with id $id" );
						$published++;
					}
					else {
					XIMS::Debug( 3, "could not $method object with id $id" );
					next;
					}
				}#end if method unpublish
				
			}#end if check for privileges
			else {
				XIMS::Debug( 3, "no privileges to $method object with id $id" );
				next;
			}
		}# end if object
		else {
			XIMS::Debug( 3, "could not find an object with id $id" );
			next;
		}
	}# end foreach objids
	return $published;
}

sub rebless {
	my $object  = shift;
	my $otclass = "XIMS::" . $object->object_type->fullname();

	# load the object class
	eval "require $otclass;" if $otclass;
	if ($@) {
		die "Could not load object class $otclass: $@\n";
	}

	# rebless the object
	bless $object, $otclass;
	return $object;
}

=head2 event_search()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_search(...)

=cut

sub event_search {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	# if we are coming from a different interface (e.g. user(s)) we have to
	# check for that here
	if ( not $ctxt->object() ) {

		# reuse code
		require XIMS::CGI::defaultbookmark;
		return XIMS::CGI::defaultbookmark::redirToDefault( $self, $ctxt );
	}

	my $filterpublished = $self->param('p');

	# Usage: ?intranet=intern;... filter granted, published objects that have
	# "/intern/" in their location_path.
	my $filterintranet = $self->param('intranet');
	if ($filterintranet) {
		$ctxt->properties->application->usepubui(1);
		$filterpublished = 1;
	}
	my $user = $ctxt->session->user();

	# event_search may get the search string latin1-encoded if used by the
	# public-search interface (?search=1;s=searchstring;p=1) Check for that
	# eventuality here and encode to utf-8 in case.
	my $search = XIMS::utf8_sanitize( $self->param('s') );
	if ( defined $search ) {
		$self->param( 's', $search );    # update CGI param, so that stylesheets
		                                 # get the right one
	}
	$search ||= XIMS::decode( $self->param('s') );    # fallback

	my $offset = $self->param('page');
	$offset = $offset - 1 if $offset;
	$offset ||= 0;
	my $rowlimit = XIMS::SEARCHRESULTROWLIMIT();
	$offset = $offset * $rowlimit;

	$ctxt->properties->application->style('error');

	XIMS::Debug( 6, "param $search" );

	# does the searchstring look like a command?
	if ( $search =~ /^\!\w+:/ && ( length($search) <= 55 ) && !$filterintranet )
	{

		return 0 if not defined $self->handle_bang_commands( $ctxt, $search );

		# redir to self...
		$self->redirect( $self->redirect_uri( $ctxt, $ctxt->object->id() ) );
	}

	# length within 2..30 chars
	if ( ( length($search) >= 2 ) && ( length($search) <= 30 ) ) {
		my $qbdriver;
		if ( XIMS::DBMS() eq 'DBI' ) {
			$qbdriver = XIMS::DBDSN();
			$qbdriver = ( split( ':', $qbdriver ) )[1];
		}
		else {
			XIMS::Debug( 2, "search not implemented for non DBI DPs" );
			$ctxt->session->error_msg( __
"Search mechanism has not yet been implemented for non DBI based datastores!"
			);
			return 0;
		}

		## no critic (ProhibitStringyEval)
		$qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();

		eval "require $qbdriver";    #

		if ($@) {
			XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
			$ctxt->session->error_msg(
				__ "QueryBuilder-Driver could not be found!" );
			return 0;
		}
		## use critic

		# Make sure the utf8 flag is turned on for handling the allowed
		# chars regex
		if ( not XIMS::DBENCODING() ) {
			require Encode;
			no warnings 'prototype';
			Encode::_utf8_on($search);
		}

		use encoding "latin-1";
		my $allowed =
		  XIMS::decode(
			q{\!a-zA-Z0-9öäüßÖÄÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~}
		  );
		my $qb = $qbdriver->new(
			{
				search          => $search,
				allowed         => $allowed,
				filterpublished => $filterpublished,
				fieldstolookin  => [qw(title abstract keywords body)]
			}
		);

		if ( defined $qb ) {
			my ( $critstring, @critvals ) = @{ $qb->criteria() };
			my %param = (
				criteria => [
					$critstring . " AND location <> '.diff_to_second_last'",
					@critvals
				],
				limit  => $rowlimit,
				offset => $offset,
				order  => $qb->order(),
			);
			my $method;
			my $start_here;
			if ($filterintranet) {
				$param{criteria}->[0] .= " AND location_path LIKE ?";
				push( @{ $param{criteria} }, "%/$filterintranet/%" );
				$start_here =
				  $self->param('start_here') ? $ctxt->object() : '/uniweb';
				$method = 'find_objects_granted';
			}
			elsif ($filterpublished) {
				my $searchpath = $self->param('sp');
				if ( defined $searchpath and length $searchpath > 2 ) {
					$start_here = $searchpath;
				}
				else {
					$start_here = $ctxt->object();
				}
				$method = 'find_objects';
			}
			else {
				$start_here = $ctxt->object() if $self->param('start_here');
				$method = 'find_objects_granted';
			}
			$param{start_here} = $start_here;
			my @objects = $ctxt->object->$method(%param);

			if ( not @objects ) {
				$ctxt->session->warning_msg( __ "Query returned no objects!" );
			}
			else {
				$method .= "_count";
				delete $param{order};
				delete $param{offset};
				delete $param{limit};
				my $count   = $ctxt->object->$method(%param);
				my $message = __nx(
					"Query returned one object.",
					"Query returned {count} objects.",
					$count, count => $count,
				);
				if ($count) {
					$message .= __x(
						" Displaying objects {lower} to {upper}.",
						lower => $offset + 1,
						upper => ( $offset + $rowlimit ) > $count
						? $count
						: $offset + $rowlimit
					);
				}
				$ctxt->session->message($message);
				$ctxt->session->searchresultcount($count);
			}

			$ctxt->objectlist( \@objects );
			$ctxt->properties->content->getformatsandtypes(1)
			  ;    # to resolve the result
			$ctxt->properties->content->resolveimage_id(1)
			  if $self->param('ri');
		}
		else {
			XIMS::Debug( 3, "please specify a valid query" );
			$ctxt->session->error_msg( __ "Please specify a valid query!" );
		}
	}
	else {
		XIMS::Debug( 3, "catched improper query length" );
		$ctxt->session->error_msg(
			__ "Please keep your queries between 2 and 30 characters!" );
	}

	$ctxt->properties->application->styleprefix('common_search');
	$ctxt->properties->application->style('result');

	return 0;
}

=head2 event_sitemap()

=head3 Parameter

=head3 Returns

=head3 Description

    $self->event_sitemap(...)

=cut

sub event_sitemap {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	# $ctxt->properties->application->style() = "error";

	my $object   = $ctxt->object();
	my $maxlevel = 3;                 # create XIMS::SITEMAPMAXLEVEL for that

	my @descendants = $object->descendants_granted( maxlevel => $maxlevel );

	$ctxt->objectlist( \@descendants );

	$ctxt->properties->content->getformatsandtypes(1);   # to resolve the result
	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('sitemap');

	return 0;
}

1;

package XIMS::CGI::ByeBye;
use Locale::TextDomain ('info.xims');

=head2 event_trashcan();

=head3 Parameter

    $ctxt: application context

=head3 Returns

 0 ;)

=head3 Description

    $self->event_trashcan( $ctxt );

=cut

sub event_trashcan_content {
	XIMS::Debug( 5, "called" );
	my ( $self, $ctxt ) = @_;

	my $maxresults = 50;    # hardcoded atm
	                        # sth like findObjects not yet available again
	$ctxt->objectlist(
		$ctxt->{-PROVIDER}->findObjects(
			-user         => $ctxt->session->user,
			-conditionstr => "marked_deleted = 1",
			-rowlimit     => $maxresults,
		)
	);

	$ctxt->session->error_msg(
		__ "Use the options to undelete or purge objects." );
	$ctxt->properties->application->styleprefix('common');
	$ctxt->properties->application->style('trashcan');

	return 0;
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

