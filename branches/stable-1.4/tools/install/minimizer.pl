#!/usr/bin/perl
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Term;
use XIMS::Object;
use XIMS::User;
use XIMS::CSS;
use XIMS::Exporter;
use XIMS::Importer;
use Getopt::Std;
use File::Slurp qw( slurp write_file );
use File::Temp qw( tempfile );

my %args;
getopts('hd:y:v:f:o:t:p:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Minimization Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{y} and $args{f} and $args{o} and $args{t} and $args{p} ) {
    die usage();
}

my $yuicompressor = $args{y};
my $versionpostfix = $args{v};
$versionpostfix ||= get_timestamp();

my $type = $args{t};

my $path = $args{p}; #'/uniweb/stylesheets/css/10/';
my $user = XIMS::User->new( name => 'c10209' );

### minimize
my @files = split(',',$args{f});
my $outputfile = $args{o}.'-'.$versionpostfix.'.'.$type;
my $minimized;
foreach my $file ( @files ) {
            printf( "    Handling %s\n", XIMS::PUBROOT().$file);
            $minimized .= run_yuicompressor( XIMS::PUBROOT().$file );
        }
#warn $minimized;

#if ( write_file( XIMS::PUBROOT().$path.$outputfile, $minimized ) ) {
#                printf ("%s written successfully.\n", XIMS::PUBROOT().$path.$outputfile);
#            } 


### Create and import file
my $object;
if($type eq 'css'){
	$object = XIMS::CSS->new(
		User => $user,
		location => $outputfile,
		title => $outputfile,
		);
		
		$object ->body($minimized);
}
elsif($type eq 'js'){
	$object = XIMS::Javascript->new(
		User => $user,
		location => $outputfile,
		title => $outputfile,
		);
		
		$object ->body($minimized);
}
else {
	die usage();
}

my $parent = XIMS::Object->new( path => $path );
die "Could not find object '" . $path . "'\n"
          unless $parent and $parent->id();
          
my $importer = XIMS::Importer::Object->new( User => $user, Parent => $parent );
my $documentid = $importer->import($object);
        die "Could not import $outputfile" unless defined $documentid;
        print "Successfully created '$outputfile'.\n";

my $exporter = XIMS::Exporter->new( Basedir => XIMS::PUBROOT(), User => $user, );
if ( $exporter->publish( Object => $object, User => $user ) ) {
	print "Object '".$path.$outputfile."' published successfully.\n";
}
else {
	print "could not publish object '".$path.$outputfile."'.\n";
}

chown('nobody', 'nobody', XIMS::PUBROOT().$path.$outputfile) or die "chown() error: $!";
chmod(0644, XIMS::PUBROOT().$path.$outputfile) or die "chmod() error: $!";


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

sub get_timestamp {
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   $mon += 1;
   if ($mon < 10) { $mon = "0$mon"; }
   if ($hour < 10) { $hour = "0$hour"; }
   if ($min < 10) { $min = "0$min"; }
   if ($sec < 10) { $sec = "0$sec"; }
   $year=$year+1900;

   return $year . $mon . $mday . $hour. $min . $sec;
}


sub usage {
    return qq*

  Usage: $0 [-h][-d] -y yuicompressor.jar [-v version_postfix] -f inputfiles -o outputfile -t type
        -y Path to YUI compressor JAR
        -v Version postfix ( Used to version minimized files )
        -f comma separated list of input files
        -o outputfile
        -p path to outputfile
        -t type of files (css or js)

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

