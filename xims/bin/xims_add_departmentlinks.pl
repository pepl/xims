#!/usr/bin/env perl
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Object;
use XIMS::DepartmentRoot;
use XIMS::SiteRoot;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:l:n', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Add DepartmentLinks" );

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

my $object = XIMS::Object->new( User => $user, path => $path, marked_deleted => 0 );
die "Could not find object '$path'.\n" unless $object and $object->id();

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to update '$path'.\n" unless $privmask and ($privmask & (XIMS::Privileges::CREATE() | XIMS::Privileges::WRITE()));

my $otname = $object->object_type->name();
die "Object is neither a DepartmentRoot nor a SiteRoot.\n" unless ($otname eq 'DepartmentRoot' or $otname eq 'SiteRoot');

bless $object, "XIMS::$otname";

my %param;
my @locations;
if ( $args{l} ) {
    @locations = split(',', $args{l});
}

$param{location} = \@locations unless $args{n};
$param{marked_deleted} = 0;
my @children = $object->children( %param );

if ( $args{n} ) {
    my @negativelist;
    foreach my $child ( @children ) {
        push( @negativelist, $child ) unless grep { $child->location eq $_ } @locations;
    }
    @children = @negativelist;
}

if ( $object->add_departmentlinks( @children ) ) {
    print "Successfully added Departmentlinks to '$path'.\n";
}
else {
    die "Could not add Departmentlinks.\n";
}

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-l comma-separated-list-of-locations [-n]] xims-path-to-department-|siteroot
        -l If given, this list of locations of the children of the Department- or SiteRoot will be
           used for creating the Departmentlinks. Optionally, -n can be specified, to negate that list.
           Per default, all children (except 'departmentlinks' and 'departmentlinks_portlet') will be added
           as DepartmentLinks.

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

        Example usage:
            $0 -u admin -l index.html,contact.html,about.html /foo.bar.tld
                Adds the children of /foo.bar.tld with the three specified locations
                as DepartmentLinks.

*;
}


__END__

=head1 NAME

xims_add_departmentlinks.pl - adds departmentlinks 

=head1 SYNOPSIS

xims_add_departmentlinks.pl [-h][-d][-u username -p password] [-l comma-separated-list-of-locations [-n]] xims-path-to-department-|siteroot

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-l>

If given, this list of locations of the children of the Department- or SiteRoot will be
used for creating the Departmentlinks. Optionally, -n can be specified, to negate that list.
Per default, all children (except 'departmentlinks' and 'departmentlinks_portlet') will be added
as DepartmentLinks.

=item B<-u>

The username to connect to XIMS. If not specified,
you will be asked for it interactively.

=item B<-p>

The password of the XIMS user. If not specified,
you will be asked for it interactively.

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=head1 EXAMPLE

xims_add_departmentlinks.pl -u admin -l index.html,contact.html,about.html /foo.bar.tld
                Adds the children of /foo.bar.tld with the three specified locations
                as DepartmentLinks.

Adds the children of /foo.bar.tld with the three specified locations
as DepartmentLinks.

=cut
