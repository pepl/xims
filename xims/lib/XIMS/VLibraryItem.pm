
=head1 NAME

XIMS::VLibraryItem -- A .... doing bla, bla, bla. (short)

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::VLibraryItem;

=head1 DESCRIPTION

This module bla bla

=head1 SUBROUTINES/METHODS

=cut

package XIMS::VLibraryItem;

use common::sense;
use parent qw( XIMS::Object );
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

__PACKAGE__->mk_accessors( qw(vlkeywords vlsubjects vlpublications vlauthors) );


# use Data::Dumper;



=head2    my @authors = $vlibitem->vleauthors();
    my $boolean = $vlibitem->vleauthors( @authors );

=head3 Parameter

    @authors                  (optional) : Array of XIMS::VLibAuthor objects to
                                           be associated to the VLibraryItem

=head3 Returns

    @authors    : Array of XIMS::VLibAuthor objects associated to the
                  VLibraryItem
    $boolean    : True or False for associating @authors to the VLibraryItem

=head3 Description

get/set accessor method for managing author entries of VLibrary items

=cut

sub vleauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Author', @_);
}



=head2    my @keywords = $vlibitem->vlekeywords();
    my $boolean = $vlibitem->vlekeywords( @keywords );

=head3 Parameter

    @keywords                 (optional) : Array of XIMS::VLibKeyword objects
                                           to be associated to the VLibraryItem

=head3 Returns

    @keywords   : Array of XIMS::VLibKeyword objects associated to the
                  VLibraryItem
    $boolean    : True or False for associating @keywords to the VLibraryItem

=head3 Description

get/set accessor method for managing keyword entries of VLibrary items

=cut

sub vlekeywords {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Keyword', @_);
}



=head2    my @subjects = $vlibitem->vlesubjects();
    my $boolean = $vlibitem->vlesubjects( @subjects );

=head3 Parameter

    @subjects                 (optional) : Array of XIMS::VLibSubject objects to be
                                           associated to the VLibraryItem

=head3 Returns

    @subjects   : Array of XIMS::VLibSubject objects associated to the VLibraryItem
    $boolean    : True or False for associating @subjects to the VLibraryItem

=head3 Description

get/set accessor method for managing subject entries of VLibrary items

=cut

sub vlesubjects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Subject', @_);
}



=head2    my @publications = $vlibitem->vlepublications();
    my $boolean = $vlibitem->vlepublications( @publications );

=head3 Parameter

    @publications             (optional) : Array of XIMS::VLibPublication objects
                                           to be associated to the VLibraryItem

=head3 Returns

    @publications   : Array of XIMS::VLibPublication objects associated to the
                      VLibraryItem
    $boolean        : True or False for associating @publications to the
                      VLibraryItem

=head3 Description

get/set accessor method for managing publication entries of VLibrary items

=cut

sub vlepublications {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    return $self->_vleproperties('Publication', @_);
}



=head2    my $meta = $vlibitem->vlemeta();
    my $boolean = $vlibitem->vlemeta( $meta );

=head3 Parameter

    $meta(optional) : XIMS::VLibMeta object to be associated to the VLibraryItem

=head3 Returns

    $meta           : XIMS::VLibMeta object associated to the VLibraryItem
    $boolean        : True or False for associating $meta to the VLibraryItem

=head3 Description

get/set accessor method for managing extra meta information of VLibrary items

=cut

sub vlemeta {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $meta = shift;

    return unless $self->document_id();

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
                return;
            }
        }
        else {
            if ($meta->update()) {
                XIMS::Debug( 4, "successfully updated meta with id $id" );
                return $id;
            }
            else {
                XIMS::Debug( 2, "could not update associate meta" );
                return;
            }
        }
    }
}


sub _vleproperties {
    XIMS::Debug( 5, "called" );
    my $self     = shift;
    my $property = shift;
    my @objects  = @_;

    return unless $property;

    return unless $self->document_id();

    my $class = "XIMS::VLib$property";

    if ( not( @objects and scalar @objects > 0 ) ) {

        # think of doing one instead of two queries here
        my $method     = "getVLib" . $property . "Map";
        my $propertyid = lc $property . "_id";
        my @object_ids = $self->data_provider->$method(
            document_id => $self->document_id(),
            properties  => [ ($propertyid) ],
            order       => "cilib_${property}map.id"
        );
        my $key = lc( "vlib" . $property . "map." . $property . "_id" );
        @object_ids = map { $_->{$key} } @object_ids;
        return unless scalar @object_ids;

        $method = "getVLib" . $property;

        my @objects_data;
        if ( $property eq 'Author' ) {
            # we need to keep the mapping positions (the order might matter
            # for author lists!), thus we loop here. This might be costly
            # for long lists, but these are rare in actual data.
            foreach (@object_ids) {
                push @objects_data, $self->data_provider->$method( id => $_ );
            }
        }
        else {
            # these will later be sorted alphabetically by the stylesheets.
            @objects_data = $self->data_provider->$method( id => \@object_ids );
        }

        @objects = map { $class->new->data( %{$_} ) } @objects_data;

        return wantarray ? @objects : $objects[0];
    }
    else {
        my $retval;
        my $objectmap;
        my $mapclass = $class . "Map";
        foreach my $object (@objects) {
            next
              unless defined $object
              and ref $object
              and $object->isa($class);
            my $method = lc $property . "_id";
            $objectmap = $mapclass->new(
                document_id => $self->document_id(),
                $method     => $object->id()
            );
            if ( not defined $objectmap ) {
                $objectmap = $mapclass->new();
                $objectmap->document_id( $self->document_id() );
                $objectmap->$method( $object->id() );
                my $id = $objectmap->create();
                if ( defined $id ) {
                    XIMS::Debug( 4,
                        "successfully created objectmap with id $id" );
                    $retval++;
                }
                else {
                    XIMS::Debug( 2,
                        "could not create objectmap for object "
                          . $object->id() );
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

Copyright (c) 2002-2013 The XIMS Project.

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

