#!/usr/bin/env perl 
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::Exporter;
use XIMS::Term;
use Getopt::Std;

our $total;
our $successful;
our $failed;
our $ungranted;

# untaint path and env
$ENV{PATH} = '/bin'; # CWD.pm needs '/bin/pwd'
$ENV{ENV} = '';

my %args;
getopts('hd:u:p:m:raAnf', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Object Publisher" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $ARGV[0] ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();

my $object = XIMS::Object->new( path => $ARGV[0], marked_deleted => 0, User => $user );
die "Could not find object '".$ARGV[0]."'\n" unless $object and $object->id;

# rebless to the object-type's class
$object = rebless( $object );

my $privmask = $user->object_privmask( $object );
die "Access Denied. You do not have privileges to publish '".$ARGV[0]."'\n" unless $privmask and ($privmask & XIMS::Privileges::PUBLISH());

die "Option -a specified but object is not published.\n" if ( $args{a} and not $object->published() );
die "No write access to '" . XIMS::PUBROOT() . "'.\n"  unless -d XIMS::PUBROOT() and -w XIMS::PUBROOT();

my $exporter = XIMS::Exporter->new( Basedir  => XIMS::PUBROOT(),
                                    User     => $user,
                                  );

my $method = $args{m};
$method ||= 'publish'; # default action is to publish

my %options;

$total = 0;
$successful = 0;
$failed = 0;
$ungranted = 0;

if ( $args{r} or $method eq 'unpublish' ) {
    my %param = (User => $user, marked_deleted => 0 );
    $param{published} = 1 if ( $args{a} or $args{A} or $method eq 'unpublish' );

    # process the tree depth first, needed for unpublishing and handy for publishing since things like
    # auto-indices and portlets are correctly published in a single step
    my @descendants = reverse sort { $a->{level} <=> $b->{level} } $object->descendants_granted( %param );
    $options{no_dependencies_update} = 1 if scalar @descendants > 0;
    $options{no_pubber} = 1 if $args{A} and $user->admin();

    my $path;
    my %seencontainers;
    my $lastdir;
    foreach my $child ( @descendants ) {
        next if $child->location() eq '.diff_to_second_last'; # an -exception- :-|
        $child = rebless( $child );
        $privmask = $user->object_privmask( $child );
        $path = $child->location_path();

        my ($dir) = ($path =~ m#(.*)/(.*)$#);
        if ( $method eq 'publish' and $args{f} and not exists $seencontainers{$dir} ) {
            $options{force_ancestor_publish} = 1;
        }
        else {
            delete $options{force_ancestor_publish};
        }

        if ( $privmask & XIMS::Privileges::PUBLISH() ) {
            if ( $exporter->$method( Object => $child, User => $user, %options ) ) {
                print "Object '$path' ".$method."ed successfully.\n";

                $seencontainers{$dir}++;
                $total++;
                $successful++;
            }
            else {
                print "could not $method object '$path'.\n";
                $total++;
                $failed++;
            }
        }
        else {
            print "no privileges to $method object '$path'.\n";
            $total++;
            $ungranted++;
        }
    }
}

# (re)set no_dependencies_update
$args{n} ? $options{no_dependencies_update} = 1 : delete $options{no_dependencies_update};
$options{no_pubber} = 1 if $args{A} and $user->admin();

if ( $exporter->$method( Object => $object, User => $user, %options ) ) {
    print "Object '" . $object->title . "' ".$method."ed successfully.\n";
    $total++;
    $successful++;
}
else {
    print "Could not $method object '" . $object->title . "'.\n";
    $total++;
    $failed++;
}

if ( $method eq 'publish' ) {
    my @pubrootstat = stat XIMS::PUBROOT();
    my $uid = $pubrootstat[4]; # after install, XIMS::PUBROOT is owned by the apache-user
    my $gid = $pubrootstat[5];
    # because additional files like meta-data files or autoindices are created
    # by the exporter, we have to recursively chown and chmod 755 the file to the apache-user
    system('chown','-R',$uid.':'.$gid,XIMS::PUBROOT().$object->location_path()) == 0
        or warn "Could not chown ".XIMS::PUBROOT() . $object->location_path.".\n";
    system('chmod','-R','g+w',XIMS::PUBROOT().$object->location_path()) == 0
           or warn "Could not chown ".XIMS::PUBROOT() . $object->location_path.".\n";
}

print qq*
    Publish Report:
        Total files:                    $total
        Successfully exported:          $successful
        Failed exported:                $failed
        Missing publishing privileges:  $ungranted

*;

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] [-a] [-m method -r] path-to-publish
        -m Either 'unpublish' or 'publish'; the latter is the default.
        -r Recursively publish descendants.
        -a If specified, published objects will be republished only
        -A Same, but without modifying metadata (Admin only)
        -n If specified, publishing dependencies of the object will not be updated
           Will have no effect for publishing trees recursively.

        -u The username to connect to XIMS. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

sub rebless {
    my $object = shift;
    my $otclass = "XIMS::" . $object->object_type->fullname();

    # load the object class
    eval "require $otclass;" if $otclass;
    if ( $@ ) {
        die "Could not load object class $otclass: $@\n";
    }

    # rebless the object
    bless $object, $otclass;
    return $object;
}

__END__

=head1 NAME

xims_publisher.pl - publishs large numbers of documents

=head1 SYNOPSIS

xims_publisher.pl [-h][-d][-u username -p password] [-a] [-m method -r] path-to-publish

Options:
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-m>

Either 'unpublish' or 'publish'; the latter is the default.

=item B<-r>

Recursively publish descendants.

=item B<-a>

If specified, published objects will be republished only.

=item B<-A>

Admin can re-publish objects without changing metadata (timestamps et al.)

=item B<-n>

If specified, publishing dependencies of the object will not be updated.
Will have no effect for publishing trees recursively.

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
