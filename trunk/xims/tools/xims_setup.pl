#!/usr/bin/perl -w

# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

use lib qw(/usr/local/xims/lib);
use XIMS::Installer;
use Getopt::Std;

my %args;
getopts('hcr:u:p:n:t:', \%args);

print q*
  __  _____ __  __ ____
  \ \/ /_ _|  \/  / ___|
   \  / | || |\/| \___ \
   /  \ | || |  | |___) |
  /_/\_\___|_|  |_|____/

  Setup Tool

*;

if ( $args{h} ) {
    print qq*

  Usage: $0 [-h|-c|-h httpdconf -r docroot -u user -p -pwd -n dbname -t dbtype]
        -h The path to your Apache's config file
        -u The name of your database user to connect to the XIMS
           database
        -p The password of your database user to connect to the XIMS
           database
        -n The name of the XIMS database to connect to
        -t The type of RDBMS of your XIMS database. Currently, either
           'Pg' or 'Oracle' are supported
        -c Update XIMS::Config only
        -h prints this screen

*;
    exit;
}


my @upd_fields = qw{ApacheDocumentRoot DBUser DBPassword DBName DBdsn DBDOpt DBSessionOpt};
my $installer = XIMS::Installer->new();

my $configpm = '/usr/local/xims/lib/XIMS/Config.pm';
my %Conf = parseConfigpm($configpm);
my $publicroot = '/usr/local/xims/www/' . $Conf{PublicRoot};

my $dbdsn_default = DBdsn( \%Conf );
my $conf_default = $installer->httpd_conf();

my %conf_prompts = (
    a_apache_conf    => { text  => 'Path to Apache config file (httpd.conf)',
                          var   => \$Conf{ApacheHttpdConf},
                          re    => '[a-zA-Z0-9/\-_\.]+',
                          error => 'You must enter the path to your Apache config file (httpd.conf).',
                          default => $conf_default,
                       },
    b_db_username    => { text  => 'Database Username',
                          var   => \$Conf{DBUser},
                          re    => '.+',
                          error => 'You must enter the database username for XIMS to access the database.',
                          default => $Conf{DBUser} || 'ximsrun',
                       },
    c_db_password    => { text  => 'Database Password',
                          var   => \$Conf{DBPassword},
                          re    => '.+',
                          error => "You must enter the database user's password for XIMS to access the database.",
                          default => $Conf{DBPassword} || 'ximsrun',
                        },
    d_db_dbname      => { text  => 'Database Name',
                          var   => \$Conf{DBName},
                          re    => '.+',
                          error => 'You must enter the database name.',
                          default => $Conf{DBName} || 'xims',
                        },
    e_db_dbdsn       => { text  => 'Database Type (Pg or Oracle)',
                          var   => \$Conf{DBdsn},
                          re    => '^Pg$|^Oracle$',
                          error => 'You must enter the database type (Pg or Oracle).',
                          default => $dbdsn_default,
                        },

);

if ( $args{h}
        and $args{u}
        and $args{p}
        and $args{n}
        and $args{t} ) {
    # command line mode
    print "Using command line arguments to write config.\n";
    $Conf{ApacheHttpdConf} = $args{h};
    $Conf{DBUser} = $args{u};
    $Conf{DBPassword} = $args{p};
    $Conf{DBName} = $args{n};
    $Conf{DBdsn} = $args{t};

}
else {
    # interactive mode
    print "Interactive mode. Please provide the following essential config values:\n\n";

    foreach ( sort( keys( %conf_prompts )) ) {
        $installer->prompt( $conf_prompts{$_} );
    }
}

$installer->httpd_conf( $Conf{ApacheHttpdConf} ); # set the value provided through %Conf

die( "\n" . $installer->httpd_conf() . " could not be found, exiting.\n\n") unless -f $installer->httpd_conf();
if ( $> > 0 ) {
    die "Access check failed. Make sure you have write access to "
        . $configpm . ", "
        . $installer->httpd_conf() . ", and "
        . $installer->apache_document_root() . "\n"
        unless -w $configpm
            and -w $installer->httpd_conf()
            and -w $installer->apache_document_root();
    die "Access check failed. Make sure you are owner of "
        . $configpm . " and "
        . $publicroot . "\n"
        unless  -o $configpm
            and -o $publicroot;
}

# check for DBD drivers in case someone did not read the INSTALL file
if ( $Conf{DBdsn} eq 'Pg' ) {
    eval{ require DBD::Pg;};
    if ( $@ ) {
        print "\nCould not load DBD::Pg. Perhaps it is not installed.\n",
              "Press enter to let cpan_install.pl try installing it.\n";<STDIN>;
        die "Could not install DBD::Pg, you have to install it manually!\n\n"
            unless system("/usr/local/xims/tools/cpan_install.pl","-m","DBD::Pg") == 0;
    }
}
elsif ( $Conf{DBdsn} eq 'Oracle' ) {
    eval{ require DBD::Oracle;};
    if ( $@ ) {
        print "\nCould not load DBD::Oracle. Perhaps it is not installed.\n",
              "Press enter to let cpan_install.pl try installing it.\n";<STDIN>;
        die "Could not install DBD::Oracle, you have to install it manually!\n\n"
            unless system("/usr/local/xims/tools/cpan_install.pl","-m","DBD::Oracle") == 0;
    }
}

fixupDBConfig( \%Conf ); # set config options depending on RDMBS type

# writing back to Config.pm
foreach my $directive ( @upd_fields ) {
    $installer->inplace_edit($configpm,
                             "s!^\\s*sub $directive\\(\\)\\s+{s*.+\\s*}!sub $directive() { '$Conf{$directive}' }!");
}

print "\n[+] Successfully updated $configpm\n";

exit if $args{c};

# adjust ORACLE_HOME in ximshttpd.conf if neccessary
if ( $ENV{ORACLE_HOME} and -d $ENV{ORACLE_HOME} ) {
    print "[+] Set ORACLE_HOME to $ENV{ORACLE_HOME} in ximshttpd.conf.\n" if
        $installer->inplace_edit('/usr/local/xims/conf/ximshttpd.conf',
                                 "s!#PerlSetEnv ORACLE_HOME path_to_your_oracle_home!PerlSetEnv ORACLE_HOME $ENV{ORACLE_HOME}!");

}

# append ximshttp.conf and ximsstartup.pl to httpd.conf if neccessary
unless ( $installer->xims_httpd_conf() and $installer->xims_startup_pl() ) {
    print "[+] Appending XIMS config to " . $installer->httpd_conf() . "\n";
    open(CONF, ">>".$installer->httpd_conf()) || die "Can't open $installer->httpd_conf(): $!";
    my $configline = "\n";
    $configline .= "Include /usr/local/xims/conf/ximshttpd.conf\n" unless $installer->xims_httpd_conf();
    $configline .= "PerlRequire /usr/local/xims/conf/ximsstartup.pl\n" unless $installer->xims_startup_pl();
    print CONF $configline;
    close(CONF);
}
else {
    print "[!] XIMS config already present in " . $installer->httpd_conf() . "\n";
}

# setup rights
my $apache_uid = (getpwnam($installer->apache_user()))[2] or die "$installer->apache_user() not in passwd file.\n";
my $apache_gid = (getgrnam($installer->apache_group()))[2] or die "$installer->apache_group() is an invalid group.\n";

# publicroot
my $uid = (stat $publicroot)[4];
chown( $uid, $apache_gid, $publicroot );
chmod( 0775, $publicroot );

# Config.pm
$uid = (stat $configpm)[4];
chown( $uid, $apache_gid, $configpm );
chmod( 0440, $configpm );

print "[+] Successfully set up file access rights.\n";

# create links if they not already exist
unless ( -l $installer->apache_document_root() . '/ximsroot'
         and -l $installer->apache_document_root() . '/' . $Conf{PublicRoot} ) {
    symlink( '/usr/local/xims/www/ximsroot', $installer->apache_document_root() . '/ximsroot' );
    symlink( $publicroot, $installer->apache_document_root() . '/' . $Conf{PublicRoot} );
    print "[+] Successfully set up symbolic links under " . $installer->apache_document_root()  . ".\n";
}
else {
    print "[!] Symbolic links already exist under " . $installer->apache_document_root()  . ".\n";
}

print qq*
Initial XIMS setup finished.

$0 only updates the most essential XIMS config options. It is
recommended to take a look at XIMS::Config ($configpm)
for further config customizations.

*;
sub fixupDBConfig {
    my $conf = shift;
    if ( $conf->{DBdsn} eq 'Pg' ) {
        $conf->{DBdsn} = 'dbi:Pg:dbname=' . $conf->{DBName};
        $conf->{DBDOpt} = 'FetchHashKeyName=NAME_uc;' unless $conf->{DBDOpt} =~ /FetchHashKeyName/;
        $conf->{DBSessionOpt} = 'SET DateStyle TO German;SET Client_Encoding TO LATIN1;' unless $conf->{DBSessionOpt} =~ /SET Client_Encoding/;
    }
    elsif ( $conf->{DBdsn} eq 'Oracle' ) {
        $conf->{DBdsn} = 'dbi:Oracle:' . $conf->{DBName};
        $conf->{DBDOpt} = 'LongReadLen=10485760;LongTruncOk=1' unless $conf->{DBDOpt} =~ /LongReadLen/;
        $conf->{DBSessionOpt} = "ALTER SESSION SET NLS_DATE_FORMAT=\'DD.MM.YYYY HH24:MI:SS\';" unless $conf->{DBSessionOpt} =~ /ALTER SESSION SET NLS_DATE_FORMAT=/;
    }
}

sub DBdsn {
    my $conf = shift;
    return 'Pg' if $conf->{DBdsn} =~ /^dbi:Pg/;
    return 'Oracle' if $conf->{DBdsn} =~ /^dbi:Oracle/;
    return 'Oracle' if $ENV{ORACLE_HOME};
}

sub parseConfigpm {
    my $conf = shift;
    my %Config;

    open(CONF, $conf) || die "Can't open $conf: $!";
    while (<CONF>) {
        if ( /^\s*sub (\w+)\(\)\s+{s*(.+)\s*}/) {
            my $key = $1;
            my $value = $2;
            $value =~ s/^\s+|'|"|\s+$//g;
            $Config{$key} = $value;
        }
    }
    close(CONF);

    return %Config;
}

