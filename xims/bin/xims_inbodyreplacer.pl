#!/usr/bin/env perl
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";
BEGIN{ $ENV{'XIMS_NO_XSLCONFIG'} = 1; } # don't attempt to write config.xsl
use XIMS;
use XIMS::Object;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:s:r:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Body Regex Replace Tool" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{s} and $ARGV[0] ) {
    die usage();
}

#my $user = $term->authenticate( %args );
my $user = XIMS::User->new( name => $args{u} );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $object = XIMS::Object->new( path => $ARGV[0], marked_deleted => 0, User => $user );
die "Could not find object '".$ARGV[0]."'\n" unless $object and $object->id;

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to manage privileges for '".$ARGV[0]."'\n" unless $privmask and ($privmask & XIMS::Privileges::WRITE());

my $search = $args{s};
my $replace = $args{r} || '';

my $body = $object->body();
my $count = $body =~ s/$search/$replace/g;

if ( $count ) {
    $object->body( $body );
    if ( not $object->update( no_modder => 1 ) ) {
        warn "Could not update '".$ARGV[0]."'\n";
    }
    else {
        print "Replaced '$count' occurences.\n";
    }
}

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-s] [-r] path-to-object
        -s String to be replaced
        -r Optional replacement string

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

__END__

=head1 NAME

xims_inbodyreplacer.pl 

=head1 SYNOPSIS

xims_inbodyreplacer.pl [-h][-d][-u username -p password] [-s] [-r] path-to-object

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-s>

String to be replaced

=item B<-r>

Optional replacement string

=item B<-u>

The username to connect to XIMS. If not specified,
you will be asked for it interactively.

=item B<-p>

The password of the XIMS user. If not specified,
you will be asked for it interactively.

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut
