

=head1 NAME

XIMS::Importer

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer;

=head1 DESCRIPTION

The importer base class.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer;

use common::sense;
use XIMS::Object;
use XIMS::ObjectPriv;
use XIMS::User;
use XIMS::Folder;
use XIMS::DataFormat;
use XIMS::ObjectType;


=head2    $importer = XIMS::Importer->new( %param );

=head3 Parameter

    $param{Parent}     :
    $param{User}       :

=head3 Returns

    $self : importer class

=head3 Description

Constructor of the XIMS::Importer. It creates the Importer Class and
initializes it.

=cut

sub new {
    XIMS::Debug( 5, "called" );
    my $class = shift;
    my %param = @_;
    my %data;

    $data{Parent} = $param{Parent} if defined $param{Parent};
    $data{User}   = $param{User}   if defined $param{User};

    # optional parameters
    $data{ObjectType}  = $param{ObjectType}  if defined $param{ObjectType};
    $data{DataFormat}  = $param{DataFormat}  if defined $param{DataFormat};
    $data{ArchiveMode} = $param{ArchiveMode} if defined $param{ArchiveMode};

    # Virtual chroot for absolute FS paths
    $data{Chroot} = $param{Chroot} if defined $param{Chroot};

    unless ( exists $param{IgnoreCreatePriv} ) {

        # check if parent and user exist and user has create privileges...
        if (    $data{Parent}
            and $data{Parent}->id()
            and $data{User}
            and $data{User}->id() )
        {
            my $privmask = $data{User}->object_privmask( $data{Parent} );
            return unless $privmask & XIMS::Privileges::CREATE();
        }
        else {
            return;
        }
    }

    my $self = bless \%data, $class;
    return $self;
}

=head2 data_provider()

=cut

sub data_provider { return XIMS::DATAPROVIDER() }

=head2 object()

=cut

sub object {
    my $self   = shift;
    my $object = shift;

    if ($object) {
        $self->{Object} = $object;
        return 1;
    }
    elsif ( $self->{Object} ) {
        return $self->{Object};
    }
    else {
        return unless $self->object_type();
        $object = $self->object_from_object_type( $self->object_type() );
        $self->{Object} = $object;
        return $object;
    }
}

=head2 object_type()

=cut

sub object_type {
    my $self        = shift;
    my $object_type = shift;

    if ($object_type) {
        $self->{ObjectType} = $object_type;
        return 1;
    }
    else {
        return $self->{ObjectType};
    }
}

=head2 data_format()

=cut

sub data_format {
    my $self        = shift;
    my $data_format = shift;

    if ($data_format) {
        $self->{DataFormat} = $data_format;
        return 1;
    }
    else {
        return $self->{DataFormat};
    }
}

=head2 parent()

=cut

sub parent { return shift->{Parent} }

=head2 user()

=cut

sub user { return shift->{User} }

=head2 object_from_object_type()

=cut

sub object_from_object_type {
    my $self        = shift;
    my $object_type = shift;

    $object_type ||= $self->object_type();
    return unless $object_type->isa('XIMS::ObjectType');
    ## no critic (ProhibitStringyEval)
    my $objclass = "XIMS::" . $object_type->fullname();
    eval "require $objclass;";
    if ($@) {
        XIMS::Debug( 3, "Could not load object class: $@" );
        return;
    }
    ## use critic
    return $objclass->new( User => $self->user() );
}

=head2 import()

=head3 Parameter

    $object
    $updateexisting
    $donotchecklocation
    $grantowneronly
    $grantdefaultroles

=cut

sub import {
    my ($self, $object, $updateexisting, $donotchecklocation, $grantowneronly, $grantdefaultroles) = @_;

    $self->object($object) if $object;

    return $object->id() if ( $object and $object->id() );

    return unless ( $object and $object->location() );
    $object->location(
        $self->check_location( $object->location(), $donotchecklocation ) );
    $object->title( $object->location ) unless $object->title();

    # check if the same location already exists in the current container
    my $op = $object->parent;
    my $parent = $op ? $op : $self->parent;
    if ($parent->children(
            location       => $object->location,
            marked_deleted => 0 )
        )
    {

        # overwrite the existing document, if we are told to do so
        if ($updateexisting) {
            my $oldobject = XIMS::Object->new(
                path => $parent->location_path() . '/' . $object->location(),
                marked_deleted => 0
            );

            # check for update priv
            my $privmask = $self->user->object_privmask($oldobject);
            if ( not( $privmask and $privmask & XIMS::Privileges::WRITE() ) )
            {
                XIMS::Debug( 3,
                          "missing update privileges for object '"
                        . $oldobject->location_path()
                        . "'" );
                return;
            }

            # update content data
            my %newdata = $object->data();
            my $method;
            foreach my $key ( keys %newdata ) {
                $method = $key;
                $method = 'body' if $key eq 'binfile';
                $oldobject->$method( $newdata{$key} )
                    if defined $newdata{$key};
            }
            $oldobject->update( User => $self->user() );
            return $oldobject->id();
        }
        else {
            XIMS::Debug( 2, "location already exists" );
            return;
        }
    }

    $object->parent_id( $parent->document_id() );
    $object->language_id( $parent->language_id() );
    my $id = $object->create();
    $self->default_grants($grantowneronly, $grantdefaultroles);

    return $id;
}

=head2 check_location()

=cut

sub check_location {
    XIMS::Debug( 5, "called" );
    my $self               = shift;
    my $location           = shift;
    my $donotchecklocation = shift;

    $location = ( split /[\\|\/]/, $location )[-1];
    $location = $self->clean_location($location) unless $donotchecklocation;

    #my $suffix = $self->object->data_format->suffix();
    #if ( defined $suffix and length $suffix ) {
    #    XIMS::Debug( 6, "exchanging suffix with $suffix ($location)" );
    #    $location =~ s/\.[^\.]+$//;
    #    $location .= "." . $suffix;
    #    XIMS::Debug( 6, "exchange done, location is now $location" );
    #}

    return $location;
}

=head2 resolve_filename()

=cut

sub resolve_filename {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $filename = shift;

    my ( $location, $suffix ) = ( $filename =~ m|(.*)\.(.*)$| );
    my ( $object_type, $data_format ) = $self->resolve_suffix( lc $suffix );

    unless ($object_type
        and $object_type->name()
        and $data_format
        and $data_format->name() )
    {

        # fallback value in case we could not resolve by suffix
        return (
            XIMS::ObjectType->new( fullname => 'File' ),
            XIMS::DataFormat->new( name     => 'Binary' )
        );
    }

    return ( $object_type, $data_format );
}

=head2 resolve_suffix()

=cut

sub resolve_suffix {
    XIMS::Debug( 5, "called" );
    my $self   = shift;
    my $suffix = shift;

    if ( not( $self->{dataformatmap} and $self->{suffixmap} ) ) {
        my %dataformatmap = ();
        foreach my $object_type ( $self->data_provider->object_types() ) {
            my $object = $self->object_from_object_type($object_type);
            next unless $object;

            $dataformatmap{ $object->data_format_id() } = $object_type
                if $object->data_format_id();
        }

        # !<its_a_hack_alarm>!
        my $htmldf = XIMS::DataFormat->new( name => 'HTML' );
        $dataformatmap{ $htmldf->id() }
            = XIMS::ObjectType->new( fullname => 'Document' );
        my $xmldf = XIMS::DataFormat->new( name => 'XML' );
        $dataformatmap{ $xmldf->id() }
            = XIMS::ObjectType->new( fullname => 'XML' );
        my $vlibitemdf = XIMS::DataFormat->new( name => 'DocBookXML' );
        $dataformatmap{ $vlibitemdf->id() }
            = XIMS::ObjectType->new( fullname => 'VLibraryItem::DocBookXML' );

        # !</its_a_hack_alarm>
        my $image_ot = XIMS::ObjectType->new( name => 'Image' )
            ;    # preload to avoid redundant instantiation in the loop
        my $file_ot = XIMS::ObjectType->new( name => 'File' );
        my %suffixmap = ();
        foreach my $data_format ( $self->data_provider->data_formats() ) {
            next unless $data_format->suffix();
            $suffixmap{ $data_format->suffix() } = $data_format;

            # Images and Files object types can have different data formats
            # Object Type File shall be our fallback value
            if ( not $dataformatmap{ $data_format->id() }
                and $data_format->mime_type() =~ /^image/ )
            {
                $dataformatmap{ $data_format->id() } = $image_ot;
            }
            elsif ( not $dataformatmap{ $data_format->id() } ) {
                $dataformatmap{ $data_format->id() } = $file_ot;
            }
        }

        # suffix mappings for html.xy documents ( its_a_hack_alarm ^ 2 )
        map {
            $suffixmap{$_} = XIMS::DataFormat->new( name => 'HTML' );
            $suffixmap{$_}->{suffix} = $_
        } qw(en de es it fr);

        if ($self->{ArchiveMode}) {
            # in ArchiveMode, import HTML as XIMS::File instead of
            # XIMS::Document
            $dataformatmap{ $htmldf->id() } = $file_ot;
        }

        $self->{dataformatmap} = \%dataformatmap;
        $self->{suffixmap}     = \%suffixmap;
    }

    my $suffixmap     = $self->{suffixmap};
    my $dataformatmap = $self->{dataformatmap};
    my $data_format;
    $data_format = $suffixmap->{$suffix} if $suffix;
    my $object_type
        = $data_format ? $dataformatmap->{ $data_format->id() } : undef;

    return ( $object_type, $data_format );
}

=head2 default_grants()

=head3 Parameter

     $grantowneronly
     $grantdefaultroles

=cut

sub default_grants {
    XIMS::Debug( 5, "called" );
    my $self              = shift;
    my $grantowneronly    = shift;
    my $grantdefaultroles = shift;

    my $retval = undef;

    # grant the object to the current user
    if ($self->object->grant_user_privileges(
            grantee  => $self->user(),
            grantor  => $self->user(),
            privmask => XIMS::Privileges::MODIFY()
                | XIMS::Privileges::PUBLISH()
        )
        )
    {
        XIMS::Debug( 6,
                  "granted user "
                . $self->user->name
                . " default privs on "
                . $self->object->id() );
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "failed to grant default rights!" );
        return 0;
    }

    # TODO: through the user-interface the user should be able to decide if
    # all the roles he is member of (and not only his default roles) should
    # get read-access or not
    if ( defined $retval and not $grantowneronly ) {

        # copy the grants of the parent
        my @object_privs
            = map { XIMS::ObjectPriv->new->data( %{$_} ) }
            $self->data_provider->getObjectPriv(
            content_id => $self->parent->id() );
        foreach my $priv (@object_privs) {
            $self->object->grant_user_privileges(
                grantee  => $priv->grantee_id(),
                grantor  => $self->user(),
                privmask => $priv->privilege_mask(),
            );
        }

        if ( defined $grantdefaultroles ) {
            my @roles = $self->user->roles_granted( default_role => 1 )
                ;    # get granted default roles
            foreach my $role (@roles) {
                $self->object->grant_user_privileges(
                    grantee  => $role,
                    grantor  => $self->user(),
                    privmask => XIMS::Privileges::VIEW()
                );
                XIMS::Debug( 6,
                          "granted role "
                        . $role->name
                        . " view privs on "
                        . $self->object->id() );
            }
        }
    }

    return $retval;
}

=head2 clean_location()

=cut

sub clean_location {
    my $self     = shift;
    my $location = shift;
    my %escapes  = (
        ' '  => '-',
        'ö'  => 'oe',
        'ø'  => 'oe',
        'Ö'  => 'Oe',
        'Ø'  => 'Oe',
        'ä'  => 'ae',
        'Ä'  => 'Ae',
        'ü'  => 'ue',
        'Ü'  => 'Ue',
        'ß'  => 'ss',
        'á'  => 'a',
        'à'  => 'a',
        'å'  => 'a',
        'Á'  => 'A',
        'À'  => 'A',
        'Å'  => 'A',
        'é'  => 'e',
        'ê'  => 'e',
        'è'  => 'e',
        'É'  => 'E',
        'Ê'  => 'E',
        'È'  => 'E',
        'ñ'  => 'gn',
        'Ñ'  => 'Gn',
        'ó'  => 'o',
        'ò'  => 'o',
        'ô'  => 'o',
        'Ò'  => 'O',
        'Ó'  => 'O',
        'Ô'  => 'O',
        '§'  => '-',
        "\$" => '-',
        "\%" => '-',
        '&'  => '-',
        '/'  => '-',
        '\\' => '-',
        '='  => '-',
        '?'  => '',
        '!'  => '',
        '`'  => '-',
        '´'  => '-',
        '*'  => '-',
        '+'  => '-',
        '~'  => '-',
        "'"  => '-',
        '"'  => '-',
        '#'  => '-',
        '|'  => '-',
        '°'  => '-',
    );

    # substitute badchars
    my $badchars = join( '', sort(keys %escapes));
    $location =~ s/
                    ([$badchars])     # more flexible :)
                  /
                    $escapes{$1}
                  /segx; # *coff*
    # strip the rest
    $location =~ s/[^-_.a-zA-Z0-9]//sg;

    return ( not (ref $self and $self->{ArchiveMode}) # sometimes used as a function
             and XIMS::Config::LowerCaseLocations() )
        ? lc($location)
        : $location;

}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file or the xims_importer scripts output for
messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2017 The XIMS Project.

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

