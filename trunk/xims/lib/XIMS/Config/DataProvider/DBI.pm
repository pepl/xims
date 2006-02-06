# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Config::DataProvider::DBI;

use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };
@ISA = qw( XIMS::Config );

use XIMS::Config;
use XML::LibXML;

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my $self = bless {}, $class;
    my %args = @_;
    my $file = ($args{filename} || (XIMS::HOME() . "/conf/ximsconfig-dbi.xml"));

    $self->process_file( $file );

    return $self;
}

sub process_file {
    my $self = shift;
    my $file = shift;

    return unless (defined $file and length $file);
    #warn "Processing XIMS DBI config file '$file'\n";

    my $parser = XML::LibXML->new();
    my $doc;
    eval {
        $doc = $parser->parse_file( $file )
    };
    die "Could not parse file '$file': $@\n" if $@;

    no strict 'refs';

    my @npropattribs = $doc->findnodes( '/Config/DBI/PropertyAttributes/item' );
    my $propattribs = {};
    foreach my $node ( @npropattribs ) {
        $propattribs->{$node->getAttribute('name')} = \$node->getAttribute('value');
    }
    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::DataProvider::DBI::PropertyAttributes"}{CODE} ) {
        my %existing_props = XIMS::Config::DataProvider::DBI::PropertyAttributes();
        @existing_props{keys %{$propattribs}} = values %{$propattribs};
        $propattribs = \%existing_props;
    }
    # install in the symbol table
    $self->install_methods( $propattribs, 'XIMS::Config::DataProvider::DBI', 'PropertyAttributes' );

    my @ntables = $doc->findnodes( '/Config/DBI/Tables/item' );
    my $tables = {};
    foreach my $node ( @ntables ) {
        $tables->{$node->getAttribute('name')} = $node->getAttribute('value');
    }
    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::DataProvider::DBI::Tables"}{CODE} ) {
        my %existing_tables = XIMS::Config::DataProvider::DBI::Tables();
        @existing_tables{keys %{$tables}} = values %{$tables};
        $tables = \%existing_tables;
    }
    # install in the symbol table
    $self->install_methods( $tables, 'XIMS::Config::DataProvider::DBI', 'Tables' );

    my @nproprels = $doc->findnodes( '/Config/DBI/PropertyRelations/item' );
    my $proprels = {};
    foreach my $node ( @nproprels ) {
        $proprels->{$node->getAttribute('resourcetype')} = { $node->getAttribute('property') => \$node->getAttribute('relates') };
    }
    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::DataProvider::DBI::PropertyRelations"}{CODE} ) {
        my %existing_proprels = XIMS::Config::DataProvider::DBI::PropertyRelations();
        @existing_proprels{keys %{$proprels}} = values %{$proprels};
        $proprels = \%existing_proprels;
    }
    # install in the symbol table
    $self->install_methods( $proprels, 'XIMS::Config::DataProvider::DBI', 'PropertyRelations' );

    $self->process_includes( $doc );

    return 1;
}

1;
