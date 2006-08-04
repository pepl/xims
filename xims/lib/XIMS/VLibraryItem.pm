# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::VLibraryItem;

use strict;
use base qw( XIMS::Object );
use XIMS::DataFormat;
use XIMS::VLibrary;
use XIMS::VLibAuthor;
use XIMS::VLibAuthorMap;
use XIMS::VLibKeyword;
use XIMS::VLibKeywordMap;
use XIMS::VLibSubject;
use XIMS::VLibSubjectMap;
use XIMS::VLibPublication;
use XIMS::VLibPublicationMap;
use XIMS::VLibMeta;

use Class::MethodMaker
        list       => [ qw(vlkeywords vlsubjects vlpublications vlauthors) ];

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# use Data::Dumper;

##
#
# SYNOPSIS
#    my @authors = $vlibitem->vleauthors();
#    my $boolean = $vlibitem->vleauthors( @authors );
#
# PARAMETER
#    @authors                  (optional) : Array of XIMS::VLibAuthor objects to be associated to the VLibraryItem
#
# RETURNS
#    @authors    : Array of XIMS::VLibAuthor objects associated to the VLibraryItem
#    $boolean    : True or False for associating @authors to the VLibraryItem
#
# DESCRIPTION
#    get/set accessor method for managing author entries of VLibrary items
#
sub vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Author', @_);
}

##
#
# SYNOPSIS
#    my @keywords = $vlibitem->vlekeywords();
#    my $boolean = $vlibitem->vlekeywords( @keywords );
#
# PARAMETER
#    @keywords                 (optional) : Array of XIMS::VLibKeyword objects to be associated to the VLibraryItem
#
# RETURNS
#    @keywords   : Array of XIMS::VLibKeyword objects associated to the VLibraryItem
#    $boolean    : True or False for associating @keywords to the VLibraryItem
#
# DESCRIPTION
#    get/set accessor method for managing keyword entries of VLibrary items
#
sub vlekeywords {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Keyword', @_);
}

##
#
# SYNOPSIS
#    my @subjects = $vlibitem->vlesubjects();
#    my $boolean = $vlibitem->vlesubjects( @subjects );
#
# PARAMETER
#    @subjects                 (optional) : Array of XIMS::VLibSubject objects to be associated to the VLibraryItem
#
# RETURNS
#    @subjects   : Array of XIMS::VLibSubject objects associated to the VLibraryItem
#    $boolean    : True or False for associating @subjects to the VLibraryItem
#
# DESCRIPTION
#    get/set accessor method for managing subject entries of VLibrary items
#
sub vlesubjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Subject', @_);
}

##
#
# SYNOPSIS
#    my @publications = $vlibitem->vlepublications();
#    my $boolean = $vlibitem->vlepublications( @publications );
#
# PARAMETER
#    @publications             (optional) : Array of XIMS::VLibPublication objects to be associated to the VLibraryItem
#
# RETURNS
#    @publications   : Array of XIMS::VLibPublication objects associated to the VLibraryItem
#    $boolean        : True or False for associating @publications to the VLibraryItem
#
# DESCRIPTION
#    get/set accessor method for managing publication entries of VLibrary items
#
sub vlepublications {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Publication', @_);
}

##
#
# SYNOPSIS
#    my $meta = $vlibitem->vlemeta();
#    my $boolean = $vlibitem->vlemeta( $meta );
#
# PARAMETER
#    $meta(optional) : XIMS::VLibMeta object to be associated to the VLibraryItem
#
# RETURNS
#    $meta           : XIMS::VLibMeta object associated to the VLibraryItem
#    $boolean        : True or False for associating $meta to the VLibraryItem
#
# DESCRIPTION
#    get/set accessor method for managing extra meta information of VLibrary items
#
sub vlemeta {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $meta = shift;

    return undef unless $self->document_id();

    if ( not $meta ) {
        return XIMS::VLibMeta->new( document_id => $self->document_id() );
    }
    else {
        next unless (defined $meta and ref $meta and $meta->isa( 'XIMS::VLibMeta' ));
        $meta->document_id( $self->document_id() );
        my $id = $meta->id();
        if (! $id ) {
            $id = $meta->create();
            if ( defined $id ) {
                XIMS::Debug( 4, "successfully created meta with id $id" );
                  return $id;
            }
            else {
                XIMS::Debug( 2, "could not create associate meta" );
                return undef;
            }
        }
        else {
            if ($meta->update()) {
                XIMS::Debug( 4, "successfully updated meta with id $id" );
                return $id;
            }
            else {
                XIMS::Debug( 2, "could not update associate meta" );
                return undef;
            }
        }
    }
}


sub _vleproperties {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $property = shift;
    my @objects = @_;

    return undef unless $property;

    return undef unless $self->document_id();

    my $class = "XIMS::VLib$property";

    if ( not (@objects and scalar @objects > 0) ) {
        # think of doing one instead of two queries here
        my $method = "getVLib".$property."Map";
        my $propertyid = lc $property . "_id";
        my @object_ids = $self->data_provider->$method( document_id => $self->document_id(), properties => [($propertyid)] );
        my $key = lc ("vlib".$property."map.".$property."_id");
        @object_ids = map { $_->{$key} } @object_ids;
        return undef unless scalar @object_ids;

        $method = "getVLib".$property;
        my @objects_data = $self->data_provider->$method( id => \@object_ids );
        @objects = map { $class->new->data( %{$_} ) } @objects_data;
        return wantarray ? @objects : $objects[0];
    }
    else {
        my $retval;
        my $objectmap;
        my $mapclass= $class."Map";
        foreach my $object ( @objects ) {
            next unless defined $object and ref $object and $object->isa( $class );
            my $method = lc $property."_id";
            $objectmap = $mapclass->new( document_id => $self->document_id(), $method => $object->id() );
            if ( not defined $objectmap ) {
                $objectmap = $mapclass->new();
                $objectmap->document_id( $self->document_id() );
                $objectmap->$method( $object->id() );
                my $id = $objectmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "successfully created objectmap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "could not create objectmap for object " . $object->id() );
                }
            }
            else {
                XIMS::Debug( 4, "mapping already exists" );
            }
        }
        return $retval;
    }
}

1;
