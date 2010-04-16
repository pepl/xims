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
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Portlet column info fixer" );

if ( $args{h} ) {
    print usage();
    exit;
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();

my $dp = XIMS::DataProvider->new();
my $ot  = XIMS::ObjectType->new( name => 'Portlet' );
my $iterator = $dp->objects( object_type_id => $ot->id() );
my $portletcount;
if ( defined $iterator and $portletcount = $iterator->getLength() ) {
    print "\nFound '" . $portletcount . "' Portlets.\n";
}
else {
    print "\nNo Portlets found. Looking for out-dated column information.\n";
    exit 0;
}

my $updated = 0;
while ( my $object = $iterator->getNext() ) {
    my $body = $object->body();
    # "minor_status" is a relic of Paleo-XIMS times
    my $count = $body =~ s/column name="minor_status"/column name="status"/;
    # Because of a typo in old versions of XIMS::CGI::Portlet, *_lastname has been stored two times,
    # the second time meaning *_middlename. Fixing this here
    $count += $body =~ s/column name="created_by_lastname"/column name="created_by_middlename"/;
    $count += $body =~ s/column name="last_modified_by_lastname"/column name="last_modified_by_middlename"/;
    $count += $body =~ s/column name="owned_by_lastname"/column name="owned_by_middlename"/;
    if ( $count ) {
        $object->body( $body );
        if ( not $object->update( User => $user, no_modder => 1 ) ) {
            warn "Could not update '".$object->location_path()."'\n";
        }
        else {
            $updated++;
            print "Found and updated column information for '".$object->location_path(). "'.\n";
        }
    }

}

print qq*
    Object update report:
        Total Portlet objects        $portletcount
        Updated column information   $updated
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


