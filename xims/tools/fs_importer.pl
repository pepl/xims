#!/usr/bin/perl -w
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use vars qw( @files @links );
use warnings;
no warnings 'redefine';

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";
use lib qw(lib ../lib),($ENV{'XIMS_PREFIX'} || '/usr/local')."/xims/lib";

use XIMS::Importer::FileSystem;
use XIMS::Auth;
use XIMS::Object;

use File::Find;
use File::Basename;
use Getopt::Std;

# untaint path
$ENV{PATH} = '/bin'; # CWD.pm needs '/bin/pwd'

my %args;
getopts('hd:u:p:m:', \%args);

print q*
  __  _____ __  __ ____
  \ \/ /_ _|  \/  / ___|
   \  / | || |\/| \___ \
   /  \ | || |  | |___) |
  /_/\_\___|_|  |_|____/

  File System Importer Tool

*;

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{m} and $ARGV[0] ) {
    die usage();
}

my $username;
my $password;
if ( not ($args{u} and $args{p}) ) {
    ($username, $password) = interactive_user_pass( $args{u} );
}
else {
    $username = $args{u};
    $password = $args{p};
}

my $user = XIMS::Auth->new( Username => $username, Password => $password )->authenticate();
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $parent = XIMS::Object->new( path => $args{m} );
die "Could not find object '".$args{m}."'\n" unless $parent and $parent->id();

my $privmask = $user->object_privmask( $parent );
die "Access Denied. You do not have privileges to create objects under '".$args{m}."'\n" unless $privmask & XIMS::Privileges::CREATE();

my $path = $ARGV[0];
die "Could not read '$path'\n" unless -f $path or -d $path;
die "Cannot import from symlink directory '$path'\n" if -l $path and -d $path;
# untaint the path
$path = $1 if $path =~ /^(.*)$/;

File::Find::find({wanted => \&process, untaint => 1}, $path);
push (@files, @links); # add the processed links to the files
die "No files found, nothing to do.\n" unless scalar(@files);

my $importer = XIMS::Importer::FileSystem->new( User => $user, Parent => $parent );

my $successful = 0;
my $failed = 0;
$path = dirname $path;
if ( $path eq "." ) {
    $path = '';
}
else {
    chdir $path;
}
foreach my $file ( @files ) {
    $file =~ s/$path\/// if length $path;
    if ( $importer->import( $file ) ) {
        print "'$path/$file' imported successfully.\n";
        $successful++;
    }
    else {
        print "Import of '$path/$file' failed.\n";
        $failed++;
    }
}

my $total = scalar @files;
print qq*
    Import Report:
        Total files:            $total
        Successfully imported:  $successful
        Failed imports:         $failed

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] -m xims-mount-path path-to-import
        -m The XIMS path to import to.
        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

sub process {
    if ( not -l $File::Find::dir ) {
        if ( not -l $File::Find::name ) {
            push (@files, $File::Find::name);
        }
        else {
            push (@links, $File::Find::name);
        }
    }
}

sub XIMS::DEBUGLEVEL () { $args{d} || 1 }

sub interactive_user_pass {
    my $unarg = shift;
    my ($username, $password);
    print "\nLogin to XIMS\n\n";
    $username = _prompt("Username",$unarg);
    $password = _prompt("Password",undef,1);
    print "\n";
    return ($username, $password);
}

sub _prompt {
    my ($prompt, $def, $noecho) = @_;
    print $prompt . ($def ? " [$def]" : "") . ": ";
    if ($noecho) {
        return _read_passphrase( $prompt );
    }
    else {
        chomp(my $ans = <STDIN>);
        return $ans ? $ans : $def;
    }
}

sub _read_passphrase {
    require Term::ReadKey;
    Term::ReadKey->import;
    ReadMode('noecho');
    chomp(my $password = ReadLine(0));
    ReadMode('restore');
    print "\n";
    return $password;
}




