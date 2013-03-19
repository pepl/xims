use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::Language;
#use Data::Dumper;

BEGIN {
    plan tests => 26;
}

my $lang = XIMS::Language->new();

ok( $lang );

$lang->id( 1 );
$lang->code( 'en-ubu' );
$lang->fullname( 'ubuspeak' );

ok( $lang->id() == 1 );
ok( $lang->code() eq 'en-ubu' );
ok( $lang->fullname() eq 'ubuspeak' );

# try the more Perlish short cut
$lang = undef;

my %hash = ( id   => 1,
             code => 'en-us',
             fullname => 'English (US)'
           );

$lang = XIMS::Language->new->data( %hash );

ok( $lang );
ok( $lang->id() == 1 );
ok( $lang->code() eq 'en-us' );
ok( $lang->fullname() eq 'English (US)' );

# now try fetching a real one by ID
$lang = undef;

$lang = XIMS::Language->new( id => 1 );

ok( $lang );
ok( $lang->id() == 1 );
ok( $lang->code() eq 'en-us' );
ok( $lang->fullname() eq 'English (US)' );

# now try fetching a real one from the DB by the language code
$lang = undef;

$lang = XIMS::Language->new( code => 'en-us' );
ok( $lang );
ok( $lang->id() == 1 );
ok( $lang->code() eq 'en-us' );
ok( $lang->fullname() eq 'English (US)' );

# test updating
$lang->code('en-mer');
$lang->fullname('Merkin English');
$lang->update();

$lang = undef;

$lang = XIMS::Language->new( id => 1 );
ok( $lang );
ok( $lang->id() == 1 );
ok( $lang->code() eq 'en-mer' );
ok( $lang->fullname() eq 'Merkin English' );

# put things back the way they were
$lang->code('en-us');
$lang->fullname('English (US)');
$lang->update();

# now, try creating a new one...
$lang = undef;

$lang = XIMS::Language->new();

ok( $lang );
$lang->code('dummy');
$lang->fullname('A Dummy Test Language');

my $id = $lang->create();

ok( $id and $id > 2 );

# make sure deletion works
$lang->delete();
ok( $lang->id(), undef );
ok( $lang->code(), undef );
ok( $lang->fullname(), undef );

$lang = undef;
$lang = XIMS::Language->new( id => $id );
ok( not defined $lang );

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

