# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Session;

use strict;
use vars qw($VERSION @ISA @Fields $AUTOLOAD);

$VERSION = do { my @r=(q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use XIMS;
use XIMS::AbstractClass;
@ISA = qw( XIMS::AbstractClass );

use Digest::MD5;
#use Data::Dumper;

BEGIN {
    @Fields = @{XIMS::Names::property_interface_names('Session')};
    push( @Fields, qw( error_msg warning_msg message verbose_msg date serverurl skin uilanguage searchresultcount ) );
}

use Class::MethodMaker
        get_set       => \@Fields;

sub fields {
    return @Fields;
}

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;
    my $real_session;

    # ubu: debugging, don't delete
    my ($package, $filename, $line) = caller(1);
    #warn "Session init called. arguments: " . Dumper( \%args ) . "\ncalled by: $package line $line\n";

    if ( scalar( keys( %args ) ) > 0 ) {
        if ( defined( $args{session_id} ) ) {
            XIMS::Debug( 5, "fetching session by id." );
            $real_session = $self->data_provider->getSession( %args );

            # return undef if they explicitly asked for a
            # for an existing session and it wasn't found
            return undef unless $real_session;
        }
        elsif ( defined( $args{user_id} ) ) {
            XIMS::Debug( 5, "attempting to create new user session." );

            my $host = exists $args{host} && length $args{host} ? $args{host} : '127.0.0.1';

            # for session id validation we use the first two bytes of the host's ip-address to enable clients
            # with dynamically changing ip-addresses
            $host =~ /^([0-9]{1,3}\.[0-9]{1,3})/;
            my $hostnet = $1;

            my $salt = time();
            substr($salt,0,1,'');
            substr($salt,0,3,sprintf("%03d", int(rand(999))));
            my $session_id = Digest::MD5::md5_hex( $args{user_id} . $salt . $hostnet );
            $args{session_id} = $session_id;
            $args{salt} = $salt;
            $args{host} = $host;
            $args{id} = 1;
            my $id = $self->data_provider->createSession( %args );
            $real_session = $self->data_provider->getSession( id => $id );
        }

        if ( defined( $real_session )) {
            $self->data( %{$real_session} );
        }
        else {
            $self->data( %args );
        }
    }
    return $self;
}

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $id = $self->data_provider->createSession( $self->data() );
    $self->id( $id );
    return $id;
}

sub delete {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $retval = $self->data_provider->deleteSession( $self->data() );
    if ( $retval ) {
        map { $self->$_( undef ) } @Fields;
        return 1;
    }
    else {
       return undef;
    }
}

sub validate {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $host = shift;
    my $retval = undef;

    $host =~ /^([0-9]{1,3}\.[0-9]{1,3})/;
    my $hostnet = $1;

    XIMS::Debug( 6, "hostname is $host, hostnet is $hostnet" );
    if ( length $hostnet
             and $self->session_id() eq Digest::MD5::md5_hex( $self->user_id() . $self->salt() . $hostnet ) ) {
         $retval = 1;
    }


    XIMS::Debug( 6, "user: " . $self->user_id() . "session: " . $self->session_id() .
                    " validation string: " . Digest::MD5::md5_hex( $self->user_id() . $self->salt() . $hostnet ) );

    return $retval;
}

sub user {
    my $self = shift;
    return $self->{User} if defined $self->{User};
    return undef unless $self->user_id();
    my $user = XIMS::User->new( id => $self->user_id );
    $self->{User} = $user;
    return $user;
}

1;
