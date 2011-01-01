#!/usr/bin/perl
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::Term;
use Getopt::Std;
use File::Slurp qw( slurp write_file );
use File::Temp qw( tempfile );

my %args;
getopts('hd:y:v:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "JS/CSS Minimization Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{y} ) {
    die usage();
}

my $yuicompressor = $args{y};
my $versionpostfix = $args{v};
$versionpostfix ||= '';

my %sources = ( 
    js => { min => [ qw( scripts/default.js skins/2punkt0/scripts/2punkt0.js ) ],
    },
    css => { min => [qw(skins/2punkt0/stylesheets/common.css skins/2punkt0/stylesheets/content.css skins/2punkt0/stylesheets/sprites.css skins/2punkt0/stylesheets/menu.css) ],
    }
); 
my $basedir = $xims_home . '/www/ximsroot/';
my $outputbasedir = $xims_home . '/www/ximsroot/skins/2punkt0/';
my %typedirmapping = ( js => 'scripts', css => 'stylesheets' );

foreach my $type ( keys %sources ) {
    printf( "Going to process %s files\n", $type);
    while (my($target, $files) = each %{$sources{$type}}) {
        my $minimized;
        foreach my $file ( @$files ) {
            printf( "    Handling %s\n", $file);
            $minimized .= run_yuicompressor( $basedir.$file );
        }
        if ( length($minimized) ) {
            my $outputfile = $outputbasedir.$typedirmapping{$type}.'/'.$target.$versionpostfix.'.'.$type;
            if ( write_file( $outputfile, $minimized ) ) {
                printf ("%s written successfully.\n", $outputfile);
            }
            else {
                warn "Could not write $outputfile\n: $!\n";
            }
        }
    } 
}

File::Temp::cleanup();

exit 0;

sub run_yuicompressor {
    my ($inputfile)= @_;

    my ($fh, $tempfile) = tempfile();
    my $cmd= sprintf('java -jar %s -o %s %s', $args{y}, $tempfile, $inputfile);
    my $text;
    if ( system($cmd) == 0 ) {;
        $text = slurp( $tempfile ) ;
    }
    return $text;
}

sub usage {
    return qq*

  Usage: $0 [-h][-d] -y yuicompressor.jar [-v version_postfix] 
        -y Path to YUI compressor JAR
        -v Version postfix ( Used to version minimized files )

        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

__END__

=head1 NAME

xims_minimize_jscss.pl

=head1 SYNOPSIS

xims_minimize_jscss.pl [-h][-d] -y yuicompressor.jar [-v version_postfix] 
        -y Path to YUI compressor JAR
        -v Version postfix ( Used to version minimized files )

        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen


=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-y>

Path to YUI compressor JAR - http://developer.yahoo.com/yui/compressor/

=item B<-v>

Optional version postfix which will be appended to the filenames of the minimized files.
Useful if the css and js files will be served with a far future Expires header

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut

