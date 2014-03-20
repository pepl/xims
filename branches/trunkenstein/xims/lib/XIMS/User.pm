
=head1 NAME

XIMS::User -- represents a XIMS user.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::User;

=head1 SUBROUTINES/METHODS

=cut

package XIMS::User;

use common::sense;
use XIMS;
use parent qw( XIMS::AbstractClass Class::XSAccessor::Compat );
use XIMS::Bookmark;
use XIMS::UserPrefs;
use Digest::MD5 qw( md5_hex );
use Authen::Passphrase;

our @Fields = @{ XIMS::Names::property_interface_names( resource_type() ) };

=head2 fields()

=cut

sub fields {
    return @Fields;
}

=head2 resource_type()

=cut

sub resource_type {
    my $rt = __PACKAGE__;
    $rt =~ s/.*://;
    return $rt;
}

__PACKAGE__->mk_accessors(@Fields);

=head2 validate_password()

=cut

sub validate_password {
    XIMS::Debug( 5, "called" );
    my ($self, $raw_passwd) = @_;
    my $pwhash = $self->password();

    return undef unless length($pwhash) and defined $raw_passwd and $self->enabled();

    # we still need to support md5 hashes
    # they contain no '$' separators
    if ($pwhash =~ m/\$/) {
        return Authen::Passphrase->from_crypt( $self->password() )->match( $raw_passwd );
    }
    else {
        return $pwhash eq Digest::MD5::md5_hex($raw_passwd) ? 1 : undef;
    }
}

=head2 creatable_object_types()

=cut

sub creatable_object_types {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->objecttype_privileges(@_);
}

=head2 object_privmask()

=cut

sub object_privmask {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $object   = shift;
    my $explicit = shift;
    my $privmask = 0;

    return 0xffffffff if $self->admin();

    my @id_list = $self->id();
    push( @id_list, $self->role_ids() ) unless $explicit;

    #warn "IDS: " . Dumper( \@id_list );

    my @priv_data = $self->data_provider->getObjectPriv(
        content_id => $object->id(),
        grantee_id => \@id_list,
        properties => ['privilege_mask']
    );

    #warn "privs returned: " . Dumper( @priv_data );
    if ( scalar(@priv_data) > 0 ) {
        foreach my $priv (@priv_data) {
            return
              if $priv->{'objectpriv.privilege_mask'} ==
              0;    # return if we got a specific lockout
            $privmask = $privmask | $priv->{'objectpriv.privilege_mask'};
        }

        #warn "returning privmask: $privmask";
        return $privmask;
    }
    else {
        return;
    }
}

=head2 object_privileges()

=cut

sub object_privileges {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $object   = shift;
    my $explicit = shift;
    my $mask     = $self->object_privmask( $object, $explicit );

    return () unless $mask;

    my $privs_hash = XIMS::Helpers::privmask_to_hash($mask);

    if ( ref($privs_hash) eq 'HASH' and keys( %{$privs_hash} ) > 0 ) {
        return %{$privs_hash};
    }

    return ();
}

# sub grant_object_privilege {
#     my $self = shift;
#     my %args = @_;
#     my $obj = $args{Object};
#     die "must have a object to grant to" unless defined( $object );
# }

=head2 system_privileges()

=cut

sub system_privileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $mask = $self->system_privs_mask();

    return () unless $mask;

    my $privs_hash = XIMS::Helpers::system_privmask_to_hash($mask);

    if ( ref($privs_hash) eq 'HASH' and keys( %{$privs_hash} ) > 0 ) {
        return %{$privs_hash};
    }

    return ();
}

=head2 userprefs()

=cut

sub userprefs {
    XIMS::Debug( 5, "called" );
    my ($self, %args) = @_;

    if ( scalar(@_) == 1 and defined $self->{userprefs} ) {
        return $self->{userprefs};
    }

    my @userid = ( $self->id() );

    my %params;
    $params{id}   = \@userid;
    $params{profile_type}    = $args{profile_type} if exists $args{profile_type};
    $params{skin} = $args{skin} if exists $args{skin};
    $params{publish_at_save} = $args{publish_at_save} if exists $args{publish_at_save};
    $params{containerview_show} = $args{containerview_show} if exists $args{containerview_show};

    my @userprefs_data = $self->data_provider->getUserPrefs(%params);

    $self->{userprefs} = (map { XIMS::UserPrefs->new->data( %{$_} ) } @userprefs_data)[0];

    #if user's preferences dont't exist, create default preferences
    if( not defined $self->{userprefs} ){
        my $userprefs = XIMS::UserPrefs->new();
        $userprefs->profile_type(XIMS->DefaultUserPrefsProfile());
        $userprefs->skin(XIMS->DefaultUserPrefsSkin());
        $userprefs->publish_at_save(XIMS->DefaultUserPrefsPubOnSave());
        $userprefs->containerview_show(XIMS->DefaultUserPrefsContainerview());
        $userprefs->id($self->id());
        $self->{userprefs} = $userprefs->create();
    }

    return $self->{userprefs};

}

=head2 dav_otprivileges()

=cut

sub dav_otprivileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $mask = $self->dav_otprivs_mask();

    return () unless $mask;

    my @object_types = $self->data_provider->object_types( is_davgetable => 1 );
    my $privs_hash =
      XIMS::Helpers::dav_otprivmask_to_hash( $mask, \@object_types );

    if ( ref($privs_hash) eq 'HASH' and keys( %{$privs_hash} ) > 0 ) {
        return %{$privs_hash};
    }

    return ();
}

=head2 default_bookmark()

=cut

sub default_bookmark {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $bmk = XIMS::Bookmark->new( owner_id => $self->id(), stdhome => 1 );

    if ($bmk) {
        return $bmk;
    }
    else {
        my $default_role = $self->roles_granted( default_role => 1 );
        return unless $default_role;
        $bmk =
          XIMS::Bookmark->new( owner_id => $default_role->id(), stdhome => 1 );
        if ($bmk) {
            return $bmk;
        }
    }
}

=head2 bookmarks()

=cut

sub bookmarks {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @userid            = ( $self->id() );
    my @roles_granted_ids = map { $_->id() } $self->roles_granted();
    my $explicit_only     = delete $args{explicit_only};
    push @userid, @roles_granted_ids unless $explicit_only;

    my %params;
    $params{owner_id}   = \@userid;
    $params{stdhome}    = $args{stdhome} if exists $args{stdhome};
    $params{content_id} = $args{content_id} if exists $args{content_id};

    my @bookmarks_data = $self->data_provider->getBookmark(%params);
    my @bookmarks = map { XIMS::Bookmark->new->data( %{$_} ) } @bookmarks_data;

    #warn "bookmarks" . Dumper( \@bookmarks);
    return wantarray ? @bookmarks : $bookmarks[0];
}


=head2 role_ids()

returns a list of all the roles that the
user is a member of (*not* including his/her own id).

=cut

sub role_ids {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @role_ids;

    # return cached role_ids if no args are given
    if ( keys %args == 0 and exists $self->{role_ids} ) {

        #warn "returning cached role_ids";
        return @{ $self->{role_ids} };
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

    while (1) {
        $conditions->{'userpriv.grantee_id'} = \@current_ids;
        my $id_data = $self->data_provider->{Driver}->get(
            properties => { 'userpriv.id' => 1 },
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

    # everyone but the public user has the implicit role
    # XIMS:AUTHENTICATED_USER
    if ( keys %args == 0
        and $self->id() != XIMS::PUBLICUSERID() ) {
        push @role_ids, XIMS::AUTHENTICATEDUSERROLEID();
    }

    # cache role ids if no args are given
    $self->{role_ids} = \@role_ids if keys %args == 0;

    return @role_ids;
}

=head2 roles_granted()

=cut

sub roles_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @role_ids = $self->role_ids(%args);

    return () unless scalar(@role_ids) > 0;

    my @roles_data = $self->data_provider->getUser( id => \@role_ids );
    my @roles = map { XIMS::User->new->data( %{$_} ) } @roles_data;

    #warn "roles" . Dumper( \@roles ) . "\n";
    return wantarray ? @roles : $roles[0];
}

=head2 objecttype_privileges()

=cut

sub objecttype_privileges {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @all_types = $self->data_provider->object_types();
    my @granted_types;
    my $privs;

    if ( $self->admin() ) {
        foreach my $type (@all_types) {
            $type->{can_create} = 1;
        }
        return @all_types;
    }
    else {
        my @id_list = ( $self->role_ids(), $self->id() );

        #warn "OT IDS: " . Dumper( \@id_list );
        my @privs =
          $self->data_provider->getObjectTypePriv( grantee_id => \@id_list );

        #warn "privs returned: " . Dumper( \@privs );

        my %oprivs = map {
            $_->{'objecttypepriv.object_type_id'} => [
                $_->{'objecttypepriv.grantee_id'},
                $_->{'objecttypepriv.grantor_id'}
              ]
        } @privs;

        if ( exists $args{add_oprivdata} ) {

            # make sure explicit object type grants have precedence (two loops
            # are faster than sorting the array...)
            my $userid = $self->id();
            for (@privs) {
                $oprivs{'objecttypepriv.object_type_id'} = [
                    $_->{'objecttypepriv.grantee_id'},
                    $_->{'objecttypepriv.grantor_id'}
                  ]
                  if $_->{'objecttypepriv.grantee_id'} == $userid;
            }
        }

        foreach my $type (@all_types) {
            if ( exists $oprivs{ $type->{id} } ) {
                $type->{can_create} = 1;
                if ( exists $args{add_oprivdata} ) {
                    $type->{grantee_id} = $oprivs{ $type->{id} }->[0];
                    $type->{grantor_id} = $oprivs{ $type->{id} }->[1];
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

=head2 dav_object_types_granted()

=cut

sub dav_object_types_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my @object_types = $self->data_provider->object_types( is_davgetable => 1 );
    return @object_types if $self->admin();

    my $privmask = $self->dav_otprivs_mask();

    # cast $privmask to an integer, so that the bitwise operation will work as
    # expected
    1 if $privmask == 1;

    # Add otprivs from granted roles
    my @roles = $self->roles_granted();
    foreach my $role (@roles) {
        $privmask |= $role->dav_otprivs_mask();
    }

    # warn "Aggregated privmask: $privmask";

    my @object_types_granted = ();
    foreach my $object_type (@object_types) {
        push( @object_types_granted, $object_type )
          if $privmask & $object_type->davprivval();
    }

    #warn "returning " . Dumper( \@object_types_granted );
    return @object_types_granted;
}

# use XIMS::UserPriv here?

=head2 grant_role_privileges()

=cut

sub grant_role_privileges {
    my $self = shift;
    my %args = @_;

    die "must have a grantor, a grantee and a role"
      unless defined( $args{grantor} )
      and defined( $args{grantee} )
      and defined( $args{role} );

    # these allow the User-based args to be either a User object or the id()
    # of one.

    my $grantee_id =
      ( ref( $args{grantee} ) && $args{grantee}->isa('XIMS::User') )
      ? $args{grantee}->id()
      : $args{grantee};
    my $grantor_id =
      ( ref( $args{grantor} ) && $args{grantor}->isa('XIMS::User') )
      ? $args{grantor}->id()
      : $args{grantor};
    my $role_id =
      ( ref( $args{role} ) && $args{role}->isa('XIMS::User') )
      ? $args{role}->id()
      : $args{role};

    my $serialization_method;

    if (
        $self->data_provider->getUserPriv(
            grantee_id => $grantee_id,
            id         => $role_id,
            grantor_id => $grantor_id
        )
      )
    {
        $serialization_method = 'updateUserPriv';
    }
    else {
        $serialization_method = 'createUserPriv';
    }

    my %params = (
        grantor_id => $grantor_id,
        grantee_id => $grantee_id,
        id         => $role_id
    );

    $params{default_role} = $args{default_role} if defined $args{default_role};
    $params{role_master}  = $args{role_master}  if defined $args{role_master};

    return $self->data_provider->$serialization_method(%params);
}


=head2 fullname()

=head3 Parameter

    none

=head3 Returns

    name string

=head3 Description

Returns the user's firstname, middlename, and lastname in one, whitespace
normalised string.

=cut


sub fullname {
    my $self = shift;

    my $fullname =
        $self->firstname  . ' '
      . $self->middlename . ' '
      . $self->lastname;

    $fullname =~ s/(?:^\s*|\s*$)//g;
    $fullname =~ s/\s+/ /g;

    return $fullname;
}


1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

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

