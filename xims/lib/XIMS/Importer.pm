# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer;

use strict;
use XIMS;
use XIMS::Object; # just to be failsafe
use XIMS::ObjectPriv;
use XIMS::User;
use XIMS::Folder;
use XIMS::DataFormat;
use XIMS::ObjectType;

##
#
# SYNOPSIS
#    $importer = XIMS::Importer->new( %param );
#
# PARAMETER
#    $param{Parent}     :
#    $param{User}       :
#
# RETURNS
#    $self : importer class
#
# DESCRIPTION
#
#    Constructor of the XIMS::Importer. It creates the Importer Class and
#    initializes it.
#
#
sub new {
    XIMS::Debug( 5, "called" );
    my $class = shift;
    my %param = @_;
    my %data;

    $data{Parent}     = $param{Parent}     if defined $param{Parent};
    $data{User}       = $param{User}       if defined $param{User};

    # optional parameters
    $data{ObjectType} = $param{ObjectType} if defined $param{ObjectType};
    $data{DataFormat} = $param{DataFormat} if defined $param{DataFormat};

    # check if parent and user exist and user has create privileges...
    if ( $data{Parent} and $data{Parent}->id() and $data{User} and $data{User}->id() ) {
        my $privmask = $data{User}->object_privmask( $data{Parent} );
        return undef unless $privmask & XIMS::Privileges::CREATE();
    }
    else {
        return undef;
    }

    my $self = bless \%data, $class;
    return $self;
}

sub data_provider { XIMS::DATAPROVIDER() }

sub object {
    my $self = shift;
    my $object = shift;

    if ( $object ) {
        $self->{Object} = $object;
        return 1;
    }
    elsif ( $self->{Object} ) {
        return $self->{Object};
    }
    else {
        return undef unless $self->object_type();
        $object = $self->object_from_object_type( $self->object_type() );
        $self->{Object} = $object;
        return $object;
    }
}

sub object_type {
    my $self = shift;
    my $object_type = shift;

    if ( $object_type ) {
        $self->{ObjectType} = $object_type;
        return 1;
    }
    else {
        return $self->{ObjectType};
    }
}

sub data_format {
    my $self = shift;
    my $data_format = shift;

    if ( $data_format ) {
        $self->{DataFormat} = $data_format;
        return 1;
    }
    else {
        return $self->{DataFormat};
    }
}

sub parent { return shift->{Parent} }
sub user { return shift->{User} }

sub object_from_object_type {
    my $self = shift;
    my $object_type = shift;

    $object_type ||= $self->object_type();
    return undef unless $object_type->isa('XIMS::ObjectType');

    my $objclass = "XIMS::". $object_type->name();
    eval "require $objclass;";
    if ( $@ ) {
        XIMS::Debug( 3, "Could not load object class: $@" );
        return undef;
    }
    return $objclass->new( User => $self->user() );
}

sub import {
    my $self = shift;
    my $object = shift;
    my $updateexisting = shift;

    $self->object( $object ) if $object;

    return $object->id() if ($object and $object->id());

    return undef unless ($object and $object->location());
    $object->location( $self->check_location( $object->location() ) );
    $object->title( $object->location ) unless $object->title();

    # check if the same location already exists in the current container
    my $op = $object->parent;
    my $parent = $op ? $op : $self->parent;
    if ( $parent->children( location => $object->location, marked_deleted => undef ) ) {
        # overwrite the existing document, if we are told to do so
        if ( $updateexisting ) {
            my $oldobject = XIMS::Object->new( path => $parent->location_path() . '/' . $object->location(), marked_deleted => undef );

            # check for update priv
            my $privmask = $self->user->object_privmask( $oldobject );
            if ( not ($privmask and $privmask & XIMS::Privileges::WRITE()) ) {
                XIMS::Debug( 3, "missing update privileges for object '" . $oldobject->location_path() . "'" );
                return undef
            }

            # copy content data
            my %olddata = $oldobject->data();
            my %newdata = $object->data();
            foreach my $key ( keys %olddata ) {
                $newdata{$key} = $olddata{$key} unless defined $newdata{$key};
            }
            my $nobject = XIMS::Object->new->data( %newdata );
            $nobject->update( User => $self->user() );
            return $nobject->id();
        }
        else {
            XIMS::Debug( 2, "location already exists" );
            return undef;
        }
    }

    $object->parent_id( $parent->document_id() );
    $object->language_id( $parent->language_id() ) ;
    my $id = $object->create();
    $self->default_grants();

    return $id;
}

sub check_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    $location = ( split /[\\|\/]/, $location )[-1];
    $location = $self->_clean_location( $location );

    #my $suffix = $self->object->data_format->suffix();
    #if ( defined $suffix and length $suffix ) {
    #    XIMS::Debug( 6, "exchanging suffix with $suffix ($location)" );
    #    $location =~ s/\.[^\.]+$//;
    #    $location .= "." . $suffix;
    #    XIMS::Debug( 6, "exchange done, location is now $location" );
    #}

    return $location;
}

sub resolve_filename {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $filename = shift;

    my ( $location, $suffix ) = ( $filename =~ m|(.*)\.(.*)$| );
    my ( $object_type, $data_format ) = $self->resolve_suffix( $suffix );

    unless ( $object_type and $object_type->name() and $data_format and $data_format->name() ) {
        # fallback value in case we could not resolve by suffix
        return ( XIMS::ObjectType->new( name => 'File' ), XIMS::DataFormat->new( name => 'Binary' ) );
    }

    return ( $object_type, $data_format );
}

sub resolve_suffix {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $suffix = shift;

    if ( not ( $self->{dataformatmap} and $self->{suffixmap} ) ) {
        my %dataformatmap = ();
        foreach my $object_type ( $self->data_provider->object_types() ) {
            my $object = $self->object_from_object_type( $object_type );
            next unless $object;
            $dataformatmap{$object->data_format_id()} = $object_type if $object->data_format_id();
        }
        # !<its_a_hack_alarm>!
        my $htmldf = XIMS::DataFormat->new( name => 'HTML' );
        $dataformatmap{$htmldf->id()} = XIMS::ObjectType->new( name => 'Document' );
        # !</its_a_hack_alarm>
        my $image_ot = XIMS::ObjectType->new( name => 'Image' ); # preload to avoid redundant instantiation in the loop
        my $file_ot  = XIMS::ObjectType->new( name => 'File' );
        my %suffixmap = ();
        foreach my $data_format ( $self->data_provider->data_formats() ) {
            next unless $data_format->suffix();
            $suffixmap{$data_format->suffix()} = $data_format;
            # Images and Files object types can have different data formats
            # Object Type File shall be our fallback value
            if ( not $dataformatmap{$data_format->id()} and $data_format->mime_type() =~ /^image/ ) {
                $dataformatmap{$data_format->id()} = $image_ot;
            }
            elsif ( not $dataformatmap{$data_format->id()} ) {
                $dataformatmap{$data_format->id()} = $file_ot;
            }
        }
        $self->{dataformatmap} = \%dataformatmap;
        $self->{suffixmap} = \%suffixmap;
    }

    my $suffixmap = $self->{suffixmap};
    my $dataformatmap = $self->{dataformatmap};
    my $data_format = $suffixmap->{$suffix} if $suffix;
    my $object_type = $data_format ? $dataformatmap->{$data_format->id()} : undef;

    return ( $object_type, $data_format );
}

sub default_grants {
    XIMS::Debug( 5, "called" );
    my $self           = shift;
    my $grantowneronly = shift;
    my $grantdefaultroles = shift;

    my $retval  = undef;

    # grant the object to the current user
    if ( $self->object->grant_user_privileges(
                                         grantee  => $self->user(),
                                         grantor  => $self->user(),
                                         privmask => XIMS::Privileges::MODIFY|XIMS::Privileges::PUBLISH
                                       )
       ) {
        XIMS::Debug( 6, "granted user " . $self->user->name . " default privs on " . $self->object->id() );
        $retval = 1;
    }
    else {
        XIMS::Debug( 2, "failed to grant default rights!" );
        return 0;
    }

    # TODO: through the user-interface the user should be able to decide if all the roles he
    # is member of (and not only his default roles) should get read-access or not
    if ( defined $retval and not $grantowneronly ) {
        # copy the grants of the parent
        my @object_privs = map { XIMS::ObjectPriv->new->data( %{$_} ) } $self->data_provider->getObjectPriv( content_id => $self->parent->id() );
        foreach my $priv ( @object_privs ) {
            $self->object->grant_user_privileges(
                                        grantee   => $priv->grantee_id(),
                                        grantor   => $self->user(),
                                        privmask  => $priv->privilege_mask(),
                                    )
        }

        if ( defined $grantdefaultroles ) {
            my @roles = $self->user->roles_granted( default_role => 1 ); # get granted default roles
            foreach my $role ( @roles ) {
                $self->object->grant_user_privileges(
                                                     grantee  => $role,
                                                     grantor  => $self->user(),
                                                     privmask => XIMS::Privileges::VIEW
                                                    );
                XIMS::Debug( 6, "granted role " . $role->name . " view privs on " . $self->object->id()  );
            }
        }
    }

    return $retval;
}

sub _clean_location {
    my $self = shift;
    my $location = shift;
    my %escapes = (
                   ' '  =>  '_',
                   'ö'  =>  'oe',
                   'ø'  =>  'oe',
                   'Ö'  =>  'Oe',
                   'Ø'  =>  'Oe',
                   'ä'  =>  'ae',
                   'Ä'  =>  'Ae',
                   'ü'  =>  'ue',
                   'Ü'  =>  'Ue',
                   'ß'  =>  'ss',
                   'á'  =>  'a',
                   'à'  =>  'a',
                   'å'  =>  'a',
                   'Á'  =>  'A',
                   'À'  =>  'A',
                   'Å'  =>  'A',
                   'é'  =>  'e',
                   'ê'  =>  'e',
                   'è'  =>  'e',
                   'É'  =>  'E',
                   'Ê'  =>  'E',
                   'È'  =>  'E',
                   'ñ'  =>  'gn',
                   'Ñ'  =>  'Gn',
                   'ó'  =>  'o',
                   'ò'  =>  'o',
                   'ô'  =>  'o',
                   'Ò'  =>  'O',
                   'Ó'  =>  'O',
                   'Ô'  =>  'O',
                   '§'  =>  '_',
                   "\$" =>  '_',
                   "\%" =>  '_',
                   '&'  =>  '_',
                   '/'  =>  '_',
                   '\\' =>  '_',
                   '='  =>  '_',
                   '?'  =>  '',
                   '!'  =>  '',
                   '`'  =>  '_',
                   '´'  =>  '_',
                   '*'  =>  '_',
                   '+'  =>  '_',
                   '~'  =>  '_',
                   "'"  =>  '_',
                   '#'  =>  '_',
                   '|'  =>  '_',
                   '°'  =>  '_',
                   ','  =>  '',
                   ';'  =>  '',
                   ':'  =>  ''
                  );

    my $badchars = join "", keys %escapes;
    $location =~ s/
                    ([$badchars])     # more flexible :)
                  /
                    $escapes{$1}
                  /segx;              # *coff*
    $location =~ s/_+/_/g;
    return lc($location);
}

1;
