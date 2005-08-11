# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Importer::FileSystem::SymbolicLink;

use XIMS::Importer::FileSystem;
use vars qw( @ISA );
@ISA = qw(XIMS::Importer::FileSystem);

use XIMS::Object;
use File::Basename;

sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $location = shift;

    my $object = $self->SUPER::handle_data( $location );
    my $targetlocation = readlink $location;
    return undef unless $targetlocation;

    my $parent_path = $self->parent->location_path();
    my $exp = $targetlocation;
    my $dirname = dirname($location);
    if ( $exp =~ m|^\.\./| ) {
        my $anclevel = ( $exp =~ tr|../|../| );
        $anclevel = ($anclevel + 1) / 3;
        my $ancestors = $self->parent->ancestors();
        my $i = scalar @{$ancestors} + 1 - $anclevel;
        my $relparent = ${@{$ancestors}}[$i];
        next unless $relparent;
        $exp =~ s|\.\./||g;
        $exp = $relparent->location_path() . "/" . $exp;
    }
    elsif ( $exp =~ m|^\./| or $exp =~ m{^[^\./]|^[^/]}) {
        $exp =~ s/^\.\///;
        $exp = "$parent_path/$dirname/$exp";
    }
    elsif ( $exp =~ m|^/| ) {
        my $cwd = `pwd`;
        chomp $cwd;
        $exp =~ s|$cwd||;
        $exp = "$parent_path$exp";
    }

    my $targetobj = XIMS::Object->new( path => $exp );
    if ( $targetobj and $targetobj->id() ) {
        $object->symname_to_doc_id( $targetobj->document_id() );
    }
    else {
        XIMS::Debug( 3, "Could not resolve symlink $location, $targetlocation, $exp" );
        return undef;
    }

    return $object;
}

1;
