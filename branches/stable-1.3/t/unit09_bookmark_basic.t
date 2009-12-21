use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::Bookmark;
#use Data::Dumper;

BEGIN {
    plan tests => 24;
}

my $bmk = XIMS::Bookmark->new();

ok( $bmk );

$bmk->id( 1 );
$bmk->content_id( 2 );
$bmk->owner_id( 1 );
$bmk->stdhome( 1 );

ok( $bmk->id() == 1 );
ok( $bmk->content_id() == 2 );
ok( $bmk->owner_id() == 1 );
ok( $bmk->stdhome() == 1 );

# try the more Perlish short cut
$bmk = undef;

my %hash = ( id   => 1,
             content_id => 2,
             owner_id => 1,
             stdhome => 1,
           );

$bmk = XIMS::Bookmark->new->data( %hash );

ok( $bmk->id() == 1 );
ok( $bmk->content_id() == 2 );
ok( $bmk->owner_id() == 1 );
ok( $bmk->stdhome() == 1 );

# now create one
$bmk = XIMS::Bookmark->new();

ok( $bmk );
$bmk->content_id( 2 );
$bmk->owner_id( 1 );
$bmk->stdhome( 1 );

my $id = $bmk->create();

ok( $id and $id > 0 );

# now select it back out of the DB.

$bmk = undef;
$bmk = XIMS::Bookmark->new( id => $id );

ok( $bmk );
ok( $bmk->id() == $id );
ok( $bmk->content_id() == 2 );
ok( $bmk->owner_id() == 1 );
ok( $bmk->stdhome() == 1 );

# now modify a field and test updating

$bmk->stdhome( 0 );

ok( $bmk->update() );

$bmk = undef;
$bmk = XIMS::Bookmark->new( id => $id );

ok( $bmk );
ok( $bmk->id() == $id );
ok( $bmk->content_id() == 2 );
ok( $bmk->owner_id() == 1 );
ok( $bmk->stdhome() == 0 );

# now delete

ok( $bmk->delete() );

# and make sure

$bmk = undef;
$bmk = XIMS::Bookmark->new( id => $id );
ok( not defined $bmk );

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

