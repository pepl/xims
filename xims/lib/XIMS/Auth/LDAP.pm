
=head1 NAME

XIMS::Auth::LDAP -- A module providing LDAP authentication for XIMS

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Auth::LDAP;

=head1 DESCRIPTION

This module provides LDAP authentication for XIMS

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Auth::LDAP;

use common::sense;
use XIMS::User;
use Net::LDAP qw(LDAP_SUCCESS);


=head2 new()

=cut

sub new {
    my $class = shift;
    my %param = @_;
    my $self = undef;

    if ( $param{Server} and $param{Login} and $param{Password} ) {
        # using hardcoded port atm
        if ( my $ldap = Net::LDAP->new( $param{Server} ) ) {
            my $uid = lc($param{Login});
            $uid =~ s/\@.+$//; # remove domain part
            my $dn = "uid=$uid," . XIMS::LDAPBase();
            my $msg = $ldap->bind( $dn, password => $param{Password} );
            if ( $msg->code() == LDAP_SUCCESS ) {
                my $user = XIMS::User->new( name => $param{Login} );
                if ( $user and $user->enabled() ne '0' and $user->id ){
                    XIMS::Debug( 4, "user confirmed" );
                    $self = bless { User => $user }, $class;
                }
                else {
                    XIMS::Debug( 3, "user could not be found or has been disabled" );
                }
            }
            else {
                XIMS::Debug( 3, "could not authenticate" );
            }
        }
        else {
            XIMS::Debug( 2, "no connection to LDAP Server: $@" );
        }
    }

    return $self;
}

=head2 getUserInfo()

=cut

sub getUserInfo { return $_[0]->{User}; }

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

In F<ximsconfig.xml>

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2015 The XIMS Project.

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

