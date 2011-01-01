
=head1 NAME

XIMS::Term -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::Term;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::Term;

use strict;
# use warnings;
no warnings 'redefine';
use Encode;
use File::Find;
use Term::ReadKey;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );
our @files;
our @links;

=head2 new()

=cut

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless {}, $class;
    $self->debuglevel( $args{debuglevel} );

    return $self;
}

=head2 debuglevel()

=cut

sub debuglevel {
    my $self = shift;
    my $debuglevel = shift;

    if ( not $self->{debuglevel} or defined $debuglevel ) {
        *XIMS::DEBUGLEVEL = sub () { $debuglevel || 1 };
        $self->{debuglevel} = $debuglevel;
        my $dp;
        eval { $dp = XIMS::DATAPROVIDER() };
        if ( $debuglevel < 6 and not $@ ) {
            $dp->driver->dbh->SQLLogging(0);
        }
        return $debuglevel;
    }
    else {
        return $self->{debuglevel};
    }
}

=head2 authenticate()

=cut

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

    my $auth;
    eval { require XIMS::Auth; };
    if ( $@ ) {
        die "Could not load XIMS::Auth $@\n";
    }
    else {
        $auth = XIMS::Auth->new( Username => $username, Password => $password );
    }

    return $auth->authenticate();
}

=head2 banner()

=cut

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

=head2 interactive_user_pass()

=cut

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

=head2 findfiles()

=cut

sub findfiles {
    my $self = shift;
    my $path = shift;
    File::Find::find({wanted => \&_process, untaint => 1}, $path);
    push (@files, @links); # add the processed links to the files
    return @files;
}

=head2 private functions/methods

=over

=item _prompt()

=item _read_passphrase()

=item _process()

=back

=cut

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

=head2 utf8_sanitize()

=cut

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
__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2011 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

