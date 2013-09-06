#!/usr/bin/env perl
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::Installer;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hl:f:b:o:d:u:p:n:t:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Database Setup Tool" );

if ( $args{h} ) {
    print qq*

  Usage: $0 [-h|-u user -p pwd -n dbname -t dbtype [-b host [-o port]] -f path -l logfile ]
        -u The name of your database user to connect to the XIMS
           database
        -p The password of your database user to connect to the XIMS
           database
        -n The name of the XIMS database to connect to
        -t The type of RDBMS of your XIMS database. Currently, either
           'Pg' or 'Oracle' are supported
        -b The name of the database host if you connect to a remote machine (optional for Pg)
        -o The port number of the database listener at the remote machine, omit for default (Pg if -b is needed)
        -l Path to the setup_db.pl logfile
        -h prints this screen

*;
    exit;
}

print "\n\033[1m[WARNING] This script will (re)create your XIMS database, existing data will be lost! [WARNING]\033[m\n\n";


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
    b_db_password    => { text  => 'Database Password (For Pg, this is only needed if your Pg installation is configured to use "password" or "md5" as authentication method. If that is not the case or you are unsure, leave it blank.',
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
        and $args{n}
        and $args{t}
        and $args{l} ) {
    # command line mode
    print "Using command line arguments to set up db.\n";
    $Conf{DBUser} = $args{u};
    $Conf{DBPassword} = $args{p};
    $Conf{DBName} = $args{n};
    $Conf{DBdsn} = $args{t};
    $Conf{DBhost} = $args{b};
    $Conf{DBport} = $args{o};
    # Tablefunctions are to be set up with 'CREATE EXTENSION' now.
    #$Conf{DBPgtablefunc} = $args{f};
    $Conf{log_file} = $args{l};
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
            print "\nYou specified a database host. The postmaster on that host\n",
                  "needs to be started with the \"-i\" option (TCP/IP sockets).\n\n";
                  #"You will have to manually install the table functions into the remote\n",
                  #"'xims' database after its creation through this script.\n",
                  #"This may be achieved with executing a command like the following:\n\n",
                  #"psql -U postgres -d xims -f /path/to/tablefunc.sql\n\n";
        }
        #else {
        #    $installer->prompt( { text => 'Path to tablefunc.sql',
        #                          var   => \$Conf{DBPgtablefunc},
        #                          re    => '.+',
        #                          error => 'Please specify a path to your copy of "tablefunc.sql"',
        #                          default => PgFindTableFunc(),
        #                        } );
        #}
    }
    $installer->prompt( { text  => "Enter a log file name\n",
                      var   => \$Conf{log_file},
                      re    => '\w+',
                      error => 'No nutty characters, just a simple file name, please.',
                      default => 'sql/setup_db.log',
                    }
                  );
}

logfile( $Conf{log_file} ); # hook up log file filter to STDOUT

if ( $Conf{DBdsn} eq 'Oracle' ) {
    chdir "$xims_home/sql/Oracle";
    warn "\nORACLE_HOME not set, sqlplus will likely fail now!\n\n" unless $ENV{ORACLE_HOME};
    system('sqlplus',$Conf{DBUser}.'/'.$Conf{DBPassword}.'@'.$Conf{DBName},'@ci_ddl.sql') == 0
        or die "Setting up DB via sqlplus failed: $?\n. Please check your config information or try manually setting up the DB.\b";
}
elsif ( $Conf{DBdsn} eq 'Pg' ) {
    my @args = ('psql','-U',$Conf{DBUser},'-d',$Conf{DBName},'-f','setup.sql');
    # psql has no -pwd option, therefore we have to set the PGPASSWORD
    # environment variable for non-interactive use
    if ( $Conf{DBPassword} and length $Conf{DBPassword} ) {
        if ( _isCShell() ) {
            @args = ('setenv PGPASSWORD ' . $Conf{DBPassword} . ' &&' , @args);
        }
        else {
            @args = ('PGPASSWORD=' . $Conf{DBPassword}, @args);
        }
    }

    if ( not ($Conf{DBhost} and length $Conf{DBhost}) ) {
        my $current_user = getpwuid($>);
        if ( $current_user ne $Conf{DBUser} ) {
            if ( $> == 0 ) {
                @args = ('su', '-', $Conf{DBUser}, '-c', "cd $xims_home/sql/Pg; " . join(' ', @args));
            }
            else {
                warn "\n\n[WARNING] You are neither logged in as root nor the database user you specified.\n",
                "Since you did not provide a password, the database setup process is relying on the fact that in your PostgreSQL",
                " 'pg_hba.conf' access is set to 'trust' now!\n\n";
            }
        }
    }
    else {
        push(@args, '-h', $Conf{DBhost});
        if ( $Conf{DBport} and length $Conf{DBport} ) {
            push(@args, '-p', $Conf{DBport});
        }
    }

    chdir "$xims_home/sql/Pg";

    unless ( system(@args) == 0 ) {
        $args[-1] = '"' . $args[-1] . '"';
        die "\n\033[1mSetting up DB failed! Error: $?.\nDo you have psql in your path?\nPlease check your config information or try manually setting up the DB using\n\n" . join(' ',@args) . #"\n\nfirst and after that with '-f $Conf{DBPgtablefunc}
            ' instead of setup.sql\033[m\n\n';
    }

    #if ( not ($Conf{DBhost} and length $Conf{DBhost}) ) {
    #    # tablefunctions
    #    my $tablefunc = $Conf{DBPgtablefunc};
    #    if ( $> == 0 ) {
    #        $args[-1] =~ s/setup.sql/$tablefunc/;
    #        $args[-1] =~ s/$Conf{DBName}/xims/;
    #    }
    #    else {
    #        $args[-1] = $tablefunc;
    #        $args[4] = 'xims';
    #    }

    #    die "\n\033[1m'tablefunc.sql' could not be found at " . $tablefunc . ". Please run\n\n",
    #    join(" ", @args), "\n\n manually with the correct path to your copy of 'tablefunc.sql'\033[m\n\n"
    #        unless -f $tablefunc;

    #   system(@args) == 0
    #        or die "\n\033[1mSetting up table functions failed! Error: $?.\nPlease check your config information or try manually setting up the table functions into the XIMS database.\033[m\n\n";
    #}
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

#sub PgFindTableFunc {
#    my @guesses = ('/usr/share/postgresql/contrib/tablefunc.sql');
#    my $pgversion = _PgVersion();
#    if ( $pgversion ) {
#        push(@guesses,"/usr/local/pgsql-$pgversion/share/contrib/tablefunc.sql","/usr/pgsql-$pgversion/share/contrib/tablefunc.sql");
#    }
#    foreach ( @guesses ) {
#        return $_ if -f $_;
#    }
#    my $tablefunc;
#    eval {
#       $tablefunc = `locate contrib/tablefunc.sql`;
#        chomp $tablefunc;
#    };
#    return $tablefunc;
#}

sub _PgVersion {
    my $version;
    eval {
        $version = `psql -V | grep PostgreSQL`
    };
    return unless $version;
    chomp $version;
    $version =~ s/.*\s(.+)$/$1/;
    return $version;
}

sub _isCShell {
    my $ppid = getppid();
    my $v = `ps -p $ppid 2>&1`;
    return $v =~ m/[\r\n].+csh[\r\n]/ms;
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

__END__

=head1 NAME

setup_db.pl

=head1 SYNOPSIS

setup_db.pl [-h|-u user -p pwd -n dbname -t dbtype [-b host [-o port]] -f path -l logfile ]
  
Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-u>

The name of your database user to connect to the XIMS
database

=item B<-p>

The password of your database user to connect to the XIMS
database

=item B<-n>

The name of the XIMS database to connect to

=item B<-t>

The type of RDBMS of your XIMS database. Currently, either
'Pg' or 'Oracle' are supported

=item B<-b>

The name of the database host if you connect to a remote machine (optional for Pg)

=item B<-o>

The port number of the database listener at the remote machine, omit for default (Pg if -b is needed)

=item B<-f>

Path to your copy of 'tablefunc.sql' (Pg only)

=item B<-l>

Path to the setup_db.pl logfile

=back

=cut
