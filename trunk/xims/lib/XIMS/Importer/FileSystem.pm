
=head1 NAME

XIMS::Importer::FileSystem -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Importer::FileSystem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Importer::FileSystem;

use strict;
use base qw( XIMS::Importer );
use XIMS::DataFormat;
use XIMS::ObjectType;
use XIMS::Object;
use File::Basename;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

=head2 import()

=cut

sub import {
    my $self = shift;
    my $location = shift;
    my $updateexisting = shift;
    return unless $location;

    my $importer = $self->resolve_importer( $location );
    return unless $importer;

    my $object = $importer->handle_data( $location );

    return $self->SUPER::import( $object, $updateexisting );
}

=head2 handle_data()

=cut

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->object();
    $object->location( $location );
    $object->parent_id( $self->parent_by_location( $location )->document_id() );
    $object->data_format_id( $self->data_format->id() );

    return $object;
}

=head2 parent_by_location()

=cut

sub parent_by_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $dirname = dirname($location);
    my $plocation = $self->parent->location_path();
    $plocation .= '/' . $dirname if ( length $dirname and $dirname ne '.' );
    $plocation = '/root' unless (defined $plocation and $plocation);

    return XIMS::Object->new( path => lc($plocation) );
}

=head2 resolve_location()

=cut

sub resolve_location {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    XIMS::Debug( 6, "location: $location" );

    if ( -l $location ) {
        return ( XIMS::ObjectType->new( name => 'SymbolicLink' ), XIMS::DataFormat->new( name => 'SymbolicLink' ) );
    }
    elsif ( -f $location ) {
        return $self->resolve_filename( basename($location) );
    }
    elsif ( -d $location ) {
        return ( XIMS::ObjectType->new( name => 'Folder' ), XIMS::DataFormat->new( name => 'Container' ) );
    }
    else {
        die "could not resolve location '$location'. (we should not get there)";
    }
}

=head2 resolve_importer()

=cut

sub resolve_importer {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;
    return unless $location;

    my ($object_type, $data_format) = $self->resolve_location( $location );
    my $impclass = "XIMS::Importer::FileSystem::" . $object_type->fullname();
    eval "require $impclass;";
    if ( $@ ) {
        XIMS::Debug( 3 , "Could not load importer class: $@" );
        return;
    }
    my $importer = $impclass->new( Provider => $self->data_provider(),
                                   Parent => $self->parent(),
                                   User => $self->user(),
                                   ObjectType => $object_type,
                                   DataFormat => $data_format,
                                   );

    return $importer;
}

=head2 get_strref()

=cut

sub get_strref {
    my $self = shift;
    my $file = shift;
    local $/;
    die "could not open $file: $!" unless -R $file and open (INPUT, $file);
    my $contents = <INPUT>;
    close INPUT;
    return \$contents;
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

Copyright (c) 2002-2007 The XIMS Project.

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

