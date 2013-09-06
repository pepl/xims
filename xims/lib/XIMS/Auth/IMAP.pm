
=head1 NAME

XIMS::Auth::IMAP -- A module providing IMAP authentication for XIMS

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Auth::IMAP;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Auth::IMAP;

use common::sense;
use XIMS::User;
use IMAP::Admin;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 new

=cut

sub new {
    my $class = shift;
    my %param = @_;
    my $self  = undef;


    if ( $param{Server} and $param{Login} and $param{Password} ) {
        if ( $class->_authenticate(%param) ) {
            my $user = XIMS::User->new( name => $param{Login} );
            if ( $user and $user->enabled() ne '0' and $user->id ) {
                XIMS::Debug( 4, "user confirmed" );
                $self = bless { User => $user }, $class;
            }
            else {
                XIMS::Debug( 3, "user not found or user is disabled" );
            }
        }
        else {
            XIMS::Debug( 3, "could not authenticate" );
        }
    }

    return $self;
}

sub _authenticate {
    my $self    = shift;
    my %param   = @_;
    my $boolean = undef;

    my $imap = IMAP::Admin->new(%param);
    $imap->close;

    if ( $imap->error eq 'No Errors' ) {
        $boolean = 1;
    }
    else {
        XIMS::Debug( 3, $imap->error );
    }

    return $boolean;
}

=head2 getUserInfo

=cut

sub getUserInfo { return $_[0]->{USER}; }

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<ximsconfig.xml>:

    <AuthStyle>XIMS::Auth::IMAP</AuthStyle>
    <AuthServer>imap.foo.tld</AuthServer>

=head1 DEPENDENCIES

    IMAP::Admin

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2013 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

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
