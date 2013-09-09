#!/usr/bin/env perl
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Importer::FileSystem;
use XIMS::Object;
use XIMS::Term;
use File::Basename;
use Getopt::Std;

# untaint path and env
$ENV{PATH} = '/bin:/usr/bin'; # older versions of CWD.pm need 'pwd'
$ENV{ENV} = '';

my $autoindex = XIMS::AUTOINDEXFILENAME();
my $skippattern = qr{
     $autoindex           # auto index files
    | ^ou\.xml$           # object root files (DepartmentRoot|SiteRoot)
    | \.container.xml$    # Container metadata files
}x;

my %args;
getopts('hafd:u:p:m:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "File System Importer Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{m} and $ARGV[0] ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $parent = XIMS::Object->new( path => $args{m} );
die "Could not find object '".$args{m}."'\n" unless $parent and $parent->id();

my $privmask = $user->object_privmask( $parent );
die "Access Denied. You do not have privileges to create objects under '".$args{m}."'\n" unless $privmask and ($privmask & XIMS::Privileges::CREATE());

my $path = $ARGV[0];
die "Could not read '$path': $!\n" unless (-R $path && -f $path or -d $path);
die "Cannot import from symlink directory '$path'\n" if -l $path and -d $path;
# untaint the path
$path = $1 if $path =~ /^(.*)$/;

my $importer = XIMS::Importer::FileSystem->new( User => $user,
                                                Parent => $parent,
                                                ArchiveMode =>  $args{a}
               );

my $successful = 0;
my $failed = 0;
my $dirname = dirname $path;
if ( $dirname eq "." ) {
    $dirname = '';
}
else {
    chdir $dirname;
}
my $displaydir = $dirname;
if ( length $displaydir ) {
    $displaydir .= '/' unless $displaydir =~ /\/$/;
}

my @files = $term->findfiles( $path );
die "No files found, nothing to do.\n" unless scalar(@files);

my $total = scalar @files;
foreach my $file ( @files ) {
    if ( skipfile( $file ) ) {
        XIMS::Debug( 4, "Skipping $file");
        $total--;
        next;
    }

    $file =~ s/$dirname\/// if length $dirname;
    if ( $importer->import( $file, $args{f} ) ) {
        print "'$displaydir$file' imported successfully.\n";
        $successful++;
    }
    else {
        print "Import of '$displaydir$file' failed.\n";
        $failed++;
    }
}

print qq*
    Import Report:
        Total files:            $total
        Successfully imported:  $successful
        Failed imports:         $failed

*;

exit 0;

sub skipfile {
    my ($location) = @_;
 
    my $filename = basename $location;
    if ( $filename =~ /$skippattern/ ) {
        return 1;
    }
    return 0;
}

sub usage {
    return qq*

  Usage: $0 [-h][-d][-f][-a][-u username -p password] -m xims-mount-path path-to-import
        -m The XIMS path to import to.
        -a Archive mode. Treat .html as file and keep the location's capitalisation.
        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -f Update existing objects. If not set, the importer will skip objects
           that already exist with the same location in a container.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}


__END__

=head1 NAME

xims_importer.pl - imports large numbers of documents

=head1 SYNOPSIS

xims_importer.pl [-h][-d][-f][-a][-u username -p password] -m xims-mount-path path-to-import

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-a>

 Archive mode. Treat .html as file and keep the location's capitalisation.

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

xims_importer.pl -u admin -l index.html,contact.html,about.html /foo.bar.tld
    Adds the children of /foo.bar.tld with the three specified locations
    as DepartmentLinks.

=cut
