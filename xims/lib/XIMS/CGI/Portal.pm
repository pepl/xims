# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::Portal;

use strict;
use vars qw( $VERSION @params @ISA);

use XIMS::CGI::Folder;

# #############################################################################
# GLOBAL SETTINGS
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( XIMS::CGI::Folder );

# parameters recognized by the script
@params = qw( id name title depid symid delforce del);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt) = @_;

    $self->resolve_content( $ctxt, [ qw( SYMNAME_TO_DOC_ID ) ] );

    return $self->SUPER::event_default( $ctxt );
}

# END RUNTIME EVENTS
# #############################################################################

1;
