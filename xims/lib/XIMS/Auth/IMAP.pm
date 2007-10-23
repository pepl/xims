# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::IMAP;

use strict;
use XIMS::User;
use IMAP::Admin;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;

    if ( $param{Server} and $param{Login} and $param{Password} ) {
        if ( $class->_authenticate( %param ) ) {
            my $user = XIMS::User->new( name => $param{Login} );
            if ( $user and $user->enabled() ne '0' and $user->id ) {
                XIMS::Debug( 4, "user confirmed" );
                $self = bless { User => $user}, $class;
            }
            else {
                XIMS::Debug( 3, "user could not be found or has been disabled" );
            }
        }
        else {
            XIMS::Debug( 3, "could not authenticate");
        }
    }

    return $self;
}

sub _authenticate {
    my $self = shift;
    my %param = @_;
    my $boolean = undef;

    my $imap = IMAP::Admin->new( %param );
    $imap->close;

    if ( $imap->error eq 'No Errors' ) {
        $boolean = 1;
    }
    else {
        XIMS::Debug( 3, $imap->error)
    }

    return $boolean;
}

sub getUserInfo { return $_[0]->{USER}; }

1;
