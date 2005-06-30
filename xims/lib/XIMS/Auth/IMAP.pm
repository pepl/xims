# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::IMAP;

use strict;
use vars qw( $VERSION );

use XIMS::User;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

sub new {
    my $class = shift;
    my %params = @_;
    my $self = undef;

    my $dp = $params{Provider};
    delete $params{Provider} if exists $params{Provider};

    if ( defined $dp and exists $params{'Server'} and exists $params{'Login'} ) {
        if ( $class->_authenticate( %params ) ) {
            XIMS::Debug(4, "IMAP authentication succesful");
            my $cUser = XIMS::User->new( -NAME => $params{Login} );
            if ( $dp->getUser( -user => $cUser ) ){
                $self = bless {USER => $cUser}, $class;
            }
            else {
                XIMS::Debug( 2, "user could not be found" );
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
    my %params = @_;
    my $boolean = undef;

    require IMAP::Admin;
    my $imap = IMAP::Admin->new( %params );
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
