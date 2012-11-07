use Test::More qw(no_plan);
use lib "../lib";
use strict;
use File::Find;
use XML::LibXML;

my $ximshome = $ENV{'XIMS_HOME'} || '/usr/local/xims';

my $parser = XML::LibXML->new();
$parser->pedantic_parser(1);
$parser->line_numbers(1);

my $schema = XML::LibXML::RelaxNG->new( location => "$ximshome/t/schemata/xslt.rng" );

my @files;

sub wanted {
    push @files, $File::Find::name if /\.xsl$/;
}

find( \&wanted, "$ximshome/www");

foreach my $file (@files) {
    eval{
        my $doc = $parser->parse_file( $file );
        $schema->validate( $doc );
    };

    is($@, q{}, 'Can XSLT files be parsed and validated?');
}


__END__
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

