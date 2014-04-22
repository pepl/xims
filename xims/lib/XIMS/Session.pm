
=head1 NAME

XIMS::Session -- A class representing a XIMS session.

=head1 VERSION

$Id$

=head1 SYNOPSIS

use XIMS::Session;

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Session;

use common::sense;
use parent qw( XIMS::AbstractClass Class::XSAccessor::Compat );
use Digest::SHA3 qw(sha3_224_base64 sha3_224_hex);
use Math::Random::Secure qw(irand);
use Time::HiRes  qw(gettimeofday);
use Time::Piece;

our @Fields = (
    @{ XIMS::Names::property_interface_names( resource_type() ) },
    qw( error_msg   warning_msg message
        verbose_msg date        serverurl
        skin        uilanguage  searchresultcount
    )
);

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    return 'Session';
}

__PACKAGE__->mk_accessors(@Fields);

=head2 new()

=head3 Parameter

    session_id: hash value of an existing session.

    user_id:    XIMS::User id.

    host:       the requesting hosts IP address.

=head3 Returns

a XIMS::Session object or nothing.

=head3 Description

Creates a new XIMS::Session object. There are two possible ways of calling:

    # Look up an existing session. Returns either a session object if found,
    # or nothing.

    new( session_id => $session_id );

    # Create a new session for the $user_id requesting from $host_ip. Only the
    # first two bytes of the host's ip-address are used for session
    # validation. This helps clients with dynamically changing ip-addresses.

    new( user_id => $user_id, host => $host_ip );

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args  = @_;

    my $self = bless {}, $class;
    my $real_session;

    if ( scalar( keys(%args) ) > 0 ) {
        if ( $args{session_id} eq 'ephemeral' and defined($args{user_id}) ) {
            # return ephemeral session, attributes get set below...
        }
        elsif ( defined( $args{session_id} ) ) {
            # Don't instantiate voided sessions (There is also a regex check
            # upfront in the Auth middleware.)
            if ( $args{session_id} =~ /^!/ ) {
                XIMS::Debug(1, "Eek! Attempt to instantiate voided Session!");
                return;
            }

            XIMS::Debug( 5, "fetching session by id." );
            $real_session = $self->data_provider->getSession(%args);

            # return if they explicitly asked for a
            # for an existing session and it wasn't found
            return unless $real_session;
        }
        elsif ( defined($args{user_id}) ) {
            XIMS::Debug( 5, "attempting to create new user session." );

            # for session id validation we use the first two bytes of the
            # host's ip-address to enable clients with dynamically changing
            # ip-addresses
            my $hostnet = q{};
            my $host = exists $args{host}
                && length $args{host} ? $args{host} : '127.0.0.1';

            # XXX: matching the full IP can be annoying if IPs change often
            if ( $host =~ /^([0-9]{1,3}(?:\.[0-9]{1,3}){3})/ ) {
                $hostnet = $1;
            }

            # the salt is a hash from gettimeofday()'s microseconds, two 32 bit
            # random numbers and the PID as the 'known unknowns'.
            my $salt = sha3_224_base64((gettimeofday())[1] . irand() . $$ . irand());
            # prepare a second token for CSRF prevention
            my $token      = sha3_224_base64((gettimeofday())[1] . $$ . irand());
            # for the session_id, we hash the userid and the hostnet in.
            my $session_id = sha3_224_hex( $args{user_id}
                                         . $salt
                                         . $hostnet );


            $args{session_id} = $session_id;
            $args{salt}       = $salt;
            $args{host}       = $host;
            $args{token}      = $token;
            $args{id}         = 1;
            my $id = $self->data_provider->createSession(%args);
            $real_session = $self->data_provider->getSession( id => $id );
        }

        if ($real_session) {
            $self->data( %{$real_session} );
        }
        else {
            $self->data(%args);
        }
    }

    return $self;
}

=head2 create()

=head3 Returns

The sessions id.

=head3 Description

A wrapper for the DataProviders createSession method.

=cut

# XXX: Seems unused at the moment. pepl?
sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $id   = $self->data_provider->createSession( $self->data() );
    $self->id($id);
    return $id;
}

=head2 delete()

=head3 Returns

1 on success, nothing on failure.

=head3 Description

Calls the DataProviders deleteSession method, then undefs the objects
attributes.

=cut

sub delete {
    XIMS::Debug( 5, "called" );
    my $self   = shift;

    my $retval = $self->data_provider->deleteSession( $self->data() );
    if ($retval) {
        map { $self->$_(undef) } @Fields;
        return 1;
    }
    else {
        return;
    }
}


=head2 void()

=head3 Returns

1 on success, nothing on failure.

=head3 Description

Invalidates the session_id and removes salt and token in the sessions table,
then undefs the objects attributes.

=cut

sub void {
    XIMS::Debug( 5, "called" );
    my $self   = shift;

    # session_id must be unique and not null...
    $self->session_id( q{!} . $self->session_id );
    $self->salt( q{} );
    $self->token( q{} );

    my $retval = $self->update();
    if ($retval) {
        map { $self->$_(undef) } @Fields;
        return 1;
    }
    else {
        return;
    }
}


=head2 validate($host)

=head3 Parameter

    $host: the requesting hosts IP number.

=head3 Returns

1 on success, undef on failure

=head3 Description

Validate the session and update the last access_timestamp. Verifies, that the
$host is in the same netblock (first two bytes of the IP-address) as the one
that created this session and that this session has not timed out yet.

=cut

sub validate {
    XIMS::Debug( 5, "called" );
    my $self    = shift;
    my $host    = shift;
    my $hostnet = q{};
    my $retval  = undef;

    # XXX: matching the full IP can be annoying if IPs change often
    if ( $host =~ /^([0-9]{1,3}(?:\.[0-9]{1,3}){3})/ ) {
        $hostnet = $1;
    }

    XIMS::Debug( 6, "hostname is $host, hostnet is $hostnet" );

    if ( length $hostnet
         and $self->session_id() eq
         sha3_224_hex( $self->user_id() . $self->salt() . $hostnet ) )
    {

        my $lat = Time::Piece->strptime( $self->last_access_timestamp(),
            "%Y-%m-%d %H:%M:%S" );
        my $now = localtime();

        # Time::Piece believes this to be UTC
        $lat -= $now->tzoffset;

        if ( ( $now - $lat ) < XIMS::Config::SessionTimeout() ) {
            $self->last_access_timestamp(
                $now->strftime("%Y-%m-%d %H:%M:%S") );
            if ( $self->update() ) {
                $retval = 1;
            }
            else {
                XIMS::Debug( 2, "updating sessions last_access_timestamp failed" );
            }
        }
        else {
            XIMS::Debug( 4, "session timed out" );
            $self->void();
        }
    }

    XIMS::Debug( 6, "user: "
                  . $self->user_id()
                  . " session: "
                  . $self->session_id()
                  . " validation string: "
                  . sha3_224_hex( $self->user_id()
                                   . $self->salt()
                                   . $hostnet
                  )
                  . " last_access_timestamp: "
                  . $self->last_access_timestamp()
    );
    return $retval;
}

=head2 user()

=head3 Returns

The XIMS::User object owning this session, nothing on error.

=cut

sub user {
    my $self = shift;
    return $self->{User} if defined $self->{User};
    return unless $self->user_id();
    my $user = XIMS::User->new( id => $self->user_id );
    $self->{User} = $user;
    return $user;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

See the file "LICENSE" for information and conditions for use,
reproduction, and distribution of this work, and for a DISCLAIMER OF ALL
WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

