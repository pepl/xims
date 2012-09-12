use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::User;
use XIMS::Object;
use XIMS::Document;
use XIMS::Image;

BEGIN {
    plan tests => 8;
}

# we need a User object to fill in the right data
my $user = XIMS::User->new( id => 2 );
ok( $user );
ok( $user->name() eq 'admin' );

my $body = qq|<p><h1>This is only a test!</h1></p>|;

my %doc_hash = ( language_id => 1,
                 location => 'testdoc.xml',
                 title    => 'my test document',
                 parent_id => 2,
                 department_id => 2,
                 body => $body,
               );

my $o = XIMS::Document->new->data( %doc_hash );
my $o_id = $o->create( User => $user );
ok( $o_id and $o_id > 1 );

# now fetch it back and check the body;

$o = undef;

$o = XIMS::Object->new( id => $o_id, User => $user );

ok( length( $o->body() ) == length( $body ) );

# now clean up
$o->delete();
# and make sure...
$o = undef;
$o = XIMS::Object->new( id => $o_id );
ok( not defined $o );


# now test binary object goodness.
open( IMG, "misc/ubu_small.png" ) || die "could not open image, aborting";
local $/ = undef;
my $img_data = <IMG>;
close IMG;

my %img_hash = ( language_id => 1,
                 location => 'ubu_small.png',
                 title    => 'fezzes rule!',
                 parent_id => 2,
                 department_id => 2,
                 data_format_id => 15,
                 body => $img_data,
               );

my $img = XIMS::Image->new->data( %img_hash );

my $i_id = $img->create( User => $user );
ok( $i_id and $i_id > 1 );

# now fetch it back and check the body;
$img = undef;
$img = XIMS::Object->new( id => $i_id, User => $user );
ok( length( $img->body() ) == length( $img_data ) );

# now clean up
$img->delete();

# and make sure...
$img = undef;
$img = XIMS::Object->new( id => $o_id );
ok( not defined $img );


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

