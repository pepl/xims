# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::ReferenceLibrary;

use strict;
# use warnings;

our $VERSION;
use base qw( XIMS::Folder );

use XIMS::DataFormat;
use XIMS::RefLibReferenceType;
use XIMS::VLibAuthor;
use XIMS::RefLibSerial;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

##
#
# SYNOPSIS
#    my $reflib = XIMS::ReferenceLibrary->new( %args )
#
# PARAMETER
#    %args: recognized keys are the fields from XIMS::Object::new()
#
# RETURNS
#    $reflib: instance of XIMS::ReferenceLibrary
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::ReferenceLibrary for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'ReferenceLibrary' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    my @reference_types = $reflib->reference_types( [ %args ] )
#
# PARAMETER
#    %args: One of the properties of XIMS::ReflibReferenceType
#
# RETURNS
#    @reference_types: Array of available reference types
#
# DESCRIPTION
#    Fetches available reference types. Reference Types can be filtered by a reference
#    type property. (E.g. name => '%Talk%')
#
sub reference_types {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $cache = 1 unless scalar keys %args > 0;
    if ( defined $cache and defined $self->{'_cachedreft'} ) {
        return @{$self->{'_cachedreft'}};
    }
    my @data = $self->data_provider->getRefLibReferenceType( %args );
    my @out = map { XIMS::RefLibReferenceType->new->data( %{$_} ) } @data;
    $self->{'_cachedreft'} = \@out if defined $cache;
    return @out;
}

##
#
# SYNOPSIS
#    my @reference_properties = $reflib->reference_properties( [ %args ] )
#
# PARAMETER
#    %args: One of the properties of XIMS::ReflibReferenceProperty
#
# RETURNS
#    @reference_properties: Array of available reference properties
#
# DESCRIPTION
#    Fetches available reference properties. Reference Properties can be filtered by a reference
#    property property. (E.g. name => '%conf%')
#
sub reference_properties {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $cache = 1 unless scalar keys %args > 0;
    if ( defined $cache and defined $self->{'_cachedrefp'} ) {
        return @{$self->{'_cachedrefp'}};
    }
    my @data = $self->data_provider->getRefLibReferenceProperty( %args );
    my @out = map { XIMS::RefLibReferenceProperty->new->data( %{$_} ) } @data;
    $self->{'_cachedrefp'} = \@out if defined $cache;
    return @out;
}

##
#
# SYNOPSIS
#    my @vlauthors = $reflib->vlauthors()
#
# PARAMETER
#    none
#
# RETURNS
#    @vlauthors: Array of VLAuthors mapped to the Reference Library
#
# DESCRIPTION
#    Fetches VLAuthors mapped to the Reference Library
#
sub vlauthors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = 'Author';

    my $sql = 'select DISTINCT m.'.$type.'_id AS ID from cireflib_'.$type.'map m, ci_documents d, cireflib_references r where d.id = r.document_id and r.id = m.reference_id and d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );
    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    my $method = "getVLib$type";
    my @data = $self->data_provider->$method( id => \@ids );
    my $class = "XIMS::VLib$type";
    my @objects = map { $class->new->data( %{$_} ) } @data;

    return @objects;
}

##
#
# SYNOPSIS
#    my @vlserials = $reflib->vlserials()
#
# PARAMETER
#    none
#
# RETURNS
#    @vlserials: Array of RefLibSerials mapped to the Reference Library
#
# DESCRIPTION
#    Fetches RefLibSerials mapped to the Reference Library
#
sub vlserials {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $type = 'Serial';

    my $sql = 'select DISTINCT r.'.$type.'_id AS ID from ci_documents d, cireflib_references r where d.id = r.document_id and d.parent_id = ?';
    my $iddata = $self->data_provider->driver->dbh->fetch_select( sql => [ $sql, $self->document_id() ] );
    my @ids = map { $_->{id} } @{$iddata};
    return () unless scalar @ids;

    my $method = "getRefLib$type";
    my @data = $self->data_provider->$method( id => \@ids );
    my $class = "XIMS::RefLib$type";
    my @objects = map { $class->new->data( %{$_} ) } @data;

    return @objects;
}

##
#
# SYNOPSIS
#    my ($item_count, $reflibitems) = $reflib->items_granted( [ %args ] )
#
# PARAMETER
#    $args{ User }              (optional) :  XIMS::User instance
#
#    $args{ limit }             (optional) :  Limit size of $reflibitems arrayref
#                                             Usually used together with 'offset' for pagination
#    $args{ offset }            (optional) :  Offset of returned items relative to total items
#                                             Usually used together with 'limit' for pagination
#    $args{ order }             (optional) :  Sort by object property
#
#    $args{ date }              (optional) :  Filter items by date ReflibReferenceProperty
#    $args{ author_id }         (optional) :  Filter items by VLAuthor id
#    $args{ author_lname }      (optional) :  Filter items by VLAuthor lastname
#    $args{ serial_id }         (optional) :  Filter items by ReflibSerial id
#    $args{ reference_type_id } (optional) :  Filter items by reference_type_id
#    $args{ workgroup_id }      (optional) :  Filter items by workgroup_id
#
# RETURNS
#    $item_count:  Count of total items
#    $reflibitems: Arrayref of ReferenceLibraryItems part of the Reference Library,
#                  slice selected by $args{limit} and $args{offset}
#
# DESCRIPTION
#    Fetches ReferenceLibraryItems part of the Reference Library granted to $args{User} or $reflib->User resp.
#    Returned ReferenceLibraryItems will include 'authorgroup' and 'editorgroup' keys containing arrayrefs of
#    authors and editors assigned to the ReferenceLibraryItem as well as a 'user_privileges' key containing
#    the active user object privileges
#
sub items_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $user = delete $args{User} || $self->{User};
    my $date = delete $args{date};
    my $author_id = delete $args{author_id};
    my $author_lname = delete $args{author_lname};
    my $serial_id = delete $args{serial_id};
    my $reference_type_id = delete $args{reference_type_id};
    my $workgroup_id = delete $args{workgroup_id};
    my $criteria = delete $args{criteria};

    my $child_count;
    my @children;
    my %privmask;
    my $userid = $user->id();
    my $properties = 'distinct c.id, r.id AS reference_id, r.serial_id, r.reference_type_id, d.document_status, d.position, d.parent_id, object_type_id, creation_timestamp, symname_to_doc_id, last_modified_by_middlename, last_modified_by_firstname, language_id, last_publication_timestamp, last_published_by_lastname, css_id, created_by_firstname, data_format_id, keywords, last_modification_timestamp, last_modified_by_id, c.title, c.document_id, location, created_by_lastname, attributes, last_modified_by_lastname, image_id, created_by_id, owned_by_firstname, marked_deleted, last_published_by_id, notes, style_id, owned_by_lastname, owned_by_middlename, abstract, published, locked_by_lastname, locked_by_id, last_published_by_firstname, script_id, owned_by_id, created_by_middlename, data_format_name, locked_by_middlename, last_published_by_middlename, marked_new, locked_time, department_id, locked_by_firstname ';
    my $tables = 'ci_content c, ci_documents d, cireflib_references r';
    my $conditions = 'c.document_id = d.id AND r.document_id = d.id AND d.parent_id = ?';
    my @values = ( $self->document_id() );
    if ( not $user->admin() ) {
        my @userids = ( $userid, $user->role_ids());
        $tables .= ', ci_object_privs_granted p';
        $conditions .= ' AND p.content_id = c.id AND p.privilege_mask >= 1 AND p.grantee_id IN (' . join(',', map { '?' } @userids) . ')';
        push @values, @userids;
    }

    if ( defined $criteria ) {
        $tables .= ', cireflib_authormap am';
        $conditions .= " AND am.reference_id = r.id AND $criteria";
    }
    else {
        if ( defined $reference_type_id ) {
            $conditions .= " AND r.reference_type_id = ?";
            push @values, $reference_type_id;
        }
        if ( defined $date ) {
            $tables .= ', cireflib_ref_propertyvalues pv';
            $conditions .= " AND pv.reference_id = r.id AND pv.property_id = (SELECT id FROM cireflib_reference_properties WHERE name = 'date') AND pv.value LIKE ?";
            push @values, $date;
        }
        if ( defined $workgroup_id ) {
            unless ( defined $date ) {
                $tables .= ', cireflib_ref_propertyvalues pv';
                $conditions .= ' AND pv.reference_id = r.id ';
            }
            $conditions .= " AND pv.property_id = (SELECT id FROM cireflib_reference_properties WHERE name = 'workgroup') AND pv.value LIKE ?";
            push @values, $workgroup_id;
        }
        if ( defined $author_id ) {
            $tables .= ', cireflib_authormap am';
            $conditions .= " AND am.reference_id = r.id AND am.author_id = ?";
            push @values, $author_id;
        }
        elsif ( defined $author_lname ) {
            $tables .= ', cireflib_authormap am';
            $conditions .= " AND am.reference_id = r.id AND am.author_id in (SELECT id FROM cilib_authors WHERE lower(lastname) LIKE ?)";
            push @values, lc $author_lname;
        }
        if ( defined $serial_id ) {
            $conditions .= " AND r.serial_id = ?";
            push @values, $serial_id;
        }
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
            push( @children, (bless $kiddo, 'XIMS::ReferenceLibraryItem') );
            push( @childids, $kiddo->{id} );
            $privmask{$kiddo->{id}} = 0xffffffff if $user->admin();

            my $audata = $self->data_provider->driver->dbh->fetch_select( table => [ qw( cireflib_authormap cilib_authors ) ],
                                                                          criteria => { 'cilib_authors.id'  => \'cireflib_authormap.author_id',
                                                                                        'cireflib_authormap.reference_id' => $kiddo->{reference_id}
                                                                                       } );
            my @authors;
            my @editors;
            foreach my $author ( @{$audata} ) {
                if ( $author->{role} eq '0' ) {
                    push( @authors, $author );
                }
                else {
                    push( @editors, $author );
                }
            }
            $kiddo->{authorgroup} = { author => \@authors };
            $kiddo->{editorgroup} = { author => \@editors };

            my @propdata = $self->data_provider->getRefLibReferencePropertyValue( reference_id => $kiddo->{reference_id},
                                                                                  properties => [ qw( property_id value ) ] );
            my @propout = map { XIMS::RefLibReferencePropertyValue->new->data( %{$_} ) } @propdata;
            $kiddo->{reference_values} = { reference_value => \@propout };
        }

        if ( not $user->admin() ) {
            my @uid_list = ($userid, $user->role_ids());
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
