#!/usr/bin/perl -w

# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

use CPAN;
use File::Copy;

print q*
  __  _____ __  __ ____
  \ \/ /_ _|  \/  / ___|
   \  / | || |\/| \___ \
   /  \ | || |  | |___) |
  /_/\_\___|_|  |_|____/

  Module Patcher (Hopefully not needed any more some time.)

*;

print "\033[1m"; # turn bold on, not to confuse our messages with the CPAN output
print "Trying to patch AxKit::XSP:WebUtils.\n\n";
patch_webutils();
print "\033[m";

sub patch_webutils {
    print "\033[m"; # turn bold off
    my $module = CPAN::Shell->expand('Module','AxKit::XSP::WebUtils');
    print "\033[1m\n";
    die "AxKit::XSP::WebUtils is not installed.\n" unless $module->inst_file();

    my $file = $module->inst_file();
    my ( $axkit_xsp_dir ) = $file =~ /(.*)\/WebUtils.pm$/;
    die "Could not change to $axkit_xsp_dir.\033[m\n" unless chdir $axkit_xsp_dir;

    if ( -f $file and -w $file ) {
        if ( $module->inst_version eq '1.5' ) {
            my $filesize = (stat($file))[7];
            (print "$file has incorrect file size. Perhaps it has been patched before? Will keep $file untouched.\033[m\n\n" and exit) unless $filesize == 7978;

            print "Creating backup copy.\n";
            copy('WebUtils.pm','WebUtils.pm-1.5_ximbackupcopy') or die "Could not create backup copy: $!\033[m\n";

            print "Patching '" . $file . "'.\n";
            eval {
                `patch -p0 < /usr/local/xims/patches/WebUtils.pm-1.5.diff`;
            };
            if ( $@ ) {
                die "Patch failed: $@. Do you have patch installed and in your path?\033[m\n";
            }
            print "Patch successful.\n\n";
        }
        else {
            die "Patch is for AxKit::XSP::WebUtils version 1.5 only. You have got " . $module->inst_version() . " installed.\033[m\n";
        }

    }
    else {
        die "WebUtils.pm could not be found or is not writable.\033[m\n";
    }

}

