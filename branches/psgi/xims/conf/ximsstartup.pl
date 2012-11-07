use strict;

# Make sure we are in a sane environment.
$ENV{MOD_PERL} or die "not running under mod_perl!";

use Apache::DBI ();
use XML::LibXSLT ();

# allow deeper recursion (default 250)
XML::LibXSLT->max_depth(500);

# DBD preloading, uncomment to suit your needs
# DBI->install_driver("Pg");
# DBI->install_driver("Oracle");

# use AxKit ();

use lib qw( /usr/local/xims/lib );
use goxims ();

1;
