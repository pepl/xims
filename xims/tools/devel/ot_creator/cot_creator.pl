#!/usr/bin/perl
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
no warnings 'redefine';

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib",($ENV{'XIMS_HOME'} || '/usr/local/xims')."/tools/lib";

use Getopt::Std;
use XIMS::Term;
use XIMS::ObjectType;
use XIMS::DataFormat;
use FileHandle;
use File::Basename;
use File::Path;
use XML::LibXML;
use XML::LibXSLT;
use XML::LibXML::SAX::Builder;
use XML::Generator::PerlData;

my %args;
getopts('hcn:f:m:s:i:o:u:p:d:g:r:t:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Content Object Type Creator" );

# parameter checks
if ( $args{h} or not $args{n} ) {
    usage();
    exit();
}
if ( $args{o} ) {
    die "Output directory $args{o} is not writable.\n"
        unless -d $args{o} and -w $args{o};
}

my $o_isa;
my $o_isa_object;
my $df;
my $created_df;

# check for ISA parameter
if ( defined $args{i} and $args{i} ne 'XIMS::Object' ) {
    my $o_isa_class = $args{i};
    eval "require $o_isa_class;";
    die "Could not load ISA class: $@\n" if $@;

    $o_isa_object = $o_isa_class->new();
    $o_isa = $o_isa_class;
}
else {
    die "Need '-f' if '-i' is 'XIMS::Object' or not specified!\n"
        unless defined $args{f};
    $o_isa = 'XIMS::Object';
}

# set data format
if ( not defined $args{f} ) {
    $df = $o_isa_object->data_format();
}
else {
    $df = XIMS::DataFormat->new( name => $args{f} );
    if ( not $df ) {
        # create data format if it not already exists and mime_type and
        # suffix are given
        if ( $args{c} and $args{m} ) {
            $df = XIMS::DataFormat->new();
            $df->name( $args{f} );
            $df->mime_type( $args{m} );
            $df->suffix( $args{s} ) if defined $args{s};

            eval { $df->create(); };
            die "Could not create data format in database: $@\n" if $@;
            $created_df = 1;
        }
        else {
            print "Could not load data format '".$args{f}."'.\n",
            "Specify a valid data format name or parameters to create one.\n\n";
            print "Press any key to see a list of existing data format names";<STDIN>;
            foreach my $data_format ( XIMS::DataFormat->new->data_provider->data_formats() ) {
                print $data_format->name() . " (" . $data_format->mime_type() . ")\n";
            }
            die "\n";
        }
    }
}

my $ot = XIMS::ObjectType->new( name => $args{n} );
if ( $ot and $ot->id() ) {
    warn "Object type of that name already exists!\n";
    if ( $created_df ) {
        eval { $df->delete(); };
        if ( $@ ) {
            die "Could not delete newly created data format: $@\n";
        }
        else {
            print "Newly created data format deleted.\n";
        }
    }
    exit;
}

# for now, we create a non-container ot per default...
$ot = XIMS::ObjectType->new->data(
                                  name => $args{n},
                                  is_fs_container => $args{t} || 0,
                                  redir_to_self => $args{r} || 1,
                                  publish_gopublic => $args{g} || 0,
                                 );

eval { $ot->create(); };
if ( $@ ) {
    print "Could not create object type in database: $@\n";
    if ( $created_df ) {
        eval { $df->delete(); };
        if ( $@ ) {
            die "Could not delete newly created data format: $@\n";
        }
        else {
            print "Newly created data format deleted.\n";
        }
    }
    die "\n";
}


print "\nObject type '" . $ot->name() . "' has been sucessfully created in the database.\n\n";
print "Going to create the template modules and stylesheets.\n";

my $a_isa;
if ( $o_isa eq 'XIMS::Object' ) {
    $a_isa = 'XIMS::CGI';
}
else {
    ($a_isa) = $o_isa =~ /XIMS::(\w+)/;
    $a_isa = lc($a_isa);
}
my $e_isa = $o_isa;
$e_isa =~ s/XIMS::/XIMS::Exporter::/;
$e_isa = $e_isa eq 'XIMS::Exporter::Object' ? 'XIMS::Exporter::XML' : $e_isa;
my $i_isa = $o_isa;
$i_isa =~ s/XIMS::/XIMS::Importer::/;
$i_isa = $i_isa eq 'XIMS::Importer::Object' ? 'XIMS::Importer::FileSystem' : $i_isa;


my $objecttype = {
            object_type_name => $ot->name(),
            o_isa => $o_isa,
            a_isa => $a_isa,
            e_isa => $e_isa,
            i_isa => $i_isa,
            data_format_name => $df->name(),
           };

my $styledir = 'www/ximsroot/skins/skinname/stylesheets/language/';
my %templates_outputpaths = (
    'templates/ObjectClass.xsl' => 'lib/XIMS/'. $objecttype->{object_type_name} . '.pm',
    'templates/ApplicationClass.xsl' => 'lib/XIMS/CGI/'. $objecttype->{object_type_name} . '.pm',
    'templates/ExporterClass.xsl' => 'lib/XIMS/Exporter/'. $objecttype->{object_type_name} . '.pm',
    'templates/ImporterClass.xsl' => 'lib/XIMS/Importer/FileSystem/'. $objecttype->{object_type_name} . '.pm',
    'templates/event_create.xsl' => $styledir . lc($objecttype->{object_type_name}) . '_create.xsl',
    'templates/event_default.xsl' => $styledir . lc($objecttype->{object_type_name}) . '_default.xsl',
    'templates/event_edit.xsl' => $styledir . lc($objecttype->{object_type_name}) . '_edit.xsl',
    'templates/exporter.xsl' => 'www/ximsroot/stylesheets/exporter/export_' . lc($objecttype->{object_type_name}) . '.xsl',
    );

if ( defined $args{g} ) {
    delete $templates_outputpaths{'templates/ExporterClass.xsl'};
    delete $templates_outputpaths{'templates/ImporterClass.xsl'};
    delete $templates_outputpaths{'templates/exporter.xsl'};
}

my $xml_dom = dom_from_data($objecttype);

my $outputdir;
if ( $args{o} ) {
    $outputdir = $args{o};
    $outputdir =~ s/\/$//;
}
else {
    $outputdir = ".";
}
$outputdir = $outputdir . '/ot_creator_out/';

foreach my $stylefile ( sort keys %templates_outputpaths ) {
    my $filename = $outputdir . $templates_outputpaths{$stylefile};
    my $string = transform( $xml_dom, $stylefile );
    if ( not(-d dirname($filename)) ) {
        if ( not mkpath(dirname($filename)) ) {
            warn "Could not create " . dirname($filename) . ": $!\n";
            next;
        }
    }
    my $fh = FileHandle->new(">".$filename);
    if (defined $fh) {
        print $fh $string;
        $fh->close;
        print "\t$filename written.\n";
    }
    else {
        warn "Could not write to $filename: $!\n";
    }
}

print "\nPlease consult the 'Content Object Type Howto' on what to do next.\n\n";

sub dom_from_data {
    my $data = shift;
    my $driver = XML::Generator::PerlData->new( Handler => XML::LibXML::SAX::Builder->new() );
    # generate XML from the data structure...
    return $driver->parse( $data );
}

sub transform {
    my $xml_dom = shift;
    my $stylefile = shift;

    my $parser = XML::LibXML->new();
    my $xslt   = XML::LibXSLT->new();

    # parse the stylesheet
    my $xsl_dom;
    eval {
        $xsl_dom  = $parser->parse_file( $stylefile );
    };
    if ( $@ ) {
        die( "Corrupted Stylesheet:\n broken XML\n". $@ );
    }

    my $style;
    eval {
        $style = $xslt->parse_stylesheet( $xsl_dom );
    };
    if ( $@ ) {
        die(  "Corrupted Stylesheet:\n". $@ ."\n" );
    }

    # do the transformation
    my $out_string;
    my $transformed_dom = $style->transform( $xml_dom );
    eval {
        $out_string =  $style->output_string( $transformed_dom );
    };
    if ( $@ ) {
        die( "Corrupted Output:\n", $@ , "\n" );
    }

    return $out_string;
}

# fake the config, if user specified to use different db credentials or loglevel
sub XIMS::Config::DBUser() { return ($args{u} || XIMS::Config::DBUser()) }
sub XIMS::Config::DBPassword() { return ($args{p}|| XIMS::Config::DBPassword()) }

sub usage {
    print qq*
  Usage: $0 [-h|-n object_type_name [-i isa] [-f data_format_name]
            [-c -m mime_type -s suffix] [-o outputdir]
            [-r redir_to_self] [-g publish_gopublic] [-t is_fs_container]
            [-u dbusername] [-p dbpassword] [-d debuglevel] ]

        -n The name of the object type you want to create
        -i The super class of the object-, application-, and exporter
           class; defaults to XIMS::Object, XIMS::CGI, and
           XIMS::Exporter::XML respectively
        -r Set redir_to_self objecttype property, defaults to 1
        -g Set publish_gopublic objecttype property, defaults to 0
        -t Set is_fs_container objecttype property, defaults to 0
        -f The name of the data format (list of df)
            If you want to create a new data format, you have to set the
            following three arguments:
            -c flag to actually create the data format
            -m mime-type
            -s suffix
        -u If set, overrides XIMS::Config::DBUser. You may need this if
           the database user specified in XIMS::Config::DBUser has
           insufficient privileges to create object types or data
           formats. For Pg, for example the user default user 'xims' has
           the privileges, whereas 'ximsrun' does not.
        -p If set, overrides XIMS::Config::DBPassword
        -o Output directory of template modules and stylesheets,
           defaults to '.'
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

__END__

=head1 NAME

cot_creator.pl

=head1 SYNOPSIS
cot_creator.pl	 [-h|-n object_type_name [-i isa] [-f data_format_name]
	         [-c -m mime_type -s suffix] [-o outputdir]
           	 [-r redir_to_self] [-g publish_gopublic] [-t is_fs_container]
           	 [-u dbusername] [-p dbpassword] [-d debuglevel] ]

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-n>

The name of the object type you want to create

=item B<-i>

The super class of the object-, application-, and exporter
class; defaults to XIMS::Object, XIMS::CGI, and
XIMS::Exporter::XML respectively

=item B<-r>

Set redir_to_self objecttype property, defaults to 1

=item B<-g>

Set publish_gopublic objecttype property, defaults to 0

=item B<-t>

Set is_fs_container objecttype property, defaults to 0

=item B<-f>

The name of the data format (list of df)
If you want to create a new data format, you have to set the
following three arguments:
-c flag to actually create the data format
-m mime-type
-s suffix

=item B<-u>

If set, overrides XIMS::Config::DBUser. You may need this if
the database user specified in XIMS::Config::DBUser has
insufficient privileges to create object types or data
formats. For Pg, for example the user default user 'xims' has
the privileges, whereas 'ximsrun' does not.

=item B<-p>

If set, overrides XIMS::Config::DBPassword

=item B<-o>

Output directory of template modules and stylesheets,
defaults to '.'

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut
