#!/usr/bin/perl -w

# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

# Alternative to `psql -U xims -c 'select * from ci_odata_formats;'` ;-)

use strict;
use warnings;
no warnings 'redefine';

use lib qw(/usr/local/xims/lib);
use XIMS::DataFormat;

my $df = XIMS::DataFormat->new();
my @data_formats = XIMS::DataFormat->new->data_provider->data_formats();
my $format = "%-25s %-3s %-35s %-5s\n";

print sprintf($format, "Name", "ID", "Mime Type", "Suffix");
print "="x72 . "\n";

foreach my $df ( @data_formats ) {
    print sprintf($format, $df->name(), $df->id(), $df->mime_type, $df->suffix||'');
}

sub XIMS::Config::DebugLevel() { 1 }