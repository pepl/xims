use Test::More tests => 13;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibAuthor' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $author = XIMS::VLibAuthor->new();

isa_ok( $author, 'XIMS::VLibAuthor' );

$author->lastname( 'TestAuthorLastName' );
$author->middlename( 'TestAuthorMiddleName' );
$author->firstname( 'TestAuthorFirstName' );
$author->object_type( 0 );

my $id = $author->create();
cmp_ok( $id, '>', 0, "Author created with id $id" );

# fetch it back...
$author = undef;
$author = XIMS::VLibAuthor->new( id => $id );

ok( $author );
is( $author->lastname(), 'TestAuthorLastName', 'Testauthor has correct lastname' );
is( $author->middlename(), 'TestAuthorMiddleName' , 'Testauthor has correct middlename' );
is( $author->firstname(), 'TestAuthorFirstName' , 'Testauthor has correct firstname' );
is( $author->object_type(), 0 , 'Testauthor has correct objecttype (Person)' );

# now, change something
$author->firstname( 'RenamedTestAuthorFirstName' );
ok( $author->update(), 'Updated TestauthorFirstName' );

# fetch it back...
$author = undef;
$author = XIMS::VLibAuthor->new( id => $id );

ok( $author );
is( $author->firstname(), 'RenamedTestAuthorFirstName' , 'Testauthor has correct firstname' );

ok( $author->delete(), 'Successfully deleted testauthor' );

# try to fetch it back
$author = undef;
$author = XIMS::VLibAuthor->new( id => $id );
is( $author, undef, 'Unable to fetch deleted testauthor (OK)' );
