use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Document;
#use Data::Dumper;

BEGIN {
    plan tests => 7;
}

my $o = XIMS::Object->new( id => 2 );

ok ( $o );
ok( $o->content_length() == 0 );

# now. let's get happy...

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
ok( $user );
ok( $user->name() eq 'admin' );

my $body = qq|<p><h1>This is only a test!</h1></p>|;

my %doc_hash = ( language_id => 1,
                 location => 'testdoc.xml',
                 title    => 'my test document',
                 parent_id => 2,
                 department_id => 1,
                 body => $body,
               );

$o = XIMS::Document->new->data( %doc_hash );
my $o_id = $o->create( User => $user );
ok( $o_id and $o_id > 1 );

# all that for this one test :-)

# note that, at the time of this writing, the following test fails.
# the length of the string is 41 characters but the lob_length col
# in the Oracle view reports a length of 21. WTF???

ok( $o->content_length() == length( $body ) );

# now clean up
$o->delete();
# and make sure...
$o = undef;
$o = XIMS::Object->new( id => $o_id );
ok( not defined $o );

