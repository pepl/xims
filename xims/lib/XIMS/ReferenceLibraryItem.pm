# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::ReferenceLibraryItem;

use strict;
use base qw( XIMS::Object );
use Encode;
use XIMS::DataFormat;
use XIMS::ReferenceLibrary;
use XIMS::RefLibReferenceProperty;
use XIMS::RefLibReferencePropertyValue;
use XIMS::RefLibReference;
use XIMS::RefLibAuthorMap;
use XIMS::VLibAuthor;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

__PACKAGE__->mk_accessors( qw(vlauthors) );

#use Data::Dumper;

##
#
# SYNOPSIS
#    my $item = XIMS::ReferenceLibraryItem->new( [ %args ] )
#
# PARAMETER
#    %args                  (optional) :  Takes the same arguments as its super class XIMS::Object
#
# RETURNS
#    $item : instance of XIMS::ReferenceLibraryItem
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::ReferenceLibraryItem for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    my @property_list = $item->property_list()
#
# PARAMETER
#    none
#
# RETURNS
#    @property_list: Array of reference properties mapped to the RefLibReferenceItem
#
# DESCRIPTION
#    Fetches reference properties mapped to the RefLibReferenceItem
#
sub property_list {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $reference_type_id = shift;

    if ( defined $self->reference ) {
        $reference_type_id ||= $self->reference->reference_type_id;
    }
    return () unless $reference_type_id;

    my @property_data = $self->data_provider->getRefLibReferencePropertyMap( reference_type_id => $reference_type_id, properties => [ qw( property_id ) ] );
    return () unless scalar(@property_data) > 0;
    my @property_ids = map { $_->{'reflibreferencepropertymap.property_id'} } @property_data;
    my @data = $self->data_provider->getRefLibReferenceProperty( id => \@property_ids );
    my @out = map { XIMS::RefLibReferenceProperty->new->data( %{$_} ) } @data;
    return @out;
}

##
#
# SYNOPSIS
#    my @property_values = $item->property_values()
#
# PARAMETER
#    none
#
# RETURNS
#    @property_values: Array of reference property values mapped to the RefLibReferenceItem
#
# DESCRIPTION
#    Fetches reference property values mapped to the RefLibReferenceItem
#
sub property_values {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $reference = $self->reference();
    my $reference_id;
    return () unless ( defined $reference and $reference_id = $reference->id );

    my @data = $self->data_provider->getRefLibReferencePropertyValue( reference_id => $reference_id, properties => [ qw( property_id value ) ] );
    my @out = map { XIMS::RefLibReferencePropertyValue->new->data( %{$_} ) } @data;
    return @out;
}

sub content_field {
    return 'binfile';
}

##
#
# SYNOPSIS
#    my $reference = $reflibitem->reference( [ $reference ] );
#
# PARAMETER
#    $reference    (optional) : Set reference entry of XIMS::ReferenceLibraryItem
#
# RETURNS
#    $reference    : instance of XIMS::RefLibReference
#
# DESCRIPTION
#    Gets/Sets reference entry of the XIMS::ReferenceLibraryItem
#
sub reference {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $reference = shift;

    if ( defined $reference and $reference->isa( 'XIMS::RefLibReference' ) ) {
        $self->{reference} = $reference;
        return $reference;
    }
    else {
        return $self->{reference} if defined $self->{reference};
        $reference = XIMS::RefLibReference->new( document_id => $self->document_id() );
        if ( defined $reference ) {
            $self->{reference} = $reference;
            return $reference;
        }
        else {
            return undef;
        }
    }
}

##
#
# SYNOPSIS
#    my @authors = $item->vleauthors();
#    my $boolean = $item->vleauthors( @authors );
#
# PARAMETER
#    @authors                  (optional) : Array of XIMS::VLibAuthor objects to be associated to the ReferenceLibraryItem
#
# RETURNS
#    @authors    : Array of XIMS::VLibAuthor objects associated to the ReferenceLibraryItem
#    $boolean    : True or False for associating @authors to the ReferenceLibraryItem
#
# DESCRIPTION
#    Get/Set accessor method for managing author entries of ReferenceLibraryItem items
#
sub vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleauthors( 0, @_ );
}

##
#
# SYNOPSIS
#    my @authors = $item->vleeditors();
#    my $boolean = $item->vleeditors( @authors );
#
# PARAMETER
#    @authors                  (optional) : Array of XIMS::VLibAuthor objects to be associated to the ReferenceLibraryItem
#
# RETURNS
#    @authors    : Array of XIMS::VLibAuthor objects associated to the ReferenceLibraryItem
#    $boolean    : True or False for associating @authors to the ReferenceLibraryItem
#
# DESCRIPTION
#    Get/Set accessor method for managing author entries of ReferenceLibraryItem items
#
sub vleeditors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleauthors( 1, @_ );
}

##
#
# SYNOPSIS
#    my $serial = $item->vleserial();
#    my $boolean = $item->vleserial( $serial );
#
# PARAMETER
#    $serial                  (optional) : Instance of a XIMS::RefLibSerial object to be associated to the ReferenceLibraryItem
#
# RETURNS
#    $serial     : Instance of the XIMS::RefLibSerial object to be associated to the ReferenceLibraryItem
#    $boolean    : True or False for associating $serial to the ReferenceLibraryItem
#
# DESCRIPTION
#    Get/Set accessor method for managing the serial publication entry of ReferenceLibraryItem items
#
sub vleserial {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $serial = shift;

    return undef unless $self->reference;
    my $reference_id = $self->reference->id();
    return undef unless $reference_id;

    if ( defined $serial and $serial->id() ) {
        $self->reference->serial_id( $serial->id() );
        if ( not $self->reference->update() ) {
            XIMS::Debug( 3, "Setting serial association failed." );
            return undef;
        }
        else {
            return 1;
        }
    }
    else {
        my $serial_id = $self->reference->serial_id();
        $serial = XIMS::RefLibSerial->new( id => $serial_id ) if defined $serial_id;
        return $serial;
    }
}


##
#
# SYNOPSIS
#    my @authors = $item->_vleauthors( 1|0 );
#    my $boolean = $item->vleauthors( 1|0, @authors );
#
# PARAMETER
#    1 | 0                                : 0 for authors, 1 for editors
#    @authors                  (optional) : Array of XIMS::VLibAuthor objects to be associated to the ReferenceLibraryItem
#
# RETURNS
#    @authors    : Array of XIMS::VLibAuthor objects associated to the ReferenceLibraryItem
#    $boolean    : True or False for associating @authors to the ReferenceLibraryItem
#
# DESCRIPTION
#    Get/Set helper method for managing author/editor entries of ReferenceLibraryItem items
#
sub _vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $role = shift;
    my @objects = @_;

    my $property = 'Author';

    if ( not defined $role and $role != 1 and $role != 0 ) {
        XIMS::Debug( 3, "Called with wrong arguments, need 0|1 (role) as initial argument" );
        return undef;
    }

    return undef unless $self->document_id();
    return undef unless $self->reference();
    my $reference_id = $self->reference->id();
    return undef unless $reference_id;

    my $class = "XIMS::VLib$property";

    if ( not (@objects and scalar @objects > 0) ) {
        # think of doing one instead of two queries here
        my $method = "getRefLib".$property."Map";
        my $propertyid = lc $property . "_id";
        my @object_ids = $self->data_provider->$method( reference_id => $reference_id, properties => [($propertyid)], role => $role, order => 'position ASC' );
        my $key = lc ("reflib".$property."map.".$property."_id");
        @object_ids = map { $_->{$key} } @object_ids;
        return () unless scalar @object_ids;

        $method = "getVLib".$property;
        my @objects_data = $self->data_provider->$method( id => \@object_ids );
        @objects = map { $class->new->data( %{$_} ) } @objects_data;

        # add the authors' positions and resort
        my @sorted_objects;
        my ($i, $j);
        for ( $i=0; $i < @object_ids; $i++ ) {
            for ( $j=0; $j < @objects; $j++ ) {
                if ( $object_ids[$i] == $objects[$j]->{id} ) {
                    $objects[$j]->{position} = $i+1;
                    push( @sorted_objects, $objects[$j] );
                    splice( @objects,$j,1 );
                    last;
                }
            }
        }
        #warn "objects" . Dumper( \@sorted_objects ) . "\n";
        return @sorted_objects;
    }
    else {
        my $retval;
        my $objectmap;
        my $mapclass= "XIMS::RefLibAuthorMap";
        my @existing_authors = $self->_vleauthors( $role );
        my $position = scalar(@existing_authors) || 0;
        foreach my $object ( @objects ) {
            next unless defined $object and ref $object and $object->isa( $class );
            my $method = lc $property."_id";
            $objectmap = $mapclass->new( reference_id => $reference_id, $method => $object->id(), role => $role );
            if ( not defined $objectmap ) {
                $objectmap = $mapclass->new();
                $objectmap->reference_id( $reference_id );
                $objectmap->$method( $object->id() );
                $objectmap->role( $role );
                $objectmap->position( ++$position );
                my $id = $objectmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4, "Successfully created authormap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2, "Could not create authormap for author " . $object->id() );
                }
            }
            else {
                XIMS::Debug( 4, "Mapping already exists" );
            }
        }
        return $retval;
    }
}

##
#
# SYNOPSIS
#    my $boolean = $item->reposition_author( %args );
#
# PARAMETER
#    $args{ old_position }    :  Old position
#    $args{ new_position }    :  New position
#    $args{ author_id }       :  Author ID
#    $args{ role }            :  Role (0|1)
#
# RETURNS
#    $boolean : True or False for repositioning object
#
# DESCRIPTION
#    Updates position of the author relative to the other associated VLibAuthors
#    associated to the ReferenceLibraryItem
#
sub reposition_author {
    my $self = shift;
    my %args = @_;

    my $old_position = delete $args{old_position};
    return undef unless $old_position;

    my $new_position = delete $args{new_position};
    return undef unless $new_position;

    my $author_id = delete $args{author_id};
    return undef unless defined $author_id;

    my $role = delete $args{role};
    return undef unless defined $role;

    return undef unless $self->document_id();
    return undef unless $self->reference;
    my $reference_id = $self->reference->id();
    return undef unless $reference_id;

    my $position_diff = $old_position - $new_position;

    my ( $udop, $upperop, $lowerop );
    if ( $position_diff > 0 ) {
        $udop    = "+";
        $upperop = "<";
        $lowerop = ">=";
    }
    else {
        $udop    = "-";
        $upperop = ">";
        $lowerop = "<=";
    }

    my $data = $self->data_provider->dbh->do_update( sql => [ qq{UPDATE cireflib_authormap
                                                    SET
                                                      position = position $udop 1
                                                    WHERE
                                                      position $upperop ?
                                                      AND position $lowerop ?
                                                      AND reference_id = ?
                                                      AND role = ?
                                                    }
                                                  , $old_position
                                                  , $new_position
                                                  , $reference_id
                                                  , $role
                                               ]
                                       );
    #warn "Repositioning Siblings. Driver returned: " . Dumper( $data ) . "\n";

    $data = $self->data_provider->dbh->do_update( table    => 'cireflib_authormap',
                                     values   => { 'position' => $new_position },
                                     criteria => { reference_id => $reference_id, role => $role, author_id => $author_id } );
    #warn "Repositioning Object. Driver returned: " . Dumper( $data ) . "\n";

    return $data;
}

##
#
# SYNOPSIS
#    my $boolean = $object->create_author_mapping_from_name( $role, $namestring );
#
# PARAMETER
#    $role                    :  0 for author, 1 for editor
#    $namestring              :  Namestring of the author(s); Multiple authors ';'-separated, author name parts ','-separated
#
# RETURNS
#    $boolean : True or False for creating author mapping
#
# DESCRIPTION
#    Associates author specified by name to the ReferenceLibraryItem. Creates new VLibAuthors if they do not exist yet.
#
sub create_author_mapping_from_name {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $role = shift;
    my $propertyvalue = shift;
    my @authors = ();

    $propertyvalue = Encode::decode_utf8($propertyvalue); # set the utf-8 bit to on, so that the regexes will work...
    my @vlpropvalues = split(";", XIMS::trim( XIMS::decode( $propertyvalue ) ) );
    foreach my $value ( @vlpropvalues ) {
        my $parsed_name = XIMS::VLibAuthor::parse_namestring( $value );
        my ($firstname, $middlename, $lastname, $suffix);
        if ( defined $parsed_name ) {
            $firstname = $parsed_name->{firstname};
            $lastname = $parsed_name->{lastname};
            $middlename = $parsed_name->{middlename};
            $suffix = $parsed_name->{suffix};
        }
        else {
            next;
        }

        my $vlibauthor = XIMS::VLibAuthor->new( lastname => XIMS::escapewildcard( $lastname ),
                                                middlename => $middlename,
                                                firstname => $firstname,
                                                suffix => $suffix);
        if ( not (defined $vlibauthor and $vlibauthor->id) ) {
            $vlibauthor = XIMS::VLibAuthor->new();
            $vlibauthor->lastname( $lastname );
            $vlibauthor->middlename( $middlename ) if ( defined $middlename and length $middlename );
            $vlibauthor->firstname( $firstname ) if ( defined $firstname and length $firstname );
            $vlibauthor->suffix( $suffix ) if ( defined $suffix and length $suffix );
            if ( not $vlibauthor->create() ) {
                XIMS::Debug( 3, "Could not create VLibauthor $lastname" );
                next;
            }
        }
        push( @authors, $vlibauthor );
    }

    my $method = 'vleauthors';
    $method = 'vleeditors' if $role == 1;
    return $self->$method( @authors );
}

##
#
# SYNOPSIS
#    my $boolean = $item->update_title( $date, $title, [ @vleauthors ] );
#
# PARAMETER
#    $date                    :  Date to be part of the title
#    $title                   :  Title of the reference item to be part in the object's title
#    @vleauthors (optional)   :  Array of XIMS::VLibAuthor instances; if not given $object->vleauthors() will be used.
#
# RETURNS
#    $boolean : True or False for updating the title
#
# DESCRIPTION
#    Sets $item->title() to a short citation based on VLibAuthors, reference title and reference date.
#    E.g. "AuthorOneLastname, AuthorTwoLastname, Title of Book (Year of Publication)"
#    Note: This method does not update the object in the database after setting the title
#
sub update_title {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $date = shift;
    my $title = shift;
    my @vleauthors = @_;

    $date = XIMS::trim( XIMS::decode( $date ) );
    $title = XIMS::trim( XIMS::decode( $title ) );
    $date ||= $self->{_date};
    $title ||= $self->{_title};

    my @authors = scalar @vleauthors ? @vleauthors : $self->vleauthors();
    my $ntitle;

    if ( defined $authors[0] ) {
        my @lastnames;
        for ( @authors ) {
            my $lastname = $_->lastname;
            if ( not XIMS::DBENCODING() ) {
                # DBD::Pg does not set UTF-8 Flag when returning data. During import,
                # $title has the flag set and if the non-utf8-flagged lastnames are concatenated,
                # garbage results. Hence, we have to check here, if the utf-8 flag is set for
                # the lastnames and if it is not, set it. :-|
                $lastname = Encode::decode_utf8($lastname) unless Encode::is_utf8($lastname);
            }
            push( @lastnames, $lastname );
        }
        #my @lastnames = map { $_->lastname } @authors;
        # Set the title to a brief quote of the reference
        $ntitle = join(', ', @lastnames);
    }
    else {
        $ntitle = 'Anonymous';
    }

    if ( defined $date and length $date ) {
        $ntitle .= ' (' . $date . ')';
    }

    # Similar UTF-8 check for title if it comes in via the Web-UI... :-|
    $title = Encode::decode_utf8($title) unless Encode::is_utf8($title); # and not XIMS::DBENCODING()

    $ntitle .= '. ' . $title;
    $self->title( $ntitle );

    return 1;
}

1;
