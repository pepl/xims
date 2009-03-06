# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::Document;

use strict;
use vars qw( $VERSION @ISA @MSG @params );

use XIMS::CGI;
use Text::Iconv;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( XIMS::CGI );

# the names of pushbuttons in forms or symbolic internal handler
# each application should register the events required, even if they are
# defined in XIMS::CGI. This is for having a chance to
# deny certain events for the script.
#
# only dbhpanic and access_denied are set by XIMS::CGI itself.
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          default
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
          test_wellformedness
          pub_preview
          )
        );
}

# error messages
@MSG = ( "Document body could not be converted to a well balanced string. Please consult the User's Reference for information on well-balanced document bodies." );

# parameters recognized by the script
@params = qw( id name title depid symid delforce del plain trytobalance);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $ctxt->properties->content->escapebody( 1 );

    # event edit in SUPER implements operation control
    $self->SUPER::event_edit( $ctxt );
    return 0 if $ctxt->properties->application->style() eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
    $ctxt->properties->application->style( "edit" . $ed );

    return 0;
}

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    # event edit in SUPER implements operation control
    $self->SUPER::event_create( $ctxt );
    return 0 if $ctxt->properties->application->style eq 'error';

    # check if a WYSIWYG Editor is to be used based on cookie or config
    my $ed = $self->_set_wysiwyg_editor( $ctxt );
    $ctxt->properties->application->style( "create" . $ed );

    return 0;
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 unless $self->init_store_object( $ctxt )
                    and defined $ctxt->object();

    my $trytobalance  = $self->param( 'trytobalance' );

    my $body = $self->param( 'body' );
    if ( defined $body and length $body ) {
        if ( XIMS::DBENCODING() and $self->request_method eq 'POST' ) {
            $body = Text::Iconv->new("UTF-8", XIMS::DBENCODING())->convert($body);
        }

        my $object = $ctxt->object();

        # The HTMLArea WYSIWG-editor in combination with MSIE translates relative paths in 'href' and 'src' attributes
        # to their '/goxims/content'-absolute path counterparts. Since we do not want '/goxims/content' references. which will
        # very likely breaks after the content has been published, we have to mangle with the 'href' and 'src' attributes.
        my $absolute_path = defined $object->id() ? $object->location_path() : ($ctxt->parent->location_path() . '/' . $object->location());
        $body = $self->_absrel_urlmangle( $ctxt, $body, '/' . XIMS::GOXIMS() . XIMS::CONTENTINTERFACE(), $absolute_path );

        if ( $trytobalance eq 'true' and $object->body( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        elsif ( $object->body( $body, dontbalance => 1 ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "could not convert to a well balanced string" );
            $self->sendError( $ctxt, $MSG[0] );
            return 0;
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_exit( $ctxt );
}

#
# the following events extend the edit mode. in browse mode this
# information should be displayed by default.
#
# may be inserted into event_default ...

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    # pepl: why do we need two ways to load links and annotations? if
    # annotations would have the privs/grants of the owner document
    # copied "by definition", this would not be neccessary

    # pepl/ phish: this is strictly related to the general privilege
    # system we have to discuss more intense.

    # the following still has to be implemented with the new system

    $ctxt->properties->content->getchildren->objecttypes( [ qw( URLLink SymbolicLink ) ] );

    # temporarily deactivated until privilege inheritation of annotations is dicussed and clear
    #$self->resolve_annotations( $ctxt );

    return 0;
}

sub event_pub_preview {
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    # Emulate request.uri CGI param, set by Apache::AxKit::Plugin::AddXSLParams::Request
    # ($request.uri is used by default document_publishing_preview.xsl)
    $self->param( 'request.uri', $ctxt->object->location_path_relative() );

    $ctxt->properties->application->style("pub_preview");

    # not mod_perl safe...
    #*XIMS::CGI::Document::getDOM = *XIMS::CGI::Document::getPubPreviewDOM;
    #*XIMS::CGI::Document::selectStylesheet = *XIMS::CGI::Document::selectPubPreviewStylesheet;
    # ...therefore we are overriding getDom() and selectStylesheet() below...
    return 0;
}


# END RUNTIME EVENTS
# #############################################################################

# #############################################################################
# Local Helper functions

sub getPubPreviewDOM {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    require XIMS::Exporter;
    my $handler = XIMS::Exporter::Document->new(
                                       Provider   => $ctxt->data_provider,
                                       Basedir    => XIMS::PUBROOT(),
                                       Stylesheet => XIMS::XIMSROOT().'/stylesheets/exporter/export_document.xsl',
                                       User       => $ctxt->session->user,
                                       Object     => $ctxt->object,
                                       );
    my $raw_dom = $handler->generate_dom();
    my $transd_dom = $handler->transform_dom( $raw_dom );
    return undef unless defined $transd_dom;
    return $transd_dom;
}

sub selectPubPreviewStylesheet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $stylepath = $self->getStylesheetDir() . '/public/';
    my $filename = 'document_publishing_preview.xsl';
    my $style;

    my $stylesheet = $ctxt->object->stylesheet();
    if ( defined $stylesheet and $stylesheet->published() ) {
        if ( $stylesheet->object_type->name() eq 'XSLStylesheet' ) {
            XIMS::Debug( 4, "using assigned pub-preview-stylesheet" );
            $style = XIMS::PUBROOT() . $stylesheet->location_path();
        }
        else {
            XIMS::Debug( 4, "using pub-preview-stylesheet from assigned directory" );
            $stylepath = XIMS::PUBROOT() . $stylesheet->location_path() . '/' . $ctxt->session->uilanguage . '/';
        }
    }
    else {
        XIMS::Debug( 4, "using default pub-preview stylesheet" );
    }

    $style ||= $stylepath . $filename;
    return $style;
}

sub selectStylesheet {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    if ( $ctxt->properties->application->style eq 'pub_preview' ) {
        return $self->selectPubPreviewStylesheet( $ctxt );
    }
    else {
        return $self->SUPER::selectStylesheet( $ctxt );
    }
}

sub getDOM {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    if ( $ctxt->properties->application->style eq 'pub_preview' ) {
        return $self->getPubPreviewDOM( $ctxt );
    }
    else {
        return $self->SUPER::getDOM( $ctxt );
    }
}

sub resolve_annotations {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    $ctxt->sax_filter( [] ) unless defined $ctxt->sax_filter();
    require XIMS::SAX::Filter::AnnotationCollector;
    push ( @{$ctxt->sax_filter()},
           XIMS::SAX::Filter::AnnotationCollector->new( Object => $ctxt->object() )
         );
}

sub _set_wysiwyg_editor {
    my ( $self, $ctxt ) = @_;

    my $cookiename = 'xims_wysiwygeditor';
    my $editor = $self->cookie($cookiename);
    my $plain = $self->param( 'plain' );
    if ( $plain or defined $editor and $editor eq 'plain' ) {
        $editor = undef;
    }
    elsif ( not(length $editor) and length XIMS::WYSIWYGEDITOR() ) {
        $editor = lc( XIMS::WYSIWYGEDITOR() );
        if ( $self->user_agent('Gecko') or not $self->user_agent('Windows') ) {
             $editor = 'htmlarea';
        }
        my $cookie = $self->cookie( -name    => $cookiename,
                                    -value   => $editor,
                                    -expires => "+2160h"); # 90 days
        $ctxt->properties->application->cookie( $cookie );
    }
    my $ed = '';
    $ed = "_" . $editor if defined $editor;
    return $ed;
}

sub _absrel_urlmangle {
    my $self = shift;
    my $ctxt = shift;
    my $body = shift;
    my $goximscontent = shift;
    my $absolute_path = shift;



    my $doclevels = split('/', $absolute_path) - 1;
    my $docrepstring = '../'x($doclevels-1);
    while ( $body =~ /(src|href)=("|')$goximscontent([^("|')]+)/g ) {
        my $dir = $3;
        $dir =~ s#[^/]+$##;
    warn "gotabs, dir: $absolute_path, $dir";
        if ( $absolute_path =~ $dir ) {
            my $levels = split('/', $dir) - 1;
            my $repstring = '../'x($doclevels-$levels-1);
            $body =~ s/(src|href)=("|')$goximscontent$dir/$1=$2$repstring/;
        }
        else {
            $body =~ s#(src|href)=("|')$goximscontent/#$1=$2$docrepstring#;
        }
    }

    return $body;
}

1;