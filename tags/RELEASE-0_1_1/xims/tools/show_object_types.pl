#!/usr/bin/perl -w

# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

# Alternative to `psql -U xims -c 'select * from ci_object_types;'` ;-)

use strict;
use warnings;
no warnings 'redefine';

use lib qw(lib ../lib /usr/local/xims/lib);
use XIMS::ObjectType;

my $ot = XIMS::ObjectType->new();
my @object_types = XIMS::ObjectType->new->data_provider->object_types();
my $format = "%-30s %-3s %-15s %-13s %-13s\n";

print sprintf($format, "Name", "ID", "Is FS-Container", "Is XIMS-Data", "Redir To Self");
print "="x72 . "\n";

foreach my $ot ( @object_types ) {
    print sprintf($format, $ot->name(), $ot->id(), $ot->is_fs_container(), $ot->is_xims_data, $ot->redir_to_self);
}

sub XIMS::Config::DebugLevel() { 1 }
