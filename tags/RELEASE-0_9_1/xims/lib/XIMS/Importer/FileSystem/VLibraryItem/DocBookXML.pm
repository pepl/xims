# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::VLibraryItem::DocBookXML;

use XIMS::Importer::FileSystem;
use XIMS::Importer::FileSystem::XML;
use XIMS::Importer::Object::VLibraryItem::DocBookXML;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem::XML XIMS::Importer::Object::VLibraryItem::DocBookXML);

use File::Basename;

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location, 1 );
    my $root = $self->get_rootelement( $location, nochunk => 1 );
    return undef unless $root;

    # hacky, tracky - there is no such thing as SUPER::SUPER :-|
    # the vl* methods need an already created object with a document_id to assign the foreign
    # key mappings
    XIMS::Importer::import( $self, $object );

    $self->vlproperties_from_document( $root, $object );

    # bidok specific .zip import -- to be replaced by auto generated pdf-version
    #my ( $stripped_location ) = ( $location =~ s|(.*)\..*$|$1| );
    #my $zip_location .= $stripped_location.'.zip';

    my @filerefs = $root->findnodes( '//@fileref' );
    if ( @filerefs and scalar @filerefs > 0 ) {
        my $importer = XIMS::Importer::FileSystem->new( User => $self->user, Parent => $object );
        foreach my $fileref ( @filerefs ) {
            my $filename = $fileref->to_literal();

            $filename =~ s#\.(/|\\)##; # clean up the filename
            next if $filename =~ m#/|\\#; # only import filerefs in the same dir for now

            $filename = dirname($location).'/'.$filename;
            if ( not -f $filename ) {
                XIMS::Debug( 3, "could not find referenced file '$filename'" );
                next;
            }
            if ( $importer->import( $filename ) ) {
                print "'$filename' imported successfully.\n";
            }

            else {
                print "Import of '$filename' failed.\n";
            }
        }
    }

    return $object;
}

1;
