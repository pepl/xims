#!/usr/bin/perl -w
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;
no warnings 'redefine';

use vars qw($dbuser $dbpassword);

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";
use lib ($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/lib",($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/tools/lib";

use XIMS::Object;
use XIMS::DataProvider;
use XIMS::DataFormat;
use XIMS::ObjectType;

use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "DocBookXML to sDocBookXML update" );

if ( $args{h} ) {
    print usage();
    exit;
}

if ( not ($args{u} and $args{p}) ) {
    print<<EOF;

Provide XIMS database authentification:

You will need a database user with update privileges to the dataformat
and objecttype tables. In a default XIMS installation this would be 'xims'
and not 'ximsrun' for example.


EOF
    $dbuser = $term->_prompt("Username",$args{u});
    $dbpassword = $term->_prompt("Password",undef,1);
}
else {
    $dbuser = $args{u};
    $dbpassword = $args{p};
}


my $dp;
eval {
    $dp = XIMS::DataProvider->new();
};
die "\nCould not authenticate database user '".$dbuser."'\n" unless defined $dp;

print warning();
print "Press enter to start.\n";<STDIN>;

my $admin = XIMS::User->new( name => 'admin' );

# update object-type and data-format names
my $df = XIMS::DataFormat->new( name => 'DocBookXML' );
die "Could not find dataformat 'DocBookXML'. Perhaps the update has already been run?!\n" unless $df;

$df->suffix( 'sdbk' );
$df->name( 'sDocBookXML' );
if ( $df->update() ) {
    print "DataFormat updated.\n";
}
else {
    die "Could not rename dataformat.\n";
}

my $ot = XIMS::ObjectType->new( name => 'DocBookXML' );
$ot->name( 'sDocBookXML' );
if ( $ot->update() ) {
    print "ObjectType updated.\n";
}
else {
    die "Could not rename objecttype.\n";
}

# rename existing objects with the old location
my @objects = $dp->objects( location => '%.dkb' );

my $total;
if ( defined @objects and scalar @objects > 0 ) {
    $total = scalar @objects;
    print "\nFound '" . $total . "' objects with the old .dkb suffix.\n";
}
else {
    print "\nNo objects with the old .dkb suffix found.\n";
    exit 0;
}

my $updated;
foreach my $object ( @objects ) {
    my $location = $object->location();
    $location =~ s/\.dkb$/.sdbk/;
    $object->location( $location );
    if ( $object->update( User => $admin ) ) {
        $updated++;
    }
    else {
        warn "Could not update object '" . $object->location_path . "'.\n";
    }
}

print qq*
    Object update report:
        Total .dkb objects   $total
        Updated to .sdbk     $updated

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

sub warning {
    return qq*

  $0 will rename 'DocBookXML' objecttype and dataformat to 'sDocBookXML' in your
  XIMS database. Furthermore, it will update the suffix 'dkb' to 'sdbk' and rename all
  existing objects with the old suffix.

*;
}

# fake the config
sub XIMS::Config::DBUser() { $dbuser }
sub XIMS::Config::DBPassword() { $dbpassword }
