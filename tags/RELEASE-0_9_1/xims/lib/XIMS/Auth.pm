# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth;

use strict;
use vars qw( $VERSION );

use XIMS;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

sub new {
    XIMS::Debug( 5, "called" );
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless { Username => $args{Username}, Password => $args{Password} }, $class;
    return $self ;
}

# returns an instance of XIMS::User
sub authenticate {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $username = $args{Username} || $self->{Username};
    my $password = $args{Password} || $self->{Password};
    return undef unless ( $username and $password );

    my @authmods = split(',', XIMS::AUTHSTYLE());
    foreach my $authmod ( @authmods ) {
        XIMS::Debug( 6, "trying authstyle: $authmod" );
        eval "require $authmod;";
        if ( $@ ) {
            XIMS::Debug( 2, "could not load authmod $authmod! reason: $@" );
        }
        else {
            my $login = $authmod->new(  Server   => XIMS::AUTHSERVER(),
                                        Login    => $username,
                                        Password => $password );
            if ( $login ) {
                XIMS::Debug( 4, "login with authstyle $authmod ok" );
                return $login->getUserInfo();
            }
            else {
                XIMS::Debug( 4, "login with authstyle $authmod failed" );
            }
        }
    }
    XIMS::Debug( 3, "login failed!" );
    return undef;

}

1;