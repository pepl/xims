use Test::More tests => 10;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
#use Data::Dumper;

BEGIN {
    use_ok('XIMS::Object');
}

# we need a User object to determine grants
my $admin = XIMS::User->new( id => 2 );
isa_ok( $admin, 'XIMS::User' );

my $o = XIMS::Object->new( id => 1 );
isa_ok( $o, 'XIMS::Object' );

my @granted_kids = $o->children_granted( User => $admin );
my $granted_kids_iterator = $o->children_granted( User => $admin );
cmp_ok( scalar( @granted_kids ), '>=',  1, 'found granted kids for admin' );
cmp_ok( $granted_kids_iterator->getLength(), '>=',  1, 'found granted kids for admin (iterator interface)' );
is( scalar( @granted_kids ), $granted_kids_iterator->getLength(), 'sanity check array-iterator interface' );

@granted_kids = ();

my $guest = XIMS::User->new( id => 1 );
isa_ok( $guest, 'XIMS::User' );

@granted_kids = $o->children_granted( User => $guest );
$granted_kids_iterator = $o->children_granted( User => $guest );

cmp_ok( scalar( @granted_kids ), '>=',  1, 'found granted kids for guest' );
cmp_ok( $granted_kids_iterator->getLength(), '>=',  1, 'found granted kids for guest (iterator interface)' );
is( scalar( @granted_kids ), $granted_kids_iterator->getLength(), 'sanity check array-iterator interface' );


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

