
=head1 NAME

XIMS::Privileges -- XIMS privileges.

=head1 VERSION

$Id:$

=head1 SYNOPSIS

    use XIMS::Privileges;

=head1 DESCRIPTION

This package defines the set of XIMS privileges. System privileges are
defined in XIMS::Privileges::System.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Privileges;

use common::sense;

# we use `constant functions´ with prototypes as described in perlsub(1).
## no critic

=head2 list

Returns the complete list of defined system privileges.

Example usage:

    {
        no strict 'refs';
        for (XIMS::Privileges::list()) {
            print $_ . ": " . &{"XIMS::Privileges::$_"} . "\n";
        }
    }

=cut

sub list { qw( DENIED          VIEW       WRITE DELETE    PUBLISH ATTRIBUTES
               TRANSLATE       CREATE     MOVE  COPY      LINK    PUBLISH_ALL
               ATTRIBUTES_ALL  DELETE_ALL GRANT GRANT_ALL OWNER   MASTER
               SEND_AS_MAIL
           );
}

=head2 0x00 - 0x80: primitive user rights on content

=head3 DENIED

Explicit denial of content.

=cut

sub DENIED () { 0x00000000 }

=head3 VIEW

View content.

=cut

sub VIEW () { 0x00000001 }

=head3 WRITE

Edit content.

=cut

sub WRITE () { return 0x00000002; } 

=head3 DELETE

Delete content.

=cut

sub DELETE () { 0x00000004 }

=head3 PUBLISH

Publish content.

=cut

sub PUBLISH () { 0x00000008 }

=head3 ATTRIBUTES 

Change attributes for content.

=cut

sub ATTRIBUTES () { 0x00000010 }

=head2 0x100 - 0x8000: document related rights

=head3 TRANSLATE

Create new contents.

=cut

sub TRANSLATE () { 0x00000100 }

=head3 CREATE

Create new child.

=cut

sub CREATE () { 0x00000200 }

=head3 MOVE

Move document to another location.

=cut

sub MOVE () { 0x00000400 }

=head3 LINK

Create a symlink on document.

=cut

sub LINK () { 0x00000800 }

=head3 PUBLISH_ALL

Publish all content.

=cut

sub PUBLISH_ALL () { 0x00001000 }

=head3 ATTRIBUTES_ALL

Change attributes for document.

=cut

sub ATTRIBUTES_ALL () { 0x00002000 }

=head3 COPY

Copy object to another location.

=cut

sub COPY () { 0x00004000 }

=head3 SEND_AS_MAIL

Send object as email.

=cut

sub SEND_AS_MAIL () { 0x00008000 }

=head2 0x10000 - 0x80000: administrative subtree privileges

=head3 DELETE_ALL

Delete document subtree.

The DELETE_ALL flag is not granted by default to the owner!

=cut

sub DELETE_ALL () { 0x00010000 }

=head2 0x01000000 - 0x08000000: grant privileges

=head3 GRANT

Grant/revoke other users on content.

The GRANT right is a little complicated: If a user wants to grant a certain
right to another user, the grantor needs to have the right to grant! This is
to avoid users grant privileges to others they don't have themself. Any ACL
implementaion should follow this, to avoid security leaks.

=cut

sub GRANT () { 0x01000000 }

=head3 GRANT_ALL

Grant/revoke other users on all content.

=cut

sub GRANT_ALL () { 0x02000000 }

=head2 0x10000000 - 0x80000000: special roles

=head3 OWNER

User owns document.

The OWNER flag shows, that the user is the owner of the current document. This
should be a workaround for the missing document owner. This flag implies
0x0300031f, I guess. This means the owner is only entitled to do simple
operations on the document.

=cut

sub OWNER () { 0x40000000 }

=head3 MODIFY

MODIFY is a - for now static - combination of a list of privileges to be given
to creating users on object creation. For example MODIFY could be changed to be
more restrictive in the future.

=cut

sub MODIFY () { 0x43016F17 }

=head3 MASTER

User has VIEW, WRITE, DELETE, ATTRIBUTES, TRANSLATE, CREATE, MOVE, COPY, LINK,
ATTRIBUTES_ALL, DELETE_ALL, GRANT, GRANT_ALL, and OWNER privilege on the
object.

The MASTER flag shows, that the user is the master of the entire subtree. This
should imply 0x0301331d. This privilege is mainly for administrative reasons.
Therefore a master has also the right to grant/revoke privileges not owned by
the master himself. As well the MASTER is allowed to delete an entire subtree
regardless of the rights the user has on any child in the subtree.

Since the master is generally not responsible for the content he is not
allowed to edit the content.

=cut

sub MASTER () { 0x80000000 }

=head3 ADMIN

The ADMIN privilege indicates extreme superuser! Actually this is the helper
right :P

Note to self: Isn't this more of a system privilege?

=cut

sub ADMIN () { 0xffffffff }

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

This file contains lots of funny English.

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

