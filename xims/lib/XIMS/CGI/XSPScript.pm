# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::XSPScript;

use strict;
use vars qw( $VERSION @ISA );

use XIMS::CGI::XML;
use Apache;
use AxKit;
use Apache::AxKit::ConfigReader;
use Apache::AxKit::Language::XSP;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( XIMS::CGI::XML );

sub registerEvents {
    return
    qw(
      default
      create
      edit
      store
      del
      del_prompt
      obj_acllist
      obj_aclgrant
      obj_aclrevoke
      publish
      publish_prompt
      unpublish
      cancel
      test_wellformedness
      process_xsp
      );
}

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    if ( $ctxt->object->attribute_by_key( 'processxsp' ) == 1
         and not defined $self->param('process_xsp')
         and not defined $self->param('do_not_process_xsp') ) {

        my $redirect_path = $self->redirect_path( $ctxt, $ctxt->object->id() );
        if ( $redirect_path =~ /\?/ ) {
            $redirect_path .= ';';
        }
        else {
            $redirect_path .= '?';
        }

        $self->redirect( $redirect_path . "process_xsp=1" );
        return 1;
    }

    return $self->SUPER::event_default( $ctxt );
}

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $self->expand_attributes( $ctxt );

    return $self->SUPER::event_edit( $ctxt );
}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $processxsp  = $self->param( 'processxsp' );
    if ( defined $processxsp ) {
        XIMS::Debug( 6, "processxsp: $processxsp" );
        if ( $processxsp eq 'true' ) {
            $ctxt->object->attribute( processxsp => '1' );
        }
        elsif ( $processxsp eq 'false' ) {
            $ctxt->object->attribute( processxsp => '0' );
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

sub event_process_xsp {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    my $object = $ctxt->object();
    my $r = Apache->request;

    # having to encode here sucks
    my $body =  XIMS::DBENCODING() ? XML::LibXML::encodeToUTF8( XIMS::DBENCODING(), $object->body() ) : $object->body();

    $r->pnotes( 'xml_string', $body );

    my $dom_tree;

    # reusing AxKit's Configreader
    $AxKit::Cfg = Apache::AxKit::ConfigReader->new($r);

    # using dummy-provider-class needed for key()-method
    my $xml = xspscript::dummy->new($object->location());

    # there's the magic
    Apache::AxKit::Language::XSP::handler(undef, $r, $xml);

    # The XSP handler store its result in pnotes
    my $dom_tree = $r->pnotes('dom_tree');

    $dom_tree->setEncoding(XIMS::DBENCODING()) if XIMS::DBENCODING();

    my $newbody = $dom_tree->toString();

    # :/
    $newbody =~ s/^<\?xml.*//;
    $object->body( $newbody );

    return 0;
}

package xspscript::dummy;

sub new {
    my $class = shift;
    my $key   = shift;
    my $self = bless { key => $key }, $class;

    return $self;
}

sub key { $_[0]->{key} }
sub mtime { time }
sub has_changed { 1 }

1;
