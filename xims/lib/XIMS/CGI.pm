# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI;

use strict;
use vars qw( $VERSION @ISA );

use XIMS;
use XIMS::DataFormat;
use XIMS::SAX;
use XIMS::ObjectPriv;
use CGI::XMLApplication 1.1.3; # sub-sub-version is not recognized here :-/
use XML::LibXML::SAX::Builder;
use Apache::URI;
# <pepl> The LibXML utf8(de|en-)coding functions won't convert strings coming from
# $self->param() even if they are utf-8. Possibly because the high-bit is not
# set. (Which I cannot check for in Perl 5.6.1).
# The behaviour may be different with other XML::LibXML versions besides 1.56.
# The behaviour may also be different with other Perl versions besides 5.6.1
# Text::Iconv seems to be the most compatible module, so we are using it here.
use Text::Iconv;

#use Data::Dumper;
############################################################################
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
############################################################################

@ISA = qw/CGI::XMLApplication/; # change the base class if necessary

# These are messages all app-scripts should use. [0-6]
@XIMS::CGI::MSG  = (  "No object id found!",
           "Object id is not valid!",
           "No location set!",
           "Database synchronization failed!",
           "Access Denied! Sorry.",
           "Location already exists in container!",
           "Delete failed!",
           "Document could not be formed well. Please consult the User's Reference for information on well-formed document bodies.",
                 );

# some callbacks we need to the the thing run
# first we register the events we handle
sub registerEvents {
    my $self = shift;
    return ( 'dbhpanic', 'access_denied', 'move_browse', 'move', 'copy', 'cancel', 'contentbrowse', 'search', 'sitemap', 'reposition', 'posview', 'plain', 'trashcan_prompt', 'trashcan', 'delete', 'delete_prompt', 'undelete', 'trashcan_content', 'error', @_ );
}

############################################################################
# event methods
############################################################################

sub event_init {
    my $self = shift;
    my $ctxt = shift;
    $self->SUPER::event_init( $ctxt );

    return $self->sendEvent( 'access_denied' ) unless $ctxt->session->user();
    return unless $ctxt->object(); # no object-ACL-check needed if we do not have a content object

    # ACL check
    if ( length $self->checkPush('create')
         || ( length $self->checkPush('store')
              and length $self->param( 'objtype' ) ) ) {

        my $objtype = $self->param( 'objtype' );
        if ( not $objtype ) {
            $self->sendError( $ctxt, "Specify an object type to create an object!" );
            return $self->sendEvent( 'error' );
        }

        my $parent = $ctxt->object();
        $ctxt->parent( $parent ); # used later in the app chain and for serialization

        my $privmask = $ctxt->session->user->object_privmask( $ctxt->object() );
        return $self->event_access_denied( $ctxt ) unless $privmask & XIMS::Privileges::CREATE();

        my %obj = ( parent_id           => $parent->document_id(),
                    language_id         => $parent->language_id(),
                  );

        my $class = 'XIMS::' . $objtype;
        eval "require $class";
        if ( $@ ) {
            XIMS::Debug( 2, "Can't find the object class: " . $@ );
            $self->sendError( $ctxt, "Can't find the object class: " . $@ );
            return $self->sendEvent( 'error' );
        }
        $ctxt->object( $class->new( %obj, User => $ctxt->session->user ) );
    }
    else {
        my $privmask = $ctxt->session->user->object_privmask( $ctxt->object() );
        return $self->sendEvent( 'access_denied' ) unless $privmask & XIMS::Privileges::VIEW();
    }
}

sub event_dbhpanic {
    my $self = shift;
    $self->setPanicMsg( "Can not connect to database server." );
    return -4
}

sub event_access_denied {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->sendError( $ctxt, "Access Denied" );

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_default {
    XIMS::Debug( 5, "called");
    my ( $self, $ctxt ) = @_;


    # redirect to full path in case object is called via id
    if ( $self->path_info() eq XIMS::CONTENTINTERFACE()
         and not $ctxt->object->marked_deleted() ) {

        # not needed anymore
        $self->delete('id');

        XIMS::Debug( 4, "redirecting to full path" );
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) );

        return 1;
    }

    if ( $self->param( 'bodyonly' ) ) {
        $ctxt->properties->application->styleprefix( 'common' );
        $ctxt->properties->application->style( 'bodyonly' ) ;
    }

    $ctxt->properties->content->getchildren->level( 1 );

    return 0;
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $dp = $ctxt->data_provider();

    my $r_type = $self->resource_type( $ctxt );
    return $self->event_access_denied( $ctxt ) unless defined( $r_type );

    $ctxt->properties->application->style( "edit" ) ;
    $ctxt->properties->content->dontescapestringprops( 1 );

    my $object = $ctxt->object();

    # operation control section
    unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
        return $self->event_access_denied( $ctxt );
    }

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

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # check for CREATE privilege is done in event_init

    my $r_type = $self->resource_type( $ctxt );
    return $self->event_access_denied( $ctxt ) unless defined( $r_type );

    $ctxt->properties->application->style( "create") ;

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my $self   = shift;
    my $ctxt   = shift;

    my $r_type = $self->resource_type( $ctxt );
    return $self->event_access_denied( $ctxt ) unless defined( $r_type );

    my $object = $ctxt->object();

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

        XIMS::Debug( 4, "granting privileges" );

        my $owneronly = $self->param( 'owneronly' );
        if ( defined $owneronly and ( $owneronly eq 'true' or $owneronly == 1 ) ) {
            $owneronly = 1;
        }
        else {
            $owneronly = 0;
        }
        my $defaultroles = $self->param( 'defaultroles' );
        if ( defined $defaultroles and ( $defaultroles eq 'true' or  $defaultroles == 1 ) ) {
            $defaultroles = 1;
        }
        else {
            $defaultroles = 0;
        }

        if ( $self->default_grants( $ctxt, $owneronly, $defaultroles, ) ) {
            XIMS::Debug( 4, "updated user privileges" );
        }
        else {
            $self->sendError( $ctxt , "failed to set default grants" );
            XIMS::Debug( 2, "failed to set default grants" );
            return 0;
        }
    }

    XIMS::Debug( 4, "redirecting" );
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 1;
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_trashcan_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'trashcan_confirm' );
}

sub event_delete_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'delete_confirm' );
}

sub event_cancel {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $r_type = $self->resource_type( $ctxt );
    return $self->event_access_denied( $ctxt ) unless defined( $r_type );

    if ( $r_type eq 'object' ) {
        my $object = $ctxt->object();
        if ( $object->unlock() ) {
            XIMS::Debug( 4, "object has been un-locked" );
        }
        else {
            XIMS::Debug( 2, "object could not be unlocked!" );
            $self->sendError( $ctxt, "Object could not be unlocked!" );
            return 0;
        }
        XIMS::Debug( 4, "redirecting" );
        $self->redirect( $self->redirect_path( $ctxt ) );
    }

    return 0;
}

sub event_plain {
    # give back only and really only the body of the object with its content-type and the DB-Encoding
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $body = $ctxt->object->body();
    my $df = XIMS::DataFormat->new( id => $ctxt->object->data_format_id() );
    my $mime_type = $df->mime_type;

    my $charset;
    if (! ($charset = XIMS::DBENCODING )) { $charset = "UTF-8"; }
    print $self->header( -Content_type => $mime_type."; charset=".$charset );
    print $body;
    $self->skipSerialization(1);

    return 0;
  }


#*#
############################################################################
# methods called directly by (or overrides to methods in) CGI::XMLApplication
############################################################################

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

    my $stylepath = $self->getStylesheetDir() . '/';
    my $stylefilename = $styleprefix . '_' . $stylesuffix . '.xsl';

    my $publicusername = $ctxt->apache()->dir_config('ximsPublicUserName');
    if ( defined $publicusername ) {
        # Emulate request.uri CGI param, set by Apache::AxKit::Plugin::AddXSLParams::Request
        # ($request.uri is used by public/*.xsl stylesheets)
        $self->param( 'request.uri', $ctxt->object->location_path_relative() );

        my $stylesheet = $ctxt->object->stylesheet();

        my $pubstylepath;
        if ( defined $stylesheet and $stylesheet->published() ) {
            # check here if the stylesheet is not a directory but a single XSLStylesheet?
            #
            XIMS::Debug( 4, "trying public-user-stylesheet from assigned directory" );
            $pubstylepath = XIMS::PUBROOT() . $stylesheet->location_path() . '/' . $ctxt->session->uilanguage . '/';
        }
        else {
            XIMS::Debug( 4, "trying fallback public-user-stylesheet" );
            $pubstylepath = XIMS::XIMSROOT() . '/skins/' . $ctxt->session->skin . '/stylesheets/public/' . $ctxt->session->uilanguage() . '/';
        }

        my $filepath = $pubstylepath . $stylefilename;
        if ( -f $filepath and -r $filepath ) {
            $stylepath = $pubstylepath;
        }
        else {
            XIMS::Debug( 4, "no public-user-stylesheet found, using default stylesheet" );
        }
    }

    $retval = $stylepath . $stylefilename;
    XIMS::Debug( 6, "stylesheet is '$retval'\n" );

    return $retval;
}

sub getDOM {
    XIMS::Debug( 5, "called" );
    my $self    = shift;
    my $ctxt    = shift;
    my %handlerargs;

    my $generator = defined $ctxt->sax_generator() ? $ctxt->sax_generator() : undef;
    my $filter    = defined $ctxt->sax_filter()    ? $ctxt->sax_filter()    : [];
    my $handler   = XML::LibXML::SAX::Builder->new();
    $handler->{Encoding} = XIMS::DBENCODING() if XIMS::DBENCODING();
    my $controller = XIMS::SAX->new( Handler => $handler,
                                     Generator => $generator,
                                     FilterList => $filter,
                                   );
    return undef unless $controller;

    my $dom = $controller->parse( $ctxt );
    XIMS::Debug( 5, "done" );
    return $dom;
}

sub setHttpHeader {
    my $self = shift;
    my $ctxt = shift;
    my %my_headers = ();
    $my_headers{-cookie} = $ctxt->properties->application->cookie() if defined $ctxt->properties->application->cookie();
    $my_headers{-nocache} = 1 if defined $ctxt->properties->application->nocache();
    return %my_headers;
}

sub getXSLParameter {
    my ( $self, $ctxt ) = @_;
    return %{ $self->Vars() };
}

sub sendError {
    my $self = shift;
    my $ctxt = shift;
    my $msg  = shift;

    $ctxt->session->error_msg( $msg );
    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( "error" );
}

sub event_error {
    return 0;
}

############################################################################
# helper methods available to all event subs.
############################################################################

sub object_locked {
    my $self = shift;
    my $ctxt = shift;
    if ( $ctxt->object->locked() and
         $ctxt->object->locked_by_id() ne $ctxt->session->user->id() ) {
        return 1;
    }
    return undef;
}

sub redirect {
    my $self = shift;
    XIMS::Debug( 6, "called " . join( ", " ,@_ ));
    $self->redirectToURI( @_ );
}

# small helper to determine what sort of 'thingie'
# we are operating on (user, content object, whatever
# we might add later)
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
        return undef;
    }
}

sub expand_attributes {
    my ( $self, $ctxt ) = @_;

    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
    push @{$ctxt->sax_filter()}, "XIMS::SAX::Filter::Attributes"
}

sub resolve_content {
    my $self = shift;
    my $ctxt = shift;
    my $list = shift;
    my $reltosite = shift;

    return unless defined $list and scalar @$list;

    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();

    eval "require XIMS::SAX::Filter::ContentIDPathResolver;";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load ContentIDPathResolver: $@" );
        return 0;
    }

    my %args = ( Provider => $ctxt->data_provider(),
                 ResolveContent => $list,
                 NonExport => 1,
               );

    push ( @{$ctxt->sax_filter()}, XIMS::SAX::Filter::ContentIDPathResolver->new( %args ) );
}

sub resolve_user {
    my $self = shift;
    my $ctxt = shift;
    my $list = shift;

    return unless defined $list and scalar @$list;

    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();

    eval "require XIMS::SAX::Filter::UserIDNameResolver;";
    if ( $@ ) {
        XIMS::Debug( 2, "could not load UserIDNameResolver: $@" );
        return 0;
    }

    push ( @{$ctxt->sax_filter()},
           XIMS::SAX::Filter::UserIDNameResolver->new( Provider => $ctxt->data_provider(),
                                                       ResolveUser => $list,
                                                     )
         );
}

sub redirect_path {
    my ( $self, $ctxt, $id ) = @_;

    my $object = $ctxt->object();
    my $dp     = $ctxt->data_provider();

    my $redirectpath;
    my $r = $self->param('r');
    if ( defined $r ) {
        $redirectpath = $dp->location_path( id => $r );
    }
    elsif ( defined $id ) {
        $redirectpath = $dp->location_path( id => $id );
    }
    else {
        my $objtype = $object->object_type();
        if ( $objtype->redir_to_self() == 0 ) {
            $redirectpath = $dp->location_path( document_id => $object->parent_id() );
        }
        else {
            $redirectpath = $dp->location_path( document_id => $object->document_id() );
        }
    }

    # special case for '/root' which got an undefined location_path
    $redirectpath ||= '/root';

    my $sb = $self->param( "sb" );
    my $order = $self->param( "order" );
    my $m = $self->param( "m" );
    my $hd = $self->param( "hd" );
    my $hls = $self->param( "hls" );
    my $bodyonly = $self->param( "bodyonly" );
    my $plain = $self->param( "plain" );
    my $page = $self->param( "page" );
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

    my $uri = Apache::URI->parse( $ctxt->apache() );
    $uri->path( $ctxt->apache->parsed_uri->rpath() . $redirectpath );
    $uri->query( $params );

    # warn "redirecting to ". $uri->unparse();
    return $uri->unparse();
}

sub clean_location {
    my $self = shift;
    my $location = shift;
    my %escapes = (
                   ' '  =>  '_',
                   'צ'  =>  'oe',
                   'ר'  =>  'oe',
                   'ײ'  =>  'Oe',
                   '״'  =>  'Oe',
                   'ה'  =>  'ae',
                   'ִ'  =>  'Ae',
                   'ü'  =>  'ue',
                   'Ü'  =>  'Ue',
                   'ß'  =>  'ss',
                   'ב'  =>  'a',
                   'א'  =>  'a',
                   'ו'  =>  'a',
                   'ֱ'  =>  'A',
                   'ְ'  =>  'A',
                   'ֵ'  =>  'A',
                   'י'  =>  'e',
                   'ך'  =>  'e',
                   'ט'  =>  'e',
                   'ֹ'  =>  'E',
                   'Ê'  =>  'E',
                   'ָ'  =>  'E',
                   'ס'  =>  'gn',
                   'ׁ'  =>  'Gn',
                   'ף'  =>  'o',
                   'ע'  =>  'o',
                   'פ'  =>  'o',
                   'ׂ'  =>  'O',
                   '׃'  =>  'O',
                   'װ'  =>  'O',
                   '§'  =>  '_',
                   "\$" =>  '_',
                   "\%" =>  '_',
                   '&'  =>  '_',
                   '/'  =>  '_',
                   '\\' =>  '_',
                   '='  =>  '_',
                   '?'  =>  '',
                   '!'  =>  '',
                   '`'  =>  '_',
                   '´'  =>  '_',
                   '*'  =>  '_',
                   '+'  =>  '_',
                   '~'  =>  '_',
                   "'"  =>  '_',
                   '#'  =>  '_',
                   '|'  =>  '_',
                   '°'  =>  '_',
                   ','  =>  '',
                   ';'  =>  '',
                   ':'  =>  ''
                  );
    my $badchars = join "", keys %escapes;
    $location =~ s/
                    ([$badchars])     # more flexible :)
                  /
                    $escapes{$1}
                  /segx;              # *coff*
    $location =~ s/_+/_/g;

    XIMS::Debug( 5, "done" );
    return lc($location);
}

sub init_store_object {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $object = $ctxt->object();
    my $parent;
    my $location   = $self->param( 'name' ); # is somehow xml-escaped magically by libxml2 (???)
    my $title      = $self->param( 'title' );
    my $markednew  = $self->param( 'markednew' );
    my $keywords   = $self->param( 'keywords' );
    my $image      = $self->param( 'image' );

    my $converter = Text::Iconv->new("UTF-8", "ISO-8859-1");
    # will be undef if string can not be converted to iso-8859-1;
    $location = $converter->convert($location) if defined $location;

    if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
        $title = XIMS::decode($title) if defined $title;
        $keywords = XIMS::decode($keywords) if defined $keywords;
    }

    if ( $object and $object->id() and length $self->param( 'id' ) ) {
        unless ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::WRITE ) {
            return $self->event_access_denied( $ctxt );
        }
        XIMS::Debug( 4, "storing existing object" );
        $parent = XIMS::Object->new( document_id => $object->parent_id );
    }
    else {
        $parent = $ctxt->parent();
    }

    if ( defined $location and length $location ) {
        if ( not $ctxt->properties->application->preservelocation ) { # some object types, like URLLink for example
                                                                      # need the location to be untouched
            $location = ( split /[\\|\/]/, $location )[-1]; # should always work
            $location = $self->clean_location( $location );
            unless ( $ctxt->properties->application->keepsuffix ) { # some object type, like File or Image for example
                                                                    # don't want filesuffixes to be overridden by our
                                                                    # data format's default value
                my $suffix = $object->data_format->suffix();
                # temp. hack until multi-language support is implemented
                # to allow simple content-negotiation using .lang suffixes
                if ( defined $suffix and length $suffix and not ($suffix eq 'html'
                                                                 and $location =~ /.*\.html\.(de|en|es|it|fr|html)$/) ) {
                    XIMS::Debug( 6, "exchanging suffix with $suffix ($location)" );
                    $location =~ s/\.[^\.]+$//;
                    $location .= "." . $suffix;
                    XIMS::Debug( 6, "exchange done, location is now $location" );
                }
            }
            unless ( ($location =~ /[\w\d]+\.[\w\d]+/) || ($location =~ /[\w\d]+/) ) {
                XIMS::Debug( 2, "dirty location" );
                $self->sendError( $ctxt, "failed to clean the location / filename. Please supply a sane filename!" );
                return 0;
            }
        }

        if ( ($location ne $object->location())
            and $object->published()
            and not $object->object_type->publish_gopublic()
            and $object->object_type->name() ne 'URLLink' ) { # URLLink is a special case for now.
                                                              # Maybe we set publish_gopublic to 1 for it,
                                                              # or we will be adding an object-type
                                                              # property at the point when similar
                                                              # object-types will be added that do not have
                                                              # publish_gopublic set but are not published
                                                              # to the filesystem either
            $self->sendError( $ctxt, "Cannot rename this published object, please unpublish it first!" );
            return 0;
        }

        # check if the same location already exists in the current container (and its a different object)
        if ( defined $parent ) {
            my @children = $parent->children( location => $location, marked_deleted => undef );
            if ( ( $object->id() and scalar @children == 1 and $children[0] and $children[0]->id() != $self->param( 'id' ) ) or ( not $object->id() and defined $children[0] ) ) {
                XIMS::Debug( 2, "location already exists" );
                $self->sendError( $ctxt, "Location '$location' already exists in container." );
                return 0;
            }
        }

        XIMS::Debug (6, "got location: $location ");
        $object->location( $location );
    }
    else {
        XIMS::Debug( 3, "no location" );
        $self->sendError( $ctxt, "Please supply a location!" );
        return 0;
    }

    my $location_nosuffix = $location;
    $location_nosuffix =~ s/\.[^\.]+$// unless $ctxt->properties->application->preservelocation();
    $object->title( $title || $location_nosuffix );

    if ( defined $markednew ) {
        XIMS::Debug( 6, "markednew: $markednew" );
        if ( $markednew eq 'true' ) {
            $object->marked_new( 1 );
        }
        elsif ( $markednew eq 'false' ) {
            $object->marked_new( 0 );
        }
    }

    if ( defined $keywords and length $keywords > 0 and $keywords !~ /^\s+$/ ) {
        XIMS::Debug( 6, "keywords: $keywords" );
        $object->keywords( $keywords );
    }

    my $abstract = $self->param( 'abstract' );
    if ( defined $abstract and length $abstract and $abstract !~ /^\s+$/ ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $abstract = XIMS::decode($abstract);
        }
        if ( $object->abstract( $abstract ) ) {
            XIMS::Debug( 6, "abstract set, len: " . length($abstract) );
        }
        else {
            XIMS::Debug( 2, "could not form well" );
            $self->sendError( $ctxt, $XIMS::CGI::MSG[7] );
            return 0;
        }
    }

    if ( defined $image and length $image ) {
        XIMS::Debug( 6, "image: $image" );
        my $imageobj;
        if ( $image =~ /^\d+$/
             and $imageobj = XIMS::Object->new( id => $image )
             and $imageobj->object_type->name() eq 'Image' ) {
            $object->image_id( $imageobj->id() );
        }
        elsif ( $imageobj = XIMS::Object->new( path => $image )
             and $imageobj->object_type->name() eq 'Image' ) {
            $object->image_id( $imageobj->id() );
        }
        else {
            XIMS::Debug( 3, "could not set image_id" );
        }
    }

    my $stylesheet = $self->param( 'stylesheet' );
    if ( defined $stylesheet and length $stylesheet ) {
        XIMS::Debug( 6, "stylesheet: $stylesheet" );
        my $styleobj;
        if ( $stylesheet =~ /^\d+$/
             and $styleobj = XIMS::Object->new( id => $stylesheet )
             and ( $styleobj->object_type->name() eq 'XSLStylesheet'
                   or $styleobj->object_type->name() eq 'Folder' )
                 ) {
            $object->style_id( $styleobj->id() );
        }
        elsif ( $styleobj = XIMS::Object->new( path => $stylesheet )
             and ( $styleobj->object_type->name() eq 'XSLStylesheet'
                   or $styleobj->object_type->name() eq 'Folder' )
                 ) {
            $object->style_id( $styleobj->id() );
        }
        else {
            XIMS::Debug( 3, "could not set style_id" );
        }
    }

    my $schema = $self->param( 'schema' );
    if ( defined $schema and length $schema ) {
        XIMS::Debug( 6, "schema: $schema" );
        my $schemaobj;
        if ( $schema =~ /^\d+$/
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

    my $css = $self->param( 'css' );
    if ( defined $css and length $css ) {
        XIMS::Debug( 6, "css: $css" );
        my $cssobj;
        if ( $css =~ /^\d+$/
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
                XIMS::Debug( 3, "could not set css_id" );
        }
    }


    return 1;
}

sub default_grants {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my $ctxt           = shift;
    my $grantowneronly = shift;
    my $grantdefaultroles = shift;

    my $retval  = undef;

    # grant the object to the current user
    if ( $ctxt->object->grant_user_privileges(
                                         grantee  => $ctxt->session->user(),
                                         grantor  => $ctxt->session->user(),
                                         privmask => XIMS::Privileges::MODIFY|XIMS::Privileges::PUBLISH
                                       )
       ) {
        XIMS::Debug( 6, "granted user " . $ctxt->session->user->name . " default privs on " . $ctxt->object->id() );
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "failed to grant default rights!" );
        return 0;
    }

    # TODO: through the user-interface the user should be able to decide if all the roles he
    # is member of (and not only his default roles) should get read-access or not
    if ( defined $retval and $grantowneronly != 1) {
        # copy the grants of the parent
        my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $ctxt->data_provider->getObjectPriv( content_id => $ctxt->parent->id() );
        foreach my $priv ( @object_privs ) {
            $ctxt->object->grant_user_privileges(
                                        grantee   => $priv->grantee_id(),
                                        grantor   => $ctxt->session->user(),
                                        privmask  => $priv->privilege_mask(),
                                    )
        }

        if ( defined $grantdefaultroles and $grantdefaultroles == 1 ) {
            my @roles = $ctxt->session->user->roles_granted( default_role => 1 ); # get granted default roles
            foreach my $role ( @roles ) {
                $ctxt->object->grant_user_privileges(
                                                     grantee  => $role,
                                                     grantor => $ctxt->session->user(),
                                                     privmask => XIMS::Privileges::VIEW
                                                    );
                XIMS::Debug( 6, "granted role " . $role->name . " view privs on " . $ctxt->object->id()  );
            }
        }
    }

    return $retval;
}

sub event_undelete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::DELETE();

    my $object = $ctxt->object();

    # test for a non deleted object in the current container with the same location
    my $parent = XIMS::Object->new( document_id => $object->parent_id(), User => $ctxt->session->user() );
    my @children = $parent->children( location => $object->location() );
    my $gotactive;
    foreach my $child ( @children ) {
        $gotactive++ unless $child->marked_deleted();
    }

    if ( $gotactive ) {
        #
        # If there is already an active (non deleted) object with the same location
        # we'll reject for now. Later, we should implement a dialogue which asks for a new location
        # for the undeleted object.
        #
        $self->sendError( $ctxt, "An object with the location '" .
                                  $object->location() .
                                 "' already exists in container. Please rename or move that object before undeleting this one." );

        return 0;
    }

    if ( $object->undelete() ) {
        XIMS::Debug( 4, "object has been undeleted" );
    }
    else {
        XIMS::Debug( 2, "object could not be undeleted!" );
        $self->sendError( $ctxt, "Object could not be undeleted!" );
        return 0;
    }

    XIMS::Debug( 4, "redirecting" );
    $self->redirect( $self->redirect_path( $ctxt ) );
    return 0;
}

sub event_trashcan {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::DELETE();

    my $object = $ctxt->object();

    if ( $object->published() ) {
        XIMS::Debug( 3, "attempt to trash pub'd object" );
        $self->sendError( $ctxt, "Can't move a published object to the trashcan, please unpublish first" );
        return 0;
    }

    my $force_trash = 1 if $self->param( 'forcetrash' );
    my @chldinfo = $object->descendant_count();
    my $diffobject = XIMS::Object->new( location => '.diff_to_second_last', parent_id => $object->document_id() );

    if ( $force_trash == 1 ) {
        if ( $object->trashcan() ) {
            XIMS::Debug( 4, "object trashed" );
        }
        else {
            XIMS::Debug( 2, "object could not be trashed" );
            $self->sendError( $ctxt, "Moving to the trashcan failed." );
            return 0;
        }
    }
    elsif ( (defined $diffobject and $chldinfo[0] > 1) or (not defined $diffobject and $chldinfo[0] > 0) ) {
        # In case the object is a container and has remaining children besided an automatically created
        # .diff_to_second_last object, we are asking for confirmation of recursion
        XIMS::Debug( 4, "container has got children, ask for confirmation of recursion" );
        # pepl: should not DELETE_ALL be test for in case of deleting all the language version of an object?
        if ( $current_user_object_priv & XIMS::Privileges::DELETE_ALL() ) {
            $ctxt->session->warning_msg( "This Container has " . $chldinfo[0] . " child(ren) over " . $chldinfo[1] . " level(s) in the hierarchy ");
            $ctxt->properties->application->styleprefix( "common" );
            $ctxt->properties->application->style( "recursive_trashcan_confirm" );
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
            XIMS::Debug( 4, "object trashed");
        }
        else {
            XIMS::Debug( 2, "object could not be trashed" );
            $self->sendError( $ctxt, "Moving to the trashcan failed." );
            return 0;
        }
    }

    XIMS::Debug( 4, "redirecting to the parent");
    $self->redirect( $self->redirect_path( $ctxt, $object->parent->id ) );
    return 0;
}


sub event_delete {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::DELETE();

    my $object = $ctxt->object();
    my $parent_content_id = XIMS::Object->new( document_id => $object->parent_id() )->id(); # needed for redirection after deletion
    if ( $object->published() ) {
        XIMS::Debug( 3, "attempt to delete pub'd object" );
        $self->sendError( $ctxt, "Can't delete a published object, please unpublish first" );
        return 0;
    }

    my $force_delete = 1 if $self->param( 'forcedelete' );
    my @chldinfo = $object->descendant_count();
    my $diffobject = XIMS::Object->new( location => '.diff_to_second_last', parent_id => $object->document_id() );

    if ( $force_delete == 1 ) {
        if ( $object->delete() ) {
            XIMS::Debug( 4, "object deleted" );
        }
        else {
            XIMS::Debug( 2, "object could not be deleted" );
            $self->sendError( $ctxt, "Delete failed." );
            return 0;
        }
    }
    elsif ( (defined $diffobject and $chldinfo[0] > 1) or (not defined $diffobject and $chldinfo[0] > 0) ) {
        # In case the object is a container and has remaining children besided an automatically created
        # .diff_to_second_last object, we are asking for confirmation of recursion
        XIMS::Debug( 4, "container has got children, ask for confirmation of recursion" );
        # pepl: should not DELETE_ALL be test for in case of deleting all the language version of an object?
        if ( $current_user_object_priv & XIMS::Privileges::DELETE_ALL() ) {
            $ctxt->session->warning_msg( "This Container has " . $chldinfo[0] . " child(ren) over " . $chldinfo[1] . " level(s) in the hierarchy ");
            $ctxt->properties->application->styleprefix( "common" );
            $ctxt->properties->application->style( "recursive_delete_confirm" );
            return 0;
        }
        else {
            $self->sendError( $ctxt, "Privilege mismatch." );
            return 0;
        }
    }
    else {
        XIMS::Debug( 4, "object has no children?" );
        if ( $object->delete() ) {
            XIMS::Debug( 4, "object deleted");
        }
        else {
            XIMS::Debug( 2, "object could not be deleted" );
            $self->sendError( $ctxt, "Delete failed." );
            return 0;
        }
    }

    XIMS::Debug( 4, "redirecting to the parent");
    $self->redirect( $self->redirect_path( $ctxt, $parent_content_id ) );
    return 0;
}

sub event_contentbrowse {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $to        = $self->param( "to" );
    my $otfilter  = $self->param( "otfilter" );
    my $notfilter = $self->param( "notfilter" ); # negative otfilter :P
    my $objecttypes = [];

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "error" );

    $ctxt->properties->content->getchildren->level( 1 );

    $to = $ctxt->object->id() unless $to =~ /^\d+$/;
    $ctxt->properties->content->getchildren->objectid( $to );

    if ( defined $otfilter and length $otfilter > 0 ) {
        my @otherot = split '\s*,\s*', $otfilter; # in case we want to filter a comma separated list of object types
        push @{$objecttypes}, ('Folder', 'DepartmentRoot', @otherot);
    }
    elsif ( defined $notfilter and length $notfilter > 0 ) {
        my @otherot = split '\s*,\s*', $notfilter;
        my %fh = ();
        @fh{@otherot} = map { 1; } @otherot;
        # fetch all objecttypes and filter the listed types
        foreach my $ot ( $ctxt->data_provider->object_types() ) {
            next if exists $fh{$ot->name()};
            push @{$objecttypes}, $ot->name();
        }
    }

    $ctxt->properties->content->getchildren->objecttypes( $objecttypes );
    $ctxt->properties->application->style( "contentbrowse" );

    my $style;
    if ( $style = $self->param( "style" ) and length $style ) {
        $ctxt->properties->application->style( $ctxt->properties->application->style . "_" . $style );
    }

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_move_browse {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "error" );

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::MOVE();

    if ( not $ctxt->object->published() ) {
        my $to = $self->param( "to" );
        if ( not ( $to =~ /^\d+$/ ) ) {
            XIMS::Debug( 3, "Where to move?" );
            $ctxt->session->error_msg("Where to move?");
            return 0;
        }

        $ctxt->properties->content->getchildren->level( 1 );
        $ctxt->properties->content->getchildren->objecttypes( [qw(Folder DepartmentRoot)] );
        $ctxt->properties->content->getchildren->objectid( $to );
        $ctxt->properties->application->style( "move_browse" );
    }
    else {
        XIMS::Debug( 3, "attempt to move published object" );
        $ctxt->session->error_msg( "Moving published objects has not been implemented yet." );
        return 0;
    }

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_move {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "error" );

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::MOVE();

    if ( not $object->published() ) {
        my $to = $self->param( "to" );
        if ( not (length $to) ) {
            XIMS::Debug( 3, "Where to move?" );
            $ctxt->session->error_msg( "Where to move?" );
            return 0;
        }

        my $target;
        if ( not ($target = XIMS::Object->new( path => $to, User => $ctxt->session->user ) and $target->id()) ) {
            $ctxt->session->error_msg( "Invalid target path!" );
            return 0;
        }

        if ( $object->document_id() == $target->document_id() ) {
            XIMS::Debug( 2, "target and source are the same" );
            $ctxt->session->error_msg( "Target and source are the same. (Why would you want doing that?)" );
            return 0;
        }

        if ( $target->object_type->is_fs_container() ) {
            XIMS::Debug( 4, "we got a valid target" );
        }
        else {
            XIMS::Debug( 3, "Target is not a valid container" );
            $ctxt->session->error_msg( "Target is not a valid container" );
            return 0;
        }

        #my $old_parent = $object->getParentID();
        #my $old_pos    = $object->getPosition();

        if ( not $object->move( target => $target->document_id ) ) {
            $ctxt->session->error_msg( "move failed!" );
            return 0;
        }
        else {
            XIMS::Debug( 4, "move ok, redirecting to the parent");

            # correct department of the object and its children
            #$dp->reconciliateDepartment( -object => $object,
            #                             -parent => $target );

            # correct the positions in the source container
            #$dp->reconciliatePosition( -parentid => $old_parent,
            #                           -position  => $old_pos );


            $self->redirect( $self->redirect_path( $ctxt, $object->parent->id() ) );
            return 0;
        }
    }
    else {
        XIMS::Debug( 3, "attempt to move published object" );
        $ctxt->session->error_msg( "Moving published objects has not been implemented yet.");
        return 0;
    }

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_copy {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;
    my $object = $ctxt->object();

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "error" );

    my $parent = XIMS::Object->new( document_id => $object->parent_id, User => $ctxt->session->user() );
    my $parent_user_object_priv = $ctxt->session->user->object_privmask( $parent );
    return $self->event_access_denied( $ctxt )
           unless $parent_user_object_priv & XIMS::Privileges::CREATE();

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::COPY();

    my $recursivecopy = 1 if $self->param( 'recursivecopy' );
    my $confirmcopy = 1 if $self->param( 'confirmcopy' );
    my @chldinfo = $object->descendant_count();
    my $diffobject = XIMS::Object->new( location => '.diff_to_second_last', parent_id => $object->document_id() );

    if ( $confirmcopy == 1 or $chldinfo[0] == 0 or defined $diffobject and $chldinfo[0] == 1) {
        if ( not $object->clone( scope_subtree => $recursivecopy ) ) {
            $ctxt->session->error_msg( "copy failed!" );
            return 0;
        }
        else {
            XIMS::Debug( 4, "copy ok, redirecting to the parent");
            # be sure to show the user the new copy at the first page
            $self->param( 'sb', 'date' );
            $self->param( 'order', 'desc' );
            $self->redirect( $self->redirect_path( $ctxt, $parent->id() ) );
            return 0;
        }
    }
    else {
        $ctxt->session->warning_msg( "This Container has " . $chldinfo[0] . " child(ren) over " . $chldinfo[1] . " level(s) in the hierarchy ");
        $ctxt->properties->application->styleprefix( "common" );
        $ctxt->properties->application->style( "recursive_copy_confirm" );
        return 0;
    }

}

sub event_publish_prompt {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    my @objects;
    # check for body references in (X)HTML documents
    my $dfmime_type = $ctxt->object->data_format->mime_type();
    if ( $dfmime_type eq 'text/html' ) {
        XIMS::Debug( 4, "checking body refs" );
        @objects = $self->body_ref_objects($ctxt);
    }
    elsif ( $dfmime_type eq 'application/x-container' ) {
        my @non_container_ot = $ctxt->data_provider->object_types( is_fs_container => '0' );
        my @ids = map { $_->id() } @non_container_ot;
        @objects = $ctxt->object->children_granted( object_type_id => \@ids, marked_deleted => undef ); # get non-container objects only
        for ( @objects ) {
            $_->{location_path} = $_->location_path();
        }
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
            foreach my $object ( @objects ) {
                next unless ( defined $object and $object->id() ); # skip unresolved references
                my $objectpriv = XIMS::ObjectPriv->new( content_id => $object->id(), grantee_id => \@role_ids );
                push (@locations_ungranted, $object->location) unless $objectpriv && ($objectpriv->privilege_mask() & XIMS::Privileges::PUBLISH());
            }

            if ( scalar(@locations_ungranted) > 0 ) {
                $ctxt->session->message( join ",", @locations_ungranted );
            }
         }
    }

    $ctxt->properties->application->styleprefix('common_publish');
    $ctxt->properties->application->style('prompt');

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_publish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    require XIMS::Exporter;
    my $exporter = XIMS::Exporter->new( Provider => $ctxt->data_provider,
                                        Basedir  => XIMS::PUBROOT(),
                                        User     => $ctxt->session->user
                                      );

    my $published = 0;
    if ( defined $self->param( "autopublish" )
         and $self->param( "autopublish" ) == 1 ) {
        XIMS::Debug( 4, "going to publish references" );
        my @objids = $self->param( "objids" );
        $published = $self->autopublish( $ctxt, $exporter, 'publish', \@objids);
    }

    my $no_dependencies_update = 1;
    if ( defined $self->param( "update_dependencies" )
        and $self->param( "update_dependencies" ) == 1 ) {
        $no_dependencies_update = undef;
    }

    if ( $exporter->publish( Object => $ctxt->object, no_dependencies_update => $no_dependencies_update ) ) {
        XIMS::Debug( 6, "object published!" );
        if ( $published > 0 ) {
            $ctxt->session->message("Object '" .  $ctxt->object->title() . "' together with $published related objects published.");
        }
        else {
            $ctxt->session->message("Object '" .  $ctxt->object->title() . "' published.");
        }
        $ctxt->properties->application->styleprefix('common_publish');
        $ctxt->properties->application->style('update');
    }
    else {
        XIMS::Debug( 3, "object could not be published!" );
        $ctxt->session->error_msg( "Object '" . $ctxt->object->title() . "' not published");
        $ctxt->properties->application->styleprefix('common');
        $ctxt->properties->application->style('error');
    }

    return 0;
}

sub event_unpublish {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $ctxt->object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::PUBLISH();

    if ( $ctxt->object->data_format->mime_type() eq 'application/x-container' ) {
        my @container_ot = $ctxt->data_provider->object_types( is_fs_container => '1' );
        my @ids = map { $_->id() } @container_ot;
        my @objects = $ctxt->object->children( object_type_id => \@ids, published => '1' ); # get published container objects
        if ( scalar @objects ) {
            $ctxt->session->error_msg( "Object '" . $ctxt->object->title() . "' contains published container objects. Please unpublish those first.");
            $ctxt->properties->application->styleprefix('common');
            $ctxt->properties->application->style('error');
            return 0;
        }
    }

    require XIMS::Exporter;
    my $exporter = XIMS::Exporter->new( Provider => $ctxt->data_provider,
                                        Basedir  => XIMS::PUBROOT(),
                                        User     => $ctxt->session->user
                                      );

    my $no_dependencies_update = 1;
    if ( defined $self->param( "update_dependencies" )
        and $self->param( "update_dependencies" ) == 1 ) {
        $no_dependencies_update = undef;
    }

    if ( $exporter->unpublish( Object => $ctxt->object, no_dependencies_update => $no_dependencies_update ) ) {
        XIMS::Debug( 6, "object unpublished!" );
        $ctxt->session->message("Object '" .  $ctxt->object->title() . "' unpublished.");
        $ctxt->properties->application->styleprefix('common_publish');
        $ctxt->properties->application->style('update');
    }
    else {
        XIMS::Debug( 3, "object could not be unpublished!" );
        $ctxt->session->error_msg( "Object '" . $ctxt->object->title() . "' not unpublished");
        $ctxt->properties->application->styleprefix('common');
        $ctxt->properties->application->style('error');
    }

    return 0;
}

sub event_test_wellformedness {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $body = $self->param('body');

    my $test = $ctxt->object->balanced_string( $body, verbose_msg => 1 );
    if ( $test->isa('XML::LibXML::DocumentFragment') ) {
        $ctxt->session->message( "Parse ok" );
    }
    else {
        $ctxt->session->error_msg( "Parse failure" );
        $ctxt->session->verbose_msg( $test || "Cowardly refusing to fill an errorstring" );
    }

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "message_window_plain" );
    return 0;
}

sub event_obj_acllist {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );
    my $dp = $ctxt->data_provider();
    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'error' );

    if ( $user and $objprivs and $object ) {
        #
        # The acllist event will work only if there is a user,
        # an object, and a minimal privilege mask found.
        #
        # Before one can really see the privileges for an object, he has to have
        # a grant privilege (XIMS::Privilege::GRANT or XIMS::Privilege::GRANT_ALL) for it.
        # (Optionally, a system privilege may do the same trick.)
        #
        if ( $objprivs & XIMS::Privileges::GRANT()
             || $objprivs & XIMS::Privileges::GRANT_ALL() ) {
              XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

            # get the existing grants on the object
            my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $dp->getObjectPriv( content_id => $object->id() );

            if ( my $user_id = $self->param( "userid" ) ) {
                if ( my $context_user = XIMS::User->new( id => $user_id ) ) {
                    # second parameter to object_privileges forces check for explicit grants to user only
                    my %oprivs = $context_user->object_privileges( $object, 1 );
                    # xml serialization does not like undefined values
                    if ( grep { defined $_ } values %oprivs ) {
                        $context_user->{object_privileges} = {%oprivs};
                    }
                    $ctxt->user( $context_user );
                    $ctxt->properties->application->style( 'obj_user' );
                }
                else {
                    XIMS::Debug( 3, "No such user!" );
                    $self->sendError( $ctxt, "Sorry, there is no such user!" );
                }
            }
            elsif ( my $userquery = $self->param('userquery') ) {
                my %args = ();
                if ( $self->param('usertype') eq 'user' ) {
                    $args{object_type} = 0;
                }
                else {
                    $args{object_type} = 1;
                }
                # this bites, but how do we do 'LIKE' in the current model? :-(
                my @big_user_data_list = $dp->getUser( %args, properties => ['id', 'name'] );
                my @granted_user_ids = map { $_->grantee_id() } @object_privs;
                my @user_data_list = ();
                foreach my $record ( @big_user_data_list ) {
                    next if grep { $_ == $record->{'user.id'} } @granted_user_ids;
                    next unless $record->{'user.name'} =~ /$userquery/ig;
                    push @user_data_list, $record;
                }
                my @user_list = map{ XIMS::User->new( id => $_->{'user.id'} ) } @user_data_list;
                $ctxt->userlist( \@user_list );
                $ctxt->properties->application->style( 'obj_userlist' );
                XIMS::Debug( 6, "Search for user/role returned  @user_list" );
            }
            else {
                # this will fetch only the users that have one
                # or more grants on the current obj.
                my @granted_user_ids = map { $_->grantee_id() } @object_privs;
                my @granted_users = map{ XIMS::User->new( id => $_ ) } @granted_user_ids;
                #warn "acluser" . Dumper( \@granted_users );
                $ctxt->userlist( \@granted_users );
                $ctxt->properties->application->style( 'obj_userlist' );
            }

        }
        else {
            XIMS::Debug( 2, "user " . $user->name() . " denied to list privileges on object" );
            $self->sendError( $ctxt,
                               "user " .
                               $user->name() .
                               " denied to list privileges on object" );
        }
    }
    else {
        XIMS::Debug( 3, "anonymous granting rejected" );
    }

    XIMS::Debug( 5, "done" );

    return 0;
}

sub event_obj_aclgrant {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'error' );

    if ( $user and $objprivs and $object ) {
        #
        # the aclist event will only work if there can be an user,
        # object found, plus a minimal privilege mask is found.
        #
        # before one can really see the privileges on an object, one
        # needs one or the other grant privilege
        # (XIMS::Privilege::GRANT or XIMS::Privilege::GRANT_ALL) for his
        # own. Optional a system privilege may does the same trick.
        #
        if ( $objprivs & XIMS::Privileges::GRANT()
             || $objprivs & XIMS::Privileges::GRANT_ALL() ) {
            XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

            # get the other userid
            my $uid = $self->param('userid');

            # build the privilege mask
            my $bitmask = 0;

            foreach my $priv ( XIMS::Privileges::list() ) {
                my $lcname = 'acl_' . lc( $priv );
                if ( $self->param($lcname) ) {
                    {
                        no strict 'refs';
                        $bitmask += &{"XIMS::Privileges::$priv"}();
                    }
                }
            }

            # store the set to the database
            my $boolean = $object->grant_user_privileges ( grantee         => $uid,
                                                           privilege_mask  => $bitmask,
                                                           grantor         => $user->id() );

            if ( $boolean ) {
                XIMS::Debug( 6, "ACL privs changed for (" . $user->name() . ")" );
                $ctxt->properties->application->style( 'obj_user_update' );
                my $granted = XIMS::User->new( id => $uid );
                $ctxt->session->message( "Privileges changed successfully for user/role '" . $granted->name() . "'" );
            }
            else {
                XIMS::Debug( 2, "ACL grant failure on " . $object->document_id . " for " . $user->name() );
            }
        }
        else {
            XIMS::Debug( 2, "ACL check failed (" . $user->name . ")" );
        }
    }
    else {
        XIMS::Debug( 3, "anonymous granting rejected" );
    }
    XIMS::Debug( 5, "done" );

    return 0;
}


sub event_obj_aclrevoke {
    my ( $self, $ctxt ) = @_;
    XIMS::Debug( 5, "called" );

    my $user = $ctxt->session->user();
    my $object = $ctxt->object();
    my $objprivs = $user->object_privmask( $object );

    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'error' );

    if ( $user and $objprivs and $object ) {
        #
        # the aclist event will only work if there can be an user,
        # object found, plus a minimal privilege mask is found.
        #
        # before one can really see the privileges on an object, one
        # needs one or the other grant privilege
        # (XIMS::Privilege::GRANT or XIMS::Privilege::GRANT_ALL) for his
        # own. Optional a system privilege may does the same trick.
        #
        if ( $objprivs & XIMS::Privileges::GRANT()
             || $objprivs & XIMS::Privileges::GRANT_ALL() ) {
            XIMS::Debug( 6, "ACL check passed (" . $user->name() . ")" );

            # get the other userid
            my $uid = $self->param('userid');

            # revoke the privs
            my $privs_object = XIMS::ObjectPriv->new( grantee_id => $uid, content_id => $object->id() );

            if ( $privs_object and $privs_object->delete() ) {
                XIMS::Debug( 6, "ACL privs changed for (" . $user->name() . ")" );
                $ctxt->properties->application->style( 'obj_user_update' );
                my $revoked = XIMS::User->new( id => $uid );
                $ctxt->session->message( "Privileges successfully revoked for user/role '" .
                                          $revoked->name() . "'.");
            }
            else {
                XIMS::Debug( 2, "ACL grant failure on " . $object->document_id . " for " . $user->name() );
            }

        }
        else {
            XIMS::Debug( 2, "ACL check failed (" . $user->name() . ")" );
        }
    }
    else {
        XIMS::Debug( 3, "anonymous granting rejected" );
    }

    XIMS::Debug( 5, "done" );
    return 0;
}

sub event_posview {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object();
    my $parent = XIMS::Object->new( document_id => $object->parent_id, language_id => $object->language_id );

    $ctxt->properties->content->siblingscount( $parent->child_count() );
    $ctxt->properties->application->styleprefix( "container" );
    $ctxt->properties->application->style( "posview" );

    return 0;
}

sub event_reposition {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $object = $ctxt->object;

    my $current_user_object_priv = $ctxt->session->user->object_privmask( $object );
    return $self->event_access_denied( $ctxt )
           unless $current_user_object_priv & XIMS::Privileges::WRITE();

    my $new_position = $self->param( "new_position" );

    if ( $new_position > 0 and $object->position != $new_position ) {
        if ( $object->reposition( position => $new_position ) ) {
            XIMS::Debug( 4, "object repositioned" );
        }
        else {
            XIMS::Debug( 2, "repositioning failed" );
        }
    }

    # be sure the users get's to see the newly positioned object
    $self->param( 'sb', 'position' );
    $self->param( 'order', 'asc' );
    my $c = $new_position / XIMS::SEARCHRESULTROWLIMIT();
    my $page = int($c) + (scalar split(/\./,$c) > 1 ? 1 : 0); # poor man's ceiling()
    $self->param( 'page', $page );

    XIMS::Debug( 4, "redirecting to parent" );
    $self->redirect( $self->redirect_path( $ctxt, $object->parent->id() ) );
    return 0;
}

##
# SYNOPSIS
#    $self->handle_bang_commands( $ctxt, $search );
#
# PARAMETER
#    $ctxt            : Application context
#    $search          : Searchstring
#
# RETURNS
#    undef on error, 1 on succes
#
# DESCRIPTION
#    this one exists to avoid spaghetti- and nested-if-uglyness in event_search;
#    commands that start with a bang get processed here.
#
sub handle_bang_commands {
    XIMS::Debug (5, "called");
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
        $self->sendError( $ctxt, "$search is an invalid command!" );
        return undef;
    }

    if ( $object and $object->locked ) {
        my $objprivs = $user->object_privmask( $object );
        if ( defined $objprivs and ( $objprivs & XIMS::Privileges::WRITE()) ) {
            if ( $object->unlock() ) {
                $retval = 1;
            }
            else {
                $self->sendError( $ctxt, "unlock failed" );
            }
        }
        else {
            XIMS::Debug( 4, "insufficient privileges, user cannot remove lock" );
            $self->sendError( $ctxt, "Insufficient privileges, you cannot remove the lock" );
        }

    }
    else {
        XIMS::Debug( 4, "no locked object found" );
        $self->sendError( $ctxt, "Could not find a locked object with that search string" );
    }

    return $retval;
}

##
# SYNOPSIS
#     $self->body_ref_objects( $ctxt );
#
# DESCRIPTION
#
# Checks links stored within an object's body. If local
# references are found the function will test if the object is stored
# in XIMS. The function will return a hash that has the local URI as
# the key and the object as value.
#
sub body_ref_objects {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @objects;
    my $object = $ctxt->object();

    # load the objects body
    my $body = $object->body();
    return undef unless defined $body;

    my $parser = XML::LibXML->new();
    my $chunk;
    eval {
        my $data = XIMS::encode( $body );
        $chunk = $parser->parse_xml_chunk( $data );
    };
    if ( $@ ) {
        XIMS::Debug( 4, "cannot parse the body. reason: $@" );
        return ();
    }

    # pseudo code for XML::LibXML 1.52 and libxml2 < 2.4.25
    my $doc = XML::LibXML->createDocument();
    $doc->setDocumentElement( $doc->createElement( "foo" ) );
    $doc->documentElement->appendChild( $chunk );
    $chunk = $doc->documentElement;
    # end pseudo code

    # now get all the items that are referred
    my @data = $chunk->findnodes( './/@href | .//@src' );

    my @paths = map {
        $_->nodeValue();
    } @data;

    # resolve path for relative references
    my $parent = XIMS::Object->new( document_id => $object->parent_id(), language_id => $object->language_id);
    my $parent_path = $parent->location_path();
    my @ancestors = @{$object->ancestors()};

    # lets see if the objects exist in our system.
    my %paths_seen;
    my %ximspaths_seen;
    foreach my $p ( @paths ) {
        $p =~ s/\?.*$//; # strip querystring
        next unless length $p;
        next if $paths_seen{$p};
        if (
            $p =~ m|^https?://|
            or $p =~ m|^#|
            or $p =~ m|\{[^\}]*\}|
           ) {
            XIMS::Debug( 4, "real URI or anchor" );
            next;
        }
        my $exp = $p;
        if ( $exp =~ m|^\.\./| ) {
            my $anclevel = split('\.\./', $exp) - 1;
            my $i = scalar @ancestors - 1 - $anclevel; # ancestors include root
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
        my $object = XIMS::Object->new( path => $exp, language_id => $object->language_id() );
        $paths_seen{$p}++;
        next unless $object;
        $object->{location_path} = $p; # we want to preserve the original link for the users
        push @objects, $object;
    }

    return @objects;
}


sub autopublish {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my $exporter = shift;
    my $method = shift;
    my $objids = shift;

    my $published;
    foreach my $id ( @{$objids} ) {
        next unless defined $id;
        my $object = XIMS::Object->new( id => $id, User => $ctxt->session->user() );
        if ( $object ) {
            if ( $ctxt->session->user->object_privmask( $object ) & XIMS::Privileges::PUBLISH() ) {
                if ( $exporter->$method( Object => $object ) ) {
                    XIMS::Debug( 4, $method."ed object with id $id" );
                    $published++;
                }
                else {
                    XIMS::Debug( 3, "could not $method object with id $id" );
                    next;
                }
            }
            else {
                XIMS::Debug( 3, "no privileges to $method object with id $id" );
                next;
            }
        }
        else {
            XIMS::Debug( 3, "could not find an object with id $id" );
            next;
        }
    }

    return $published;
}

sub event_search {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # if we are coming from a different interface (e.g. defaultboomark or user(s)) we have to check for that here
    return $self->event_access_denied( $ctxt ) unless $ctxt->object();

    my $user = $ctxt->session->user();
    my $search = XIMS::decode($self->param('s'));
    my $offset = $self->param('page');
    $offset = $offset - 1 if $offset;
    my $rowlimit = XIMS::SEARCHRESULTROWLIMIT();
    $offset = $offset * $rowlimit;

    $ctxt->properties->application->style( 'error' );

    XIMS::Debug( 6, "param $search");

    if ( $search =~ /^\!/ && ( length($search) <= 55 ) ) {
        # searchstring starts with a bang...
        return 0 if not defined $self->handle_bang_commands( $ctxt, $search );

        # redir to self...
        $self->redirect( $self->redirect_path( $ctxt, $ctxt->object->id() ) );
    }

    # length within 2..30 chars
    if (( length($search) >= 2 ) && ( length($search) <= 30 )) {
        my $qbdriver;
        if ( XIMS::DBMS() eq 'DBI' ) {
            $qbdriver = XIMS::DBDSN();
            $qbdriver = ( split(':',$qbdriver))[1];
        }
        else {
            XIMS::Debug( 2, "search not implemented for non DBI DPs" );
            $ctxt->session->error_msg( "Search mechanism has not yet been implemented for non DBI based datastores!" );
            return 0;
        }

        $qbdriver = 'XIMS::QueryBuilder::' . $qbdriver . XIMS::QBDRIVER();

        eval "require $qbdriver"; #

        if ( $@ ) {
            XIMS::Debug( 2, "querybuilderdriver $qbdriver not found" );
            $ctxt->session->error_msg( "QueryBuilder-Driver could not be found!" );
            return 0;
        }

        my $qb = $qbdriver->new( { search => $search, allowed => q{\!a-zA-Z0-9צהüßײִÜß%:\-<>\/\(\)\\.,\*&\?\+\^'\"\$\;\[\]~} } );

        # refactor! build() should not be needed and only $qb should be passed

        #'# just for emacs' font-lock...
        my $qbr = $qb->build( [qw(title abstract keywords body)] );
        if ( defined $qbr->{criteria} and length $qbr->{criteria} ) {
            my %param = (
                        criteria => $qbr->{criteria} . " AND title <> '.diff_to_second_last'",
                        limit => $rowlimit,
                        offset => $offset,
                        order => $qbr->{order},
                        );
            $param{start_here} = $ctxt->object() if $self->param('start_here');

            my @objects = $ctxt->object->find_objects_granted( %param );

            if ( not @objects ) {
                 $ctxt->session->warning_msg( "Query returned no objects!" );
            }
            else {
                %param = ( criteria => $qbr->{criteria} . " AND title <> '.diff_to_second_last'" );
                $param{start_here} = $ctxt->object() if $self->param('start_here');
                my $count = $ctxt->object->find_objects_granted_count( %param );
                my $message = "Query returned $count objects.";
                if ( $count ) {
                    $message .= " Displaying objects " . ($offset+1);
                    $message .= " to ";
                    if ( ($offset+$rowlimit) > $count ) {
                        $message .= $count;
                    }
                    else {
                        $message .= $offset+$rowlimit;
                    }
                }
                $ctxt->session->message( $message );
                $ctxt->session->searchresultcount( $count );
            }

            # superfluos db hits!
            # every look up takes 0.008s to 0.009s at c102-bruce after init
            # this has to be changed!!!
            map { $_->{content_length} = $_->content_length() } @objects;

            $ctxt->objectlist( \@objects );
            $ctxt->properties->content->getformatsandtypes( 1 ); # to resolve the result
            $ctxt->properties->application->styleprefix( 'common_search' );
            $ctxt->properties->application->style( 'result' );
        }
        else {
            XIMS::Debug( 3, "please specify a valid query" );
            $ctxt->session->error_msg( "Please specify a valid query!" );
        }

    }
    else {
        XIMS::Debug( 3, "catched improper query length" );
        $ctxt->session->error_msg( "Please keep your queries between 2 and 30 characters!" );
    }
    return 0;
}

sub event_sitemap {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # $ctxt->properties->application->style() = "error";

    my $object = $ctxt->object();
    my $maxlevel = 3; # create XIMS::SITEMAPMAXLEVEL for that

    my @descendants = $object->descendants_granted( maxlevel => $maxlevel );

    $ctxt->objectlist( \@descendants );

    $ctxt->properties->content->getformatsandtypes( 1 ); # to resolve the result
    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'sitemap' );

    return 0;
}

1;

package XIMS::CGI::ByeBye;

##
#
# SYNOPSIS
#    $self->event_trashcan( $ctxt );
#
# PARAMETER
#    $ctxt: application context
#
# RETURNS
# 0 ;)
#
# DESCRIPTION
#    none
#
#
sub event_trashcan_content {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $maxresults = 50; # hardcoded atm
    # sth like findObjects not yet available again
    $ctxt->objectlist( $ctxt->{-PROVIDER}->findObjects( -user => $ctxt->session->user,
                                                        -conditionstr => "marked_deleted = 1",
                                                        -rowlimit     => $maxresults,
                                                       )
                     );

    $ctxt->session->error_msg = "Use the options to undelete or purge objects.";
    $ctxt->properties->application->styleprefix( 'common' );
    $ctxt->properties->application->style( 'trashcan' );

    XIMS::Debug( 5, "done" );
    return 0;
}

1;
