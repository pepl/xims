# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package xspscript;

use strict;
use vars qw( $VERSION @ISA );

use xml;
use Apache;
use AxKit;
use Apache::AxKit::ConfigReader;
use Apache::AxKit::Language::XSP;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( xml );

sub event_default {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    return 0 if $self->SUPER::event_default( $ctxt );

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    my $object = $ctxt->object();
    my $r = Apache->request;

    # two things: (1) having to encode here sucks
    #             (2) fetchlob here sucks
    my $body =  ( XIMS::DBENCODING() ? XML::LibXML::encodeToUTF8( XIMS::DBENCODING(), $object->body )
                : $object->body;

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

1;
