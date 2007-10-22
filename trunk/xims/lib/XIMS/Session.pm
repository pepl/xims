# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Session;

use strict;
use base qw( XIMS::AbstractClass Class::Accessor );
use Digest::MD5;
use Time::Piece;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @Fields = ( @{XIMS::Names::property_interface_names( resource_type() )}, qw( error_msg warning_msg message verbose_msg date serverurl skin uilanguage searchresultcount ) );

sub fields {
    return @Fields;
}

sub resource_type {
    return 'Session';
}

__PACKAGE__->mk_accessors( @Fields );

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;
    my $real_session;

    if ( scalar( keys( %args ) ) > 0 ) {
        if ( defined( $args{session_id} ) ) {
            XIMS::Debug( 5, "fetching session by id." );
            $real_session = $self->data_provider->getSession( %args );

            # return if they explicitly asked for a
            # for an existing session and it wasn't found
            return unless $real_session;
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

        if ( $real_session ) {
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
       return;
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

        my $lat = Time::Piece->strptime( $self->last_access_timestamp(), "%Y-%m-%d %H:%M:%S" );
        my $now = localtime();

        # Time::Piece believes this to be UTC
        $lat -= $now->tzoffset;

        if ( ($now - $lat) < XIMS::Config::SessionTimeout() ) {
            $self->last_access_timestamp( $now->strftime("%Y-%m-%d %H:%M:%S") );
            if ( $self->update() ) {
                $retval = 1;
            }
            else {
                XIMS::Debug( 2, "last access timestamp of session could not be updated" );
            }
        }
        else {
            XIMS::Debug( 4, "session timed out" );
        }
    }

    XIMS::Debug( 6, "user: " . $self->user_id() . " session: " . $self->session_id() .
                    " validation string: " . Digest::MD5::md5_hex( $self->user_id() . $self->salt() . $hostnet .
                    " last_access_timestamp: " . $self->last_access_timestamp() ) );

    return $retval;
}

sub user {
    my $self = shift;
    return $self->{User} if defined $self->{User};
    return unless $self->user_id();
    my $user = XIMS::User->new( id => $self->user_id );
    $self->{User} = $user;
    return $user;
}

1;
