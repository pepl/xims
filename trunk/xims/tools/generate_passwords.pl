#!/usr/bin/perl -w

# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

use strict;
use Crypt::GeneratePassword qw(word);
use Digest::MD5 qw(md5_hex);

while (<>) {
    my $username = $_;
    chomp $username;
    my $password = word(8,8,'en',0, 3 );
    print $username . "\t" . $password . "\t" . md5_hex($password) . "\n";
}
