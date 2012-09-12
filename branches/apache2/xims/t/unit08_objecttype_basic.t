use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::Names;
use XIMS::ObjectType;
#use Data::Dumper;

BEGIN {
    plan tests => 36;
}

my $ot = XIMS::ObjectType->new();
ok( $ot );

#  now try loading one by hand
$ot->id( 99 );
$ot->name( 'UbuDoc' );
$ot->is_fs_container( 0 );
$ot->is_xims_data( 1 );
$ot->redir_to_self( 1 );

ok( $ot->id() == 99 );
ok( $ot->name() eq 'UbuDoc' );
ok( $ot->is_fs_container() == 0 );
ok( $ot->is_xims_data() == 1 );
ok( $ot->redir_to_self() == 1 );

# same, but via the Perlish shortcut
my %hash = ( id => 99,
             name => 'UbuDoc',
             is_fs_container => 0,
             is_xims_data => 1,
             redir_to_self => 1
           );

$ot = undef;
$ot = XIMS::ObjectType->new->data( %hash );

ok( $ot );
ok( $ot->id() == 99 );
ok( $ot->name() eq 'UbuDoc' );
ok( $ot->is_fs_container() == 0 );
ok( $ot->is_xims_data() == 1 );
ok( $ot->redir_to_self() == 1 );

# now let's fetch a real one
$ot = undef;
$ot = XIMS::ObjectType->new( id => 2 );
ok( $ot );
ok( $ot->id() == 2 );
ok( $ot->name() eq 'Document' );
ok( $ot->is_fs_container() == 0 );
ok( $ot->is_xims_data() == 1 );
ok( $ot->redir_to_self() == 1 );

# now, let's create a new one and serialize it.
$ot = undef;

$ot = XIMS::ObjectType->new();
$ot->name( 'UbuDoc' );
$ot->is_fs_container( 0 );
$ot->is_xims_data( 1 );
$ot->redir_to_self( 1 );

my $id = $ot->create();
ok( $id and $id > 2 );

# now fetch the one we just created and check that
# the data made it into the DB

$ot = undef;
$ot = XIMS::ObjectType->new( id => $id );

ok( $ot );
ok( $ot->id() == $id );
ok( $ot->name() eq 'UbuDoc' );
ok( $ot->is_fs_container() == 0 );
ok( $ot->is_xims_data() == 1 );
ok( $ot->redir_to_self() == 1 );

# now alter it...

$ot->name( 'UnitTestDoc' );
ok ( $ot->update() );

# fetch again
$ot = undef;
$ot = XIMS::ObjectType->new( id => $id );

ok( $ot );
ok( $ot->id() == $id );
ok( $ot->name() eq 'UnitTestDoc' );
ok( $ot->is_fs_container() == 0 );
ok( $ot->is_xims_data() == 1 );
ok( $ot->redir_to_self() == 1 );

# finally, delete the bogus ot.

ok ( $ot->delete() );

# and make sure...
$ot = undef;
$ot = XIMS::ObjectType->new( id => $id );

ok( not defined $ot );

# test hierarchic object types
$ot = XIMS::ObjectType->new( fullname => 'VLibraryItem::DocBookXML' );
ok( $ot->id() );

warn "You should see a warning about an ambigous object type lookup following.\n";
$ot = XIMS::ObjectType->new( name => 'DocBookXML' );
ok( not defined $ot );





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

