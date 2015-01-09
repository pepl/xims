#!/usr/bin/env perl -w
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die
    "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n"
    unless -f "$xims_home/Makefile";
use lib ( $ENV{'XIMS_HOME'} || '/usr/local/xims' ) . "/lib";

use XIMS;
use XIMS::User;
use XIMS::Object;
use XIMS::ObjectPriv;
use XIMS::Term;
use Getopt::Std;

#use Data::Dumper;

my %args;
getopts( 'herd:u:p:l:g:', \%args );

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner("User Privilege Manager");

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{g} and $ARGV[0] ) {
    die usage();
}

my $user = $term->authenticate(%args);
die "Could not authenticate user '" . $args{u} . "'\n"
    unless $user and $user->id();

my $object = XIMS::Object->new(
    path           => $ARGV[0],
    marked_deleted => 0,
    User           => $user
);
die "Could not find object '" . $ARGV[0] . "'\n"
    unless $object and $object->id;

my $privmask = $user->object_privmask($object);
die "Access Denied. You do not have privileges to manage privileges for '"
    . $ARGV[0] . "'\n"
    unless $privmask and ( $privmask & XIMS::Privileges::GRANT() );

my @grantees;

foreach ( split( /\s*,\s*/, $args{g} ) ) {
    my $grantee = XIMS::User->new( name => $_ );
    die "Grantee '" . $_ . "' could not be found.\n"
        unless $grantee and $grantee->id();
    push @grantees, $grantee;
}

my $privnames = $args{l} || 'VIEW';
my $gprivmask;
if ( my $privlist = $args{l} ) {
    my @privileges = split ',', $privlist;
    my $tpriv;
    foreach my $priv (@privileges) {
        no strict 'refs';
        $tpriv = &{"XIMS::Privileges::$priv"};
        $gprivmask |= $tpriv if ( $tpriv and $tpriv > 0 );
    }
}
else {
    $gprivmask = XIMS::Privileges::VIEW;
}

my $method = 'grant';
$method = 'revoke' if $args{e};

my $path = $object->location_path();

my $total          = 0;
my $successful     = 0;
my $failed         = 0;
my $ungranted      = 0;
my $iterate_anyway = 0;

if ( $method eq 'grant' ) {
    my $ok = 1;

    foreach my $grantee (@grantees) {

        #$ok &=
        $object->grant_user_privileges(
            grantee  => $grantee,
            grantor  => $user,
            privmask => $gprivmask
        );
    }

    if ($ok) {
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

    my $ok = 1;

    foreach my $grantee (@grantees) {

        my $privs_object = XIMS::ObjectPriv->new(
            grantee_id => $grantee->id,
            content_id => $object->id()
        );
        $ok &= ( $privs_object and $privs_object->delete() );
    }

    if ($ok) {
        print "Revoked grantee(s)) from '$path'.\n";
        $successful++;
    }
    else {
        print "Could not revoke grantee(s) from '$path'.\n";
        $failed++;

        # for recursive revocation of grants if the upmost object itself
        # lacks the acl-entry to be removed
        $iterate_anyway = 1;
    }
    $total++;
}

if ( ( $successful or $iterate_anyway ) and $args{r} ) {
    my $desc_privmask;
    my $iterator = $object->descendants_granted(
        User           => $user,
        marked_deleted => 0
    );
    while ( my $desc = $iterator->getNext() ) {
        $desc_privmask = $user->object_privmask($desc);
        $path          = $desc->location_path();
        if ( $desc_privmask & XIMS::Privileges::GRANT() ) {
            if ( $method eq 'grant' ) {
                my $ok = 1;

                foreach my $grantee (@grantees) {
                    $ok &= $desc->grant_user_privileges(
                        grantee  => $grantee,
                        grantor  => $user,
                        privmask => $gprivmask
                    );
                }

                if ($ok) {
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
                my $ok = 1;
                foreach my $grantee (@grantees) {
                    my $privs_object = XIMS::ObjectPriv->new(
                        grantee_id => $grantee->id,
                        content_id => $desc->id()
                    );
                    $ok &= ( $privs_object and $privs_object->delete() );
                }

                if ($ok) {
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
            print
                "Insufficient privileges to $method privileges on '$path'.\n";
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
        -g Comma-separated list of grantee's usernames

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

__END__

=head1 NAME

xims_user_privileges.pl - changes object privileges

=head1 SYNOPSIS

xims_user_privileges.pl [-h][-d][-u username -p password] [-r] [-e] [-l privilege-list] -g grantee-username path-to-object-to-grant

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-r>

Recursively grant descendants.

=item B<-e>

If specified, all privileges of the grantee will be revoked instead of granted.

=item B<-l>

Comma-separated list of XIMS::Privileges to be granted, default is VIEW.
Example: -l MODIFY,PUBLISH

=item B<-g>

Comma-separated list of grantee's usernames.

=item B<-u>

The username to connect to XIMS. If not specified,
you will be asked for it interactively.

=item B<-p>

The password of the XIMS user. If not specified,
you will be asked for it interactively.

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut
