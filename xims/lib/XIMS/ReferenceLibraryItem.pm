
=head1 NAME

XIMS::ReferenceLibraryItem

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::ReferenceLibraryItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::ReferenceLibraryItem;

use common::sense;
use parent qw( XIMS::Object );
use Encode;
use XIMS::DataFormat;
use XIMS::ReferenceLibrary;
use XIMS::RefLibReferenceProperty;
use XIMS::RefLibReferencePropertyValue;
use XIMS::RefLibReference;
use XIMS::RefLibAuthorMap;
use XIMS::VLibAuthor;

__PACKAGE__->mk_accessors( qw(vlauthors) );

#use Data::Dumper;



=head2    my $item = XIMS::ReferenceLibraryItem->new( [ %args ] )

=head3 Parameter

    %args                  (optional) :  Takes the same arguments as its super
                                         class XIMS::Object

=head3 Returns

    $item : instance of XIMS::ReferenceLibraryItem

=head3 Description

Fetches existing objects or creates a new instance of
XIMS::ReferenceLibraryItem for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'XML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}



=head2    my @property_list = $item->property_list()

=head3 Parameter

    none

=head3 Returns

    @property_list: Array of reference properties mapped to the
                    RefLibReferenceItem

=head3 Description

Fetches reference properties mapped to the RefLibReferenceItem

=cut

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



=head2    my @property_values = $item->property_values()

=head3 Parameter

    none

=head3 Returns

    @property_values: Array of reference property values mapped to the
                      RefLibReferenceItem

=head3 Description

Fetches reference property values mapped to the RefLibReferenceItem

=cut

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

=head2 content_field()

=cut

sub content_field {
    return 'binfile';
}



=head2    my $reference = $reflibitem->reference( [ $reference ] );

=head3 Parameter

    $reference    (optional) : Set reference entry of
                               XIMS::ReferenceLibraryItem

=head3 Returns

    $reference    : instance of XIMS::RefLibReference

=head3 Description

Gets/Sets reference entry of the XIMS::ReferenceLibraryItem

=cut

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
            return;
        }
    }
}



=head2    my @authors = $item->vleauthors();
    my $boolean = $item->vleauthors( @authors );

=head3 Parameter

    @authors                  (optional) : Array of XIMS::VLibAuthor objects
                                           to be associated to the 
                                           ReferenceLibraryItem

=head3 Returns

    @authors    : Array of XIMS::VLibAuthor objects associated to the
                  ReferenceLibraryItem
    $boolean    : True or False for associating @authors to the
                  ReferenceLibraryItem

=head3 Description

Get/Set accessor method for managing author entries of ReferenceLibraryItem
items

=cut

sub vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleauthors( 0, @_ );
}



=head2    my @authors = $item->vleeditors();
    my $boolean = $item->vleeditors( @authors );

=head3 Parameter

    @authors                  (optional) : Array of XIMS::VLibAuthor objects to
                                           be associated to the
                                           ReferenceLibraryItem

=head3 Returns

    @authors    : Array of XIMS::VLibAuthor objects associated to the
                  ReferenceLibraryItem
    $boolean    : True or False for associating @authors to the
                  ReferenceLibraryItem

=head3 Description

Get/Set accessor method for managing author entries of ReferenceLibraryItem
items

=cut

sub vleeditors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleauthors( 1, @_ );
}



=head2    my $serial = $item->vleserial();
    my $boolean = $item->vleserial( $serial );

=head3 Parameter

    $serial                  (optional) : Instance of a XIMS::RefLibSerial
                                          object to be associated to the
                                          ReferenceLibraryItem

=head3 Returns

    $serial     : Instance of the XIMS::RefLibSerial object to be associated
                  to the ReferenceLibraryItem
    $boolean    : True or False for associating $serial to the 
                  ReferenceLibraryItem

=head3 Description

Get/Set accessor method for managing the serial publication entry of
ReferenceLibraryItem items

=cut

sub vleserial {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $serial = shift;

    return unless $self->reference;
    my $reference_id = $self->reference->id();
    return unless $reference_id;

    if ( defined $serial and $serial->id() ) {
        $self->reference->serial_id( $serial->id() );
        if ( not $self->reference->update() ) {
            XIMS::Debug( 3, "Setting serial association failed." );
            return;
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




=head2    my @authors = $item->_vleauthors( 1|0 );
    my $boolean = $item->vleauthors( 1|0, @authors );

=head3 Parameter

    1 | 0                                : 0 for authors, 1 for editors
    @authors                  (optional) : Array of XIMS::VLibAuthor objects
                                           to be associated to the
                                           ReferenceLibraryItem

=head3 Returns

    @authors    : Array of XIMS::VLibAuthor objects associated to the
                  ReferenceLibraryItem
    $boolean    : True or False for associating @authors to the
                  ReferenceLibraryItem

=head3 Description

Get/Set helper method for managing author/editor entries of ReferenceLibraryItem
items

=cut

sub _vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $role = shift;
    my @objects = @_;

    my $property = 'Author';

    if ( not defined $role and $role != 1 and $role != 0 ) {
        XIMS::Debug( 3, "Called with wrong arguments, need 0|1 (role) as initial argument" );
        return;
    }

    return unless $self->document_id();
    return unless $self->reference();
    my $reference_id = $self->reference->id();
    return unless $reference_id;

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



=head2    my $boolean = $item->reposition_author( %args );

=head3 Parameter

    $args{ old_position }    :  Old position
    $args{ new_position }    :  New position
    $args{ author_id }       :  Author ID
    $args{ role }            :  Role (0|1)

=head3 Returns

    $boolean : True or False for repositioning object

=head3 Description

Updates position of the author relative to the other associated VLibAuthors
associated to the ReferenceLibraryItem

=cut

sub reposition_author {
    my $self = shift;
    my %args = @_;

    my $old_position = delete $args{old_position};
    return unless $old_position;

    my $new_position = delete $args{new_position};
    return unless $new_position;

    my $author_id = delete $args{author_id};
    return unless defined $author_id;

    my $role = delete $args{role};
    return unless defined $role;

    return unless $self->document_id();
    return unless $self->reference;
    my $reference_id = $self->reference->id();
    return unless $reference_id;

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



=head2    my $boolean = $object->create_author_mapping_from_name( $role, $namestring );

=head3 Parameter

    $role                    :  0 for author, 1 for editor
    $namestring              :  Namestring of the author(s); Multiple authors
                                ';'-separated, author name parts ','-separated

=head3 Returns

    $boolean : True or False for creating author mapping

=head3 Description

Associates author specified by name to the ReferenceLibraryItem. Creates new
VLibAuthors if they do not exist yet.

=cut

sub create_author_mapping_from_name {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $role = shift;
    my $propertyvalue = shift;
    my @authors = ();

    $propertyvalue = Encode::decode('UTF-8',$propertyvalue); # set the utf-8 bit to on, so that the regexes will work...
    my @vlpropvalues = split(";", XIMS::trim( $propertyvalue ) );
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
                                                suffix => $suffix,
                                                document_id => $self->parent_id
                                              );
        if ( not (defined $vlibauthor and $vlibauthor->id) ) {
            $vlibauthor = XIMS::VLibAuthor->new();
            $vlibauthor->lastname( $lastname );
            $vlibauthor->middlename( $middlename ) if ( defined $middlename and length $middlename );
            $vlibauthor->firstname( $firstname ) if ( defined $firstname and length $firstname );
            $vlibauthor->suffix( $suffix ) if ( defined $suffix and length $suffix );
            $vlibauthor->document_id( $self->parent_id);
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



=head2    my $boolean = $item->update_title( $date, $title, [ @vleauthors ] );

=head3 Parameter

    $date                    :  Date to be part of the title
    $title                   :  Title of the reference item to be part in the
                                object's title
    @vleauthors (optional)   :  Array of XIMS::VLibAuthor instances; if not
                                given $object->vleauthors() will be used.

=head3 Returns

    $boolean : True or False for updating the title

=head3 Description

Sets $item->title() to a short citation based on VLibAuthors, reference title
and reference date. E.g. "AuthorOneLastname, AuthorTwoLastname, Title of Book
(Year of Publication)" Note: This method does not update the object in the
database after setting the title

=cut

sub update_title {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $date = shift;
    my $title = shift;
    my @vleauthors = @_;

    $date = XIMS::trim( $date );
    $title = XIMS::trim( $title );
    $date ||= $self->{_date};
    $title ||= $self->{_title};

    my @authors = scalar @vleauthors ? @vleauthors : $self->vleauthors();
    my $ntitle;

    if ( defined $authors[0] ) {
        my @lastnames;
        for ( @authors ) {
            my $lastname = $_->lastname;

            # DBD::Pg does not set UTF-8 Flag when returning data. During import,
            # $title has the flag set and if the non-utf8-flagged lastnames are concatenated,
            # garbage results. Hence, we have to check here, if the utf-8 flag is set for
            # the lastnames and if it is not, set it. :-|
            $lastname = Encode::decode('UTF-8', $lastname) unless Encode::is_utf8($lastname);

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
    $title = Encode::decode('UTF-8', $title) unless Encode::is_utf8($title);

    $ntitle .= '. ' . $title;
    $self->title( $ntitle );

    return 1;
}

1;

__END__

=head1 DIAGNOSTICS

Look at the F<error_log> file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

in F<httpd.conf>: yadda, yadda...

Optional section , remove if bogus

=head1 DEPENDENCIES

Optional section, remove if bogus.

=head1 INCOMPATABILITIES

Optional section, remove if bogus.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-2015 The XIMS Project.

See the file F<LICENSE> for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

