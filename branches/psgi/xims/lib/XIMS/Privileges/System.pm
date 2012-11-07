
=head1 NAME

XIMS::Privileges::System -- XIMS system privileges.

=head1 VERSION

$Id: $

=head1 SYNOPSIS

    use XIMS::Privileges::System;

=head1 DESCRIPTION

This package defines the set of XIMS system privileges.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Privileges::System;

use strict;

# we use `constant functions´ with prototypes as described in perlsub(1).
## no critic

=head2 list

Returns the complete list of defined system privileges.

=cut

sub list () { qw( CHANGE_PASSWORD         GRANT_ROLE           RESET_PASSWORD
                  SET_STATUS              CREATE_ROLE          DELETE_ROLE
                  CHANGE_ROLE_FULLNAME    CHANGE_USER_FULLNAME CHANGE_ROLE_NAME
                  CHANGE_USER_NAME        CREATE_USER          DELETE_USER
                  CHANGE_DAV_OTPRIVS_MASK CHANGE_SYSPRIVS_MASK SET_ADMIN_EQU
                  GEN_WEBSITE
              );
}

=head2 0x01 - 0x80: user-self-management

=head3 CHANGE_PASSWORD

User can change his password.

=cut

sub CHANGE_PASSWORD () { 0x00000001 }

=head3 GRANT_ROLE

If users are role-masters of a role, they can grant/revoke other user/roles
to/from this role.

=cut

sub GRANT_ROLE () { 0x00000002 }

=head3 GEN_WEBSITE

Generate a new XIMS-Departmentroot with Departmentlinks and Speciallinks

=cut

sub GEN_WEBSITE () { 0x00000100 }

=head2 0x1000 - 0x800000: helpdesk-related user/role-management

=head3 RESET_PASSWORD

undocumented.

=cut

sub RESET_PASSWORD () { 0x00001000 }

=head3 SET_STATUS

(un)lock users.

=cut

sub SET_STATUS () { 0x00002000 }

=head3 CREATE_ROLE

With this privilege, users can add role-members without being role-masters of
the role.

=cut

sub CREATE_ROLE () { 0x00004000 }

=head3 DELETE_ROLE

undocumented.

=cut

sub DELETE_ROLE () { 0x00008000 }

=head3 CHANGE_ROLE_FULLNAME

undocumented.

=cut

sub CHANGE_ROLE_FULLNAME () { 0x00010000 }

=head3 CHANGE_USER_FULLNAME

undocumented.

=cut

sub CHANGE_USER_FULLNAME () { 0x00020000 }

=head3 CHANGE_ROLE_NAME

undocumented.

=cut

sub CHANGE_ROLE_NAME () { 0x00040000 }

=head3 CHANGE_USER_NAME

undocumented.

=cut

sub CHANGE_USER_NAME () { 0x00080000 }

=head3 CREATE_USER

undocumented.

=cut

sub CREATE_USER () { 0x00100000 }

=head3 DELETE_USER

undocumented.

=cut

sub DELETE_USER () { 0x00200000 }

=head3 CHANGE_DAV_OTPRIVS_MASK

undocumented.

=cut

sub CHANGE_DAV_OTPRIVS_MASK () { 0x00400000 }


=head2 0x10000000 - 0x80000000: system-management related

=head3 CHANGE_SYSPRIVS_MASK

undocumented.

=cut

sub CHANGE_SYSPRIVS_MASK () { 0x10000000 }


=head3 SET_ADMIN_EQU

undocumented.

=cut

sub SET_ADMIN_EQU () { 0x20000000 }




1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

Despite the package name, this is I<not> a subclass of XIMS::Privileges.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

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

