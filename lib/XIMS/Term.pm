# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Term;

use strict;
# use warnings;
no warnings 'redefine';
use Encode;
use XIMS::Auth;
use File::Find;
use Term::ReadKey;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @files;
our @links;

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless {}, $class;
    $self->debuglevel( $args{debuglevel} );

    return $self;
}

sub debuglevel {
    my $self = shift;
    my $debuglevel = shift;

    if ( not $self->{debuglevel} or defined $debuglevel ) {
        *XIMS::DEBUGLEVEL = sub () { $debuglevel || 1 };
        $self->{debuglevel} = $debuglevel;
        return $debuglevel;
    }
    else {
        return $self->{debuglevel};
    }
}

sub authenticate {
    my $self = shift;
    my %args = @_;

    my $username;
    my $password;
    if ( not ($args{u} and $args{p}) ) {
        ($username, $password) = $self->interactive_user_pass( $args{u} );
    }
    else {
        $username = $args{u};
        $password = $args{p};
    }

    return XIMS::Auth->new( Username => $username, Password => $password )->authenticate();
}

sub banner {
    my $self = shift;
    my $name = shift;

return q*
  __  _____ __  __ ____
  \ \/ /_ _|  \/  / ___|
   \  / | || |\/| \___ \
   /  \ | || |  | |___) |
  /_/\_\___|_|  |_|____/

* . qq*
  $name

*;
}

sub interactive_user_pass {
    my $self = shift;
    my $unarg = shift;
    my ($username, $password);
    print "\nLogin to XIMS\n\n";
    $username = $self->_prompt("Username",$unarg);
    $password = $self->_prompt("Password",undef,1);
    print "\n";
    return ($username, $password);
}

sub findfiles {
    my $self = shift;
    my $path = shift;
    File::Find::find({wanted => \&_process, untaint => 1}, $path);
    push (@files, @links); # add the processed links to the files
    return @files;
}

sub _prompt {
    my $self = shift;
    my ($prompt, $def, $noecho) = @_;
    print $prompt . ($def ? " [$def]" : "") . ": ";
    if ($noecho) {
        return $self->_read_passphrase( $prompt );
    }
    else {
        chomp(my $ans = <STDIN>);
        return $ans ? $ans : $def;
    }
}

sub _read_passphrase {
    my $self = shift;
    ReadMode('noecho');
    chomp(my $password = ReadLine(0));
    ReadMode('restore');
    print "\n";
    return $password;
}

sub _process {
    if ( not -l $File::Find::dir ) {
        if ( not -l $File::Find::name ) {
            push (@files, $File::Find::name);
        }
        else {
            push (@links, $File::Find::name);
        }
    }
}

sub utf8_sanitize {
    my $self = shift;
    my $string = shift;
    if ( _is_notutf8( $string ) ) {
        return Encode::encode_utf8($string);
    }
    else {
        return $string;
    }
}

# poor man's check
sub _is_notutf8 {
    eval {Encode::decode_utf8(shift, Encode::FB_CROAK)};
    return 0 unless $@;
    return 1;
}

1;