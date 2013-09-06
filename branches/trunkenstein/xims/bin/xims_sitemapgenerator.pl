#!/usr/bin/env perl
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Object;
use XIMS::Term;
use XML::LibXML;
use Time::Piece;
use Getopt::Std;

my %args;
getopts('hd:u:p:o:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "(Google) Sitemap Generation Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $ARGV[0] ) {
    die usage();
}

my $outputfile = $args{o};

my $now = localtime();

# for now, only go with the date
my $dateregex = qr/^(\d\d\d\d-\d\d-\d\d) \d\d:\d\d:\d\d$/;

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $object = XIMS::Object->new( path => $ARGV[0], marked_deleted => 0, User => $user );
die "Could not find object '".$ARGV[0]."'\n" unless $object and $object->id;

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to access '".$ARGV[0]."'\n" unless $privmask and ($privmask & XIMS::Privileges::VIEW());

my $siterooturl = $object->siteroot->url;

my $dom = XML::LibXML::Document->new();
my $root = $dom->createElementNS( 'http://www.sitemaps.org/schemas/sitemap/0.9', 'urlset' );
$dom->addChild($root);

append_path( $root, '' );
append_object( $root, $object );

my $dp = $object->data_provider();
my @dfs = ($dp->data_formats( mime_type => 'text/html' ), $dp->data_formats( mime_type => 'text/plain' ), $dp->data_formats( mime_type => 'application/pdf' ) );
my @df_ids = map { $_->id() } @dfs;

my $iterator = $object->descendants_granted(
        published => 1,
        data_format_id => \@df_ids,
        User           => $user,
        marked_deleted => 0
);

while ( my $desc = $iterator->getNext() ) {
    next if $desc->location eq '.diff_to_second_last';
    next if $desc->location eq 'robots.txt';

    # Skip symlinks|portlets that do not have a suffix in their location
    if ( $desc->symname_to_doc_id() and $desc->location !~ m#\.\w+$# ) {
        next;
    }

    append_object( $root, $desc );
}

if ( defined $outputfile ) {
    if ( $dom->toFile($outputfile) and system('gzip','-f','-9',$outputfile) == 0 ) {
        print "Wrote $outputfile.gz\n";
    }
    else {
        warn "Could not write $outputfile.gz\n";
    }
}
else {
    print $root->toString;
}

exit 0;

sub append_object {
    my ( $element, $object ) = @_;

    my ( $date ) = ( $object->last_publication_timestamp =~ $dateregex );

    my $path = $object->location_path_relative();
    $path =~ s#/index\.html(\..+)?$#/#;
    return unless length($path);

    $path = $siterooturl . $path;

    my $url = $dom->createElement('url');
    $url->appendTextChild( 'loc', $path );
    $url->appendTextChild( 'lastmod', $date );
    $element->addChild($url);

    return $url;
}

sub append_path {
    my ( $element, $path) = @_;

    my $url = $dom->createElement('url');
    $url->appendTextChild( 'loc', $siterooturl . $path );
    $url->appendTextChild( 'lastmod', $now->ymd );
    $element->addChild($url);

    return $url;
}


sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-o outputfile] path-to-object
        -o Optional path to gzipped output file
        -r Optional replacement string

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

xims_sitemapgenerator.pl

=head1 SYNOPSIS

xims_sitemapgenerator.pl [-h][-d][-u username -p password] [-o outputfile] path-to-object
        -o Optional path to gzipped output file

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen


=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-o>

Optional path to outputfile

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

