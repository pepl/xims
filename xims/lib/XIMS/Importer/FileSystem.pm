
=head1 NAME

XIMS::Importer::FileSystem

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem;

=head1 DESCRIPTION

This module implements the importer's common methods related to filesystem
operations.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem;

use strict;
use parent qw( XIMS::Importer );
use XIMS::DataFormat;
use XIMS::ObjectType;
use XIMS::Object;
use File::Basename;
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# Global hash for parsed files memoization
my %parsed_files;

=head2 import()

=cut

sub import {
    my $self           = shift;
    my $location       = shift;
    my $updateexisting = shift;
    return unless $location;

    my $importer = $self->resolve_importer($location);
    return unless $importer;

    my $object = $importer->handle_data($location);

    return $self->SUPER::import( $object, $updateexisting );
}

=head2 handle_data()

=cut

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $location = shift;

    my $object = $self->object();
    $object->location($location);
    $object->parent_id( $self->parent_by_location($location)->document_id() );
    $object->data_format_id( $self->data_format->id() );

    # Parse information from published metadata files if available
    $self->handle_container_metadata($object);

    return $object;
}

=head2 parent_by_location()

=cut

sub parent_by_location {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $location = shift;

    my $dirname   = dirname($location);
    my $plocation = $self->parent->location_path();

    # for absolute paths, look for a virtual chroot parameter
    if ( $dirname =~ m#^/# and defined $self->{Chroot} ) {
        $dirname =~ s/$self->{Chroot}//;
        $plocation .= $dirname;
    }
    elsif ( length $dirname and $dirname ne '.' ) {
        $plocation .= '/' . $dirname;
    }

    $plocation = '/root' unless ( defined $plocation and $plocation );

    return XIMS::Object->new( path => $plocation );
}

=head2 resolve_location()

=cut

sub resolve_location {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $location = shift;
    XIMS::Debug( 6, "location: $location" );

    if ( -l $location ) {
        return (
            XIMS::ObjectType->new( name => 'SymbolicLink' ),
            XIMS::DataFormat->new( name => 'SymbolicLink' )
        );
    }
    elsif ( -f $location ) {
        return $self->resolve_filename( basename($location) );
    }
    elsif ( -d $location ) {
        return (
            XIMS::ObjectType->new( name => 'Folder' ),
            XIMS::DataFormat->new( name => 'Container' )
        );
    }
    else {
        die
            "could not resolve location '$location'. (we should not get there)";
    }
}

=head2 resolve_importer()

=cut

sub resolve_importer {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $location = shift;
    return unless $location;

    my ( $object_type, $data_format ) = $self->resolve_location($location);
    my $impclass = "XIMS::Importer::FileSystem::" . $object_type->fullname();
    ## no critic (ProhibitStringyEval)
    eval "require $impclass;";
    if ($@) {
        XIMS::Debug( 3, "Could not load importer class: $@" );
        return;
    }
    ## use critic
    my $importer = $impclass->new( Provider   => $self->data_provider(),
                                   Parent     => $self->parent(),
                                   User       => $self->user(),
                                   ObjectType => $object_type,
                                   DataFormat => $data_format,
                                   Chroot     => $self->{Chroot},
                   );

    return $importer;
}

=head2 handle_container_metadata()

=head3 Parameter

    $object    :  Manadatory object to be checked for metadata

=head3 Returns

    $object    : Object instance with metadata set depending of availability of
                 metadata file

=head3 Description

Looks for $containerlocation.container.xml metadata files which get created by
the XIMS::Exporter and extracts metadata information from it.

Currently, 'title', 'keywords', 'abstract' and 'attributes' will be extracted.

=cut

sub handle_container_metadata {
    XIMS::Debug( 5, "called" );
    my ( $self, $object ) = @_;
    return unless defined $object;

    my $basexpath;
    my $metadata_filename;
    if ( $self->data_format->name() eq 'Container' ) {
        $metadata_filename
            = $object->location() . '/'
            . basename $object->location()
            . '.container.xml';
        $basexpath = '/document/context/object';
    }
    else {
        $metadata_filename
            = substr( $object->parent->location_path_relative(), 1 ) . '/'
            . basename $object->parent->location()
            . '.container.xml';
        $basexpath = '/document/context/object/children/object';
    }

    return unless -R $metadata_filename;

    my $doc = $self->parse_file($metadata_filename);
    return unless defined $doc;

    my $location_path = $object->parent->location_path()
        . '/'
        . basename $object->location();
    my %importmap = (
        title      => $basexpath . "[location_path='$location_path']/title",
        keywords   => $basexpath . "[location_path='$location_path']/keywords",
        abstract   => $basexpath . "[location_path='$location_path']/abstract",
        attributes => $basexpath . "[location_path='$location_path']/attributes",
        # TODO: maybe position-, user-, time- metadata here too?
    );

    foreach my $field ( keys %importmap ) {
        my $value = $doc->findvalue( $importmap{$field} );
        if ( defined $value and length $value ) {

            #warn "$field is $value";
            $object->$field($value);
        }
    }

    return $object;
}

=head2 get_strref()

=cut

sub get_strref {
    my $self = shift;
    my $file = shift;
    local $/ = undef;
    die "could not open $file: $!"
        unless -R $file and open( my $INPUT, '<', $file );
    my $contents = <$INPUT>;
    close $INPUT;
    return \$contents;
}

=head2 parse_file()

=cut

sub parse_file {
    my ( $self, $filename ) = @_;

    # Check if we already parsed that file and return DOM in case
    my $key = "_parsed_$filename";
    return $parsed_files{$key} if defined $parsed_files{$key};

    my $parser = XML::LibXML->new();
    my $doc;
    eval {
        $doc = $parser->parse_file($filename);
        XIMS::Debug( 4, "Parsed $filename" );
    };
    if ($@) {
        XIMS::Debug( 3, "Could not parse: $@" );
        return;
    }

    # Memoize and return
    return $parsed_files{$key} = $doc;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file or xims_importer's output for messages.

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

