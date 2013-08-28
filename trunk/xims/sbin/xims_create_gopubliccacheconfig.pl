#!/usr/bin/env perl
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xims_create_departmentroot.pl 1441 2006-03-26 18:40:45Z pepl $

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::DataProvider;
use XIMS::ObjectType;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:o:s:b:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Gopublic Cache Config Creator" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{b} ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();


my $outputdir = $args{o};
if ( defined $outputdir and ( ! -d $outputdir or ! -w $outputdir ) ) {
    die "$outputdir is not a directory or not writable.\n";
}
$outputdir .= "/" if (defined $outputdir and $outputdir !~ /\/$/ );

my $backend = $args{b};

my $location = $args{s};
if ( defined $location ) {
    $args{location} = $location;
}

my $dp = XIMS::DataProvider->new();
my $siterootot  = XIMS::ObjectType->new( name => 'SiteRoot' );

# SQLReport is currently the only object type, where AxNoCache has to be turned on
# Maybe we'll introduce an object type property for that later, currently explicitly
# check for SQLReport object type
my $sqlreportot  = XIMS::ObjectType->new( name => 'SQLReport' );

my @ots  = $dp->object_types( publish_gopublic => 1 );
# *Item Object Types will be handled by the location entries of their parent objects
my @ot_nonitems = grep { $_->name() !~ /Item$/ } @ots;
my @ot_ids = map { $_->id() } @ot_nonitems;

my $siteroots = $dp->objects( object_type_id => $siterootot->id(), published => 1, %args );

my $updated = 0;
while ( my $siteroot = $siteroots->getNext() ) {
    print "\nProcessing SiteRoot " . $siteroot->location() . "\n";
    my $iterator = $siteroot->descendants( object_type_id => \@ot_ids, published => 1  );
    my $objectcount;
    if ( defined $iterator and $objectcount = $iterator->getLength() ) {
        print "  Found '" . $objectcount . "' published gopublic objects.\n";
        my $file = $outputdir . $siteroot->location() . "-gopubliccache.conf";
        my $fh = IO::File->new( $file, 'w' );
        if ( not defined $fh ) {
            warn "Could not open $file for writing.\n";
            next;
        }
        while ( my $object = $iterator->getNext() ) {
            my $cache;
            $cache = 1 if $sqlreportot->id() == $object->object_type_id();
            print $fh config_string( $object, $backend, $cache);
        }
        $fh->close();
        print "  Wrote $file\n";
    }
    else {
        print "  No published gopublic objects found.\n";
    }
}

print "\n";
exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] -b backend-xims-server-url [-o outputdir] [-s siteroot_location ]

        -b URL of backend XIMS server.
        -o (optional) Output directory of config files.
        -s (optional) Location of a SiteRoot object which should be used for config
           generation. Per default, config files for all SiteRoots will be generated.

        -u The username to connect to the XIMS database. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS database user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

sub config_string {
    my $object = shift;
    my $backend = shift;
    my $nocache = shift;

    my $path_relative = $object->location_path_relative();
    my $path = $object->location_path();
    $backend =~ s#/$##;
    my $axnocache = defined $nocache ? '' : ' #';

    return qq{
<Location $path_relative>
    SetHandler axkit
    AxContentProvider Apache::AxKit::Provider::XIMSGoPublic
    AxIgnoreStylePI On
    AxAddPlugin Apache::AxKit::Plugin::QueryStringCache
   $axnocache AxNoCache On
    AxGzipOutput On
    AxResetProcessors
    AxResetPlugins
    AxResetStyleMap
    AxResetOutputTransformers
    AxAddStyleMap text/xsl Apache::AxKit::Language::Passthru
    PerlSetVar ProxyObject $backend/gopublic/content$path
</Location>
};

}

__END__

=head1 NAME

xims_create_gopubliccacheconfig.pl

=head1 SYNOPSIS

xims_create_gopubliccacheconfig.pl [-h][-d][-u username -p password] -b backend-xims-server-url [-o outputdir] [-s siteroot_location ]

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-b>

URL of backend XIMS server.

=item B<-o>

(optional) Output directory of config files.

=item B<-s>

(optional) Location of a SiteRoot object which should be used for config
generation. Per default, config files for all SiteRoots will be generated.

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
