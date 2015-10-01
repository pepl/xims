use Test::More tests => 71;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Folder;
use XIMS::CSS;
use XIMS::Image;
use XIMS::Document;
use XIMS::Portlet;
use XIMS::JavaScript;
use XIMS::XSLStylesheet;
#use Data::Dumper;

BEGIN {
    use_ok('XIMS::DepartmentRoot');
}

my $user = XIMS::User->new( id => 1 );

# fetch the 'root' container
my $root = XIMS::Object->new( id => 1 );
isa_ok( $root, 'XIMS::Object' );

# Build Test Hierachy
my $testroot = XIMS::SiteRoot->new(
    User        => $user,
    parent_id   => $root->document_id(),
    language_id => $root->language_id(),
    location    => "unittest-88",
    title       => "Test Site",
);
ok( $testroot->create() );

my $testdept = XIMS::DepartmentRoot->new(
    User        => $user,
    parent_id   => $testroot->document_id(),
    language_id => $testroot->language_id(),
    location    => "testdept",
    title       => "Test Dept.",
);

ok( $testdept->create() );
isa_ok( $testdept, 'XIMS::DepartmentRoot' );

my %folders;
foreach my $name ( qw(stylesheets pubstylesheets images scripts folder) ) {
    $folders{$name} = XIMS::Folder->new(
        User        => $user,
        parent_id   => $testdept->document_id(),
        language_id => $testdept->language_id(),
        location    => $name,
        title       => ucfirst($name),
    );
    ok(  $folders{$name}->create() );
}

# single Objects
my $css = XIMS::CSS->new(
    User        => $user,
    parent_id   => $folders{stylesheets}->document_id(),
    location    => 'css.css',
    title       => 'CSS',
);
ok(  $css->create() );

my $pubstylesheet = XIMS::XSLStylesheet->new(
    User        => $user,
    parent_id   => $folders{pubstylesheets}->document_id(),
    location    => 'xsl.xsl',
    title       => 'XSL',
);
ok(  $pubstylesheet->create() );

my $image = XIMS::Image->new(
    User        => $user,
    parent_id   => $folders{images}->document_id(),
    location    => 'image.png',
    title       => 'Image',
);
ok( $image->create() );

my $script = XIMS::JavaScript->new(
    User        => $user,
    parent_id   => $folders{scripts}->document_id(),
    location    => 'js.js',
    title       => 'JS',
);
ok( $script->create() );

my $dept1 = XIMS::DepartmentRoot->new(
    User        => $user,
    parent_id   => $folders{folder}->document_id(),
    location    => 'dept1',
    title       => 'Dept1',
);
ok( $dept1->create() );

my $doc1 = XIMS::Document->new(
    User        => $user,
    parent_id   => $testdept->document_id(),
    location    => 'doc1.html',
    title       => 'Doc1',
);
ok( $doc1->create() );

my $doc2 = XIMS::Document->new(
    User        => $user,
    parent_id   => $folders{folder}->document_id(),
    location    => 'doc2.html',
    title       => 'Doc2',
);
ok( $doc2->create() );

my $doc3 = XIMS::Document->new(
    User        => $user,
    parent_id   => $dept1->document_id(),
    location    => 'doc3.html',
    title       => 'Doc3',
);
ok( $doc3->create() );

my $ptlt = XIMS::Portlet->new(
    User        => $user,
    parent_id   => $testdept->document_id(),
    location    => 'ptlt.ptlt',
    title       => 'PTLT',
);
ok( $ptlt->create() );

ok( $testdept->add_portlet($ptlt), 'add Portlet');

ok( $testdept->image_id( $image->document_id() ) );
ok( $testdept->feed_id( $ptlt->document_id() ) );
ok( $testdept->css_id( $css->document_id() ) );
ok( $testdept->script_id( $script->document_id() ) );
ok( $testdept->style_id( $folders{pubstylesheets}->document_id() ) );
ok( $testdept->update() );

is( $testdept->image_id(), $image->document_id() );
is( $testdept->feed_id(), $ptlt->document_id() );
is( $testdept->css_id(), $css->document_id() );
is( $testdept->script_id(), $script->document_id() );
is( $testdept->style_id(), $folders{pubstylesheets}->document_id() );

# testing department_ids before conversion
is( $testdept->department_id(), $testroot->document_id(), 'Testdepartment has correct Department Id.' );
is( $folders{stylesheets}->department_id(), $testdept->document_id(), 'Stylesheets has correct Department Id.' );
is( $folders{pubstylesheets}->department_id(), $testdept->document_id(), 'Pubstylsheets has correct Department Id.' );
is( $folders{images}->department_id(), $testdept->document_id(), 'Images has correct Department Id.' );
is( $folders{scripts}->department_id(), $testdept->document_id(), 'Scripts has correct Department Id.' );
is( $folders{folder}->department_id(), $testdept->document_id(), 'Folder has correct Department Id.' );
is($css->department_id(), $testdept->document_id(), 'CSS has correct Department Id.' );
is($pubstylesheet->department_id(), $testdept->document_id(), 'XSL has correct Department Id.' );
is($image->department_id(), $testdept->document_id(), 'Image has correct Department Id.' );
is($script->department_id(), $testdept->document_id(), 'JS has correct Department Id.' );
is($ptlt->department_id(), $testdept->document_id(), 'Portlet has correct Department Id.' );
is($dept1->department_id(), $testdept->document_id(), 'Dept1 has correct Department Id.' );
is($doc1->department_id(), $testdept->document_id(), 'Doc1 has correct Department Id.' );
is($doc2->department_id(), $testdept->document_id(), 'Doc2 has correct Department Id.' );
is($doc3->department_id(), $dept1->document_id(), 'Doc3 has correct Department Id.' );


ok( $testdept->convert2folder );

# reinstantiate Objects from database for subsequent tests
my $converted = XIMS::Object->new(document_id => $testdept->document_id);
is($converted->object_type->fullname, 'Folder', 'Testdepartment is a folder now.');
is($converted->department_id, $testroot->document_id, 'Testdepartment has correct Department Id.');

is( $converted->image_id(), undef, 'Empty image_id');
is( $converted->feed_id(), undef, 'Empty feed_id');
is( $converted->css_id(), undef, 'Empty css_id' );
is( $converted->script_id(), undef, 'Empty script_id' );
is( $converted->style_id(), undef, 'Empty style_id' );
is( $converted->attributes(), undef, 'Empty attributes' );
is( $converted->body(), ' ', 'Empty body (no Portlets)' );
print $converted->notes()."\n";

is(XIMS::Object->new(document_id => $folders{stylesheets}->document_id)->department_id, $testroot->document_id, 'Stylesheets has correct Department Id.' );
is(XIMS::Object->new(document_id => $folders{pubstylesheets}->document_id)->department_id(), $testroot->document_id, 'Pubstylsheets has correct Department Id.' );
is(XIMS::Object->new(document_id => $folders{images}->document_id)->department_id(), $testroot->document_id, 'Images has correct Department Id.' );
is(XIMS::Object->new(document_id => $folders{scripts}->document_id)->department_id(), $testroot->document_id, 'Scripts has correct Department Id.' );
is(XIMS::Object->new(document_id => $folders{folder}->document_id)->department_id(), $testroot->document_id, 'Folder has correct Department Id.' );
is(XIMS::Object->new(document_id => $css->document_id)->department_id(), $testroot->document_id, 'CSS has correct Department Id.' );
is(XIMS::Object->new(document_id => $pubstylesheet->document_id)->department_id(), $testroot->document_id, 'XSL has correct Department Id.' );
is(XIMS::Object->new(document_id => $image->document_id)->department_id(), $testroot->document_id, 'Image has correct Department Id.' );
is(XIMS::Object->new(document_id => $script->document_id)->department_id(), $testroot->document_id, 'JS has correct Department Id.' );
is(XIMS::Object->new(document_id => $ptlt->document_id)->department_id(), $testroot->document_id, 'Portlet has correct Department Id.' );
is(XIMS::Object->new(document_id => $dept1->document_id)->department_id(), $testroot->document_id, 'Dept1 has correct Department Id.' );
is(XIMS::Object->new(document_id => $doc1->document_id)->department_id(), $testroot->document_id, 'Doc1 has correct Department Id.' );
is(XIMS::Object->new(document_id => $doc2->document_id)->department_id(), $testroot->document_id, 'Doc2 has correct Department Id.' );
is(XIMS::Object->new(document_id => $doc3->document_id)->department_id, $dept1->document_id, 'Doc3 has correct Department Id.' );

ok( $testroot->delete(), 'delete testfolder');


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

