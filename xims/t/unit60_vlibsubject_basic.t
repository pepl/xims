use Test::More tests => 12;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibSubject' );
}

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $subject = XIMS::VLibSubject->new();

isa_ok( $subject, 'XIMS::VLibSubject' );

$subject->name( 'TestSubjectName' );
$subject->description( 'TestSubjectDescription' );

eval { my $id = $subject->create(); };
like( $@, qr/Query failed/, 'record insert w/o document_id must fail' );

$subject->document_id(2);

my $id = $subject->create();
cmp_ok( $id, '>', 0, "Subject created with id $id" );

# fetch it back...
$subject = undef;
$subject = XIMS::VLibSubject->new( id => $id );

ok( $subject );
is( $subject->name(), 'TestSubjectName', 'TestSubject has correct name' );
is( $subject->description(), 'TestSubjectDescription' , 'TestSubject has correct description' );

# now, change something
$subject->name( 'RenamedTestSubjectName' );
ok( $subject->update(), 'Updated TestSubjectName' );

# fetch it back...
$subject = undef;
$subject = XIMS::VLibSubject->new( id => $id );

ok( $subject );
is( $subject->name(), 'RenamedTestSubjectName' , 'TestSubject has correct name' );

ok( $subject->delete(), 'Successfully deleted testsubject' );

# try to fetch it back
$subject = undef;
$subject = XIMS::VLibSubject->new( id => $id );
is( $subject, undef, 'Unable to fetch deleted testsubject (OK)' );
