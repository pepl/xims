#!/usr/bin/env perl -w

# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

use strict;
use Crypt::GeneratePassword qw(word);
use Authen::Passphrase::BlowfishCrypt;
 
while (<>) {
    my $username = $_;
    chomp $username;
    my $password = word(10,10,'en',0, 3);
    my $ppr = Authen::Passphrase::BlowfishCrypt->new( cost => 12, 
                                                      salt_random => 1,
                                                      passphrase => $password );
 
    print $username . "\t" . $password . "\t" . $ppr->as_crypt . "\n";
}
