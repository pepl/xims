use strict;

# Make sure we are in a sane environment.
$ENV{MOD_PERL} or die "not running under mod_perl!";

use Apache::DBI ();
# use AxKit ();

use lib qw( /usr/local/xims/lib );
use goxims ();

1;
