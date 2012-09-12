#!/usr/bin/perl -w
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Object;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Fix Children Positions" );
my $path = $ARGV[0];

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $path ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'.\n" unless $user and $user->id();

my $object = XIMS::Object->new( User => $user, path => $path );
die "Could not find object '$path'.\n" unless $object and $object->id();

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to modify '$path'.\n" unless $privmask and ($privmask & XIMS::Privileges::MODIFY());

my $iterator = $object->children( order => 'position', marked_deleted => undef );
my $i = 0;
while ( my $child = $iterator->getNext() ) {
    my $oldposition = $child->position();
    $child->position( ++$i );
    if ( $child->update( User => $user, no_modder => 1 ) ) {
        print "Updated position of '" . $child->title . "' from $oldposition to " . $child->position() . ".\n";
    }
    else {
        warn "Could not update position of '" . $child->location_path . "'.\n";
    }
}

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] xims-path-to-container

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

fix_children_positions.pl

=head1 SYNOPSIS

fix_children_positions.pl [-h][-d][-u username -p password] xms-path-to-container

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

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
