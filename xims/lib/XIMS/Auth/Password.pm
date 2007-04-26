# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Auth::Password;

use strict;
use XIMS::User;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;
    my $user = XIMS::User->new( name => $param{Login} );

    if ( $user and $user->enabled() ne '0' and $user->validate_password( $param{Password} ) ) {
        XIMS::Debug( 4, "user confirmed" );
        $self = bless { User => $user}, $class;
    }
    else {
        XIMS::Debug( 3, "could not authenticate (user may have been disabled)" );
    }
    return $self ;
}

sub getUserInfo { return $_[0]->{User}; }

1;
