#!/usr/bin/env perl -w
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: fixup_publisheddocumentstitle.pl 1444 2006-03-26 21:39:26Z pepl $

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";
BEGIN{ $ENV{'XIMS_NO_XSLCONFIG'} = 1; } # don't attempt to write config.xsl
use XIMS;
use XIMS::DataProvider;
use XIMS::DataFormat;
use XIMS::URLLink;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:l:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Update HTTP status of URLLink objects" );

if ( $args{h} ) {
    print usage();
    exit;
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();
# TODO: Instead of only letting admins taste the sugar, check for write privileges per object

my $dp = XIMS::DataProvider->new();
my $urllink_df  = XIMS::DataFormat->new( name => 'URL' );

my $location_path = delete $args{l};

my %params = ( data_format_id => $urllink_df->id() );
$params{location_path} = "$location_path%" if defined $location_path;
my $iterator = $dp->objects( %params );
my $objectcount;
if ( defined $iterator and $objectcount = $iterator->getLength() ) {
    print "\nFound '" . $objectcount . "' URLLink objects.\n\n";
}
else {
    print "\nNo URLLink objects found.\n";
    exit 0;
}

my $updated = 0;
while ( my $object = $iterator->getNext() ) {
    bless $object, 'XIMS::URLLink'; # rebless
    print "Checking " . $object->location()  ." [id: " . $object->id() . "]";
    if ( $object->update_status( User => $user, no_modder => 1 ) ) {
        printf(" - %s\n", $object->status());
        $updated++;
    }
    else {
        warn "\nCould not update" . $object->location()  ." [" . $object->id() . "].\n";
    }
}

print qq*
    URLLink update statusreport:
        Total URLLink objects                             $objectcount
        Updated objects                                       $updated

*;

exit 0;

sub usage {
    return qq*

  Description:
        Tool to check and update the HTTP status of (VLibrary::)URLLink objects.

  Usage: $0 [-h][-d][-u username -p password] [-l location_path]
        -l If given, filters URLLink objects below that location_path


        -u The username to connect to the XIMS database. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS database user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}


