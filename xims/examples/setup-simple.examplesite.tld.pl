#!/usr/bin/env perl -w
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::User;
use XIMS::Term;
use XIMS::SiteRoot;
use XIMS::Folder;

my $adminpwd = '_adm1nXP';
my $importdir = 'simple.examplesite.tld';
my $siterooturl = "http://$importdir";
my $deptlinks = "index.html,about.html,team.html,contact.html";

my $term = XIMS::Term->new( debuglevel => 2 );

print "\nThis script will set up $importdir. If you have changed the admin password,
also adapt the change in this script for the import to work.

Press enter to continue.\n";
getc;

my $user = XIMS::User->new( name => 'admin' );
die "Could not find 'admin' user, aborting.\n" unless ( defined $user and $user->id() );

my $object = XIMS::SiteRoot->new( User => $user, path => "/$importdir", marked_deleted => undef );
if ( defined $object and defined $object->id() ) {
    print "'$importdir' has already been imported. Press enter to continue and re-import.\n";
    getc;
}

system("$xims_home/bin/xims_importer.pl -u admin -p $adminpwd -f -m /root $xims_home/examples/$importdir") == 0 || die "Could not import $importdir\n";
system("$xims_home/sbin/xims_folder_to_objectroot.pl -u admin -p $adminpwd -s $siterooturl /$importdir") == 0 || die "Could not convert $importdir to SiteRoot\n";
system("$xims_home/bin/xims_add_departmentlinks.pl -u admin -p $adminpwd -l $deptlinks /$importdir") == 0 || die "Could not add DepartmentLinks to $importdir\n";
system("$xims_home/bin/xims_publisher.pl -u admin -p $adminpwd -r /$importdir") == 0 || die "Could not publish $importdir\n";

$object = XIMS::SiteRoot->new( User => $user, path => "/$importdir", marked_deleted => undef );
if ( defined $object and defined $object->id() ) {
    my $pubstyledir = XIMS::Folder->new( User => $user, path => "/$importdir/pubstylesheets", marked_deleted => undef );
    if ( defined $pubstyledir and defined $pubstyledir->id() ) {
        $object->style_id( $pubstyledir->id() );
        $object->update();
        print "Assigned 'pubstylesheets' folder as stylesheet folder for publishing preview and goxims-based events.\n";
    }
    else {
        warn "Could not find '/$importdir/pubstylesheets'\n";
    }
}

