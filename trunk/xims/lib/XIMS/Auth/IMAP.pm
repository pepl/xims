# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::IMAP;

use strict;
use vars qw( $VERSION );

use XIMS::User;
use IMAP::Admin;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;

    if ( $param{Server} and $param{Login} and $param{Password} ) {
        if ( $class->_authenticate( %param ) ) {
            my $user = XIMS::User->new( name => $param{Login} );
            if ( $user and $user->id ) ){
                XIMS::Debug( 4, "user confirmed" );
                $self = bless { User => $user}, $class;
            }
            else {
                XIMS::Debug( 2, "user could not be found in xims-db" );
            }
        }
        else {
            XIMS::Debug( 2, "could not authenticate");
        }
    }
    else {
        XIMS::Debug( 3, "wrong parameters");
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
        XIMS::Debug( 2, $imap->error)
    }

    return $boolean;
}

sub getUserInfo { return $_[0]->{USER}; }

1;
