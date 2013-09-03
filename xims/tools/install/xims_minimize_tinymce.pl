#!/usr/bin/env perl
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

our $cwd = get_cwd();
my %args;
getopts('hd:p:l:t:y', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "TinyMCE Minimization Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

$args{y} ||= sprintf('%s/tools/install/yuicompressor-current.jar', $xims_home);
my $yuicompressor = $args{y};

# Custom extra javascripts to pack
my @custom_files = qw();

my %modules = (
         custom_files => \@custom_files,
         ( map { $_ => [ split( ',', $args{$_} ) ] } qw(p l t) )
);
my $js_file = 'tiny_mce_min.js';

my $outputbasedir = $xims_home .'/www/ximsroot/vendor/tinymce3/jscripts/tiny_mce/';
my $outputfile = $outputbasedir.$js_file;

my $data = generate_data(\%modules, $outputbasedir);
write_file( $outputfile, $data ); 

printf( "    Handling %s\n", $js_file);
            my $minimized = run_yuicompressor( $outputbasedir.$js_file );

if ( write_file( $outputfile, $minimized ) ) {
                printf ("%s written successfully.\n", $outputfile);
            }
            else {
                warn "Could not write $outputfile\n: $!\n";
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

#===================================
sub generate_data {
#===================================
    my $modules  = shift;
    my $outputbasedir = shift;
    my $suffix   = '';

    # Core file plus langs
    my @langs = @{ $modules->{l} };
warn "langs : ".$langs[0].", ".$langs[1];
    my $js_data = join( '', map { slurp_file( $outputbasedir.'langs', "$_.js" ) } @langs );

    # Themes plus their langs
    foreach my $theme ( @{ $modules->{t} } ) {
        $js_data
            .= slurp_file( $outputbasedir.'themes', $theme, "editor_template${suffix}.js" )
            . join( '',
                    map { slurp_file( $outputbasedir.'themes', $theme, 'langs', "$_.js" ) }
                        @langs );
    }

    # Plugins plus their langs
    foreach my $plugin ( @{ $modules->{p} } ) {
        $js_data
            .= slurp_file( $outputbasedir.'plugins', $plugin, "editor_plugin${suffix}.js" )
            . join(
            '',
            map {
                eval {
                    slurp_file( $outputbasedir.'plugins', $plugin, 'langs', "$_.js" );
                    }
                    || ''
                } @langs
            );
    }

    # Any custom files
    $js_data .= slurp_file($_) for ( @{ $modules->{custom_files} } );

        $js_data
            = slurp_file($outputbasedir."tiny_mce${suffix}.js")
            . 'tinyMCE_GZ.start();'
            . $js_data
            . 'tinyMCE_GZ.end();';

    return $js_data;
}

#===================================
sub slurp_file {
#===================================
    my $file = File::Spec->catfile(@_);
    unless ( File::Spec->file_name_is_absolute($file) ) {
        $file = File::Spec->catfile( $cwd, $file );
    }
    return slurp( $file, binmode => ':raw' );
}

#===================================
sub get_cwd {
#===================================
    return File::Spec->catpath(
              File::Spec->no_upwards( ( File::Spec->splitpath($0) )[ 0, 1 ] ) );
}

sub usage {
    return qq*

  Usage: $0 [-h][-d] [-y yuicompressor.jar] -l languages -t themes -p plugins -f timymce_folder 
        -y Path to YUI compressor JAR (defaults to tools/install/yuicompressor-current.jar)
        
        -l comma-separated list of languages (eg. en,de)
        -t comma-separated list of themes (eg. simple,advanced)
        -p comma-seaprated list of plugins (eg. table,advimage,advlink)

        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

__END__

=head1 NAME

xims_minimize_tinymce.pl

=head1 SYNOPSIS

xims_minimize_jscss.pl [-h][-d] [-y yuicompressor.jar] -l languages -t themes -p plugins -f timymce_folder 
        -y Path to YUI compressor JAR (defaults to tools/install/yuicompressor-current.jar)
        
        -l comma-separated list of languages (eg. en,de)
        -t comma-separated list of themes (eg. simple,advanced)
        -p comma-seaprated list of plugins (eg. table,advimage,advlink)
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen


=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-y>

Path to YUI compressor JAR - http://yuilibrary.com/projects/yuicompressor/

=item B<-v>

Optional version postfix which will be appended to the filenames of the minimized files.
Useful if the css and js files will be served with a far future Expires header

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut

