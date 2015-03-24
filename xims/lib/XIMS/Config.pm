
=head1 NAME

XIMS::Config - the configreader

=head1 VERSION

$Id$

=head1 SYNOPSIS

Loaded by XIMS.pm; do not load it in your scripts, access it through

    XIMS::CONFIG();

=head1 DESCRIPTION

This module reads the XML-formatted configuration files under $XIMSHOME/conf
and its subdirectories. On startup, it dynamically generates and installs
methods for general configurable items and the data provider from information
stored in this files.

=head1 SUBROUTINES/METHODS

=cut

## no critic

package XIMS::Config;

use common::sense;
use XML::LibXML;
use XML::LibXSLT;

our $VERSION = do { my @r = ( q$Revision$ =~ /\d+/g ); 
                    sprintf "%d." . "%02d" x $#r, @r; 
               };

our $XIMS_HOME = $ENV{'XIMS_HOME'} || '/usr/local/xims';

=head2    XIMS::Config->new( [%args] )

=head3 Parameter

    $args{filename}   (optional) :  filename of the config file

=head3 Returns

    $config    : Instance of XIMS::Config

=head3 Description

Loaded by XIMS.pm; do not load it in your scripts, access it through XIMS::CONFIG()

=cut

=head2 new()

=cut

sub new {
    my $proto   = shift;
    my $class   = ref($proto) || $proto;
    my $self    = bless {}, $class;
    my %args    = @_;
    my $general = ( $args{file} || ( $XIMS_HOME . "/conf/ximsconfig.xml" ) );
    my $dbi     = ( $args{dbi}  || ( $XIMS_HOME . "/conf/ximsconfig-dbi.xml" ) );

    $self->process_file($general);
    $self->process_dbi($dbi);
    $self->gen_xsl_config($general) unless $args{ro};

    return $self;
}

=head2 general()

=cut

sub general { shift->{general} }

=head2 dpconfig()

=cut

sub dpconfig { shift->{dpconfig} }

=head2 process_file()

=cut

sub process_file {
    my $self = shift;
    my $file = shift;

    unless ( defined $file and -f $file and -r $file ) {
        die "Could not access '$file'.\n";
    }

    #warn "Processing XIMS config file '$file'\n";

    my $parser = XML::LibXML->new();
    my $doc;
    eval { $doc = $parser->parse_file($file) };
    die "Could not parse file '$file': $@\n" if $@;

    my @ngeneral = $doc->findnodes('/Config/General/*');
    my $general;
    if ( scalar @ngeneral ) {
        $general = $self->get_values(@ngeneral);
        $self->install_methods($general);
        foreach my $key ( keys %{$general} ) {
            $self->{general}->{$key} = $general->{$key};
        }
    }

    no strict 'refs';

    my @nrt            = $doc->findnodes('/Config/Names/ResourceTypes');
    my $resource_types = $self->get_values(@nrt);

    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::Names::ResourceTypes"}{CODE} ) {
        my @existing_rst = XIMS::Config::Names::ResourceTypes();
        unshift( @{ $resource_types->{ResourceTypes} }, @existing_rst )
            if scalar @existing_rst;
    }

    # install in the symbol table
    $self->install_methods( $resource_types, 'XIMS::Config::Names' );

    my @nproperties = $doc->findnodes('/Config/Names/Properties/*');
    my $properties  = $self->get_values(@nproperties);

    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::Names::Properties"}{CODE} ) {
        my %existing_props = XIMS::Config::Names::Properties();
        @existing_props{ keys %{$properties} } = values %{$properties};
        $properties = \%existing_props;
    }

    # install in the symbol table
    $self->install_methods( $properties, 'XIMS::Config::Names',
        'Properties' );

    $self->process_includes($doc);

    return 1;
}

=head2 process_dbi()

=cut

sub process_dbi {
    my $self = shift;
    my $file = shift;

    return unless ( defined $file and length $file );

    #warn "Processing XIMS DBI config file '$file'\n";

    my $parser = XML::LibXML->new();
    my $doc;
    eval { $doc = $parser->parse_file($file) };
    die "Could not parse file '$file': $@\n" if $@;

    no strict 'refs';

    my @npropattribs = $doc->findnodes('/Config/DBI/PropertyAttributes/item');
    my $propattribs  = {};
    foreach my $node (@npropattribs) {
        $propattribs->{ $node->getAttribute('name') }
            = \$node->getAttribute('value');
    }

    # merge new properties if there already are some
    if (defined *{"XIMS::Config::DataProvider::DBI::PropertyAttributes"}
        {CODE} )
    {
        my %existing_props
            = XIMS::Config::DataProvider::DBI::PropertyAttributes();
        @existing_props{ keys %{$propattribs} } = values %{$propattribs};
        $propattribs = \%existing_props;
    }

    # install in the symbol table
    $self->install_methods( $propattribs, 'XIMS::Config::DataProvider::DBI',
        'PropertyAttributes' );

    my @ntables = $doc->findnodes('/Config/DBI/Tables/item');
    my $tables  = {};
    foreach my $node (@ntables) {
        $tables->{ $node->getAttribute('name') }
            = $node->getAttribute('value');
    }

    # merge new properties if there already are some
    if ( defined *{"XIMS::Config::DataProvider::DBI::Tables"}{CODE} ) {
        my %existing_tables = XIMS::Config::DataProvider::DBI::Tables();
        @existing_tables{ keys %{$tables} } = values %{$tables};
        $tables = \%existing_tables;
    }

    # install in the symbol table
    $self->install_methods( $tables, 'XIMS::Config::DataProvider::DBI',
        'Tables' );

    my @nproprels = $doc->findnodes('/Config/DBI/PropertyRelations/item');
    my $proprels  = {};
    foreach my $node (@nproprels) {
        $proprels->{ $node->getAttribute('resourcetype') }
            = {
            $node->getAttribute('property') => \$node->getAttribute('relates')
            };
    }

    # merge new properties if there already are some
    if (defined *{"XIMS::Config::DataProvider::DBI::PropertyRelations"}
        {CODE} )
    {
        my %existing_proprels
            = XIMS::Config::DataProvider::DBI::PropertyRelations();
        @existing_proprels{ keys %{$proprels} } = values %{$proprels};
        $proprels = \%existing_proprels;
    }

    # install in the symbol table
    $self->install_methods( $proprels, 'XIMS::Config::DataProvider::DBI',
        'PropertyRelations' );

    $self->process_includes( $doc, 'dbi' );

    return 1;
}

=head2 get_values()

=cut

sub get_values {
    my $self  = shift;
    my @nodes = @_;
    my %rv;
    foreach my $node (@nodes) {
        my @items = $node->findnodes('item');
        if ( scalar @items ) {
            my @values = map { $_->textContent() } @items;

            # untaint the values for running with setuid - if you have
            # less trust in your configfile, adapt the regex.
            @values = map { $_ = $1 if /^(.*)$/ } @values;
            $rv{ $node->localname() } = \@values;
        }
        else {
            my $value = $node->textContent();

            # untaint the values for running with setuid
            $value = $1 if $value =~ /^(.*)$/;
            $rv{ $node->localname() } = $value;
        }
    }
    return \%rv;
}

=head2 install_methods()

=cut

sub install_methods {
    my $self        = shift;
    my $methods     = shift;
    my $package     = ( shift || __PACKAGE__ );
    my $return_hash = shift;

    $package .= "::";

    #warn "package: $package\n";

    no strict 'refs';
    no warnings 'redefine';
    my $code;
    if ( defined $return_hash ) {
        $code = sub { return %{$methods} };
        *{"$package$return_hash"} = $code;
    }
    else {
        my ( $name, $value );
        while ( ( $name, $value ) = each %{$methods} ) {
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

=head2 process_includes()

=cut

sub process_includes {
    my $self = shift;
    my $doc  = shift;
    my $type = shift;
    $type ||= 'file';
    my $processmethod = "process_$type";

    my @includes
        = map { $_->textContent() } $doc->findnodes('/Config/Include');
    foreach my $path (@includes) {
        $path = $XIMS_HOME . "/conf/" . $path;
        if ( -d $path and -x $path ) {
            opendir( DIR, $path )
                || die "Could not open directory '$path': $!\n";
            my @files = grep { /\.xml$/ && -f "$path/$_" && -r "$path/$_" }
                readdir(DIR);
            closedir DIR;
            foreach my $f (@files) {
                $self->$processmethod("$path/$f");
            }
        }
        elsif ( -f $path and -r $path ) {
            $self->$processmethod($path);
        }
        else {
            die "Could not access included config '$path': $!\n";
        }
    }

    return 1;
}

=head2 gen_xsl_config( $ximsconfig )

Recreates config.xsl from ximsconfig.xml. We check for existence and
timestamps but do not try to be all too smart. Transform or die.

=cut


sub gen_xsl_config {
    my ($self, $config_in) = @_;
    my ($stylesheet,$results);

    # check existance and permissions
    -r $config_in or die "\nConfiguration file '$config_in' is not readable.\nExiting.\n";

    my $xsl_in = $XIMS_HOME . '/conf/xslconfig.xsl';
    -r $xsl_in or die "\n'Stylesheet  $xsl_in' is not readable.\nExiting.\n";

    my $outdir = $self->ServerDocumentRoot() . '/' . $self->XIMSRoot() . '/stylesheets/';
    my $config_out = $outdir . 'config.xsl';

    unless(-w $config_out or (not -e $config_out and -w $outdir)) {
        die "\n'$config_out' is not writable.\n" .
            "Is '$outdir' really an absolute and writable filesystem path?\n" .
            "You might want to double-check permissions and settings like 'ServerDocumentRoot' or 'XIMSRoot'.\n" .
            "Exiting.\n";
    }

    # check timestamps (yes, it correctly handles a non-existing $config_out)
    # and recreate if necessary
    if ( (stat($config_in))[9] > (stat($config_out))[9]
      or (stat($xsl_in))[9]    > (stat($config_out))[9] ) {
        my $proc = XML::LibXSLT->new();
        eval{
            $stylesheet = $proc->parse_stylesheet_file($xsl_in);
            $results = $stylesheet->transform_file($config_in);
        };
        die "Could not transform xsl-config:\n\n$@\nExiting.\n" if $@;

        eval{
            $stylesheet->output_file($results, $config_out)
        };
        die "Could not write '$config_out':\n\n$@\nExiting.\n" if $@;

        return 1;
    }

    return 0;
}


1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2015 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

