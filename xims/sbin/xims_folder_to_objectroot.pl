#!/usr/bin/env perl
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Object;
use XIMS::ObjectType;
use XIMS::DataFormat;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:s:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Folder to Site|Department-Root Converter" );
my $path = $ARGV[0];

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $path ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'.\n" unless ($user and $user->id());

my $object = XIMS::Object->new( User => $user, path => $path );
die "Could not find object '$path'.\n" unless ($object and $object->id());

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to modify '$path'.\n" unless ($privmask and ($privmask & XIMS::Privileges::MODIFY()));

my $folder_ot = XIMS::ObjectType->new( name => 'Folder' );
die "Object '$path' is not a Folder.\n" unless ($object->object_type_id() == $folder_ot->id());

my $objroot_name = $args{s} ? 'SiteRoot' : 'DepartmentRoot';
my $objroot_ot = XIMS::ObjectType->new( name => $objroot_name );
die "Could not resolve object type for ObjectRoot (should not happen).\n" unless $objroot_ot;
my $objroot_df = XIMS::DataFormat->new( name => $objroot_name );
die "Could not resolve data format for ObjectRoot (should not happen).\n" unless $objroot_df;

# Convert the folder
$object->object_type_id( $objroot_ot->id() );
$object->data_format_id( $objroot_df->id() );
$object->title( $args{s} ) if $args{s};
die "Could not convert '$path'.\n" unless $object->update( User => $user );
print "'$path' converted to $objroot_name";
print ", SiteRoot URL set" if $args{s};
print ".\n";

# Update the department_id of descendants
my $iterator = $object->descendants( department_id => $object->department_id() );

# Exit if no descendant has to be updated
exit 0 unless defined $iterator;

while ( my $descendant = $iterator->getNext() ) {
    $descendant->department_id( $object->document_id() );
    if ( $descendant->update( User => $user, no_modder => 1 ) ) {
        print "Updated department_id of '" . $descendant->title . "'.\n";
    }
    else {
        warn "Could not update department_id of '" . $descendant->location_path . "'.\n";
    }
}

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-s SiteRootURL] xims-path-to-folder
        -s If given, the folder will be converted to a SiteRoot instead of
           a DepartmentRoot and the SiteRootURL will be set.

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}


__END__

=head1 NAME

xims_folder_to_objectroot.pl

=head1 SYNOPSIS

xims_folder_to_objectroot.pl [-h][-d][-u username -p password] [-s SiteRootURL] xims-path-to-folder

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-s>

If given, the folder will be converted to a SiteRoot instead of
a DepartmentRoot and the SiteRootURL will be set.

=item B<-u>

The username to connect to XIMS. If not specified,
you will be asked for it interactively.

=item B<-p>

The password of the XIMS user. If not specified,
you will be asked for it interactively.

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut
