#!/usr/bin/perl
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS;
use XIMS::DepartmentRoot;
use XIMS::Object;
use XIMS::User;
use XIMS::Document;
use XIMS::Bookmark;
use XIMS::Importer::Object;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:m:t:o:r:l:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "DepartmentRoot Creator" );

if ( $args{h} ) {
    print usage();
    exit;
}

unless ( $args{m} and $args{t} and $args{o} and $args{r} and $args{l} ) {
    die usage();
}

my $user = $term->authenticate( %args );
die "Could not authenticate user '".$args{u}."'\n" unless $user and $user->id();
die "Access Denied. You need to be admin.\n" unless $user->admin();

my $parent = XIMS::Object->new( path => $args{m} );
die "Could not find object '".$args{m}."'\n" unless $parent and $parent->id();

my $owner = XIMS::User->new( name => $args{o} );
die "Could not find user '".$args{o}."'\n" unless $owner and $owner->id();

my $role = XIMS::User->new( name => $args{r} );
die "Could not find role '".$args{r}."'\n" unless $role and $role->id();

my $importer = XIMS::Importer::Object->new( User => $user, Parent => $parent );

my $title = $term->utf8_sanitize( $args{t} );
my $deptroot = XIMS::DepartmentRoot->new( User => $user, location => $args{l}, title => $title );
my $deptrootid = $importer->import( $deptroot );
if ( $deptrootid ) {
    print "Successfully created DepartmentRoot.\n";

    # Set ci_departmentroot_properties.generate_stats to 1
    #my $engine = $deptroot->data_provider->{Driver}->{dbh};
    #unless ( $engine->do_insert( table => 'ci_departmentroot_properties',
    #                values => { 'document_id'=>$deptroot->document_id(), 'generate_stats'=>1 }) == 1) {
    #    warn "Unable to set departmentroot properties!\n";
    #};

    my $document = XIMS::Document->new( User => $owner, location => 'index.html', title => $title);
    $document->body( '<h1>'.$title.'</h1>' );

    my $deptimporter = XIMS::Importer::Object->new( User => $user, Parent => $deptroot );
    my $documentid = $deptimporter->import( $document );
    die "Could not import index.html\n" unless defined $documentid;
    print "Successfully created 'index.html'.\n";

    # Cheat a bit with the Departmentlinks
    $document->title( 'Home');
    $document->abstract( $title );
    if ( $deptroot->add_departmentlinks( ($document) ) ) {
        print "Successfully added Departmentlinks.\n";
        my $deptlink = XIMS::Object->new( User => $owner, path => $deptroot->location_path().'/departmentlinks/'.$deptroot->location_path_relative().'/index.html');
        if ( $deptlink and $deptlink->id() ) {
            $deptlink->location( $deptroot->location_path_relative() . '/' );
            $deptlink->update();
        }
        else {
            warn "Could not find Departmentlink.\n";
        }
    }
    else {
        die "Could not add Departmentlinks.\n";
    }
}
else {
    die "Could not import DepartmentRoot\n";
}

defaultgrants( $deptroot, $owner, $role );

my $iterator = $deptroot->descendants();
while ( my $desc = $iterator->getNext() ) {
    defaultgrants( $desc, $owner, $role );
}

my $default_bookmark = $role->bookmarks( explicit_only => 1, stdhome => 1 );
if ( $default_bookmark ) {
    $default_bookmark->stdhome( undef );
    warn "Could not unset existing default bookmark for '" . $role->name . "'\n" unless $default_bookmark->update();
}

my $bookmark = XIMS::Bookmark->new->data( owner_id => $role->id(), stdhome => 1, content_id => $deptroot->id() );
die "Could not create default bookmark\n" unless $bookmark->create();
print "Successfully set default bookmark.\n";

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] -m parent_path -o owner_username -r role_username -l location -t title

        -m Path to the XIMS container where the DepartmentRoot should be created.
        -o Username used as owner, creator and last_modifier of the created DepartmentRoot.
           MODIFY and PUBLISH privileges will be granted to this user.
        -r Rolename to which VIEW privileges will be granted. The newly created DepartmentRoot
           will be set as default bookmark of this role.
        -l Location of the DepartmentRoot
        -t Title of the DepartmentRoot. Will be used as title and header for the automatically created
           index.html

        -u The username to connect to the XIMS database. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS database user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

sub defaultgrants {
    my $object = shift;
    my $owner = shift;
    my $role = shift;

    if ( $object->grant_user_privileges(
                                        grantee  => $owner,
                                        grantor  => $user,
                                        privmask => (XIMS::Privileges::MODIFY|XIMS::Privileges::PUBLISH)
                                           )) {
    }
    else {
        warn "Could not grant privileges to " . $owner->name() . " .\n";
    }

    if ( $object->grant_user_privileges(
                                        grantee  => $role,
                                        grantor  => $user,
                                        privmask => XIMS::Privileges::VIEW
                                           )) {
    }
    else {
        warn "Could not grant privileges to " . $role->name() . " .\n";
    }
}

__END__

=head1 NAME

xims_create_departmentroot.pl - creates a departmentroot

=head1 SYNOPSIS

xims_create_departmentroot.pl [-h][-d][-u username -p password] -m parent_path -o owner_username -r role_username -l location -t title

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

Path to the XIMS container where the DepartmentRoot should be created.

=item B<-o>

Username used as owner, creator and last_modifier of the created DepartmentRoot.
MODIFY and PUBLISH privileges will be granted to this user.

=item B<-r>

Rolename to which VIEW privileges will be granted. The newly created DepartmentRoot
will be set as default bookmark of this role.

=item B<-l>

Location of the DepartmentRoot

=item B<-t>

Title of the DepartmentRoot. Will be used as title and header for the automatically created
index.html

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
