#!/usr/bin/perl -w
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

# Alternative to `psql -U xims -c 'select * from ci_odata_formats;'` ;-)

use strict;
use warnings;

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";
use lib ($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/lib",($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/tools/lib";

use XIMS;
use XIMS::DataFormat;
use XIMS::Term;

my $term = XIMS::Term->new( debuglevel => 1 );
print $term->banner( "Data Format Dumper" );

my $df = XIMS::DataFormat->new();
my @data_formats = XIMS::DataFormat->new->data_provider->data_formats();
my $format = "%-25s %-3s %-35s %-5s\n";

print sprintf($format, "Name", "ID", "Mime Type", "Suffix");
print "="x72 . "\n";

foreach my $df ( @data_formats ) {
    print sprintf($format, $df->name(), $df->id(), $df->mime_type, $df->suffix||'');
}
