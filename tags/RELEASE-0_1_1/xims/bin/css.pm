# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package css;

use strict;
use vars qw( $VERSION @ISA );
use text;

use CSS::Tiny;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( text );

# (de)register events here
sub registerEvents {
    return qw(
          default
          create
          edit
          store
          trahscan
          trashcan_prompt
          delete
          delete_prompt
          obj_acllist
          obj_aclgrant
          obj_aclrevoke
          publish
          publish_prompt
          unpublish
          cancel
          parse_css
          );
}

sub event_parse_css {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    return 0 if $self->SUPER::event_default( $ctxt );

    my $body = $ctxt->object->body();
    my $css = CSS::Tiny->read_string( $body );
    if ( $CSS::Tiny::errstr ) {
        $ctxt->session->error_msg( "Parse failure" );
        $ctxt->session->verbose_msg( $CSS::Tiny::errstr );
    }
    else {
        $ctxt->session->message( "Parse ok. Parsed CSS:" );
        $ctxt->session->verbose_msg( $css->write_string() );
    }

    $ctxt->properties->application->styleprefix( "common" );
    $ctxt->properties->application->style( "message_window_plain" );

    return 0;
}

1;
