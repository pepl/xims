package Plack::Middleware::XIMS::MockSession;
use common::sense;

use parent qw( Plack::Middleware );

=head1 NAME

Plack::Middleware::XIMS::MockSession

=head1 VERSION

$Id: $

=head1 DESCRIPTION

L<Plack::Middleware> to set up a L<XIMS::MockSession> with the minimal
requirements for the public user to GET gopublic-published objects. In order to
be quick this bypasses pretty much everything.

=head1 SUBROUTINES/METHODS

=head2 call($self, $env)

=cut

sub call {
    my ( $self, $env ) = @_;

    $env->{'xims.appcontext'}->session( XIMS::MockSession->new() );
    $env->{'xims.appcontext'}->session->skin( XIMS::DEFAULT_SKIN() );

    return $self->app->($env);
}



=head1 NAME

XIMS::MockSession -- A mock session object that never gets close to the DB.

=head1 DESCRIPTION

This is needed to set up a session for the public user as quick as possible
(i.e. avoid hitting the DB), in order to have him fetch public objects. Used by
L<Plack::Middleware::XIMS::MockSession>.

=cut

package XIMS::MockSession;

use common::sense;

use parent qw(XIMS::Session);
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args  = @_;

    my $self = bless {}, $class;

    return $self;
}

sub create {}
sub delete {}
sub validate {1}
sub auth_module {'XIMS::Auth::Public'}

sub user {
    my $self = shift;
    return $self->{User} if defined $self->{User};
    my $user = XIMS::User->new( id => XIMS::PUBLICUSERID );
    $self->{User} = $user;

    # mock Userprefs
    $self->{User}->userprefs(
        bless {
            profile_type       => 'standard',
            containerview_show => 'location',
            skin               => 'default',
            publish_at_save    => 0
        },
        'XIMS::UserPrefs'
    );
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

