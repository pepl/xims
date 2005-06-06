#!/usr/bin/perl -w
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib",($ENV{'XIMS_HOME'} || '/usr/local/xims')."/tools/lib";

use XIMS::Exporter;
use XIMS::ObjectType;

use XIMS::Term;
use Getopt::Std;

# untaint path and env
$ENV{PATH} = '/bin'; # CWD.pm needs '/bin/pwd'
$ENV{ENV} = '';

my %args;
getopts('hd:u:f:t:a', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Object Mover" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{f} and $args{t} ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $object = XIMS::Object->new( path => $args{f}, marked_deleted => undef, User => $user );
die "Could not find object '".$args{f}."'\n" unless $object and $object->id;

my $oldpath = $object->location_path_relative();

if ( $object->published() ) {
    die "No write access to '" . XIMS::PUBROOT() . "'.\n"  unless -d XIMS::PUBROOT() and -w XIMS::PUBROOT();
}

my $target = XIMS::Object->new( path => $args{t}, marked_deleted => undef, User => $user );
die "Could not find object '".$args{t}."'\n" unless $target and $target->id;

die "Target and Parent are the same, aborting\n" if $object->parent_id() == $target->document_id();

# rebless to the object-type's class
$object = rebless( $object );

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to move '".$args{f}."'\n" unless $privmask and ($privmask & XIMS::Privileges::MOVE());

$privmask = $user->object_privmask( $target );
die "Access Denied. You do not have privileges to move '".$args{f}."' to '".$args{t}."'\n" unless $privmask and ($privmask & XIMS::Privileges::CREATE());

die "Could not move object.\n" unless scalar $object->move( target => $target->document_id() );
print "Object moved.\n";

my $newpath = $object->location_path_relative();

my @dfs = $object->data_provider->data_formats( mime_type => 'text/%' );
my @ids = map { $_->id } @dfs;

my $urllink_otid = XIMS::ObjectType->new( name => 'URLLink' )->id();

my $iter = $object->descendants( data_format_id => \@ids );
if ( defined $iter and $iter->getLength > 0 ) {
    print "Checking links in descendants.\n";
    while ( my $desc = $iter->getNext() ) {
        next if $desc->location_path() =~ /__stats\/[0-9]/;

        if ( $desc->object_type_id == $urllink_otid ) {
            my $location = $desc->location();
            my $count = $location =~ s/$oldpath/$newpath/g;
            if ( $count ) {
                $desc->location( $location );
                if ( scalar $desc->update( User => $user, no_modder => 1 ) ) {
                    print "Replaced location of '".$desc->location_path()."'.\n";
                }
                else {
                    warn "Could not update '".$desc->location_path()."'\n";
                }
            }
        }

        my $body = $desc->body();
        next unless defined $body;

        my $count = $body =~ s/$oldpath/$newpath/g;
        if ( $count ) {
            $desc->body( $body );
            if ( scalar $desc->update( User => $user, no_modder => 1 ) ) {
                print "Replaced '$count' occurences in '".$desc->location_path()."'.\n";
            }
            else {
                warn "Could not update '".$desc->location_path()."'\n";
            }
        }
    }
}

if ( $object->published() ) {
    unless ( $args{a} ) {
        print "Republishing '" . $object->location_path() . "'\n";
        system("$xims_home/tools/publisher.pl",'-u',$args{u},'-a','-f','-r',$object->location_path()) == 0
            or die "Could not republish '".$object->location_path()."': $?\n.";
    }
    else {
        print "Unpublishing object and descendants.\n";
        my $iter = $object->descendants();
        if ( defined $iter and $iter->getLength > 0 ) {
            while ( my $desc = $iter->getNext() ) {
                $desc->unpublish( User => $user );
            }
        }
        $object->unpublish( User => $user );
    }

    print "Removing old published object and descendants.\n";
    system('rm','-rf',XIMS::PUBROOT().$args{f}) == 0
        or die "Could not remove old published object '".XIMS::PUBROOT().$args{f}."'\n";
}

exit 0;


sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-a] -f path_to_object_to_move -t move_target
        -f Path to object to be moved
        -t Path to target container
        -a If given, object and possible descendants will be be unpublished after moving

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
    my $otclass = "XIMS::" . $object->object_type->fullname();

    # load the object class
    eval "require $otclass;" if $otclass;
    if ( $@ ) {
        die "Could not load object class $otclass: $@\n";
    }

    # rebless the object
    bless $object, $otclass;
    return $object;
}


