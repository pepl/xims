#!/usr/bin/perl -w

# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $prefix = $ENV{'XIMS_PREFIX'} || '/usr/local';
die "\nWhere am I?\n\nPlease set the XIMS_PREFIX environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$prefix/xims/Makefile";

use lib qw(lib ../lib $prefix/xims/lib);

use XIMS::Installer;
use Getopt::Std;

my %args;
getopts('hu:p:n:t:', \%args);

print q*
  __  _____ __  __ ____
  \ \/ /_ _|  \/  / ___|
   \  / | || |\/| \___ \
   /  \ | || |  | |___) |
  /_/\_\___|_|  |_|____/

  Database Setup Tool

*;

if ( $args{h} ) {
    print qq*

  Usage: $0 [-h|-u user -p -pwd -n dbname -t dbtype [-b host [-o port]]]
        -u The name of your database user to connect to the XIMS
           database
        -p The password of your database user to connect to the XIMS
           database
        -n The name of the XIMS database to connect to
        -t The type of RDBMS of your XIMS database. Currently, either
           'Pg' or 'Oracle' are supported
        -b The name of the database host if you connect to a remote machine (optional for Pg)
        -o The port number of the database listener at the remote machine, omit for default (Pg)
        -h prints this screen

*;
    exit;
}

print "\n\033[1m[WARNING] This script will recreate your XIMS database, existing data will be lost! [WARNING]\033[m\n\n";


my $installer = XIMS::Installer->new();
my %Conf;
my $dbdsn_default = DBdsn();

my %conf_prompts = (
    a_db_username    => { text  => 'Database Username (For Pg, DB-Superuser; likely one of "postgres", "postmaster", or "pgsql"',
                          var   => \$Conf{DBUser},
                          re    => '.+',
                          error => 'You must enter the database username for XIMS to access the database.',
                          default => $ENV{ORACLE_HOME} ? '' : PgUser(),
                       },
    b_db_password    => { text  => 'Database Password (For Pg, pg_hba.conf should have set trust to local and this password should remain blank.',
                          var   => \$Conf{DBPassword},
                          re    => '.*',
                          error => "You must enter the database user's password for XIMS to access the database.",
                          default => '',
                        },
    c_db_dbname      => { text  => 'Database Name to connect to',
                          var   => \$Conf{DBName},
                          re    => '.+',
                          error => 'You must enter the database name to connect to.',
                          default => $ENV{ORACLE_HOME} ? '' : 'template1',
                        },
    d_db_dbdsn       => { text  => 'Database Type (Pg or Oracle)',
                          var   => \$Conf{DBdsn},
                          re    => '^Pg$|^Oracle$',
                          error => 'You must enter the database type (Pg or Oracle).',
                          default => $dbdsn_default,
                        },

);

if ( $args{u}
        and $args{p}
        and $args{n}
        and $args{t} ) {
    # command line mode
    print "Using command line arguments to set up db.\n";
    $Conf{DBUser} = $args{u};
    $Conf{DBPassword} = $args{p};
    $Conf{DBName} = $args{n};
    $Conf{DBdsn} = $args{t};
    $Conf{DBhost} = $args{b};
    $Conf{DBport} = $args{o};
}
else {
    # interactive mode
    print "Interactive mode. Please provide the following essential config values:\n\n";
    foreach ( sort( keys( %conf_prompts )) ) {
        $installer->prompt( $conf_prompts{$_} );
    }
    if ( $Conf{DBdsn} eq 'Pg' ) {
        $installer->prompt( { text => 'Database Host. Leave blank if you are connecting to localhost',
                              var   => \$Conf{DBhost},
                              re    => '.*',
                              error => '',
                              default => '',
                            } );
        if ( $Conf{DBhost} and length $Conf{DBhost} ) {
            $installer->prompt( { text => 'Database Port. Leave blank for the default PostgreSQL port.',
                                  var   => \$Conf{DBport},
                                  re    => '.*',
                                  error => '',
                                  default => '',
                                } );
        }
    }
}

$installer->prompt( { text  => "Enter a log file name\n",
                      var   => \$Conf{log_file},
                      re    => '\w+',
                      error => 'No nutty characters, just a simple file name, please.',
                      default => 'sql/setup_db.log',
                    }
                  );

if ( $Conf{DBhost} and length $Conf{DBhost} ) {
    print "\nYou specified a database host. The postmaster on that host\n".
    "needs to be started with the \"-i\" option (TCP/IP sockets).\n\n";
}

logfile( $Conf{log_file} ); # hook up log file filter to STDOUT

if ( $Conf{DBdsn} eq 'Oracle' ) {
    chdir "$prefix/xims/sql/Oracle";
    system('sqlplus',$Conf{DBUser}.'/'.$Conf{DBPassword}.'@'.$Conf{DBName},'@ci_ddl.sql') == 0
        or die "Setting up DB failed: $?\n. Please check your config information or try manually setting up the DB.\b";
}
elsif ( $Conf{DBdsn} eq 'Pg' ) {
    chdir "$prefix/xims/sql/Pg";
    my @args = ('psql','-U',$Conf{DBUser},'-d',$Conf{DBName},'-f','setup.sql');
    if ( $Conf{DBhost} and length $Conf{DBhost} ) {
        push(@args, '-h', $Conf{DBhost});
        if ( $Conf{DBport} and length $Conf{DBport} ) {
            push(@args, '-p', $Conf{DBport});
        }
    }
    system(@args) == 0
        or die "Setting up DB failed: $?\n. Please check your config information or try manually setting up the DB.\b";
}

close STDOUT; # forks, we're done
exit;

sub DBdsn {
    if ( $ENV{ORACLE_HOME} ) {
        return 'Oracle';
    }
    else {
        return 'Pg';
    }
}

sub PgUser {
    foreach my $user (qw/postgres postmaster pgsql/) {
        my $pgsuperuser = (getpwnam($user))[0];
        return $pgsuperuser if defined $pgsuperuser;
    }
    return 'postgres';
}

sub logfile {
    my $logfile = shift;
    my $pid;
    return if $pid = open(STDOUT, "|-");
    die "cannot fork: $!" unless defined $pid;
    open(LOGFILE, ">$logfile") || die "Failed to write to $logfile: $!\n";
    while (<STDIN>) {
        print $_;
        print LOGFILE $_;
    }
    close LOGFILE;
    print "\n\033[1mXIMS database setup finished. Please review " . $logfile . " for possible warnings or errors.\033[m\n\n";
    exit;
}
