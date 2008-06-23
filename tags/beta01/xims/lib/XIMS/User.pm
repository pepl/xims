# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

# $Id$
package XIMS::User;

use strict;
use vars qw($VERSION @ISA @Fields);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use XIMS;
use XIMS::Bookmark;
use XIMS::AbstractClass;
@ISA = qw( XIMS::AbstractClass );

use Digest::MD5 qw( md5_hex );
#use Data::Dumper;

BEGIN {
     @Fields = @{XIMS::Names::property_interface_names('User')};
}

use Class::MethodMaker
        get_set       => \@Fields;

sub new {
    XIMS::Debug( 5, "called" );
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;
    my ( $package, $file, $line ) = caller(1);
    #warn "USER init called by $package line $line, passed " . Dumper( \%args );

    # fetch or create, based on the presence of an 'id' or 'name' argument
    if ( defined( $args{id} ) or defined( $args{name} ) ) {
        my $real_user = $self->data_provider->getUser( %args );
        if ( scalar( keys( %{$real_user} ) ) > 0 ) {
            $self->data( %{$real_user} );
        }
        else {
            return undef;
        }
    }
    elsif ( scalar( keys( %args) ) > 0 ) {
        $self->data( %args );
    }

    # special instance cacheing for some foreign properties
    return $self;
}


sub update {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->data_provider->updateUser( $self->data() );
}

sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $id = $self->data_provider->createUser( $self->data() );
    $self->id( $id );
    return $id;
}

sub delete {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $retval = $self->data_provider->deleteUser( $self->data() );
    if ( $retval ) {
        map { $self->$_( undef ) } @Fields if $retval;
        return 1;
    }
    else {
       return undef;
    }
}

sub fields {
    XIMS::Debug( 5, "called" );
    return @Fields;
}

sub validate_password {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $raw_passwd = shift;
    if ( defined( $raw_passwd ) and $self->password() eq Digest::MD5::md5_hex( $raw_passwd ) ) {
        return 1;
    }
    return undef;
}

sub creatable_object_types {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->objecttype_privileges( @_ );
}

sub object_privmask {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $object = shift;

    return 0xffffffff if $self->admin();

    my @id_list = ( $self->role_ids(), $self->id() );
    #warn "IDS: " . Dumper( \@id_list );

    my @priv_data = $self->data_provider->getObjectPriv( content_id => $object->id(),
                                                         grantee_id => \@id_list,
                                                         properties => [ 'privilege_mask' ] );

    #warn "privs returned: " . Dumper( @priv_data );
    return undef unless scalar( @priv_data ) > 0;
    return undef if $priv_data[0]->{'objectpriv.privilege_mask'} == 0;

    # ubu: need to get smarter here... what do we do
    # if there are more than one priv mask based on roles granted to the
    # current user?
    return $priv_data[0]->{'objectpriv.privilege_mask'};
}

sub object_privileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $object = shift;
    my $mask = $self->object_privmask( $object );
    return undef unless $mask;
    my $privs_hash = XIMS::Helpers::privmask_to_hash( $mask );
    return %{$privs_hash} if ref( $privs_hash ) eq 'HASH' and keys( %{$privs_hash} ) > 0;
    return undef;
}

#sub grant_object_privilege {
#    my $self = shift;
#    my %args = @_;
#    my $obj = $args{Object};
#    die "must have a object to grant to" unless defined( $object );
#
#
#
#}

# ubu: fixme
sub default_bookmark {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $bmk = XIMS::Bookmark->new( owner_id => $self->id(), stdhome => 1 );
    if ( $bmk ) {
        return $bmk;
    }
}

# returns a list of all the roles that the
# user is a member of (*not* including his/her own id).
sub role_ids {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @current_ids = ();
    push @current_ids, $self->id();
    my @id_list = @current_ids;

    my $conditions = {};
    if ( defined $args{default_role} ) {
        $conditions->{'userpriv.default_role'} = 1;
    }
    if ( defined $args{role_master} ) {
        $conditions->{'userpriv.role_master'} = 1;
    }

    while ( 1 ) {
        $conditions->{'userpriv.grantee_id'} = \@current_ids;
        my $id_data = $self->data_provider->{Driver}->get( properties => { 'userpriv.id' => 1 },
                                                           conditions => $conditions
                                                         );
        if ( scalar( @{$id_data} ) > 0 ) {
            @current_ids = map { values %{$_} } @{$id_data};
            push @id_list, @current_ids;
            last if defined $args{explicit_only};

        }
        else {
            last;
        }
    }

    # snip off the the first role, as it will only contain the current user's id
    shift @id_list;
    return @id_list;
}

sub roles_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @role_ids = $self->role_ids( %args );
    return () unless scalar( @role_ids ) > 0 ;
    my @roles_data = $self->data_provider->getUser( id => \@role_ids );
    my @roles = map { XIMS::User->new->data( %{$_} ) } @roles_data;
    #warn "roles" . Dumper( \@roles ) . "\n";
    return wantarray ? @roles : $roles[0];
}

sub objecttype_privileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my @all_types = $self->data_provider->object_types();
    my @granted_types;
    my $privs;

    if ( $self->admin() ) {
       foreach my $type ( @all_types ) {
           $type->{can_create} = 1;
       }
       return @all_types;
    }
    else {
        my @id_list = ( $self->role_ids(), $self->id() );
        #warn "OT IDS: " . Dumper( \@id_list );
        my @privs = $self->data_provider->getObjectTypePriv( grantee_id => \@id_list );
        #warn "privs returned: " . Dumper( \@privs );

        foreach my $type ( @all_types ) {
            if ( grep { $_->{'objecttypepriv.object_type_id'} == $type->{id} } @privs ) {
                $type->{can_create} = 1;
            }
        }
    }
    #warn "returning alltypes " . Dumper( \@all_types );
    return @all_types;
}



# use XIMS::UserPriv here?
sub grant_role_privileges {

    my $self = shift;

    my %args = @_;



    die "must have a grantor, a grantee and a role"

        unless defined( $args{grantor} ) and defined( $args{grantee} ) and defined( $args{role} );



    # these allow the User-based args to be either a User object or the id() of one.

    my $grantee_id = ( ref( $args{grantee} ) && $args{grantee}->isa('XIMS::User') ) ? $args{grantee}->id() : $args{grantee};

    my $grantor_id = ( ref( $args{grantor} ) && $args{grantor}->isa('XIMS::User') ) ? $args{grantor}->id() : $args{grantor};

    my $role_id    = ( ref( $args{role}    ) && $args{role}->isa('XIMS::User') )    ? $args{role}->id()    : $args{role};





    my $serialization_method;



    if ( $self->data_provider->getUserPriv( grantee_id => $grantee_id, id => $role_id, grantor_id => $grantor_id ) ) {

        $serialization_method = 'updateUserPriv';

    }

    else {

        $serialization_method = 'createUserPriv';

    }



    my %params = ( grantor_id => $grantor_id,

                   grantee_id => $grantee_id,

                   id => $role_id

                 );



    $params{default_role} = $args{default_role} if defined $args{default_role};

    $params{role_master}  = $args{role_master}  if defined $args{role_master};



    return $self->data_provider->$serialization_method( %params );

}



1;