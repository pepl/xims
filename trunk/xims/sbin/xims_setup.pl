#!/usr/bin/env perl
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::Config;
use XIMS::Installer;
use XIMS::Term;
use XML::LibXML;
use Getopt::Std;

my %args;
getopts('hcd:a:u:p:n:t:b:o:x:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Setup Tool" );

if ( $args{h} ) {
    print qq*

  Usage: $0 [-h|-c|-a httpdconf -u user -p pwd -n dbname -x path_to_tidy -t dbtype [-b host [-o port]]]
        -a The path to your Apache's config file
        -u The name of your database user to connect to the XIMS
           database
        -p The password of your database user to connect to the XIMS
           database
        -n The name of the XIMS database to connect to
        -t The type of RDBMS of your XIMS database. Currently, either
           'Pg' or 'Oracle' are supported
        -b The name of the database host if you connect to a remote machine (optional for Pg)
        -o The port number of the database listener at the remote machine, omit for default (Pg)
        -x The path to your tidy executable
        -c Only update ximsconfig.xml
        -h prints this screen

*;
    exit;
}

#' just for syntax-highlighting

my @upd_fields = qw{ApacheDocumentRoot DBUser DBPassword DBdsn DBDOpt DBSessionOpt TidyPath TidyOptions};
my $installer = XIMS::Installer->new();

my $configfile = "$xims_home/conf/ximsconfig.xml";
my $xims_config = XIMS::Config->new();
my %Conf = %{$xims_config->general};
my $publicroot = "$xims_home/www/" . $Conf{PublicRoot};
my $ximsstartuppl = "$xims_home/conf/ximsstartup.pl";
my $tidypath_default = $Conf{'TidyPath'} || TidyPath();
$Conf{'TidyOptions'}= ' -config ' . $xims_home . '/conf/ximstidy.conf -quiet -f /dev/null';
my $dbdsn_default = DBdsn( \%Conf );
my $db_host = DBhost( \%Conf );
my $db_port = DBport( \%Conf );
my $conf_default = $installer->httpd_conf();

my %conf_prompts = (
    a_apache_conf    => { text  => 'Path to Apache config file (httpd.conf)',
                          var   => \$Conf{ApacheHttpdConf},
                          re    => '[a-zA-Z0-9/\-_\.]+',
                          error => 'You must enter the path to your Apache config file (httpd.conf).',
                          default => $conf_default,
                       },
    b_db_username    => { text  => 'Runtime Database Username',
                          var   => \$Conf{DBUser},
                          re    => '.+',
                          error => 'You must enter the database username for XIMS to access the database.',
                          default => $Conf{DBUser} || 'ximsrun',
                       },
    c_db_password    => { text  => 'Runtime Database Password',
                          var   => \$Conf{DBPassword},
                          re    => '.+',
                          error => "You must enter the database user's password for XIMS to access the database.",
                          default => $Conf{DBPassword} || 'ximsrun',
                        },
    d_db_dbname      => { text  => 'Database Name',
                          var   => \$Conf{DBName},
                          re    => '.+',
                          error => 'You must enter the database name. In case you are using Pg and you want to connect to another host you have add the host\'s address and perhaps a port number in the following format here:\ndbname;host=hostname;port=portnumber',
                          default => $Conf{DBName} || 'xims',
                        },
    e_db_dbdsn       => { text  => 'Database Type (Pg or Oracle)',
                          var   => \$Conf{DBdsn},
                          re    => '^Pg$|^Oracle$',
                          error => 'You must enter the database type (Pg or Oracle).',
                          default => $dbdsn_default,
                        },
    f_tidy_path       => { text  => 'Full path to the tidy executable',
                           var   => \$Conf{TidyPath},
                           re    => '^/\S+/tidy$',
                           error => 'You must enter the full path to the tidy executable.',
                           default => $tidypath_default,
                        },
);

if (     $args{a} and -f $args{a}
     and $args{u}
     and $args{p}
     and $args{n}
     and ($args{t} eq 'Pg' or $args{t} eq 'Oracle')
     and $args{x} and -x $args{x} ) {

    # command line mode
    print "Using command line arguments to write config.\n";
    $Conf{ApacheHttpdConf} = $args{a};
    $Conf{DBUser} = $args{u};
    $Conf{DBPassword} = $args{p};
    $Conf{DBName} = $args{n};
    $Conf{DBdsn} = $args{t};
    $Conf{DBhost} = $args{b};
    $Conf{DBport} = $args{o};
    $Conf{TidyPath} = $args{x};

}
else {
    # interactive mode
    print "Interactive mode. Please provide the following essential config values:\n\n";

    foreach ( sort( keys( %conf_prompts )) ) {
        $installer->prompt( $conf_prompts{$_} );
    }

    while ( not -x $Conf{TidyPath} ) {
        warn "\n[WARNING] Tidy executable not found at specified location.\n\n";
        $installer->prompt( $conf_prompts{f_tidy_path} );
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
                                  re    => '^[0-9]*$',
                                  error => 'Please specify a decimal number.',
                                  default => '',
                                } );
        }
    }
}

$installer->httpd_conf( $Conf{ApacheHttpdConf} ); # set the value provided through %Conf

die( "\n" . $installer->httpd_conf() . " could not be found, exiting.\n\n") unless -f $installer->httpd_conf();
if ( $> > 0 ) {
    die "Access check failed. Make sure you have write access to "
        . $configfile . ", "
        . $installer->httpd_conf() . ", and "
        . $installer->apache_document_root() . "\n"
        unless -w $configfile
            and -w $installer->httpd_conf()
            and -w $installer->apache_document_root();
    die "Access check failed. Make sure you are owner of "
        . $configfile . " and "
        . $publicroot . "\n"
        unless  -o $configfile
            and -o $publicroot;
}

# check for DBD drivers in case someone did not read the INSTALL file
if ( $Conf{DBdsn} eq 'Pg' ) {
    print "\n Checking for DBD::Pg...";
    eval{ require DBD::Pg;};

    if ( $@ ) {
        print "\nCould not load DBD::Pg. Perhaps it is not installed.\n",
              "Press enter to let cpan_install.pl try installing it.\n";<STDIN>;

        if ( system("$^X $xims_home/tools/install/cpan_install.pl","-m","DBD::Pg") != 0 ) {
            die "Could not install DBD::Pg, you have to install it manually!\n\n";
        }
    }
    else {
        print "  ok\n";
    }
}
elsif ( $Conf{DBdsn} eq 'Oracle' ) {
    print "\n Checking for DBD::Oracle...\n";
    eval{ require DBD::Oracle;};
    if ( $@ ) {
        print "\nCould not load DBD::Oracle. Perhaps it is not installed.\n",
              "Press enter to let cpan_install.pl try installing it.\n";<STDIN>;

        if ( system("$^X $xims_home/tools/install/cpan_install.pl","-m","DBD::Oracle") != 0 ) {
            die "Could not install DBD::Oracle, you have to install it manually!\n\n";
        }
    }
    else {
        print "  ok\n";
    }
}

fixupDBConfig( \%Conf ); # set config options depending on RDMBS type

# writing back to config file
# to keep things friendly and to avoid a second loop, we put ApacheDocumentRoot inside %Conf
$Conf{ApacheDocumentRoot} = $installer->apache_document_root();
my $doc;
eval {
    $doc = XML::LibXML->new()->parse_file( $configfile )
};
die "Could not parse file '$configfile': $@\n" if $@;

foreach my $directive ( @upd_fields ) {
    my $ndirective = XML::LibXML::Element->new( $directive );
    $ndirective->appendText( $Conf{$directive} );
    my $nl = $doc->getElementsByTagName( $directive );
    $nl->get_node(1)->replaceNode( $ndirective );
}
my $configfile_fh = IO::File->new( $configfile, 'w' );
if ( defined $configfile_fh ) {
    print $configfile_fh $doc->toString();
    $configfile_fh->close;
    print "\n[+] Successfully updated $configfile\n";
}
else {
    die "\nCould not write to $configfile: $!\n";
}

exit if $args{c};

# patch ximsstartup.pl
$installer->inplace_edit($ximsstartuppl, "s!^\\s*use lib qw\\(\\s*\\S+/xims/lib\\s*\\);\\s*!use lib qw( $xims_home/lib );\n!");

print "\n[+] Successfully updated $ximsstartuppl\n";


# adjust XIMS_HOME in ximshttpd.conf if neccessary
if ( $ENV{XIMS_HOME} and -d $ENV{XIMS_HOME} ) {
    print "[+] Set XIMS_HOME to $ENV{XIMS_HOME} in ximshttpd.conf.\n" if
        $installer->inplace_edit("$xims_home/conf/ximshttpd.conf",
                                 "s!#PerlSetEnv XIMS_HOME path_to_your_xims_home!PerlSetEnv XIMS_HOME $ENV{XIMS_HOME}!");

}

# adjust ORACLE_HOME in ximshttpd.conf if neccessary
if ( $ENV{ORACLE_HOME} and -d $ENV{ORACLE_HOME} ) {
    print "[+] Set ORACLE_HOME to $ENV{ORACLE_HOME} in ximshttpd.conf.\n" if
        $installer->inplace_edit("$xims_home/conf/ximshttpd.conf",
                                 "s!#PerlSetEnv ORACLE_HOME path_to_your_oracle_home!PerlSetEnv ORACLE_HOME $ENV{ORACLE_HOME}!");

}

# append ximshttp.conf and ximsstartup.pl to httpd.conf if neccessary
unless ( $installer->xims_httpd_conf() and $installer->xims_startup_pl() ) {
    print "[+] Appending XIMS config to " . $installer->httpd_conf() . "\n";
    open(CONF, ">>".$installer->httpd_conf()) || die "Can't open $installer->httpd_conf(): $!";
    my $configline = "\n";
    $configline .= "Include $xims_home/conf/ximshttpd.conf\n" unless $installer->xims_httpd_conf();
    $configline .= "PerlRequire $ximsstartuppl\n" unless $installer->xims_startup_pl();
    print CONF $configline;
    close(CONF);
}
else {
    print "[!] XIMS config already present in " . $installer->httpd_conf() . "\n";
}

# setup rights
if ( $installer->apache_user() and $installer->apache_group() ) {
    my $apache_uid = (getpwnam($installer->apache_user()))[2] or die "$installer->apache_user() not in passwd file.\n";
    my $apache_gid = (getgrnam($installer->apache_group()))[2] or die "$installer->apache_group() is an invalid group.\n";

    # publicroot
    my $uid = (stat $publicroot)[4];
    chown( $apache_uid, $apache_gid, $publicroot );
    chmod( 06775, $publicroot );

    # ximsconfig.xml
    $uid = (stat $configfile)[4];
    chown( $uid, $apache_gid, $configfile );
    chmod( 0440, $configfile );

    print "[+] Successfully set up file access rights.\n";
}
else {
    print "\n[WARNING] Apache group could not be determined from Apache config.\n";
    print "    Please run

    chown \$apache_user:\$apache_group $publicroot
    chmod 6775 $publicroot
    chgrp \$apache_group $configfile
    chmod 440 $configfile

    manually.\n\n";
}

my $missedfile = 0;
my $gotfile = 0;
my @ximsfiles = filter_ximsfiles( $term->findfiles("$xims_home/bin") );
$gotfile++ if scalar @ximsfiles;
chmod( 06755, @ximsfiles) or $missedfile++;

@XIMS::Term::files=(); # well, ...
@ximsfiles = filter_ximsfiles( $term->findfiles("$xims_home/sbin") );
$gotfile++ if scalar @ximsfiles;
chmod( 0700, @ximsfiles) or $missedfile++;

if ( $missedfile > 0 or $gotfile < 2 ) {
    print "\n[WARNING] Could not set file mode of xims_*.pl files.\n";
    print "    Please run

    chmod 6755 $xims_home/bin/xims_*.pl
    chmod 700 $xims_home/sbin/xims_*.pl

    manually.\n\n";
}
else {
    print "[+] Successfully set up file mode of bin/xims_*.pl and sbin/xims_*.pl files.\n";
}


# create links if they not already exist
unless ( -l $installer->apache_document_root() . '/ximsroot'
         and -l $installer->apache_document_root() . '/' . $Conf{PublicRoot}
         and -l $installer->apache_document_root() .  '/ou.xml' ) {
    symlink( "$xims_home/www/ximsroot", $installer->apache_document_root() . '/ximsroot' );
    symlink( $publicroot, $installer->apache_document_root() . '/' . $Conf{PublicRoot} );
    symlink( $publicroot . '/xims/ou.xml', $installer->apache_document_root() . '/ou.xml' );
    print "[+] Successfully set up symbolic links under " . $installer->apache_document_root()  . ".\n";
}
else {
    print "[!] Symbolic links already exist under " . $installer->apache_document_root()  . ".\n";
}

print qq*
Initial XIMS setup finished.

$0 only updates the most essential XIMS config options. It is
recommended to take a look at $configfile
for further config customizations.

*;
sub fixupDBConfig {
    my $conf = shift;
    if ( $conf->{DBdsn} eq 'Pg' ) {
        $conf->{DBdsn} = 'dbi:Pg:dbname=' . $conf->{DBName};
        $conf->{DBdsn} .= ';host=' . $conf->{DBhost} if $conf->{DBhost} and length $conf->{DBhost};
        $conf->{DBdsn} .= ';port=' . $conf->{DBport} if $conf->{DBport} and length $conf->{DBport};
        $conf->{DBDOpt} = 'FetchHashKeyName=NAME_uc;' unless $conf->{DBDOpt} =~ /FetchHashKeyName/;
        $conf->{DBSessionOpt} = 'SET DateStyle TO ISO;SET Client_Encoding TO UNICODE;' unless $conf->{DBSessionOpt} =~ /SET Client_Encoding/;
    }
    elsif ( $conf->{DBdsn} eq 'Oracle' ) {
        $conf->{DBdsn} = 'dbi:Oracle:' . $conf->{DBName};
        $conf->{DBDOpt} = 'LongReadLen=67108864;LongTruncOk=1' unless $conf->{DBDOpt} =~ /LongReadLen/;
        $conf->{DBSessionOpt} = "ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';" unless $conf->{DBSessionOpt} =~ /ALTER SESSION SET NLS_DATE_FORMAT=/;
    }
}

sub DBdsn {
    my $conf = shift;
    return 'Pg' if $conf->{DBdsn} =~ /^dbi:Pg/;
    return 'Oracle' if $conf->{DBdsn} =~ /^dbi:Oracle/;
    return 'Oracle' if $ENV{ORACLE_HOME};
    return 'Pg';
}

sub DBhost {
    my $conf = shift;
    $conf->{DBdsn} =~ /host=([^;]+)/;
    return $1;
}

sub DBport {
    my $conf = shift;
    $conf->{DBdsn} =~ /port=([^;]+)/;
    return $1;
}

sub TidyPath {
    my $path = `which tidy`;
    return $path unless defined $path;
    return '/usr/local/bin/tidy' if -f '/usr/local/bin/tidy';
    return '/usr/bin/tidy' if -f '/usr/bin/tidy';
}

sub filter_ximsfiles {
    my @ximsfiles = ();
    foreach ( @_ ) {
        push( @ximsfiles, $_ ) if /xims_.*\.pl/;
    }
    return @ximsfiles;
}

__END__

=head1 NAME

xims_setup.pl - XIMS Setup

=head1 SYNOPSIS

xims_setup.pl [-h|-c|-a httpdconf -u user -p pwd -n dbname -x path_to_tidy -t dbtype [-b host [-o port]]]

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-a>

The path to your Apache's config file

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

The port number of the database listener at the remote machine, omit for default (Pg)

=item B<-x>

The path to your tidy executable

=item B<-c>

Only update ximsconfig.xml

=back

=cut
