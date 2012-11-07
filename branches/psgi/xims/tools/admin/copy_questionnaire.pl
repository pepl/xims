#!/usr/bin/perl -w
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;
no warnings 'redefine';

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib";

use XIMS::ObjectType;
use XIMS::Questionnaire;
use XIMS::QuestionnaireResult;
use XIMS::ObjectPriv;
use XIMS::User;
use XIMS::Term;
use Getopt::Std;

my %args;
getopts('hd:u:p:l:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "Questionnaire Copier" );

if ( $args{h} ) {
    print usage();
    exit;
}

my $sourcepath = shift @ARGV;
my $targetpath = shift @ARGV;

unless ( $sourcepath and  $targetpath ) {
    die usage();
}


my $user = $term->authenticate( %args );
my $user = XIMS::User->new( name => $args{u} );

my $questionnaire = XIMS::Questionnaire->new( User => $user, path => $sourcepath, marked_deleted => undef );
die "Could not find source questionnaire\n" unless $questionnaire and $questionnaire->id;

my $privmask = $user->object_privmask( $questionnaire );
die "Access Denied. You do not have privileges to copy to '".$sourcepath."'\n" unless $privmask and ($privmask & XIMS::Privileges::COPY());

my $targetcontainer = XIMS::Object->new( User => $user, path => $targetpath, marked_deleted => undef );
die "Could not find target container\n" unless $targetcontainer and $targetcontainer->id;

die "Target is not a container\n" unless $targetcontainer->object_type->is_fs_container();

$privmask = $user->object_privmask( $targetcontainer );
die "Access Denied. You do not have privileges to copy to '".$targetpath."'\n" unless $privmask and ($privmask & XIMS::Privileges::CREATE());

my $copy = $questionnaire->copy( target => $targetcontainer->document_id() );
if ( defined $copy ) {
    print "Successfully copied '".$questionnaire->location."'\n";
}
else {
    die "Copying of '".$questionnaire->location."' unsuccessful\n";
}

exit 0;

sub usage {
    return qq*

  Usage: $0 [-h][-d][-u username -p password] source-path target-path

        -u The username to connect to the XIMS database. If not specified,
           you will be asked for it interactively.
        -p The password of the XIMS database user. If not specified,
           you will be asked for it interactively.
        -d For more verbose output, specify the XIMS debug level; default is '1'
        -h prints this screen

*;
}

sub XIMS::Questionnaire::copy {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $user = delete $args{User} || $self->{User};
    die "Copying an object requires an associated User" unless defined( $user );

    my $target_id = delete $args{target};
    return unless defined $target_id;

    my $clone = $self->clone( User => $user,
                        scope_subtree => 1,
                        target_id => $target_id,
                        target_location => $args{target_location} );

    if ( defined $clone ) {
        $self->data_provider->driver->dbh->visit_select(
            sub { my $r = shift;
                  my %data = %{$r};
                  $data{document_id} = $clone->document_id;
                  #$data{tan} = 'DUMMYTANFROMCOPYQUESTIONNAIRE';
                  my $result = XIMS::QuestionnaireResult->new( %data );
                  $result->create();
                },
            table => 'ci_questionnaire_results',
            columns => [ qw( tan question_id answer answer_timestamp ) ],
            criteria => { 'document_id' => $self->document_id() }
        );
    }

    return $clone;
}

__END__

=head1 NAME

copy_questionnaire.pl

=head1 SYNOPSIS

copy_questionnaire.pl [-h][-d][-u username -p password] source-path target-path

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

The username to connect to XIMS. If not specified,
you will be asked for it interactively.

=item B<-p>

The password of the XIMS user. If not specified,
you will be asked for it interactively.

=item B<-d>

For more verbose output, specify the XIMS debug level; default is '1'

=back

=cut
