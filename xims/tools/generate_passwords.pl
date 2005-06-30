#!/usr/bin/perl -w

use Crypt::GeneratePassword qw(word);
use Digest::MD5 qw(md5_hex);

while (<>) {
    my $username = $_;
    chomp $username;
    my $password = word(8,8,'en',0, 3 );
    print $username . "\t" . $password . "\t" . md5_hex($password) . "\n"; 
}
