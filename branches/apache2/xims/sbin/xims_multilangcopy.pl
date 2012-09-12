#!/usr/bin/perl -w
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::DataProvider;
use XIMS::ObjectType;
use XIMS::Document;
use XIMS::Exporter;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:l:s:t:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Create copies of documents for language content negotiation" );

if ( not (defined $args{l} and defined $args{s} and defined $args{t})
     or not ($args{s} =~ /[a-zA-Z]{2}/ and $args{t} =~ /[a-zA-Z]{2}/ ) # only dealing with two letter lang codes for now 
     or $args{h} ) {
    print usage();
    exit;
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();

my $sourcelangsuffix = $args{s};
my $targetlangsuffix = $args{t};

die "No write access to '" . XIMS::PUBROOT() . "'.\n"  unless -d XIMS::PUBROOT() and -w XIMS::PUBROOT();
my $dp = XIMS::DataProvider->new();
my $exporter = XIMS::Exporter->new(
    Provider => $dp,
    Basedir  => XIMS::PUBROOT(),
    User     => $user,
);
die "Could not instantiate Exporter.\n" unless defined $exporter;

my $document_ot  = XIMS::ObjectType->new( fullname => 'Document' );
my $location_path = delete $args{l};
my $iterator = $dp->objects( location_path => "$location_path%", object_type_id => $document_ot->id(), marked_deleted => 0 );
my $objectcount;
if ( defined $iterator and $objectcount = $iterator->getLength() ) {
    print "\nFound '" . $objectcount . "' Document objects.\n\n";
}
else {
    print "\nNo Document objects found.\n";
    exit 0;
}

my $updated = 0;
while ( my $object = $iterator->getNext() ) {
    bless $object, 'XIMS::Document'; # rebless

    my $orig_location_path = $object->location_path(); 

    my $copyobject;
    my $copysuccess;
    my $movesuccess;
    my $publishsuccess;

    # Skip Document which are already prepared for content negotation
    if ( $object->location() =~ /\.html\..+$/ ) {
        printf("Skipping %s [id: %d]\n", $orig_location_path, $object->id());
        next;
    }

    printf("Updating %s [id: %d]\n", $orig_location_path, $object->id());

    my $copytargetlocation = $object->location().'.'.$targetlangsuffix;
    printf("  Copying '%s' to '%s'", $object->location(), $copytargetlocation  );

    # Update the title so people will quickly see the difference in the object browser
    my $origtitle = $object->title();
    $object->title( $origtitle . " [$targetlangsuffix]" );

    $copyobject = $object->copy( target => $object->parent_id(),
                                 target_location => $copytargetlocation,
                                 dontcleanlocation => 1,
                                 User => $user, );
    $object->title( $origtitle );

    if ( defined $copyobject ) {
        print " - success\n";
        $copysuccess = 1;
    }
    else {
        print " - failed\n";
    }  

    my $movetargetlocation = $object->location().'.'.$sourcelangsuffix;
    printf("  Moving '%s' to '%s'", $object->location(), $movetargetlocation  );
    if ( rename_object( $object, $movetargetlocation, $user ) ) {
        print " - success\n";        
        $movesuccess = 1;
    }
    else {
        print " - failed\n";
    }  
    
    if ( $object->published() ) {
        my $published = 0;
        if ( $exporter->publish(
                Object                 => $object,
                no_dependencies_update => 1, ) ) {
            printf("  Republished '%s'\n", $object->location() );
            $published++;
        }
        else {
            printf("  Could not republish '%s'\n", $object->location() );
        }
        if ( $exporter->publish(
                Object                 => $copyobject, ) ) {
            printf("  Published '%s'\n", $copyobject->location() );
            $published++;
        }
        else {
            printf("  Could not publish '%s'\n", $copyobject->location() );
        }

        # Fix file system privs of newly published files
        # and remove the originally published file if publishing of both language copies
        # has been successful
        if ( $published == 2 ) {
            fix_privs( $copyobject->location_path() );
            fix_privs( $object->location_path() );
            system('rm','-rf',XIMS::PUBROOT().$orig_location_path) == 0
                or warn "Could not remove old published object '".XIMS::PUBROOT().$orig_location_path."'\n";
        }
    }
    if ( $copysuccess and $movesuccess ) {
        $updated++;
    }
}

print qq*
    Document lang copier status report:
        Total Document objects                $objectcount
        Updated objects                       $updated

*;

exit 0;

sub fix_privs {
    my $location_path = shift;
    
    my @pubrootstat = stat XIMS::PUBROOT();
    my $uid = $pubrootstat[4]; # after install, XIMS::PUBROOT is owned by the apache-user
    my $gid = $pubrootstat[5];
    system('chown',$uid.':'.$gid,XIMS::PUBROOT().$location_path) == 0
        or warn "Could not chown ".XIMS::PUBROOT() . $location_path.".\n";
    system('chmod','g+w',XIMS::PUBROOT().$location_path) == 0
           or warn "Could not chown ".XIMS::PUBROOT() . $location_path.".\n";
}

sub rename_object {
    my $object = shift;
    my $targetlocation = shift;
    my $user = shift;

    $object->location( $targetlocation );
    if ( scalar $object->update( User => $user, no_modder => 1 ) ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub usage {
    return qq*

  Description:
        Tool to create copies of documents to be used for server side language content
        negotiation.
        
        Copies \$location.html to \$location.html.\$targetlang and
        Moves \$location.html to \$location.html.\$sourcelang

  Usage: $0 [-h][-d][-u username -p password] -l location_path -s source_lang -t target_lang 
        -l Path from there the tree will be traversed looking for Document objects
        -s Source language suffix (2 characters, eg 'de') of the Documents which currently exist as .html
        -t Target language suffix (2 characters, eg 'en') to which source documents will be copied to


        -u The username to connect to the XIMS database. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS database user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}


