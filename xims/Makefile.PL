#!/usr/bin/perl -w

use strict;
use Config;
use File::Copy;

my $old = 'Makefile';
my $new = 'Makefile.new';

open OLD, "<", $old or die "Unable to open $old: $!\n";
open NEW, ">", $new or die "Unable to open $new: $!\n";
my $flag;
while (<OLD>) {
    if ($flag) {
        print NEW;
        next;
    }
    elsif (/^PERL\s*=\s*/) {
        print NEW "PERL = $Config{perlpath}\n";
    }
    else {
        print NEW;
    }
}

close OLD;
close NEW;

move $new, $old;

