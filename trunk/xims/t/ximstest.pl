use lib "lib";
use strict;
use Data::Dumper;
use Test::Harness;
use Storable qw( store retrieve );
my %Args = ();
my %Conf = ();

my %prompts = (
    test_type  => { text  => "What would you like to do?\n".
                             "1 - run all unit tests.\n".
                             "2 - run all acceptance tests.\n".
                             "3 - run both unit and acceptance tests.\n".
                             "4 - select tests individually.\n".
                             "5 - edit/create the test suite config file.\n",
                   var   => \$Args{test_type},
                   re    => '(1|2|3|4|5)',
                   error => 'You must select the numbers 1, 2, 3, 4, or 5.',
                   default => 3,
                 },
    log       => { text  => "Enter a log file name\n",
                   var   => \$Args{log_file},
                   re    => '\w+',
                   error => 'No nutty characters, just a simple file name, please.',
                   default => 'debug.log',
                 },
);


my $app_config;
my $prompt_config;
eval {
    $app_config = retrieve('lib/XIMS/.ximstest.conf');
};

if ($@) {
    $prompt_config = 1;
    %Conf = ();
}
else {
    %Conf = %{$app_config};
}

my %conf_prompts = (
    a_xims_http_host => { text  => "HTTP hostname that XIMS is running under.",
                          var   => \$Conf{http_host},
                          re    => '^http://(.+?)',
                          error => 'Just a simple host name, including scheme and port, please.',
                          default =>  $Conf{http_host} || 'http://localhost',
                 },
    b_xims_username  => { text  => 'XIMS User Name',
                          var   => \$Conf{user_name},
                          re    => '\w',
                           error => 'You must enter the name of an XIMS user.',
                          default => $Conf{user_name} || 'xgu',
                        },
    c_xims_password  => { text  => 'XIMS User Password',
                          var   => \$Conf{password},
                          re    => '\w+',
                          error => 'You must enter a password.',
                          default => $Conf{password},
                        },
    d_db_username    => { text  => 'Database Username',
                          var   => \$Conf{DBUser},
                          re    => '\w+',
                          error => 'You must enter the database username for XIMS to access the database.',
                          default => $Conf{DBUser} || 'ximsrun',
                       },
    e_db_password    => { text  => 'Database Password',
                          var   => \$Conf{DBPassword},
                          re    => '\w+',
                          error => "You must enter the database user's password for XIMS to access the database.",
                          default => $Conf{DBPassword},
                        },
    f_db_dbname      => { text  => 'Database Name',
                          var   => \$Conf{DBName},
                          re    => '\w+',
                          error => 'You must enter the database name.',
                          default => $Conf{DBName} || 'xims',
                        },
    g_db_driver      => { text  => 'Database Driver',
                          var   => \$Conf{DBMS},
                          re    => '\w+',
                          error => 'You must enter the database driver (Pg, Oracle, etc.)',
                          default => $Conf{DBMS} || 'DBI',
                        },
);


print q*
  __  _____ __  __ ____  
  \ \/ /_ _|  \/  / ___| 
   \  / | || |\/| \___ \ 
   /  \ | || |  | |___) |
  /_/\_\___|_|  |_|____/ 

  Interactive Testing Tool

*;



my @selected_tests = select_tests();

if ( $prompt_config == 1 ) {
    warn "You must set up the config before running the tests.\n";
    $Args{ask_config} = 'y'
}

if ( $Args{ask_config} eq 'y' ) {
    do_config();
}

prompt( $prompts{log} );

#warn Dumper( \%Args );
#warn Dumper( \%Conf );
#exit;

local *SAVEERR;
open(SAVEERR, ">&STDERR");
open(STDERR, ">$Args{log_file}") || die "Failed to open $Args{log_file} - $!";


test_loop( @selected_tests );

close(STDERR);
open(STDERR, ">&SAVEERR"); 

# end main
#########################################

sub do_config {
    foreach ( sort( keys( %conf_prompts )) ) {
        prompt( $conf_prompts{$_} );
    }
    store( \%Conf, 'lib/XIMS/.ximstest.conf' ) || die "Could not write conf file, aborting\n";
    print "Config file written.\n";
    $Args{ask_config} = 'n'; 
}

sub test_loop {
    my @tests = @_;
    
    if ( scalar( @tests ) > 0 ) {
        eval {
        runtests(@tests);
        };
        if ( $@ ) {
        print "\nSome tests failed...\n"
        }
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
              error => 'You must select 1, 2, or 3',
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
       return;
    }
}

        
sub prompt {
    my $def = shift;
    #warn Dumper( $def);	
    print $def->{text} . "\n";
    if ( $def->{default} ) {
        print '[' . $def->{default} . ']';
    }
    print ': ';

    while (<>) {
      chomp;
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
          prompt( $def ) & last;
      }
   }
}

sub select_tests {
    my @test_files = ();

    prompt( $prompts{test_type} );
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
         return ();
    }
    $Args{ask_config} = 'n';
    return @test_files;
}
