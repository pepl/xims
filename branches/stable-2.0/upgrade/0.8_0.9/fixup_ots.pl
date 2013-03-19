#!/usr/bin/perl -w
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$

use strict;
use warnings;
no warnings 'redefine';

my $xims_home = $ENV{'XIMS_HOME'} || '/usr/local/xims';
die "\nWhere am I?\n\nPlease set the XIMS_HOME environment variable if you\ninstall into a different location than /usr/local/xims\n" unless -f "$xims_home/Makefile";
use lib ($ENV{'XIMS_HOME'} || '/usr/local/xims')."/lib",($ENV{'XIMS_HOME'} || '/usr/local/xims')."/tools/lib";

use XIMS::Object;
use XIMS::JavaScript;
use XIMS::Text;
use XIMS::CSS;
use XIMS::DataProvider;

use XIMS::Term;
use Getopt::Std;

my %args;
getopts('d:', \%args);

my $term = XIMS::Term->new( debuglevel => $args{d} );
print $term->banner( "js,txt,css Fixer" );
print warning();
print "Press enter to start.\n";<STDIN>;

my @ots = (XIMS::JavaScript->new(), XIMS::Text->new(), XIMS::CSS->new());

my $admin = XIMS::User->new( name => 'admin' );
my $dp = XIMS::DataProvider->new();

foreach my $ot ( @ots ) {
    my @objects = $dp->objects( location => '%.' . $ot->data_format->suffix() );

    my $total;
    if ( @objects and scalar @objects > 0 ) {
        $total = scalar @objects;
        print "\nFound '" . $total . "' objects with suffix '." . $ot->data_format->suffix() . "'.\n";
    }
    else {
        print "\nNo objects with suffix '." . $ot->data_format->suffix() . "' found.\n";
        next;
    }

    my $updated;
    foreach my $object ( @objects ) {
        $object->object_type_id( $ot->object_type->id() );
        $object->data_format_id( $ot->data_format->id() );

        # since $dp->objects includes the contents of the 'binfile' column as 'body',
        # we have to do a specific look up
        my $selected_data = $object->data_provider->getObject( id => $object->id(), properties => ['body'] );
        my $body = ( values( %{$selected_data} ) )[0];

        # skip if there is already a body
        if ( not (defined $body and length $body) ) {
            $selected_data = $object->data_provider->getObject( id => $object->id(), properties => ['binfile'] );
            my $binfile = ( values( %{$selected_data} ) )[0];
            $object->body( XIMS::xml_escape( $binfile ) ) if defined $binfile;
            $dp->update_content_binfile( $object->id(), undef ) if defined $binfile;
        }

        # store back to database and delete 'binfile' value
        if ( $object->update( User => $admin ) ) {
            $updated++;
            warn "Updated '" . $object->location_path . "'.\n";
        }
        else {
            warn "Could not update object '" . $object->location_path . "'.\n";
        }
    }

    my $otname = sprintf("%-20s", $ot->object_type->name()." objects");

    print qq*
        Object update report:
            Total $otname  $total
            Updated                     $updated

*;
}

exit 0;

sub warning {
    return qq*

  $0 will update existing objects with suffixes '.js', '.txt', and 'css'
  to have the correct object-type- and data-format-ids.
  Furthermore, it will move the content of that objects from the 'binfile'
  column, (where it has been placed by older versions of XIMS because of
  having object type 'File') to the 'body' column.

*;
}
