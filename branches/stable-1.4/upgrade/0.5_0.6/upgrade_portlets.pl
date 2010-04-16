#!/usr/bin/perl -w
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;
no warnings 'redefine';

use vars qw($dbuser $dbpassword);

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib",($ENV{'XIMS_HOME'} || '/usr/local/xims')."/tools/lib";

use XIMS::Object;
use XIMS::DataProvider;
use XIMS::DataFormat;
use XIMS::ObjectType;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Portlet update" );

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

my $exporter;
eval {
   require XIMS::Exporter;
   $exporter = XIMS::Exporter->new( Provider => $dp,
                                    Basedir  => XIMS::PUBROOT(),
                                    User     => $admin
                                  );
     };
die "Could not instantiate Exporter\n" unless $exporter;

# update object-type and data-format names
my $df = XIMS::DataFormat->new( name => 'Portlet' );
die "Could not find dataformat 'Portlet'.\n" unless $df;

$df->suffix( 'ptlt' );
if ( $df->update() ) {
    print "DataFormat updated.\n";
}
else {
    die "Could not update DataFormat.\n";
}


my $ot  = XIMS::ObjectType->new( name => 'Portlet' );
my $ot_id = $ot->id();

# rename existing objects with the old location
my @objects = $dp->objects( object_type_id => $ot_id,  );

my $total;
if ( defined @objects and scalar @objects > 0 ) {
    $total = scalar @objects;
    print "\nFound '" . $total . "' Portlets.\n";
}
else {
    print "\nNo Portlets found.\n";
    exit 0;
}

my $updated = 0;
my $republished = 0;

foreach my $object ( @objects ) {

    my $location = $object->location();
    next if $location =~ /\.ptlt/;

    my $need_repub = 0;

    if ( $object->published() ) {
        print "Object '" . $object->location_path . "' is published, will be republished with the new name.\n";
        $need_repub = 1;
        $exporter->unpublish();
    }

    $location .= '.ptlt';
    $object->location( $location );
    if ( $object->update( User => $admin ) ) {
        $updated++;
        warn $object->location_path . ".\n";
    }
    else {
        warn "Could not update object '" . $object->location_path . "'.\n";
    }

    if ( $need_repub ) {  $exporter->publish(); $republished++; }

}

print qq*
    Object update report:
        Total Portlet objects   $total
        Updated to .ptlt        $updated
        Republished             $republished

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

  $0 will update the 'Portlet' dataformat in your XIMS
  database. Furthermore, it will add the suffix 'ptlt' to existing and republish published portlets.

*;
}

# fake the config
sub XIMS::Config::DBUser() { $dbuser }
sub XIMS::Config::DBPassword() { $dbpassword }
