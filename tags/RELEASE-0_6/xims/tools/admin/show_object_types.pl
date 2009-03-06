#!/usr/bin/perl -w

# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

# Alternative to `psql -U xims -c 'select * from ci_object_types;'` ;-)

use strict;
use warnings;
use strict;
use warnings;

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";
use lib ($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/lib",($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/tools/lib";

use XIMS;
use XIMS::ObjectType;
use XIMS::Term;

my $term = XIMS::Term->new( debuglevel => 1 );
print $term->banner( "Object Type Dumper" );

my $ot = XIMS::ObjectType->new();
my @object_types = XIMS::ObjectType->new->data_provider->object_types();
my $format = "%-30s %-3s %-15s %-13s %-13s %-13s\n";

print sprintf($format, "Name", "ID", "Is FS-Container", "Is XIMS-Data", "Redir To Self", "publish_gopublic");
print "="x95 . "\n";

foreach my $ot ( @object_types ) {
    print sprintf($format, $ot->name(), $ot->id(), $ot->is_fs_container(), $ot->is_xims_data, $ot->redir_to_self, $ot->publish_gopublic);
}
