#!/usr/bin/perl -w
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::DataProvider;
use XIMS::ObjectType;
use XIMS::Exporter;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Published Documents title fixer" );

if ( $args{h} ) {
    print usage();
    exit;
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();

my $dp = XIMS::DataProvider->new();
my $ot  = XIMS::ObjectType->new( name => 'Document' );
my $iterator = $dp->objects( object_type_id => $ot->id(), published => 1 );
my $documentcount;
if ( defined $iterator and $documentcount = $iterator->getLength() ) {
    print "\nFound '" . $documentcount . "' published Documents.\n";
}
else {
    print "\nNo Documents found. Republishing with correct title.\n";
    exit 0;
}

die "No write access to '" . XIMS::PUBROOT() . "'.\n"  unless -d XIMS::PUBROOT() and -w XIMS::PUBROOT();

my $exporter = XIMS::Exporter->new( Basedir  => XIMS::PUBROOT(),
                                    User     => $user,
                                  );


my $updated = 0;
while ( my $object = $iterator->getNext() ) {
    if ( not $exporter->publish( Object => $object, User => $user, no_pubber => 1 ) ) {
        warn "Could not update '".$object->location_path()."'\n";
    }
    else {
        $updated++;
        print "Updated published title for '".$object->location_path(). "'.\n";
    }
}

print qq*
    Object update report:
        Total published Documents    $documentcount
        Updated document title       $updated
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


