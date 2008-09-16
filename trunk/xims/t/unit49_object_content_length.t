use Test::More;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Document;
use utf8;
#use Data::Dumper;

BEGIN {
    plan tests => 12;
}

my $o = XIMS::Object->new( id => 2 );

ok ( $o, 'Fetched /xims object' );
is( $o->content_length(), 0, 'That one has zero bytes length' );

# now. let's get happy...

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
ok( $user, 'Fetched admin user' );
is( $user->name(), 'admin', 'Has correct user name' );

my $body = qq|<p><h1>This is only a täst!</h1></p>|;

my %doc_hash = ( location => 'testdoc.xml',
                 title    => 'my test document',
                 parent_id => 2,
                 body => $body,
               );

$o = XIMS::Document->new->data( %doc_hash );
my $o_id = $o->create( User => $user );
ok( $o_id and $o_id > 1, 'Created test document' );

my $bytes_length;
do { use bytes; $bytes_length = length( $body ) };

is( $o->content_length(), $bytes_length, 'Has correct content_length' );

my $updated_body = qq|<p><h1>This is only another täst!</h1></p>|;
$o->body( $updated_body );

$bytes_length;
do { use bytes; $bytes_length = length( $updated_body ) };

is( $o->content_length(), $bytes_length, 'Still has correct content_length after in memory update' );

ok( $o->update( User => $user ), 'Update document in database' );

is( $o->content_length(), $bytes_length, 'Document still has correct content_length' );

$o = undef;
ok ( $o = XIMS::Document->new( id => $o_id, User => $user ), 'Refetched document' );

is( $o->content_length(), $bytes_length, 'Has correct content_length' );

# now clean up
$o->delete();
# and make sure...
$o = undef;
$o = XIMS::Object->new( id => $o_id );
is( $o, undef, 'Deletion of document successful' );

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

