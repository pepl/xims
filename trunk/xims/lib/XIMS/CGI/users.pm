
=head1 NAME

XIMS::CGI::users -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::users;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::CGI::users;

use strict;
use base qw( XIMS::CGI );
use XIMS::User;
use XIMS::UserPriv;
use XIMS::ObjectType;
use XIMS::ObjectTypePriv;
use Digest::MD5 qw( md5_hex );
use Locale::TextDomain ('info.xims');

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 registerEvents()

=cut

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
          bookmarks
          objecttypeprivs
          )
        );
}

# #############################################################################
# RUNTIME EVENTS

=head2 event_init()

=cut

sub event_init {
    my $self = shift;
    my $ctxt = shift;
    $self->SUPER::event_init( $ctxt );

    # test for system_privmask later; for now, just check for admin

    unless ( $ctxt->session->user->admin() ) {
        $self->sendEvent( 'access_denied' );
    }

    $ctxt->sax_generator( 'XIMS::SAX::Generator::Users' );
}

=head2 event_default()

the 'list all users' screen

=cut

sub event_default {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    if ( my $userquery = $self->param( 'userquery' ) ) {
        $userquery = $self->clean_userquery( $userquery );
        if ( defined $userquery and length $userquery ) {
            my %param;
            $param{name} = $userquery;
            my $dp = $ctxt->data_provider();
            my @big_user_data_list = $dp->getUser( %param );
            my @user_list = map { XIMS::User->new->data( %{$_} ) } @big_user_data_list;
            $ctxt->userlist( \@user_list );
        }
    }
}

=head2 event_create()

the 'create user' data entry screen

=cut

sub event_create {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();
    unless ( ( $privmask & XIMS::Privileges::System::CREATE_ROLE() ) ||
                ( $privmask & XIMS::Privileges::System::CREATE_USER() ) ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'create' );
}

=head2 event_create_update()

the 'create user' confirmation and data-handling screen

=cut

sub event_create_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();
    unless ( ( $privmask & XIMS::Privileges::System::CREATE_ROLE() ) ||
                ( $privmask & XIMS::Privileges::System::CREATE_USER() ) ) {
        return $self->event_access_denied( $ctxt );
    }

    my @required_fields = qw( name lastname admin enabled object_type );
    my %udata = ();

    $udata{name}              = $self->param('name');
    $udata{lastname}          = $self->param('lastname');
    $udata{middlename}        = $self->param('middlename');
    $udata{firstname}         = $self->param('firstname');
    $udata{email}             = $self->param('email');
    $udata{url}               = $self->param('url');

    # build system_privs_mask from parameters 'system_privs_XXX', each holding a single bit of the mask
    my $system_privs_mask = 0;
    foreach my $privname ( XIMS::Privileges::System::list() ) {
        if( $self->param( 'system_privs_' . $privname ) ) {
            $system_privs_mask |= XIMS::Privileges::System->$privname;
        }
    }
    $udata{system_privs_mask} = $system_privs_mask;

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

    if ( defined $pass1 and length $pass1 ) {
        if ( not ( defined $pass2 and length $pass2 ) ) {
            $ctxt->properties->application->style( 'create' );
            $ctxt->session->warning_msg( __"Error: Forgot password confirmation." );
            return 0;
        }
        if ( $pass1 eq $pass2 ) {
            $udata{password} = Digest::MD5::md5_hex( $pass1 );
        }
        else {
            $ctxt->properties->application->style( 'create' );
            $ctxt->session->warning_msg( __"Passwords did not match." );
            return 0;
        }
    }

    my $existing_user = XIMS::User->new( name => $udata{name} );
    if ( defined $existing_user ) {
        $ctxt->properties->application->style( 'create' );
        $ctxt->session->warning_msg( __"Error: An account with that name already exists." );
        return 0;
    }

    my @common = ();
    foreach ( @required_fields ) {
        #warn "- " . $_ . " udata: " . $udata{$_};
        push(@common, $_) if defined $udata{$_} and length $udata{$_} > 0;
    }

    if ( scalar @common != scalar @required_fields ) {
        $ctxt->properties->application->style( 'create' );
        $ctxt->session->warning_msg( __"Error: Missing required field." );
        return 0;
    }

    # end reality checks. if we are here, the
    # passed data is okay and we can create
    # the user.
    my $user = XIMS::User->new->data( %udata );
    my $uid = $user->create();
    if ( $uid ) {
        $ctxt->userlist( [ $user ] ); # put it there, so that the stylesheet knows what kind of user we created
        $ctxt->properties->application->style( 'create_update' );
    }
    else {
        $self->sendError( $ctxt,
            __x( "Error creating user '{name}'.", name => $user->name )
                . __"Please check with your system adminstrator."
            );
    }

}

=head2 event_edit()

the 'edit user' data entry screen

=cut

sub event_edit {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();
    unless ( ( $privmask & XIMS::Privileges::System::CREATE_ROLE() ) ||
                ( $privmask & XIMS::Privileges::System::CREATE_USER() ) ) {
        return $self->event_access_denied( $ctxt );
    }

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user and $user->id() ) {
        $ctxt->user( $user );
        $ctxt->properties->application->style( 'edit' );
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, __x("User '{name}' does not exist.", name => $uname) );
    }
}

=head2 event_update()

the 'edit user' confirmation and data-handling screen

=cut

sub event_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();
    my $id = $self->param('id');
    my $user = XIMS::User->new( id => $id );

    if ( $user and $user->id() ) {
        my $name = $self->param('name');
        $user->name($name ) if length $name > 0
            and ( ( $privmask & XIMS::Privileges::System::CHANGE_ROLE_NAME() ) ||
                  ( $privmask & XIMS::Privileges::System::CHANGE_USER_NAME() )
                );
        if ( ( $privmask & XIMS::Privileges::System::CHANGE_ROLE_FULLNAME() ) ||
                ( $privmask & XIMS::Privileges::System::CHANGE_USER_FULLNAME() )
            ) {
            $user->lastname( $self->param('lastname') );
            $user->middlename( $self->param('middlename') );
            $user->firstname( $self->param('firstname') );
        }
        $user->email( $self->param('email') ); # XIMS::Privileges::System::RESET_EMAIL() needed for that
        $user->url( $self->param('url') );

        if ( $privmask & XIMS::Privileges::System::CHANGE_SYSPRIVS_MASK() ) {
            # build system_privs_mask from parameters 'system_privs_XXX', each holding a single bit of the mask
            my $system_privs_mask = 0;
            foreach my $privname ( XIMS::Privileges::System::list() ) {
                if ( $self->param( 'system_privs_' . $privname ) ) {
                    $system_privs_mask |= XIMS::Privileges::System->$privname;
                }
            }
            $user->system_privs_mask( $system_privs_mask );
        }
		
		if ( $privmask & XIMS::Privileges::System::SET_ADMIN_EQU() ) {
            if ( defined $self->param('profile_type')) {
                $user->profile_type( $self->param('profile_type') );
            }
        }
        
        if ( $privmask & XIMS::Privileges::System::SET_ADMIN_EQU() ) {
            # kinda weird to do it this way, but
            # it avoids Perl's "0 is undef" madness
            # as the data comes in through the form.
            if ( $self->param('admin') eq 'true' ) {
                $user->admin( '1' );

                #
                # grant to admins role here?
                #
            }
            else {
                $user->admin( '0' );

                #
                # revoke from admins role here?
                #
            }
        }

        if ( $privmask & XIMS::Privileges::System::SET_STATUS() ) {
            if ( $self->param('enabled') eq 'true' ) {
                $user->enabled( '1' );
            }
            else {
                $user->enabled( '0' );
            }
        }

        if ( $user->update ) {
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message(
                __x("User '{name}' updated successfully.", name => $user->name()
                )
            );
        }
        else {
            $self->sendError( $ctxt,  
                              __x( "Update failed for user '{name}'.", name => $user->name )
                                  . __"Please check with your system adminstrator."
                              );
        }
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt,  __"User does not exist.");
    }
}

=head2 event_passwd()

the 'change password' data entry screen

=cut

sub event_passwd {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::RESET_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'passwd_edit' );
}

=head2 event_passwd_update()

the 'change password' confirmation and data handling screen

=cut

sub event_passwd_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::RESET_PASSWORD() ) {
        return $self->event_access_denied( $ctxt );
    }

    my $uname = $self->param('name');
    my $pass1 = $self->param('password1');
    my $pass2 = $self->param('password2');
    # check for user error first
    if ( defined $pass1 and length ($pass1) > 0 ) {
        if ( defined $pass2 and $pass1 eq $pass2 ) {
            my $user = XIMS::User->new( name => $uname );

            $user->password( Digest::MD5::md5_hex( $pass1 ) );

            if ( $user and $user->id() ) {
                if ( $user->update() ) {
                    $ctxt->properties->application->style( 'update' );
                    $ctxt->session->message( 
                        __x("Password for user '{name}' updated successfully.", name => $user->name )
                    );
                }
                else {
                    $self->sendError( $ctxt,
                                      __x( "Password update failed for user '{name}'.", name => $user->name )
                                          . __"Please check with your system adminstrator."
                                      );
                }
            }
            else {
                $self->sendError( $ctxt, "Could not find user. Please check with your system adminstrator." );
            }
        }
        # otherwise, entered passwds were not the same, kick
        # 'em back to the prompt.
        else {
            $ctxt->properties->application->style( 'passwd_edit' );
            $ctxt->session->warning_msg( __"Passwords did not match." );
        }
    }
    else {
        $ctxt->properties->application->style( 'passwd_edit' );
        $ctxt->session->warning_msg( __"Please specify a new password." );
    }
}

=head2 event_remove()

the 'remove user' "are you *really* sure" screen

=cut

sub event_remove {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();
    unless ( ( $privmask & XIMS::Privileges::System::DELETE_ROLE() ) ||
                ( $privmask & XIMS::Privileges::System::DELETE_USER() ) ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'remove' );

    my $uname = $self->param('name');
    # boot 'em to the list if the uname is missing
    $ctxt->properties->application->style( 'default' ) unless $uname;
}

=head2 event_remove_update()

the 'remove user' "you did" and data handling screen

=cut

sub event_remove_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();
    unless ( ( $privmask & XIMS::Privileges::System::DELETE_ROLE() ) ||
                ( $privmask & XIMS::Privileges::System::DELETE_USER() ) ) {
        return $self->event_access_denied( $ctxt );
    }

    $ctxt->properties->application->style( 'remove' );

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user and $user->id() ) {
        if ( $user->delete() ) {
            $ctxt->properties->application->style( 'update' );
            $ctxt->session->message(
                __x( "User '{name}' deleted successfully.", name => $uname ) 
            );
        }
        else {
            $self->sendError( $ctxt, 
                              __x( "Error removing user '{name}'.", name => $user->name )
                                  . __"Please check with your system adminstrator." 
                              );
        }
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, 
                          __x("User '{name}' does not exist.", name => $uname)
                      );
    }
}

=head2 event_manage_roles()

=cut

sub event_manage_roles {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::GRANT_ROLE() ) {
        return $self->event_access_denied( $ctxt );
    }

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    my %conditions;
    $conditions{explicit_only} = 1 if $self->param('explicit_only');

    if ( $user and $user->id() ) {
        $ctxt->user( $user );
        $ctxt->userlist( [ $user->roles_granted( %conditions ) ] );
        $ctxt->properties->application->style( 'manage_roles' );
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, 
                          __x("User '{name}' does not exist.", name => $uname)
                      );
    }
}

=head2 event_grant_role()

=cut

sub event_grant_role {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::GRANT_ROLE() ) {
        return $self->event_access_denied( $ctxt );
    }

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user and $user->id() ) {
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
        $self->sendError( $ctxt, 
                          __x("User '{name}' does not exist.", name => $uname)
                      );
    }
}

=head2 event_grant_role_update()

=cut

sub event_grant_role_update {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::GRANT_ROLE() ) {
        return $self->event_access_denied( $ctxt );
    }

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    my $rname = $self->param('role');
    my $role = XIMS::User->new( name => $rname );

    if ( $user and $user->id() and $role and $role->id() ) {
        my $default_role;
        $default_role = 1 unless $user->roles_granted(); # grant the first role grant of a user/role as default_role

        if ( $user->grant_role_privileges( grantor => $ctxt->session->user(), grantee => $user, role => $role, default_role => $default_role ) ) {
            $ctxt->session->message( 
                __x( "Role '{role_name}' successfully granted to user/role '{user_name}'.",
                     role_name => $rname,
                     user_name => $uname
                )
            );
            $ctxt->properties->application->style( 'role_management_update' );
        }
        else {
            $self->sendError(
                $ctxt,
                __x("Error granting '{role_name}' to '{user_name}'.",
                    role_name => $rname,
                    user_name => $uname
                    )
                    . __"Please check with your system adminstrator."
            );
        }

    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, __"User does not exist." );
    }

}

=head2 event_revoke_role()

=cut

sub event_revoke_role {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    unless ( $ctxt->session->user->system_privs_mask()
        & XIMS::Privileges::System::GRANT_ROLE() )
    {
        return $self->event_access_denied($ctxt);
    }

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    my $rname = $self->param('role');
    my $role = XIMS::User->new( name => $rname );

    if ( $user and $user->id() and $role and $role->id() ) {
        my $privs_object = XIMS::UserPriv->new(
            grantee_id => $user->id(),
            id         => $role->id()
        );
        if ( $privs_object and $privs_object->delete() ) {
            $ctxt->properties->application->style('role_management_update');
            $ctxt->session->message(
                __x("Role '{role_name}' successfully revoked from user/role '{user_name}'.",
                    role_name => $rname,
                    user_name => $uname
                )
            );
        }
        else {
            $self->sendError(
                $ctxt,
                __x("Error revoking '{role_name}' from '{user_name}'.",
                    role_name => $rname,
                    user_name => $uname
                    )
                    . __"Please check with your system adminstrator."
            );
        }
    }
    else {
        XIMS::Debug( 3,
            "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, __"User does not exist." );
    }

}


=head2 event_bookmarks()

=cut

sub event_bookmarks {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    # fixme
    #unless ( $ctxt->session->user->system_privs_mask() & XIMS::Privileges::System::XXX() ) {
    #    return $self->event_access_denied( $ctxt );
    #}

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user and $user->id() ) {
        my @bookmarks = $user->bookmarks( explicit_only => 1 );
        $ctxt->bookmarklist( \@bookmarks );
        $self->resolve_content( $ctxt, [ qw( CONTENT_ID ) ] );
        $self->resolve_user( $ctxt, [ qw( OWNER_ID ) ] );
        $ctxt->properties->application->style( 'bookmarks' );
    }
    else {
        XIMS::Debug( 3, "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt, __x("User '{name}' does not exist.", name => $uname) );
    }
    return 0;
}

=head2 event_objecttypeprivs()

=cut

sub event_objecttypeprivs {
    XIMS::Debug( 5, "called" );
    my ( $self, $ctxt ) = @_;

    my $privmask = $ctxt->session->user->system_privs_mask();

    # fixme
    #unless ( $privmask & XIMS::Privileges::System::XXX() ) {
    #    return $self->event_access_denied( $ctxt );
    #}

    my $uname = $self->param('name');
    my $user = XIMS::User->new( name => $uname );

    if ( $user and $user->id() ) {
        $ctxt->user($user);
        warn "\n\nuser exists.... addpriv=".$self->param('addpriv')." ... ot=".$self->param('objtype');
        #if ( ( defined $self->param('addpriv') or defined $self->param('addpriv.x') )
        #    and my $objtype = $self->param('objtype') )
         if ( defined $self->param('addpriv') and my $objtype = $self->param('objtype') )
        {
        	warn "\n\nadding new ot priv.";
            my $object_type = XIMS::ObjectType->new( fullname => $objtype );
            return $self->sendError( $ctxt,
                __"Could not resolve object type name" )
                unless defined $object_type;

            my %data = (
                grantee_id     => $user->id(),
                object_type_id => $object_type->id(),
                grantor_id     => $ctxt->session->user->id()
            );
            my $otpriv = XIMS::ObjectTypePriv->new(%data);
            return $self->sendError( $ctxt,
                __"Objecttype privilege already exists" )
                if defined $otpriv;

            $otpriv = XIMS::ObjectTypePriv->new();
            $otpriv->data(%data);
            if ( $otpriv->create() ) {
            	warn "\n\notprivs created.";
                $self->redirect($self->redirect_path( $ctxt, 'objecttypeprivs' ) );
                return 0;
            }
            else {
                return $self->sendError( $ctxt,
                    __"Could not create Objecttype privilege." );
            }
        }
        elsif ( $self->param('delpriv')
            and my $grantor_id     = $self->param('grantor_id')
            and my $object_type_id = $self->param('object_type_id') )
        {
            my $otpriv = XIMS::ObjectTypePriv->new(
                grantee_id     => $user->id(),
                grantor_id     => $grantor_id,
                object_type_id => $object_type_id
            );
            return $self->sendError( $ctxt,
                __"Objecttype privilege not found" )
                unless defined $otpriv;

            if ( $otpriv->delete() ) {
                $self->redirect(
                    $self->redirect_path( $ctxt, 'objecttypeprivs' ) );
                return 0;
            }
            else {
                return $self->sendError( $ctxt,
                    __"Could not delete Objecttype privilege." );
            }
        }
        elsif ( $self->param('dav_otprivs_update') ) {
            if ( $privmask
                & XIMS::Privileges::System::CHANGE_DAV_OTPRIVS_MASK() )
            {
                my $dav_otprivs_mask = 0;
                foreach my $object_type (
                    $user->data_provider->object_types( is_davgetable => 1 ) )
                {
                    if ( $self->param( 'dav_otprivs_' . $object_type->name() )
                        )
                    {
                        $dav_otprivs_mask |= $object_type->davprivval();
                    }
                }
                $user->dav_otprivs_mask($dav_otprivs_mask);

                if ( $user->update ) {
                    $ctxt->session->message(
                        __x("User '{name}' updated successfully.",
                            name => $user->name()
                        )
                    );
                    $self->redirect(
                        $self->redirect_path( $ctxt, 'objecttypeprivs' ) );
                    return 0;
                }
                else {
                    $self->sendError(
                        $ctxt,
                        __x( "Update failed for user '{name}'.",
                            name => $user->name() )
                            . __ "Please check with your system adminstrator."
                    );
                }
            }
        }

        my @object_types = $user->objecttype_privileges( add_oprivdata => 1 );
        $ctxt->objecttypelist( \@object_types );
        $self->resolve_user( $ctxt, [qw( GRANTEE_ID )] );
        $ctxt->properties->application->style('objecttypeprivs');
    }
    else {
    	warn "\n\nno user!!!!.";
        XIMS::Debug( 3,
            "Attempt to edit non-existent user. POSSIBLE HACK ATTEMPT!" );
        $self->sendError( $ctxt,
            __x( "User '{name}' does not exist.", name => $uname ) );
    }
    return 0;
}

# END RUNTIME EVENTS
# #############################################################################

=head2 redirect_path()

=cut

sub redirect_path {
    my ( $self, $ctxt, $event ) = @_;

    my $uri = Apache::URI->parse( $ctxt->apache() );
    $uri->path( XIMS::GOXIMS() . '/users' );
    $uri->query( "name=" . $self->param('name') .
                 ";$event=1" .
                 ";sort-by=" . $self->param('sort-by') .
                 ";order-by=" . $self->param('order-by') .
                 ";userquery=" . $self->param('userquery')
                 );

my $port = $uri->port();
    warn "port : ".$port;
    #somehow magically the port is 82... why???
    $uri->port(80);
    $port = $uri->port();
    warn "port : ".$port;
    
    warn "\n\nredirecting to ". $uri->unparse();
    return $uri->unparse();
}


1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

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

