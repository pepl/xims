# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::Password;

use strict;
use vars qw( $VERSION );

use XIMS::User;
use Digest::MD5;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;
    my $user = XIMS::User->new( name => $param{Login} );

    if ( $user and $user->validate_password( $param{Password} ) ) {
        XIMS::Debug( 4, "user confirmed" );
        $self = bless { User => $user}, $class;
    }
    else {
        XIMS::Debug( 3, "could not authenticate" );
    }
    return $self ;
}

sub getUserInfo { return $_[0]->{User}; }

1;
