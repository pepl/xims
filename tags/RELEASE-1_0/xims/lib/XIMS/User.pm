# Copyright (c) 2002-2005 The XIMS Project.
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
    my $explicit = shift;
    my $privmask = 0;

    return 0xffffffff if $self->admin();

    my @id_list = $self->id();
    push( @id_list, $self->role_ids() ) unless $explicit;
    #warn "IDS: " . Dumper( \@id_list );

    my @priv_data = $self->data_provider->getObjectPriv( content_id => $object->id(),
                                                         grantee_id => \@id_list,
                                                         properties => [ 'privilege_mask' ] );

    #warn "privs returned: " . Dumper( @priv_data );
    if ( scalar( @priv_data ) > 0 ) {
        foreach my $priv ( @priv_data ) {
            return undef if $priv->{'objectpriv.privilege_mask'} == 0; # return undef if we got a specific lockout
            $privmask = $privmask | $priv->{'objectpriv.privilege_mask'};
        }
        #warn "returning privmask: $privmask";
        return $privmask;
    }
    else {
        return undef;
    }
}

sub object_privileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $object = shift;
    my $explicit = shift;
    my $mask = $self->object_privmask( $object, $explicit );
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

sub system_privileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $mask = $self->system_privs_mask();
    return undef unless $mask;
    my $privs_hash = XIMS::Helpers::system_privmask_to_hash( $mask );
    return %{$privs_hash} if ref( $privs_hash ) eq 'HASH' and keys( %{$privs_hash} ) > 0;
    return undef;
}

sub default_bookmark {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $bmk = XIMS::Bookmark->new( owner_id => $self->id(), stdhome => 1 );
    if ( $bmk ) {
         return $bmk;
    }
    else {
        my $default_role = $self->roles_granted( default_role => 1 );
        return undef unless $default_role;
        $bmk = XIMS::Bookmark->new( owner_id => $default_role->id(), stdhome => 1 );
        if ( $bmk ) {
            return $bmk;
        }
    }
}

sub bookmarks {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @userid = ( $self->id() );
    my @roles_granted_ids = map { $_->id() } $self->roles_granted();
    my $explicit_only = delete $args{explicit_only};
    push @userid, @roles_granted_ids unless $explicit_only;

    my %params;
    $params{owner_id} = \@userid;
    $params{stdhome} = $args{stdhome} if exists $args{stdhome};
    $params{content_id} = $args{content_id} if exists $args{content_id};

    my @bookmarks_data = $self->data_provider->getBookmark( %params );
    my @bookmarks = map { XIMS::Bookmark->new->data( %{$_} ) } @bookmarks_data;
    #warn "bookmarks" . Dumper( \@bookmarks);
    return wantarray ? @bookmarks : $bookmarks[0];
}

# returns a list of all the roles that the
# user is a member of (*not* including his/her own id).
sub role_ids {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @role_ids;

    # return cached role_ids if no args are given
    if ( keys %args == 0 and exists $self->{role_ids} ) {
        #warn "returning cached role_ids";
        return @{$self->{role_ids}};
    }

    my @current_ids = ();
    push @current_ids, $self->id();
    my %id_list;

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
            map { $id_list{$_} = 1 } @current_ids;
            last if defined $args{explicit_only};
        }
        else {
            last;
        }
    }

    @role_ids = keys %id_list;
    # cache role ids if no args are given
    $self->{role_ids} = \@role_ids if keys %args == 0;

    return @role_ids;
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
    my %args = @_;

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

        my %oprivs = map { $_->{'objecttypepriv.object_type_id'} => [ $_->{'objecttypepriv.grantee_id'}, $_->{'objecttypepriv.grantor_id'} ] } @privs;

        if ( exists $args{add_oprivdata} ) {
            # make sure explicit object type grants have precedence (two loops are faster than sorting the array...)
            my $userid = $self->id();
            for ( @privs ) {
                $oprivs{'objecttypepriv.object_type_id'} = [ $_->{'objecttypepriv.grantee_id'}, $_->{'objecttypepriv.grantor_id'} ] if $_->{'objecttypepriv.grantee_id'} == $userid;
            }
        }

        foreach my $type ( @all_types ) {
            if ( exists $oprivs{$type->{id}} ) {
                $type->{can_create} = 1;
                if ( exists $args{add_oprivdata} ) {
                    $type->{grantee_id} = $oprivs{$type->{id}}->[0];
                    $type->{grantor_id} = $oprivs{$type->{id}}->[1];
                }
            }
            else {
                delete $type->{can_create};
                delete $type->{grantee_id};
                delete $type->{grantor_id};
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
