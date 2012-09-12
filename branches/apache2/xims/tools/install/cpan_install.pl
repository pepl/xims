#!/usr/bin/perl -w
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::Installer;
use Getopt::Std;

eval { require Apache; };
if ( $@ || $Apache::VERSION < 1.25) {
    die "\nCould not load Apache. Make sure mod_perl is installed and working!\n\n";
}

my %args;
getopts('hcm:', \%args);

if ( $args{h} ) {
print qq*

  Usage: $0 [-c|-h|-m comma-separated-list-of-modules]
    -c checks for missing modules only
    -m comma separated list of modules to be installed
    -h prints this screen

*;
    exit;
}

die "CPAN installation needs root privileges.\n" unless ($args{c} or $> == 0);

my $installer = XIMS::Installer->new();

my @to_install;
if ( $args{m} ) {
    my @modnames = split(',', $args{m});
    @to_install = $installer->expand_mods( @modnames );
}
else {
    @to_install = $installer->check_required_mods();
}

my @failed = ();

print "\033[1m"; # turn bold on, not to confuse our messages with the CPAN output
if ( scalar(@to_install) > 0 ) {
    print "\nThe following modules ";
    if ( $args{c} ) {
        print "are missing in your installation:\n\n";
    }
    else {
        print "will be installed:\n\n";
    }

    foreach my $module ( @to_install ) {
        print $module->id . " " . $module->cpan_version() . "\n";
    }
    print "\n";

    if ( $args{c} ) {
        #print "Rerun without '-c' to install them.\n\n";
    }
    else {
        print "Press enter to start with installation.\n";<STDIN>;

        print "\033[m"; # turn bold off
        foreach my $module ( @to_install ) {
            if ( $module->id() eq 'XML::Parser::PerlSAX' ) {
                #XML::Parser::PerlSAX has XML::Parser as dependency,
                #XML::Parser will fail at the tests unless you have expat installed.
                #there is a known bug in one of libxml-perl-0.07's tests:
                #(http://rt.cpan.org/NoAuth/Bug.html?id=135)
                #therefore, we have to force install
                #my $xmlparser = CPAN::Shell->expand('Module','XML::Parser');
                #$xmlparser->force();
                #$xmlparser->install();
                $module->force();
            }
            $module->install();
            push( @failed, $module) if $? != 0;
        }
        print "\033[1m";

        if ( scalar(@failed) > 0 ) {
            print "\nThe following modules could not be installed:\n\n";
            foreach my $module ( @failed ) {
                print $module->id . " " . $module->cpan_version() . "\n";
            }
            _try_cpanshell($installer);
        }
        else {
            # we can't rely on the return value of $module->install(),
            # so we'll double-check here
            @to_install = $installer->check_required_mods();
            if ( scalar(@to_install) > 0 ) {
                print "\nThe following modules could not be installed:\n\n";
                foreach my $module ( @to_install ) {
                    print $module->id . " " . $module->cpan_version() . "\n";
                }
                _try_cpanshell($installer);
            }
            else {
                print "\nSuccessfully installed missing modules.\n\n";
            }
        }
    }
}
elsif ( scalar(@to_install) == 0 ) {
    print "\nAll required modules found.\n\n";
}
print "\033[m";

sub _try_cpanshell {
    my $installer = shift;

    print "\nPress enter to try installing via CPAN shell.\n";<STDIN>;

    print "\033[m";
    CPAN::Shell->install('Bundle::XIMS');
    print "\033[1m";

    # next try...
    @to_install = $installer->check_required_mods();
    if ( scalar(@to_install) > 0 ) {
        print "\nThe following modules could not be installed:\n\n";
        foreach my $module ( @to_install ) {
            print $module->id . " " . $module->cpan_version() . "\n";
        }
        die "\nPlease retry, adjust build options and/or install them manually.\033[m\n";
    }

    print "\nAll required modules found\033[m.\n\n";
}

__END__

=head1 NAME

cpan_install.pl

=head1 SYNOPSIS

cpan_install.pl [-c|-h|-m comma-separated-list-of-modules]

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-c>

checks for missing modules only

=item B<-m>

comma separated list of modules to be installed

=back

=cut
