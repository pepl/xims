#!/usr/bin/perl
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use lib "../lib";
use lib "lib";
use XIMS::Term;
use Test::Harness;
use Getopt::Std;
use Sys::Hostname;
use Storable qw( store retrieve );

use constant CONFIGFILE => 'lib/XIMS/.ximstest.conf';

my %args;
getopts('hcuabm', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Testing Tool" );

if ( $args{h} ) {
    print qq*

  Usage: $0 [-h|-c|-u|-a|-m]
        -c Create test config file with default values
        -u Run all unit tests
        -a Run all acceptance tests
        -b Run both unit and acceptance tests
        -m Maintainer mode
        -h Prints this screen

*;
    exit;
}

my %Args = ();
my %Conf = ();

my %prompts = (
    test_type  => { text  => "What would you like to do?\n".
                             "1 - run all unit tests.\n".
                             "2 - run all acceptance tests.\n".
                             "3 - run both unit and acceptance tests.\n".
                             "4 - select tests individually.\n".
                             "5 - edit/create the test suite config file.\n    (For acceptance tests and alternate configs to 'ximsconfig.xml'. Note for Pg users: Per default db user 'ximsrun' is configured in 'ximsconfig.xml'. Because that user cannot manipulate data formats amongst other things, you should configure the db user 'xims' here not to let some basic unit tests fail.).\n".
                             "q - quit.\n",
                   var   => \$Args{test_type},
                   re    => '(1|2|3|4|5)',
                   error => 'You must select 1, 2, 3, 4, 5, or q',
                   default => 3,
                 },
    log       => { text  => "Enter a log file name\n",
                   var   => \$Args{log_file},
                   re    => '\w+',
                   error => 'No nutty characters, just a simple file name, please.',
                   default => 'debug.log',
                 },
);


my %conf_defaults = (
    http_host => 'http://' . hostname(),
    user_name  => 'xgu',
    password  => 'xgu',
    DBUser    => 'xims',
    DBPassword    => 'xims',
    DBdsn      => 'dbi:Pg:dbname=xims',
);


if ( $args{c} ) {
    store( \%conf_defaults, CONFIGFILE ) || die "Could not write conf file, aborting\n";
    print "Default config file written.\n";
    exit 0;
}

my $app_config;
my $prompt_config;
eval {
    $app_config = retrieve(CONFIGFILE);
};

if ($@) {
    $prompt_config = 1;
    %Conf = ();
}
else {
    %Conf = %{$app_config};
}

my %conf_prompts = (
    a_xims_http_host => { text  => "(Virtual) HTTP host that XIMS is running under.",
                          var   => \$Conf{http_host},
                          re    => '^http://(.+)',
                          error => 'Just a simple host name with http scheme please',
                          default =>  $Conf{http_host} || $conf_defaults{http_host},
                 },
    b_xims_username  => { text  => 'XIMS User Name',
                          var   => \$Conf{user_name},
                          re    => '\w',
                          error => 'You must enter the name of an XIMS user.',
                          default => $Conf{user_name} || $conf_defaults{user_name},
                        },
    c_xims_password  => { text  => 'XIMS User Password',
                          var   => \$Conf{password},
                          re    => '\w+',
                          error => 'You must enter a password.',
                          default => $Conf{password} || $conf_defaults{password},
                        },
    d_db_username    => { text  => 'Database Username (This user has to have privileges to create languages, object types, etc.)',
                          var   => \$Conf{DBUser},
                          re    => '\w+',
                          error => 'You must enter the database username for XIMS to access the database.',
                          default => $Conf{DBUser} || $conf_defaults{DBUser},
                       },
    e_db_password    => { text  => 'Database Password',
                          var   => \$Conf{DBPassword},
                          re    => '\w+',
                          error => "You must enter the database user's password for XIMS to access the database.",
                          default => $Conf{DBPassword} || $conf_defaults{DBPassword},
                        },
    f_db_dbname      => { text  => 'Database Connection String (DSN)',
                          var   => \$Conf{DBdsn},
                          re    => '\w+',
                          error => 'You must enter the database connection string.',
                          default => $Conf{DBdsn} || $conf_defaults{DBdsn},
                        },
);


if ( $prompt_config and $prompt_config == 1 ) {
    print "\nNo test suite config file found, trying to use default config.\n";
    eval { require XIMS; };
    die "Could not load XIMS (possibly due to access rights).\n" if $@;
    print "\n\033[1mNote: Per default, the database user configured in ximsconfig.xml - for example 'ximsrun' if you have used the config defaults for Pg -, does not have sufficient database object privileges to sucessfully run the unit tests. You may consider to set up a test suite config file for that before running the tests.\033[m\n\n";
}
else {
    print "Using config information from " . CONFIGFILE . "\n\n";
}

if ( $args{u} or $args{a} or $args{m} ) {
    if ( $args{u} ) {
        $Args{test_type} = 1;
    }
    elsif ( $args{a} ) {
        $Args{test_type} = 2;
    }
    $Args{log_file} = 'debug.log';
    my @selected_tests = select_tests( 1 );
    dotests( @selected_tests );    
}
else {
    my @selected_tests = select_tests();
    test_loop( @selected_tests );
}


# end main
#########################################

sub do_config {
    foreach ( sort( keys( %conf_prompts )) ) {
        prompt( $conf_prompts{$_} );
    }
    store( \%Conf, CONFIGFILE ) || die "Could not write conf file, aborting\n";
    print "\nConfig file written.\n\n";
    $prompt_config = 0;
    $Args{ask_config} = 'n';
}

sub dotests {
    my @tests = @_;

    local *SAVEERR;
    open(SAVEERR, ">&STDERR");
    open(STDERR, ">$Args{log_file}") || die "Failed to open $Args{log_file} - $!";

    eval {
        runtests(@tests);
    };
    if ( $@ ) {
        print "\nSome tests failed...\n"
    }

    close(STDERR);
    open(STDERR, ">&SAVEERR");
}

sub test_loop {
    my @tests = @_;

    if ( scalar( @tests ) > 0 ) {
        prompt( $prompts{log} );
        dotests( @tests );
    }
    else {
        if ( $Args{ask_config} eq 'y' ) {
            do_config();
        }
        @tests = select_tests();
        test_loop( @tests );
    }

    prompt( { text  => "What would you like to do now?\n\n".
                       "1 - run the same tests.\n".
                       "2 - choose a new test plan.\n".
                       "3 - quit.\n",
              var   => \$Args{test_loop},
              re    => '(1|2|3)',
              error => 'You must select 1, 2, 3 or q',
              default => 1,
            } );

    if ( $Args{test_loop} == 1 ) {
        test_loop( @tests );
    }
    elsif ( $Args{test_loop} == 2 ) {
       @tests = select_tests();
       test_loop( @tests );
    }
    else {
       exit;
    }
}


sub prompt {
    my $def = shift;
    #use Data::Dumper;
    #warn Dumper( $def);
    print $def->{text} . "\n";
    if ( $def->{default} ) {
        print '[' . $def->{default} . ']';
    }
    print ': ';

    while (<>) {
      chomp;
      exit if $_ eq 'q';
      if ( $_ =~ /$def->{re}/ ) {
          ${$def->{var}} = $_;
          last;
      }
      elsif ( length($_) == 0 and defined( $def->{default} ) ) {
          ${$def->{var}} = $def->{default};
          last;
      }
      else {
          print $def->{error} . "\n";
          prompt( $def ) && last;
      }
   }
}

sub select_tests {
    my @test_files = ();
    my $batch = shift;

    prompt( $prompts{test_type} ) unless $batch;
    if ( $Args{test_type} == 1 ) {
        @test_files = grep { $_ =~ /^unit/ } <*.t>;
    }
    elsif ( $Args{test_type} == 2 ) {
       @test_files = grep { $_ =~ /^accept/ } <*.t>;
    }
    else {
       @test_files = <*.t>;
    }

    if ( $Args{test_type} == 4 ) {
        my $choose_string ="\n\n";
        my $i;
        for( $i = 0; $i <= $#test_files; $i++ ) {
            $choose_string .= '[' . ($i + 1) . "] $test_files[$i] \n";
        }
        $choose_string .= "\nEnter the numbers for the tests you want to run, seperated by whitespace.\n";

        prompt( { text => $choose_string,
                  var => \$Args{test_index},
                  re => '(\d+\s*)+',
                  default => '',
                });

        my @test_idx = split /\s+/, $Args{test_index};
        die "No tests selected, aborting.\n" unless scalar( @test_idx ) > 0;
        my @test_temp = map { $test_files[ $_ -1 ] } @test_idx;
        @test_files = @test_temp;
    }
    elsif ( $Args{test_type} == 5 ) {
         $Args{ask_config} = 'y';
         do_config();
         return ();
    }
    $Args{ask_config} = 'n';
    return @test_files;
}
