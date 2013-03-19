#!/usr/bin/perl -w
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: fixup_publisheddocumentstitle.pl 1444 2006-03-26 21:39:26Z pepl $

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::DataProvider;
use XIMS::ObjectType;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Published gopublic Objects Privileges Fixer" );

if ( $args{h} ) {
    print usage();
    exit;
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();

my $dp = XIMS::DataProvider->new();
my @ots  = $dp->object_types( publish_gopublic => 1 );
my @ot_ids = map { $_->id() } @ots;

my $iterator = $dp->objects( object_type_id => \@ot_ids, published => 1 );
my $objectcount;
if ( defined $iterator and $objectcount = $iterator->getLength() ) {
    print "\nFound '" . $objectcount . "' published gopublic objects.\nGoing to update grants to the public user.\n\n";
}
else {
    print "\nNo published gopublic objects found.\n";
    exit 0;
}

my $updated = 0;
while ( my $object = $iterator->getNext() ) {
    my $privilege;

    if ( not $object->grant_user_privileges( grantee         => XIMS::PUBLICUSERID(),
                                             privilege_mask  => $privilege,
                                             grantor         => $user->id() ) ) {
        warn "Could not update privileges for '".$object->location_path()."'\n";
    }
    else {
        $updated++;
        print "Updated privileges for '".$object->location_path(). "'.\n";
    }
}

print qq*
    Object privilegesupdate report:
        Total published gopublic objects    $objectcount
        Updated object privileges           $updated

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


