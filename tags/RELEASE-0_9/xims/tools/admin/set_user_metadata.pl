#!/usr/bin/perl -w
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib",($ENV{'XIMS_HOME'} || '/usr/local/xims')."/tools/lib";

use XIMS::User;
use XIMS::Object;

use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hrd:u:p:c:o:l:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "User Metadata Manager" );

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

die "Access Denied. Currently, only admins are allowed to manage user metadata.\n" unless $user->admin();

my $owner = XIMS::User->new( name => $args{o});
die "User '".$args{o}."' could not be found.\n" if $args{o} and not ($owner and $owner->id());

my $creator = XIMS::User->new( name => $args{c});
die "User '".$args{c}."' could not be found.\n" if $args{c} and not ($creator and $creator->id());

my $lmodifier = XIMS::User->new( name => $args{l});
die "User '".$args{l}."' could not be found.\n" if $args{l} and not ($lmodifier and $lmodifier->id());

my $path = $object->location_path();

my $total = 0;
my $successful = 0;
my $failed = 0;

$object->owner( $owner ) if $args{o};
$object->creator( $creator ) if $args{c};
$object->last_modifier( $lmodifier ) if $args{l};

if ( $object->update( User => $user, no_modder => 1 ) ) {
    print "Set user metadata for '$path'.\n";
    $successful++;
}
else {
    print "Could not set user metadata for '$path'.\n";
    $failed++;
}
$total++;

if ( $args{r} ) {
    foreach my $desc ( $object->descendants( User => $user, marked_deleted => undef ) ) {
        $path = $desc->location_path();
        $desc->owner( $owner ) if $args{o};
        $desc->creator( $creator ) if $args{c};
        $desc->last_modifier( $lmodifier ) if $args{l};
        if ( $desc->update( User => $user, no_modder => 1 ) ) {
            print "Set user metadata for '$path'.\n";
            $successful++;
        }
        else {
            print "Could not set user metadata for '$path'.\n";
            $failed++;
        }
        $total++;
    }
}

print qq*
    User Metadata Report:
        Total files:                    $total
        Successful:                     $successful
        Failed:                         $failed

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-r] [-o owner] [-c creator] [-l last-modifier] path-to-object
        -r Recursively set user metadata.
        -o Username of the owner
        -c Username of the creator
        -l Username of the last modifier

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}



