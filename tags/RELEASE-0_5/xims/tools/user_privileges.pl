#!/usr/bin/perl -w
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";
use lib ($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/lib",($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/tools/lib";

use XIMS::User;
use XIMS::Object;
use XIMS::ObjectPriv;

use XIMS::Term;
use Getopt::Std;

my %args;
getopts('herd:u:p:l:g:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "User Privilege Manager" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{g} and $ARGV[0] ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $object = XIMS::Object->new( path => $ARGV[0], marked_deleted => undef, User => $user );
die "Could not find object '".$ARGV[0]."'\n" unless $object and $object->id;

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to manage privileges for '".$ARGV[0]."'\n" unless $privmask and ($privmask & XIMS::Privileges::GRANT());

my $grantee = XIMS::User->new( name => $args{g});
die "Grantee '".$args{g}."' could not be found.\n" unless $grantee and $grantee->id();

my $privnames = $args{l} || 'VIEW';
my $gprivmask;
if ( my $privlist = $args{l} ) {
    my @privileges = split ',', $privlist;
    my $tpriv;
    foreach my $priv ( @privileges ) {
        no strict 'refs';
        $tpriv = &{"XIMS::Privileges::$priv"};
        $gprivmask |= $tpriv if ($tpriv and $tpriv > 0);
    }
}
else {
    $gprivmask = XIMS::Privileges::VIEW;
}

my $method = 'grant';
$method = 'revoke' if $args{e};

my $path = $object->location_path();

my $total = 0;
my $successful = 0;
my $failed = 0;
my $ungranted = 0;

if ( $method eq 'grant' ) {
    if ( $object->grant_user_privileges(
                                        grantee  => $grantee,
                                        grantor  => $user,
                                        privmask => $gprivmask
                                           )) {
        print "Granted $privnames on '$path'.\n";
        $successful++;
    }
    else {
        print "Could not grant $privnames on '$path'.\n";
        $total++;
    }
    $total++;
}
else {
    my $privs_object = XIMS::ObjectPriv->new( grantee_id => $grantee->id, content_id => $object->id() );
    if ( $privs_object and $privs_object->delete() ) {
        print "Revoked grantee from '$path'.\n";
        $successful++;
    }
    else {
        print "Could not revoke grantee from '$path'.\n";
        $failed++;
    }
    $total++;
}

if ( $successful and $args{r} ) {
    my $desc_privmask;
    foreach my $desc ( $object->descendants_granted( User => $user, marked_deleted => undef ) ) {
        $desc_privmask = $user->object_privmask( $desc );
        $path = $desc->location_path();
        if ( $desc_privmask & XIMS::Privileges::GRANT() ) {
            if ( $method eq 'grant' ) {
                if ( $desc->grant_user_privileges(
                                                grantee  => $grantee,
                                                grantor  => $user,
                                                privmask => $gprivmask
                                                  ) ) {
                    print "Granted $privnames on '$path'.\n";
                    $successful++;
                }
                else {
                    print "Could not grant $privnames on '$path'.\n";
                    $failed++;
                }
                $total++;
            }
            else {
                my $privs_object = XIMS::ObjectPriv->new( grantee_id => $grantee->id, content_id => $desc->id() );
                if ( $privs_object and $privs_object->delete() ) {
                    print "Revoked grantee from '$path'.\n";
                    $successful++;
                }
                else {
                    print "Could not revoke grantee from '$path'.\n";
                    $failed++;
                }
                $total++;
            }
        }
        else {
            print "Insufficient privileges to $method privileges on '$path'.\n";
            $total++;
            $ungranted++;
        }
    }
}

print qq*
    Publish Report:
        Total files:                    $total
        Successful:                     $successful
        Failed:                         $failed
        Insufficient privileges:        $ungranted

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-r] [-e] [-l privilege-list] -g grantee-username path-to-object-to-grant
        -r Recursively grant descendants.
        -e If specified, all privileges of the grantee will be revoked instead of granted.
        -l Comma-separated list of XIMS::Privileges to be granted, default is VIEW.
           Example: -l MODIFY,PUBLISH
        -g Username of the grantee

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}



