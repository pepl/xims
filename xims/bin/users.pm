# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package users;

use strict;
use vars qw( $VERSION @params @ISA);

use XIMS::CGI;
use XIMS::User;

use XIMS::UserPriv;

use Digest::MD5 qw( md5_hex );

# #############################################################################
# GLOBAL SETTINGS

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

# inheritation information
@ISA = qw( XIMS::CGI );

# the names of pushbuttons in forms or symbolic internal handler
# each application should register the events required, even if they are
# defined in XIMS::CGI. This is for having a chance to
# deny certain events for the script.
#
# only dbhpanic and access_denied are set by XIMS::CGI itself.
sub registerEvents {
    XIMS::Debug( 5, "called" );
    $_[0]->SUPER::registerEvents(
        qw(
          create
          create_update
          update
          edit
          remove
          remove_update
          passwd
          passwd_update
          manage_roles
          grant_role
          grant_role_update
          revoke_role
          )
        );
}

# parameters recognized by the script
@params = qw( sort-by order-by edit admin id name lastname password enabled system_privs_mask create update remove);

# END GLOBAL SETTINGS
# #############################################################################

# #############################################################################
# RUNTIME EVENTS

sub event_init {
    my $self = shift;
    my $ctxt = shift;
    $self->SUPER::event_init( $ctxt );

    # test for system_privmask later; for now, just check for admin

    unless ( $ctxt->session->user->admin() ) {
        # hmm...why is this needed...
        $ctxt->properties->application->styleprefix( 'common' );
    $self->sendEvent( 'access_denied' );
    }
}

# the 'list all users' screen
sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $dp = $ctxt->data_provider();
    my @big_user_data_list = $dp->getUser();
    my @users_list = map{ XIMS::User->new( id => $_->{'user.id'} ) } @big_user_data_list;
    $ctxt->userlist( \@users_list );
}

# the 'create user' data entry screen
sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'create' );
}

# the 'create user' confirmation and data-handling screen
sub event_create_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my @required_fields = qw( name lastname system_privs_mask admin enabled password object_type);
    my %udata = ();

    $udata{name}              = $self->param('name');
    $udata{lastname}          = $self->param('lastname');
    $udata{middlename}        = $self->param('middlename');
    $udata{firstname}         = $self->param('firstname');
    $udata{system_privs_mask} = $self->param('system_privs_mask');
   
    if ( $self->param('admin') eq 'true' ) { 
        $udata{admin} = '1';
    }
    else {
        $udata{admin} = '0';
    }

    if ( $self->param('enabled') eq 'true' ) { 
        $udata{enabled} = '1';
    }
    else {
        $udata{enabled} = '0';
    }

    if ( $self->param('object_type') eq 'user' ) { 
        $udata{object_type} = '0';
    }
    else {
        $udata{object_type} = '1';
    }

    ##
    # reality checks
    ##

    # first, check for passwd mismatch
    my $pass1 = $self->param('password1');
    my $pass2 = $self->param('password2');

    if ($pass1 eq $pass2 and length( $pass1 ) > 0) {
        $udata{password} = Digest::MD5::md5_hex( $pass1 );
    }
    else {
        $ctxt->properties->application->style( 'create' );
        $ctxt->session->warning_msg( "Error: Password mismatch." );
        return 0;
    }

    my @common = ();
    foreach ( @required_fields ) {
        warn "- " . $_ . " udata: " . $udata{$_};
        push(@common, $_) if defined $udata{$_} and length $udata{$_} > 0;
    }

    if ( scalar @common != scalar @required_fields ) {
        $ctxt->properties->application->style( 'create' );
        $ctxt->session->warning_msg( "Error: Missing required field." );
        return 0;
    }
    
    # end reality checks. if we are here, the 
    # passed data is okay and we can create
    # the user.
    
    my $user = XIMS::User->new->data( %udata );
    my $uid = $user->create();
    if ( $uid ) {
        $ctxt->properties->application->style( 'update' );
        $ctxt->session->message( "User '" . $user->name() . "' created successfully with ID '$uid'." );
    }
    else {
        $self->sendError( $ctxt, "Error creating user '" .
                                  $user->name .
                                  "'. Please check with your system adminstrator.");
    }
    
}

# the 'edit user' data entry screen
sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user ) {
        $ctxt->user( $user );
        $ctxt->properties->application->style( 'edit' );
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, "User '$uname' does not exist." );
    } 
}

# the 'edit user' confirmation and data-handling screen
sub event_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $id = $self->param('id');
    my $user = XIMS::User->new( id => $id );

    if ( $user ) {
        my $name = $self->param('name');
        $user->name($name ) if length $name > 0;
        $user->lastname( $self->param('lastname') );
        $user->middlename( $self->param('middlename') );
        $user->firstname( $self->param('firstname') );
        $user->system_privs_mask( $self->param('system_privs_mask') );

        # kinda weird to do it this way, but
        # it avoids Perl's "0 is undef" madness
        # as the data comes in through the form.
        if ( $self->param('admin') eq 'true' ) { 
            $user->admin( '1' );
        }
        else {
            $user->admin( '0' );
        }

        if ( $self->param('enabled') eq 'true' ) { 
            $user->enabled( '1' );
        }
        else {
            $user->enabled( '0' );
        }

        if ( $user->update ) {
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message( "User '" . $user->name() . "' updated successfully." );
        }
        else {
            $self->sendError( $ctxt, "Update failed for user '" . $user->name() . "'. Please check with your system adminstrator." );
        }
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt,  "User does not exist.");
    } 
}

# the 'change password' data entry screen
sub event_passwd {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'passwd_edit' );
}

# the 'change password' confirmation and data handling screen
sub event_passwd_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $uname = $self->param('name');

    my $pass1 = $self->param('password1');
    my $pass2 = $self->param('password2');

    # check for user error first
    if ($pass1 eq $pass2 and length ($pass1) > 0) {
        my $user = XIMS::User->new( name => $uname );

        $user->password( Digest::MD5::md5_hex( $pass1 ) );

        if ( $user ) {
            if ( $user->update() ) {
                $ctxt->properties->application->style( 'update' );
                $ctxt->session->message( "Password for user '" . $user->name . "' updated successfully." );
            }
            else {
                $self->sendError( $ctxt,"Password update failed for user '" . 
                                          $user->name . 
                                         "'. Please check with your system adminstrator.");
            }
        }
        else {
            $self->sendError( $ctxt, "Error removing user '$uname'. Please check with your system adminstrator." );
        }
    }
    # otherwise, entered passwds were not the same, kick
    # 'em back to the prompt.
    else {
        $ctxt->properties->application->style( 'passwd_edit' );
        $ctxt->session->warning_msg( "Passwords did not match." );
    }    
}

# the 'remove user' "are you *really* sure" screen
sub event_remove {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'remove' );

    my $uname = $self->param('name');

    # boot 'em to the list if the uname is missing
    $ctxt->properties->application->style( 'default' ) unless $uname;
}

# the 'remove user' "you did" and data handling screen
sub event_remove_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    $ctxt->properties->application->style( 'remove' );

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user ) {
        if ( $user->delete() ) {
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message( "User '$uname' deleted successfully." );
        }
        else {
            $self->sendError( $ctxt, "Error removing user '$uname'. Please check with your system adminstrator." );
        }
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, "User '$uname' does not exist." );
    } 
}

sub event_manage_roles {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    my %conditions;
    $conditions{explicit_only} = 1 if $self->param('explicit_only');

    if ( $user ) {
        $ctxt->user( $user );
        $ctxt->userlist( [ $user->roles_granted( %conditions ) ] );
        $ctxt->properties->application->style( 'manage_roles' );
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, "User '$uname' does not exist." );
    } 
}

sub event_grant_role {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user ) {
        my $dp = $ctxt->data_provider();
        my @big_user_data_list = $dp->getUser();
        my @users_list = map { XIMS::User->new( id => $_->{'user.id'} ) } @big_user_data_list;

        # filter roles and self
        @users_list = grep { $_->id != $user->id && $_->object_type == 1 } @users_list;

        # filter already granted roles
        my %seen;
        my @filtered_roles;
        my @roles_granted_ids = map { $_->id() } $user->roles_granted();
        @seen{@roles_granted_ids} = ();
        foreach my $item (@users_list) {
            push(@filtered_roles, $item) unless exists $seen{$item->id()};
        }

        $ctxt->userlist( \@filtered_roles );
        $ctxt->properties->application->style( 'grant_role' );
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, "User '$uname' does not exist." );
    } 
}

sub event_grant_role_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    my $rname = $self->param('role');
    my $role = XIMS::User->new( name => $rname );

    if ( $user and $role ) {
        if ( $user->grant_role_privileges( grantor => $ctxt->session->user(), grantee => $user, role => $role ) ) {
            $ctxt->session->message( "Role '$rname' successfully granted to user/role '$uname'." );
            $ctxt->properties->application->style( 'role_management_update' );
        }
        else {
            $self->sendError( $ctxt, "Error granting '$rname' to '$uname'. Please check with your system adminstrator." );
        }
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, "User does not exist." );
    } 

}

sub event_revoke_role {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    my $rname = $self->param('role');
    my $role = XIMS::User->new( name => $rname );

    if ( $user and $role ) {
        my $privs_object = XIMS::UserPriv->new( grantee_id => $user->id(), id => $role->id() );
        if ( $privs_object and $privs_object->delete() ) {
            $ctxt->properties->application->style( 'role_management_update' );
            $ctxt->session->message( "Role '$rname' successfully revoked from user/role '$uname'.");
        }
        else {
            $self->sendError( $ctxt, "Error revoking '$rname' from '$uname'. Please check with your system adminstrator." );
        }
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, "User does not exist." );
    } 

}


# END RUNTIME EVENTS
# #############################################################################

1;
