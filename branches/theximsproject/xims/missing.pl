#!/usr/bin/perl
#
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# contains code taken from the Perl Cookbook
#                          by Tom Christiansen & Nathan Torkington;
# $Id$


use strict;
print q*

     -  -  - - ---[ Whats Missing? ]---  - -  -  -

          @@@  @@@  @@@  @@@@@@@@@@    @@@@@@
          @@@  @@@  @@@  @@@@@@@@@@@  @@@@@@@
          @@!  !@@  @@!  @@! @@! @@!  !@@
          !@!  @!!  !@!  !@! !@! !@!  !@!
           !@@!@!   !!@  @!! !!@ @!@  !!@@!!
            @!!!    !!!  !@!   ! !@!   !!@!!!
           !: :!!   !!:  !!:     !!:       !:!
          :!:  !:!  :!:  :!:     :!:      !:!
           ::  :::   ::  :::     ::   :::: ::
           :   ::   :     :      :    :: : :



This is should help you to find missing Perl modules.
Find and press the [ANY]-Key on your Keyboard to continue ;-)

*; <STDIN>;

my %missing;
my @modules = ( "DBI",
                "AxKit",
                "XML::LibXSLT 1.49",
                "XML::LibXML 1.52",
                "AxKit::XSP::Param",
                "AxKit::XSP::IfParam",
                "AxKit::XSP::WebUtils",
                "Apache::AxKit::Plugin::AddXSLParams::Request",
                "Apache::AxKit::StyleChooser::QS_UA",
                "Digest::MD5",
                "Storable",
                "Net::LDAP",
                "XML::SAX::Machines",
                "XML::Parser::PerlSAX",
                "XML::Generator::PerlData",
                "XML::Filter::GenericChunk",
                "CGI::XMLApplication 1.1.2",
                "DBIx::SQLEngine 0.0.8",
                "Class::MethodMaker",
                "Time::Piece",
                "XML::Schematron"
              );


foreach (@modules) {
    eval  "use $_;";
    # fill $@ if we find the broken LibXML
    if ( /XML::LibXML/ and getversion("XML::LibXML") =~ /1.53/ ) {
        $@ .= "\n\033[4mNOTE:\033[m\tXML::LibXML Version 1.53 was found, which is known to be broken.\n"
           .  "\tPlease downgrade to 1.52 or use the releases from 1.54_x on!\n\n"; }
    $missing{$_} = $@ if length $@;
    
}


foreach ( keys(%missing) ) {
    print "\033[1m$_\033[m is missing!\n\n";
    if ( $missing{$_} =~ /this is only version/ ) {
        print "We need a newer version of this module, please upgrade at least to \033[4m$_\033[m\n\n";
        next;
    }
    if ( /Net::LDAP/ ) {
        print "\033[4mNote:\033[m\tNet::LDAP is only required if you want LDAP authentication\n"
            . "\tYou can safely omit it, if you do not expect to use this feature.\n\n";
        delete $missing{$_};
        next;
    }
    if ( /XML::Schematron/ ) {
        print "\033[4mNOTE:\033[m\tXML::Schematron is only required for the tests;\n"
            . "\tYou can safely omit it, if you do not expect to use this feature.\n\n";
        delete $missing{$_};
        next;
    }
    print "\"use $_;\" failed with the following message:\n$missing{$_}\n\n";
}

if ( scalar( %missing ) ) {
    print "\033[1mOne of the required modules is missing or does not compile, please recheck!\033[m\n\n";
}
else {
    print "The required modules are present and compiling, enjoy!\n\n";
}

# run Perl to load the module and print its verson number, redirecting
# errors to /dev/null
#
# this sub is taken from the
# Perl Cookbook by Tom Christiansen & Nathan Torkington;
sub getversion {
    my $mod = shift;

    my $vers = `$^X -m$mod -e 'print \$${mod}::VERSION' 2>/dev/null`;
    $vers =~ s/^\s*(.*?)\s*$/$1/; # remove stray whitespace
    return ($vers || undef);
}
# end copy&paste
