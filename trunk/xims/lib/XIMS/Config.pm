# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Config;

use strict;
use vars qw($VERSION);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

use XIMS;

# Load all known DP Configs;
use XIMS::Config::DataProvider::DBI;

use XML::LibXML;

##
#
# SYNOPSIS
#    XIMS::Config->new( [%args] )
#
# PARAMETER
#    $args{filename}   (optional) :  filename of the config file
#
# RETURNS
#    $config    : Instance of XIMS::Config
#
# DESCRIPTION
#    Loaded by XIMS.pm; do not load it in your scripts, access it through XIMS::CONFIG()
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self = bless {}, $class;
    my %args = @_;
    my $file = ($args{filename} || (XIMS::HOME() . "/conf/ximsconfig.xml") );

    $self->process_file( $file );

    # try to load DataProvider specific config
    my $dpclass = "XIMS::Config::DataProvider::" . $self->DBMS();
    my $dpconfig = $dpclass->new();

    $self->{dpconfig} = $dpconfig;

    return $self;
}

sub general { shift->{general} }
sub dpconfig { shift->{dpconfig} }

sub process_file {
    my $self = shift;
    my $file = shift;

    unless ( defined $file and -f $file and -r $file ) {
        die "Could not access '$file'.\n";
    }
    #warn "Processing XIMS config file '$file'\n";

    my $parser = XML::LibXML->new();
    my $doc;
    eval {
        $doc = $parser->parse_file( $file )
    };
    die "Could not parse file '$file': $@\n" if $@;

    my @ngeneral = $doc->findnodes( '/Config/General/*' );
    my $general;
    if ( scalar @ngeneral ) {
        $general = $self->get_values( @ngeneral );
        $self->install_methods( $general );
        $self->{general} = $general;
    }

    no strict 'refs';

    my @nrt = $doc->findnodes( '/Config/Names/ResourceTypes' );
    my $resource_types = $self->get_values( @nrt );
    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::Names::ResourceTypes"}{CODE} ) {
        my @existing_rst = XIMS::Config::Names::ResourceTypes();
        unshift (@{$resource_types->{ResourceTypes}}, @existing_rst) if scalar @existing_rst;
    }
    # install in the symbol table
    $self->install_methods( $resource_types, 'XIMS::Config::Names' );

    my @nproperties = $doc->findnodes( '/Config/Names/Properties/*' );
    my $properties = $self->get_values( @nproperties );
    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::Names::Properties"}{CODE} ) {
        my %existing_props = XIMS::Config::Names::Properties();
        @existing_props{keys %{$properties}} = values %{$properties};
        $properties = \%existing_props;
    }
    # install in the symbol table
    $self->install_methods( $properties, 'XIMS::Config::Names', 'Properties' );

    $self->process_includes( $doc );

    return 1;
}

sub get_values {
    my $self = shift;
    my @nodes = @_;
    my %rv;
    foreach my $node ( @nodes ) {
        my @items = $node->findnodes( 'item' );
        if ( scalar @items ) {
            my @values = map { $_->textContent() } @items;
            $rv{$node->localname()} = \@values;
        }
        else {
            $rv{$node->localname()} = $node->textContent();
        }
    }
    return \%rv;
}

sub install_methods {
    my $self = shift;
    my $methods = shift;
    my $package = ( shift || __PACKAGE__ );
    my $return_hash = shift;

    $package .=  "::";
    #warn "package: $package\n";

    no strict 'refs';
    no warnings 'redefine';
    my $code;
    if ( defined $return_hash ) {
        $code = sub { return %{$methods} };
        *{"$package$return_hash"} = $code;
    }
    else {
        my ($name, $value);
        while (($name, $value) = each %{$methods}) {
            if ( ref $value eq 'ARRAY' ) {
                $code = eval "sub { return qw{ @{$value} } }";
            }
            else {
                $code = eval "sub { return q{$value} }";
            }
            *{"$package$name"} = $code;
        }
    }
}

sub process_includes {
    my $self = shift;
    my $doc = shift;

    my @includes = map { $_->textContent() } $doc->findnodes( '/Config/Include' );
    foreach my $path ( @includes ) {
        $path = XIMS::HOME() . "/conf/" . $path;
        if ( -d $path and -x $path ) {
            opendir(DIR, $path) || die "Could not open directory '$path': $!\n";
            my @files = grep { /\.xml$/ && -f "$path/$_" && -r "$path/$_" } readdir(DIR);
            closedir DIR;
            foreach my $f ( @files ) {
                $self->process_file( "$path/$f" );
            }
        }
        elsif ( -f $path and -r $path ) {
            $self->process_file( $path );
        }
        else {
            die "Could not access included config '$path': $!\n";
        }
    }

    return 1;
}

1;
