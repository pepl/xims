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

use vars qw( $total $successful $failed $ungranted );

use XIMS::Exporter;

use XIMS::Term;
use Getopt::Std;

# untaint path and env
$ENV{PATH} = '/bin'; # CWD.pm needs '/bin/pwd'
$ENV{ENV} = '';

my %args;
getopts('hd:u:p:m:ra', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Object Publisher" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $ARGV[0] ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $object = XIMS::Object->new( path => $ARGV[0], marked_deleted => undef, User => $user );
die "Could not find object '".$ARGV[0]."'\n" unless $object and $object->id;

# rebless to the object-type's class
$object = rebless( $object );

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to publish '".$ARGV[0]."'\n" unless $privmask and ($privmask & XIMS::Privileges::PUBLISH());

die "Option -a specified but object is not published.\n" if ( $args{a} and not $object->published() );
die "No write access to '" . XIMS::PUBROOT() . "'.\n"  unless -d XIMS::PUBROOT() and -w XIMS::PUBROOT();

my $exporter = XIMS::Exporter->new( Basedir  => XIMS::PUBROOT(),
                                    User     => $user,
                                  );

my $method = $args{m};
$method = 'publish';

$total = 0;
$successful = 0;
$failed = 0;
$ungranted = 0;

if ( $exporter->$method( Object => $object, User => $user ) ) {
    print "Object '" . $object->title . "' ".$method."ed successfully.\n";
    $total++;
    $successful++;
}
else {
    print "Could not $method object '" . $object->title . "'.\n";
    $total++;
    $failed++;
}

if ( $successful and $args{r} ) {
    my $republishonly = 1 if $args{a};
    recurse_children( $object, $user, $exporter, $method, $republishonly );
}

my $gid = (stat XIMS::PUBROOT())[5]; # after install, XIMS::PUBROOT is writable by the
                                     # apache-user's group
# because additional files like meta-data files or autoindices are created
# by the exporter, we have to recursively chgrp and 755 the file to the apache-user's group
foreach my $file ( $term->findfiles( XIMS::PUBROOT() . $object->location_path ) ) {
    # untaint the file
    unless ($file =~ m#^([\w.\-/\\_]+)$#) {
        die "filename '$file' has invalid characters.\n";
    }
    $file = $1;
    chown( $<, $gid, $file );
    chmod( 0775, $file );
}

print qq*
    Publish Report:
        Total files:                    $total
        Successfully exported:          $successful
        Failed exported:                $failed
        Missing publishing privileges:  $ungranted

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-a] [-m method -r] path-to-publish
        -m Currently, only 'publish' is implemented.
        -r Recursively publish descendants.
        -a If specified, published objects will be republished only

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

sub rebless {
    my $object = shift;
    my $otclass = "XIMS::" . $object->object_type->name();

    # load the object class
    eval "require $otclass;" if $otclass;
    if ( $@ ) {
        die "could not load object class $otclass: $@\n";
    }

    # rebless the object
    bless $object, $otclass;
    return $object;
}

sub recurse_children {
    my $object = shift;
    my $user = shift;
    my $exporter = shift;
    my $method = shift;
    my $republishonly = shift;

    my $privmask;
    my $path;
    my %args = (User => $user, marked_deleted => undef );
    $args{published} = 1 if defined $republishonly;
    foreach my $child ( $object->children_granted( %args ) ) {
        $privmask = $user->object_privmask( $child );
        $path = $child->location_path();
        if ( $privmask & XIMS::Privileges::PUBLISH() ) {
            if ( $exporter->$method( Object => $child, User => $user ) ) {
                print "Object '$path' ".$method."ed successfully.\n";
                $total++;
                $successful++;
                recurse_children( $child, $user, $exporter, $method, $republishonly );
            }
            else {
                print "could not $method object '$path'.\n";
                $total++;
                $failed++;
            }
        }
        else {
            print "no privileges to $method object '$path'.\n";
            $total++;
            $ungranted++;
        }
    }
}


