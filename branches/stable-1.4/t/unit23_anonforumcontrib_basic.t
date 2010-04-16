use Test;
use strict;
use lib "../lib", "lib";
use XIMS::Test;
use XIMS::AnonDiscussionForumContrib;
#use Data::Dumper;

BEGIN {
    plan tests => 17;
}

# make a simple one, test that the objecttype and data_formats are set by the constructor

ok( XIMS::AnonDiscussionForumContrib::__limit_string_length('   1234567890    ', 5 ) eq '12345' );

my $o = XIMS::AnonDiscussionForumContrib->new();

ok( $o );
ok( $o->isa('XIMS::AnonDiscussionForumContrib') );

my $ot = XIMS::ObjectType->new( id => $o->object_type_id() );
my $df = XIMS::DataFormat->new( id => $o->data_format_id() );

ok( $ot );
ok( $df );
ok( $ot->name() eq 'AnonDiscussionForumContrib' );
ok( $df->name() eq 'HTML' );

ok( $o->author('Arthure de Author') );
ok( $o->email('arthure@exemple.org')  );
ok( $o->coauthor('Gutave de Author Gutave de Author Gutave de Author') );
ok( $o->coemail('gustave@exemple.org') );
ok( $o->senderip('199.555.555.555') );

ok( $o->author() eq 'Arthure de Author' );
ok( $o->email() eq 'arthure@exemple.org'  );
ok( $o->coauthor() eq 'Gutave de Author Gutave de Aut' );
ok( $o->coemail() eq 'gustave@exemple.org' );
ok( $o->senderip() eq '199.555.555.555' );


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

