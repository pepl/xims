# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package xspscript;

use strict;
use vars qw( @HANDLER $VERSION @MSG @params );

use XIMS::CGI;

use Apache;
use AxKit;
use Apache::AxKit::ConfigReader;
use Apache::AxKit::Language::XSP;

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@xspscript::ISA = qw( XIMS::CGI );

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
          )
        );
}

# error messages
@MSG = ( "No object id found!",
         "Object id is not valid",
         "No location set!",
         "Database synchronization failed.",
         "Access Denied. Sorry.",
         "Location already exists in container.",
         "Delete failed.",
         "Location must not contain dots",
         "Document could not be formed well",
         "Publishing was unsuccessful",
         "Wrong parameters",
       );

# parameters recognized by the script
@params = qw( id parid name title depid symid delforce del);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    # event edit in SUPER implements operation control
    $self->SUPER::event_default( $ctxt );
    return 0 if $ctxt->{Properties}->{Application}->{style} eq 'error';

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    my $dp = $ctxt->{-PROVIDER};
    my $object = $ctxt->{-OBJECT};
    my $r = Apache->request;

    # two things: (1) having to encode here sucks
    #             (2) fetchlob here sucks
    $r->pnotes( 'xml_string',
                XML::LibXML::encodeToUTF8( 'iso-8859-1',
                                           ${ $dp->fetchLOB(
                                                    -column => "body",
                                                    -minorID => $object->getMinorID() ) } ) );

    my $dom_tree;

    # reusing AxKit's Configreader
    $AxKit::Cfg = Apache::AxKit::ConfigReader->new($r);

    # using dummy-provider-class needed for key()-method
    my $xml = xspscript::dummy->new($object->getLocation());

    # there's the magic
    Apache::AxKit::Language::XSP::handler(undef, $r, $xml);

    # The XSP handler store its result in pnotes
    my $dom_tree = $r->pnotes('dom_tree');

    $dom_tree->setEncoding('ISO-8859-1');
    my $newbody = $dom_tree->toString();

    # :/
    $newbody =~ s/^<\?xml.*//;
    $object->setBody( $newbody, { -dontcheck => 1 });

    $ctxt->{Properties}->{Application}->{style} = "default";

    return 0;
}

sub event_edit {
    my ( $self, $ctxt) = @_;
    XIMS::Debug( 5, "called" );

    $ctxt->{Properties}->{Content}->{getbody} = 1;
    $ctxt->{Properties}->{Content}->{escapebody} = 1;

    $self->resolve_content( $ctxt, [ qw( STYLE_ID ) ] );

    return $self->SUPER::event_edit( $ctxt );

}

sub event_store {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->{Properties}->{Application}->{OBJTYPE} = "XIMS::XSPScript";

    return 0 unless $self->initStoreObject( $ctxt )
                    and defined $ctxt->{-OBJECT};

    XIMS::Debug( 6, "store initialization succeeded" );

    my $body = $self->param( 'body' );
    if ( length $body ) {
        if ( $ctxt->{-OBJECT}->setBody( $body ) ) {
            XIMS::Debug( 6, "body set, len: " . length($body) );
        }
        else {
            XIMS::Debug( 2, "could not form well" );
            $self->sendError( $ctxt, $MSG[8] );
            return 0;
        }
    }

    return $self->SUPER::event_store( $ctxt );
}

sub event_exit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    if ( not exists $ctxt->{Properties}->{Application}->{style}
         or $ctxt->{Properties}->{Application}->{style} eq "edit" ) {
        $ctxt->{Properties}->{Content}->{getbody} = 1;
    }

    return $self->SUPER::event_exit( $ctxt );
}


# END RUNTIME EVENTS
# #############################################################################

package xspscript::dummy;

sub new {
    my $class = shift;
    my $key   = shift;
    my $self = bless { key => $key }, $class;

    return $self;
}

sub key { $_[0]->{key} }

1;
