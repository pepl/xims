#!/usr/bin/env perl -w
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: fixup_publisheddocumentstitle.pl 1444 2006-03-26 21:39:26Z pepl $

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::DataProvider;
use XIMS::ObjectType;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Sync department_id of ObjectRoot objects" );

if ( $args{h} ) {
    print usage();
    exit;
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();

my $dp = XIMS::DataProvider->new();
my @oroot_ots = $dp->object_types( is_objectroot => 1 );
my @oroot_otids = map { $_->id } @oroot_ots;

my $iterator = $dp->objects( object_type_id => \@oroot_otids );
my $objectcount;
if ( defined $iterator and $objectcount = $iterator->getLength() ) {
    print "\nFound '" . $objectcount . "' ObjectRoot objects.\n\n";
}
else {
    print "\nNo ObjectRoot objects found.\n";
    exit 0;
}

my $updated = 0;
my $skipped = 0;
while ( my $object = $iterator->getNext() ) {
    if ( $object->department_id() eq $object->document_id() and $object->id != 1 ) {
        my $department_id;
        if ( $object->parent_id() == 1 ) {
            $department_id = 1;
        }
        else {
            $department_id = $object->parent->department_id();
        }
        if ( not defined $department_id ) {
            warn "Could not get department id from parent of '" . $object->location_path() . "'. Skipping...\n";
            next;
        }
        $object->department_id( $department_id );
        if ( $object->update( User => $user, no_modder => 1 ) ) {
            $updated++;
        }
        else {
            warn "\nCould not update" . $object->location_path()  .".\n";
        }
    }
    else {
        $skipped++;
    }

}

print qq*
    department_id sync report:
        Total ObjectRoot objects                          $objectcount
        Synced department_id                              $updated
        Skipped objects, due to dept_id already in sync   $skipped

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password]

        -u The username to connect to the XIMS database. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS database user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}


