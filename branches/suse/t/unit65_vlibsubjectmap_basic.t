use Test::More tests => 17;

use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Document;
use XIMS::User;
use XIMS::VLibSubject;
#use Data::Dumper;

BEGIN {
   use_ok( 'XIMS::VLibSubjectMap' );
}

# first, create a document and an subject to add VLib SubjectMap data to
my $document = XIMS::Document->new();
isa_ok( $document, 'XIMS::Document' );

$document->title( 'TestDocumentSubjectMap' );
$document->language_id( 1 );
$document->location( 'testdocumentsubjmap' );
$document->parent_id( 2 ); # /xims

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 1 );
isa_ok( $user, 'XIMS::User' );
my $doc_id = $document->create( User => $user );
cmp_ok( $doc_id, '>', 1, 'Document has a sane ID' );

my $subject = XIMS::VLibSubject->new();
isa_ok( $subject, 'XIMS::VLibSubject' );

$subject->name( 'TestSubjectMapLastName' );
$subject->document_id(2);

my $subject_id = $subject->create();
cmp_ok( $subject_id, '>', 0, "Subject created with id $subject_id" );

# make a simple one, test that the objecttype and data_formats are set by the constructor
my $subjmap = XIMS::VLibSubjectMap->new();

isa_ok( $subjmap, 'XIMS::VLibSubjectMap' );

$subjmap->document_id( $document->document_id() );
$subjmap->subject_id( $subject->id() );

my $id = $subjmap->create();
cmp_ok( $id, '>', 0, "SubjectMap created with id $id" );

# fetch it back...
$subjmap = undef;
$subjmap = XIMS::VLibSubjectMap->new( id => $id );

ok( $subjmap );
is( $subjmap->document_id(), $document->document_id(), 'TestSubjectMap has correct document_id' );
is( $subjmap->subject_id(), $subject->id(), 'TestSubjectMap has correct subject_id' );

# fetch it back by document_id
$subjmap = undef;
$subjmap = XIMS::VLibSubjectMap->new( document_id => $document->document_id(), subject_id => $subject_id );

ok( $subjmap );
is( $subjmap->id(), $id , 'TestSubjectMap has correct id' );

ok( $subjmap->delete(), 'Successfully deleted testsubjmap' );

# try to fetch it back
$subjmap = undef;
$subjmap = XIMS::VLibSubjectMap->new( id => $id );
is( $subjmap, undef, 'Unable to fetch deleted testsubjmap (OK)' );

ok( $document->delete(), 'Successfully deleted testdocumentsubjmap' );
ok( $subject->delete(), 'Successfully deleted testsubjectsubjmap' );


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

