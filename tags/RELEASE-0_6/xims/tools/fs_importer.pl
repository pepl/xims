#!/usr/bin/perl -w
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";
use lib ($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/lib",($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/tools/lib";

use XIMS::Importer::FileSystem;
use XIMS::Object;

use XIMS::Term;
use File::Basename;
use Getopt::Std;

# untaint path and env
$ENV{PATH} = '/bin'; # CWD.pm needs '/bin/pwd'
$ENV{ENV} = '';

my %args;
getopts('hd:u:p:m:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "File System Importer Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{m} and $ARGV[0] ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $parent = XIMS::Object->new( path => $args{m} );
die "Could not find object '".$args{m}."'\n" unless $parent and $parent->id();

my $privmask = $user->object_privmask( $parent );
die "Access Denied. You do not have privileges to create objects under '".$args{m}."'\n" unless $privmask and ($privmask & XIMS::Privileges::CREATE());

my $path = $ARGV[0];
die "Could not read '$path'\n" unless -f $path or -d $path;
die "Cannot import from symlink directory '$path'\n" if -l $path and -d $path;
# untaint the path
$path = $1 if $path =~ /^(.*)$/;

my @files = $term->findfiles( $path );
die "No files found, nothing to do.\n" unless scalar(@files);

my $importer = XIMS::Importer::FileSystem->new( User => $user, Parent => $parent );

my $successful = 0;
my $failed = 0;
$path = dirname $path;
if ( $path eq "." ) {
    $path = '';
}
else {
    chdir $path;
}
foreach my $file ( @files ) {
    $file =~ s/$path\/// if length $path;
    if ( $importer->import( $file ) ) {
        print "'$path/$file' imported successfully.\n";
        $successful++;
    }
    else {
        print "Import of '$path/$file' failed.\n";
        $failed++;
    }
}

my $total = scalar @files;
print qq*
    Import Report:
        Total files:            $total
        Successfully imported:  $successful
        Failed imports:         $failed

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] -m xims-mount-path path-to-import
        -m The XIMS path to import to.

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}



