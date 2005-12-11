# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SimpleDB;

use strict;
use warnings;

our $VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };;

use base qw( XIMS::Folder );
use XIMS::DataFormat;
use XIMS::SimpleDBMemberProperty;
use XIMS::SimpleDBMemberPropertyMap;

##
#
# SYNOPSIS
#    my $simpledb = XIMS::SimpleDB->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from ...
#
# RETURNS
#    $simpledb: XIMS::SimpleDB instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'SimpleDB' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    my @property_list = $simpledb->mapped_member_properties( [ %args ] );
#
# PARAMETER
#    $args{part_of_title}    (optional)    : Filter properties by part_of_title property
#    $args{mandatory}        (optional)    : Filter properties by mandatory property
#    $args{gopublic}         (optional)    : Filter properties by gopublic property
#
# RETURNS
#    @property_list  : Array of mapped member properties (XIMS::SimpleDBMemberProperty instances)
#
# DESCRIPTION
#    Fetch mapped properties assigned to the SimpleDB
#
sub mapped_member_properties {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    return () unless defined $self->document_id();

    my %params;
    $params{mandatory} = delete $args{mandatory} if exists $args{mandatory};
    $params{part_of_title} = delete $args{part_of_title} if exists $args{part_of_title};
    $params{gopublic} = delete $args{gopublic} if exists $args{gopublic};
    $params{order} = 'position ASC';

    # Think of doing a join instead of the two queries here...
    my @property_data = $self->data_provider->getSimpleDBMemberPropertyMap( document_id => $self->document_id(), properties => [ qw( property_id ) ] );
    return () unless scalar(@property_data) > 0;
    my @property_ids = map { values %{$_} } @property_data;
    my @data = $self->data_provider->getSimpleDBMemberProperty( id => \@property_ids, %params );
    my @out = map { XIMS::SimpleDBMemberProperty->new->data( %{$_} ) } @data;
    return @out;
}

##
#
# SYNOPSIS
#    my $boolean = $simpledb->map_member_property( $memberproperty );
#
# PARAMETER
#    $memberproperty                : Instance of XIMS::SimpleDBMemberProperty
#
# RETURNS
#    True if mapping suceeded, false otherwise
#
# DESCRIPTION
#    Maps a SimpleDB member property to a SimpleDB instance
#
sub map_member_property {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $memberproperty = shift;

    if ( defined $memberproperty and $memberproperty->isa('XIMS::SimpleDBMemberProperty') and defined $memberproperty->id() ) {
        my $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( document_id => $self->document_id(), property_id => $memberproperty->id() );
        if ( not defined $memberpropertymap ) {
            $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new();
            $memberpropertymap->document_id( $self->document_id() );
            $memberpropertymap->property_id( $memberproperty->id() );
            return $memberpropertymap->create();
        }
        else {
            XIMS::Debug( 3, "Mapping already exists." );
            return undef;
        }
    }
    else {
        XIMS::Debug( 3, "An existing XIMS::SimpleDBMemberProperty object is needed to map to a SimpleDB" );
        return undef;
    }
}

##
#
# SYNOPSIS
#    my $boolean = $simpledb->unmap_member_property( $memberproperty );
#
# PARAMETER
#    $memberproperty                : Instance of XIMS::SimpleDBMemberProperty
#
# RETURNS
#    True if unmapping suceeded, false otherwise
#
# DESCRIPTION
#    Unmaps a SimpleDB member property to a SimpleDB instance
#
sub unmap_member_property {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $memberproperty = shift;

    if ( defined $memberproperty and $memberproperty->isa('XIMS::SimpleDBMemberProperty') and defined $memberproperty->id() ) {
        my $memberpropertymap = XIMS::SimpleDBMemberPropertyMap->new( document_id => $self->document_id(), property_id => $memberproperty->id() );
        if ( defined $memberpropertymap ) {
            return $memberpropertymap->delete();
        }
        else {
            XIMS::Debug( 3, "Mapping does not exist and therefore cannot be deleted." );
            return undef;
        }
    }
    else {
        XIMS::Debug( 3, "An existing XIMS::SimpleDBMemberProperty object is needed to unmap from a SimpleDB" );
        return undef;
    }
}

##
#
# SYNOPSIS
#    my ($item_count, $items) = $simpledb->items_granted( [ %args ] )
#
# PARAMETER
#    $args{ User }         (optional) :  XIMS::User instance
#
#    $args{ limit }        (optional) :  Limit size of $reflibitems arrayref
#                                        Usually used together with 'offset' for pagination
#    $args{ offset }       (optional) :  Offset of returned items relative to total items
#                                        Usually used together with 'limit' for pagination
#    $args{ order }        (optional) :  Sort by object property
#
#    $args{ searchstring } (optional) :  Filter items by searchstring; searchstring will be looked
#                                        for in the mandatory member properties
#
# RETURNS
#    $item_count:  Count of total items
#    $items: Arrayref of SimpleDBItems part of the SimpleDB,
#                  slice selected by $args{limit} and $args{offset}
#
# DESCRIPTION
#    Fetches SimpleDBItems part of the SimpleDB granted to $args{User} or $simpledb->User resp.
#    Returned SimpleDBItems will include a 'member_values' key including the items member property values
#    and a 'user_privileges' key containing the active user object privileges
#
sub items_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $searchstring = delete $args{searchstring};

    my $child_count;
    my @children;
    my %privmask;
    my $userid = $self->User()->id();
    my $properties = 'distinct c.id, m.id AS member_id, d.document_status, d.position, d.parent_id, object_type_id, creation_timestamp, symname_to_doc_id, last_modified_by_middlename, last_modified_by_firstname, language_id, last_publication_timestamp, last_published_by_lastname, css_id, created_by_firstname, data_format_id, keywords, last_modification_timestamp, last_modified_by_id, c.title, c.document_id, location, created_by_lastname, attributes, last_modified_by_lastname, image_id, created_by_id, owned_by_firstname, marked_deleted, last_published_by_id, notes, style_id, owned_by_lastname, owned_by_middlename, abstract, published, locked_by_lastname, locked_by_id, last_published_by_firstname, script_id, owned_by_id, created_by_middlename, data_format_name, locked_by_middlename, last_published_by_middlename, marked_new, locked_time, department_id, locked_by_firstname ';
    my $tables = 'ci_content c, ci_documents d, cisimpledb_members m';
    my $conditions = 'c.document_id = d.id AND m.document_id = d.id AND d.parent_id = ?';
    my @values = ( $self->document_id() );
    if ( not $self->User->admin() ) {
        my @userids = ( $userid, $self->User->role_ids());
        $tables .= ', ci_object_privs_granted p';
        $conditions .= ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN (' . join(',', map { '?' } @userids) . ')';
        push @values, @userids;
    }

    if ( defined $searchstring ) {
        $tables .= ', cisimpledb_member_propertyvalues pv';
        $conditions .= " AND pv.member_id = m.id AND pv.property_id IN (SELECT id FROM cisimpledb_member_properties WHERE mandatory = 1) AND lower(pv.value) LIKE lower(?)";
        push @values, $searchstring;
    }

    my $countsql = "SELECT count(distinct c.id) AS cid FROM $tables WHERE $conditions";
    my $countdata = $self->data_provider->driver->dbh->fetch_select( sql => [ $countsql, @values ] );
    $child_count = $countdata->[0]->{cid};

    if ( defined $child_count and $child_count > 0 ) {
        my $sql = "SELECT $properties FROM $tables WHERE $conditions";
        my $data = $self->data_provider->driver->dbh->fetch_select(
                                                                     sql => [ $sql, @values ],
                                                                     limit => $args{limit},
                                                                     offset => $args{offset},
                                                                     order => $args{order}
                                                                     );

        my @childids;
        foreach my $kiddo ( @{$data} ) {
            push( @children, (bless $kiddo, 'XIMS::SimpleDBItem') );
            push( @childids, $kiddo->{id} );
            $privmask{$kiddo->{id}} = 0xffffffff if $self->User->admin();

            my @propdata = $self->data_provider->getSimpleDBMemberPropertyValue( member_id => $kiddo->{member_id},
                                                                                properties => [ qw( property_id value ) ] );
            my @propout = map { XIMS::SimpleDBMemberPropertyValue->new->data( %{$_} ) } @propdata;
            $kiddo->{member_values} = { member_value => \@propout };
        }

        if ( not $self->User->admin() ) {
            my @uid_list = ($userid, $self->User->role_ids());
            my @priv_data = $self->data_provider->getObjectPriv( content_id => \@childids,
                                                                 grantee_id => \@uid_list,
                                                                 properties => [ 'privilege_mask', 'content_id' ] );
            foreach my $priv ( @priv_data ) {
                $privmask{$priv->{'objectpriv.content_id'}} |= int($priv->{'objectpriv.privilege_mask'});
            }
        }
    }

    foreach my $child ( @children ) {
        my $privilege_mask = $privmask{$child->{id}};
        $child->{user_privileges} = XIMS::Helpers::privmask_to_hash( $privilege_mask );
    }

    return ($child_count, \@children);
}

1;
