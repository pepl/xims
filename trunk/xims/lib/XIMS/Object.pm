# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Object;

use strict;
use warnings;
no warnings 'redefine';

our $VERSION;
our @Fields;
our @Default_Properties;
our @Reference_Id_Names;
our @Reference_DocId_Names;

$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

@Reference_DocId_Names = qw( symname_to_doc_id );
@Reference_Id_Names = qw( style_id script_id css_id image_id schema_id);

use base qw( XIMS::AbstractClass );
use XIMS;
use XIMS::ObjectType;
use XIMS::DataFormat;
use XIMS::User;
use XIMS::SiteRoot;
use XIMS::Importer::Object;
use XIMS::Iterator::Object;
use XIMS::Text;
use Text::Diff;
use XML::LibXML; # for balanced_string(), balance_string()
use IO::File; # for balanced_string()

#use Data::Dumper;

sub resource_type {
    return 'Object';
}

sub fields {
    return @Fields;
}

BEGIN {
    # the binfile field is no longer available via the method interface, but is set
    # internally in the object's HASH to allow binary object types to alias body() to the binfile
    # field. This avoids madness during data serialization.

    @Fields = grep { $_ ne 'binfile' } @{XIMS::Names::property_interface_names( resource_type() )};
    @Default_Properties = grep { $_ ne 'body' } @Fields;
}

use Class::MethodMaker
        get_set       => \@Fields;

##
#
# GENERAL
#    Class::Methodmaker provides get/set accessor methods for all the content object properties specified in XIMS::Names.
#    For example uses of the XIMS::Object API see code in the unit tests t/unit??_object_*.t
#

##
#
# SYNOPSIS
#    my $object = XIMS::Object->new( [ %args ] );
#
# PARAMETER
#    $args{ User }                  (optional) :  XIMS::User instance
#    $args{ path }                  (optional) :  Location path to a XIMS Object, For example: '/xims'
#    $args{ $object_property_name } (optional) :  Object property like 'id', 'document_id', or 'title'.
#                                                 To fetch existing objects either 'path', 'id' or 'document_id' has to be specified.
#                                                 Multiple object properties can be specified in the %args hash.
#                                                 For example: XIMS::Object->new( id => $id )
#
# RETURNS
#    $object    : Instance of XIMS::Object
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::Object for object creation.
#    For fetching
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;
    $self->{User} = delete $args{User} if defined $args{User};
    my $real_object;
    if ( defined( $args{path} )) {
        XIMS::Debug( 5, "fetching object id from path $args{path}." );

        # this is bad... fix me later
        my $document_id = $self->data_provider->get_object_id_by_path( path => $args{path} );
        if ( defined $document_id ) {
            $args{document_id} = $document_id;
        }
        else {
            return undef;
        }
    }

    # check to see if we are using the constructor
    # to fetch an *existing* object by passing in it's ID
    if ( defined($args{id}) or defined($args{document_id}) ) {
        XIMS::Debug( 6, "fetching object by id: $args{id}." ) if defined($args{id});
        XIMS::Debug( 6, "fetching object by document_id: $args{document_id}." ) if defined($args{document_id});
        my $properties = delete $args{properties};
        unless ( $properties and ref $properties and scalar @{$properties} ) {
            $properties = \@Default_Properties;
        }
        my @data = $self->data_provider->getObject( %args, properties => $properties );
        return undef unless scalar @data;
        $real_object = $data[0];
        if ( defined( $real_object ) ) {
            delete $real_object->{'document.id'};
            $self->data( %{$real_object} );
        }
        else {
            return undef;
        }
    }
    # otherwise just use the args to load the unserialized (new) object.
    else {
        if ( $class ne 'XIMS::Object' ) {
            my $otname = $class;
            $otname =~ s/XIMS:://;
            if ( not $args{object_type_id} ) {
                my $ot = XIMS::ObjectType->new( fullname => $otname );
                if ( defined $ot ) {
                    $self->object_type_id( $ot->id() );
                }
                else {
                    XIMS::Debug( 1, "could not resolve object type $otname" );
                    return undef;
                }
            }
            if ( not $args{data_format_id} ) {
                my $df = XIMS::DataFormat->new( name => $otname );
                if ( $df ) {
                    $self->data_format_id( $df->id() );
                }
                else {
                    XIMS::Debug( 4, "using 'Binary' as data format fallback" );
                    $self->data_format_id( XIMS::DataFormat->new( name => 'Binary' )->id() );
                }
            }
        }
        if ( scalar( keys( %args ) ) > 0 ) {
            foreach my $field ( keys ( %args ) ) {
                $field = 'body' if $field eq 'binfile';
                $self->$field( $args{$field} ) if $self->can( $field );
            }
        }
    }

    return $self;
}



##
#
# SYNOPSIS
#    my $body = $object->body();
#    my $boolean = $object->body( $body );
#
# PARAMETER
#    $body                  (optional) :  Body string to save
#
# RETURNS
#    $body    : Body string from object
#    $boolean : True or False for storing back body to object
#
# DESCRIPTION
#    Specific override for body() to the default get/set accessor methods provided by Class::MethodMaker to
#    avoid the memory/performance hit of loading the content body in cases where it is not explictly asked for.
#
sub body {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $data = shift;
    my $content_field = $self->content_field(); # will be 'body' or 'binfile' for most objects

    if ( defined( $data ) ) {
        # since department root's portlet info is stored in the body. we have to allow setting the body for
        # containers, or create a separate dataformat for department roots...
        #unless( defined( $content_field ) ) {
        #    XIMS::Debug( 3, "Attempt to set body on Container object. This action is not allowed." );
        #    return undef;
        #}

        $self->{$content_field} = $data;
    }
    else {
        return unless defined( $content_field );
        return $self->{$content_field} if defined( $self->{$content_field} );
        return undef unless defined $self->id();
        my @selected_data = $self->data_provider->getObject( id => $self->id(), properties => [$content_field] );
        my $actual_data = ( values( %{$selected_data[0]} ) )[0];
        $self->{$content_field} = $actual_data;
        return $actual_data;
    }
}

##
#
# SYNOPSIS
#    my $size = $object->content_length();
#
# PARAMETER
#    none
#
# RETURNS
#    $size    : Content size of the object's body in kilobytes
#
# DESCRIPTION
#
#
sub content_length {
    my $self = shift;
    return $self->data_provider->content_length( id => $self->id() );
}

##################################################################
# Object selection methods based on axis relationships to the current
# object (parent, children, descendants, etc.)
##################################################################

##
#
# SYNOPSIS
#    my $parent = $object->parent();
#
# PARAMETER
#    none
#
# RETURNS
#    $parent    : XIMS::Object instance of the parent object in the content hierarchy
#
# DESCRIPTION
#
#
sub parent {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return undef unless $self->parent_id;
    return XIMS::Object->new( User => $self->User, document_id => $self->parent_id );
}

##
#
# SYNOPSIS
#    my @children = $object->children( [ %args ] );
#    my $iterator = $object->children( [ %args ] );
#
# PARAMETER
#    $args{ $object_property } (optional) :  Object property like 'location', 'department_id', or 'title'
#                                            Multiple object properties can be specified in the %args hash. For example,
#                                            $object->children( title => 'Welcome' )
#
# RETURNS
#    @objects    : Array of XIMS::Objects (list context)
#    $iterator   : Instance of XIMS::Iterator::Object created with the children ids (scalar context)
#
# DESCRIPTION
#    Returns all children of an object unless they are filtered by a specific object property.
#    In list context an array is returned, in scalar context an iterator.
#
sub children {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $properties = delete $args{properties};
    unless ( $properties and ref $properties and scalar @{$properties} ) {
        $properties = \@Default_Properties;
    }

    my @child_ids = $self->__child_ids( %args );
    return () unless scalar( @child_ids ) > 0 ;
    return XIMS::Iterator::Object->new( \@child_ids ) unless wantarray;

    my @children_data = $self->data_provider->getObject( document_id => \@child_ids, %args, properties => $properties );
    my @children = map { XIMS::Object->new->data( %{$_} ) } @children_data;
    #warn "children" . Dumper( \@children ) . "\n";
    return @children;
}

##
#
# SYNOPSIS
#    my @children = $object->children_granted( [ %args ] );
#    my $iterator = $object->children_granted( [ %args ] );
#
# PARAMETER
#    $args{ User }             (optional) :  XIMS::User instance if you want to override the user already stored in $object
#                                            or if there is no $object->User yet.
#    $args{ $object_property } (optional) :  Object property like 'location', 'department_id', or 'title'
#                                            Multiple object properties can be specified in the %args hash. For example,
#                                            $object->children_granted( title => 'Welcome' )
#
# RETURNS
#    @objects    : Array of XIMS::Objects (list context)
#    $iterator   : Instance of XIMS::Iterator::Object created with the granted children ids (scalar context)
#
# DESCRIPTION
#    Returns children granted to $args{User}. If that is not given, $object->User() will be used.
#    Children can be filtered using object property values. In list context an array is returned,
#    in scalar context an iterator.
#
sub children_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->children( %args ) if $user->admin();

    my $properties = delete $args{properties}; # save them back for the call to __get_granted_objects

    # the following is a potential performance killer, we should spare some steps here...
    # do a join in __child_ids?
    # it does not have to be the Do-it-all-in-one-query-with-Oracle way ;-)
    # SELECT d.id,c.id,location,title,object_type_id,data_format_id,privilege_mask,depth FROM ci_content c,(SELECT ci_documents.*, level depth FROM ci_documents START WITH id IN ( SELECT document_id FROM ci_content WHERE id = ?) CONNECT BY PRIOR id = parent_id AND level <= ? AND id != parent_id ORDER BY level) d,ci_object_privs_granted p,(SELECT id, level FROM ci_roles_granted START WITH grantee_id = ? CONNECT BY PRIOR id = grantee_id ORDER BY level) r WHERE c.document_id = d.id AND depth > 1 AND p.content_id = c.id AND p.content_id = c.id AND (p.grantee_id = ? OR p.grantee_id = r.id ) AND p.privilege_mask >= 1 AND (SELECT privilege_mask FROM ci_object_privs_granted WHERE content_id = c.id AND grantee_id = ? AND privilege_mask = 0) IS NULL AND marked_deleted IS NULL ORDER BY d.position
    my @child_candidate_docids = $self->__child_ids( %args );
    return () unless scalar( @child_candidate_docids ) > 0;
    if ( not wantarray ) {
        my @ids = $self->__get_granted_ids( doc_ids => \@child_candidate_docids, User => $user, %args );
        return XIMS::Iterator::Object->new( \@ids, 1 );
    }

    $args{properties} = $properties; # pass the properties
    my @children = $self->__get_granted_objects( doc_ids => \@child_candidate_docids, User => $user, %args ) ;

    #warn "Granted children" . Dumper( \@children ) . "\n";
    return @children;
}

##
#
# SYNOPSIS
#    my $count = $object->child_count( [ %args ] );
#
# PARAMETER
#    $args{ $object_property } (optional) :  Object property like 'location', 'department_id', or 'title'
#                                            Multiple object properties can be specified in the %args hash. For example,
#                                            $object->child_count( marked_deleted => undef )
#
# RETURNS
#    $count    : Number of children of the object
#
# DESCRIPTION
#
#
sub child_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @child_ids = $self->__child_ids( @_ );
    return scalar ( @child_ids );
}


##
#
# SYNOPSIS
#    my $count = $object->child_count_granted( %args );
#
# PARAMETER
#    %args     : Same as for descendants_granted()
#
# RETURNS
#    $count    : Number of granted children in the content hierarchy
#
# DESCRIPTION
#
#    Returns number of children granted to $args{User}. If that is not given, $object->User() will be used.
#
sub child_count_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $iterator = $self->children_granted( @_ );
    return undef unless defined $iterator;
    return $iterator->getLength();
}


##
#
# SYNOPSIS
#    my $ancestors = $object->ancestors();
#
# PARAMETER
#    none
#
# RETURNS
#    $ancestors : Reference to Array of XIMS::Objects
#
# DESCRIPTION
#    Returns all ancestors.
#
sub ancestors {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    if ( defined $self->{Ancestors} and $self->{_cached_parent_id} == $self->{parent_id} ) {
        my @ancs = @{$self->{Ancestors}};
        return \@ancs;
    }
    my @ancestors = $self->data_provider->recurse_ancestor( $self );
    #warn "parents " . Dumper( \@ancestors ) . "\n";

    # cache ancestors
    $self->{Ancestors} = \@ancestors;
    $self->{_cached_parent_id} = $self->{parent_id};

    my @ancs = @ancestors;
    return \@ancs;
}

##
#
# SYNOPSIS
#    my $or_ancestors = $object->objectroot_ancestors();
#
# PARAMETER
#    none
#
# RETURNS
#    $or_ancestors : Reference to Array of XIMS::Objects
#
# DESCRIPTION
#    Returns all ObjectRoot ancestors from which ObjectRoot-wide
#    settings may be inherited
#
sub objectroot_ancestors {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    if ( defined $self->{ORootAncestors} and $self->{_cached_parent_id} == $self->{parent_id} ) {
        return $self->{ORootAncestors};
    }
    my @or_ancestors = $self->data_provider->recurse_ancestor( $self, 1 );
    #warn "parents " . Dumper( \@ancestors ) . "\n";

    # cache ancestors
    $self->{ORootAncestors} = \@or_ancestors;
    $self->{_cached_parent_id} = $self->{parent_id};

    return $self->{ORootAncestors};
}

##
#
# SYNOPSIS
#    my @descendants = $object->descendants( [ %args ] );
#    my $iterator    = $object->descendants( [ %args ] );
#
# PARAMETER
#    $args{ $object_property } (optional) :  Object property like 'location', 'department_id', or 'title'
#                                            Multiple object properties can be specified in the %args hash. For example,
#                                            $object->descendants( department_id => $document_id, location => 'index.html' )
#    $args{ maxlevel }         (optional) :  Maxlevel of recursion, if unspecified or 0 results in no recursion limit
#
# RETURNS
#    @descendants : Array of XIMS::Objects including "level" pseudo-property (list context)
#    $iterator    : Instance of XIMS::Iterator::Object created with the descendants ids (scalar context)
#
# DESCRIPTION
#    Returns all descendants unless they are filtered by a specific object property.
#    In list context an array of the objects including a "level" pseudo-property is returned,
#    in scalar context an iterator is returned. The objects fetched using this iterator will NOT contain that pseudo-property!
#
sub descendants {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $properties = delete $args{properties};
    unless ( $properties and ref $properties and scalar @{$properties} ) {
        $properties = \@Default_Properties;
    }

    delete $args{parent_id};
    my $descendant_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id(), %args );

    my @doc_ids  = @{$descendant_ids_lvls->[0]};
    return () unless scalar( @doc_ids ) > 0;
    return XIMS::Iterator::Object->new( \@doc_ids ) unless wantarray;

    my @lvls = @{$descendant_ids_lvls->[1]};

    my @descendants_data =  $self->data_provider->getObject( document_id => \@doc_ids,
                                                             %args,
                                                             properties => $properties,
                                                            );

    my @descendants = map { XIMS::Object->new->data( %{$_} ) } @descendants_data;

    # getObject() returns the objects in the default sorting order, so we have to remap levels and resort descendants :-/...
    my @sorted_descendants;
    my ($i, $j);
    for ( $i=0; $i < @doc_ids; $i++ ) {
        for ( $j=0; $j < @descendants; $j++ ) {
            if ( $doc_ids[$i] == $descendants[$j]->document_id() ) {
                $descendants[$j]->{level} = $lvls[$i];
                push( @sorted_descendants, $descendants[$j] );
                splice( @descendants,$j,1 );
                last;
            }
        }
    }

    #warn "descendants" . Dumper( \@sorted_descendants ) . "\n";
    return @sorted_descendants;
}

##
#
# SYNOPSIS
#    my @descendants = $object->descendants_granted( [ %args ] );
#    my @iterator = $object->descendants_granted( [ %args ] );
#
# PARAMETER
#    $args{ User }             (optional) :  XIMS::User instance if you want to override the user already stored in $object
#                                            or if there is no $object->User yet.
#    $args{ $object_property } (optional) :  Object property like 'location', 'department_id', or 'title'
#                                            Multiple object properties can be specified in the %args hash. For example,
#                                            $object->descendants_granted( department_id => $document_id, location => 'index.html' )
#    $args{ maxlevel }         (optional) :  Maxlevel of recursion, if unspecified or 0 results in no recursion limit
#
# RETURNS
#    @descendants : Array of XIMS::Objects including "level" pseudo-property (list context)
#    $iterator    : Instance of XIMS::Iterator::Object created with the granted descendants ids (scalar context)
#
# DESCRIPTION
#    Returns descendants granted to $args{User}. If that is not given, $object->User() will be used.
#    Descendants can be filtered using object property values. In list context an array of the objects
#    including a "level" pseudo-property is returned, in scalar context an iterator is returned.
#    The objects fetched using this iterator will NOT contain that pseudo-property!
#
sub descendants_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->descendants( %args ) if $user->admin();

    my $properties = delete $args{properties}; # save them back for the call to __get_granted_objects

    delete $args{parent_id};
    my $descendant_candidate_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id(), %args );

    my @candidate_doc_ids  = @{$descendant_candidate_ids_lvls->[0]};
    my @candidate_lvls = @{$descendant_candidate_ids_lvls->[1]};

    return () unless scalar( @candidate_doc_ids ) > 0;
    if ( not wantarray ) {
        my @ids = $self->__get_granted_ids( doc_ids => \@candidate_doc_ids, User => $user, %args );
        return XIMS::Iterator::Object->new( \@ids, 1 );
    }

    $args{properties} = $properties; # pass the properties
    my @descendants = $self->__get_granted_objects( doc_ids => \@candidate_doc_ids, User => $user, %args );
    return () unless scalar( @descendants ) > 0;

    # getObject() returns the objects in the default sorting order, so we have to remap levels and resort descendants :-/...
    my @sorted_descendants;
    my ($i, $j);
    for ( $i=0; $i < @candidate_doc_ids; $i++ ) {
        for ( $j=0; $j < @descendants; $j++ ) {
            if ( $candidate_doc_ids[$i] == $descendants[$j]->document_id() ) {
                $descendants[$j]->{level} = $candidate_lvls[$i];
                push( @sorted_descendants, $descendants[$j] );
                splice( @descendants,$j,1 );
                last;
            }
        }
    }

    #warn "descendants" . Dumper( \@sorted_descendants ) . "\n";
    return @sorted_descendants;
}

##
#
# SYNOPSIS
#    my ($total_descendants, $levels) = $object->descendant_count();
#
# PARAMETER
#    none
#
# RETURNS
#    ($total_descendants, $levels)    : $total_descendants contains the descendant count,
#                                       $levels contains the number of levels in the hierarchy the
#                                       descendants are spread over.
#
# DESCRIPTION
#
#
sub descendant_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $descendant_count = 0;
    my $descendant_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id() );

    my @doc_ids  = @{$descendant_ids_lvls->[0]};
    return ( 0,0 ) unless scalar( @doc_ids ) > 0;

    my @lvls = @{$descendant_ids_lvls->[1]};

    # sort to find floor and ceiling values
    @lvls = sort { $a <=> $b } @lvls;

    return ( scalar( @doc_ids ), $lvls[-1] - $lvls[0] + 1 );
}


##
#
# SYNOPSIS
#    my $count = $object->descendant_count_granted( %args );
#
# PARAMETER
#    %args     : Same as for descendants_granted()
#
# RETURNS
#    $count    : Number of granted descendants in the content hierarchy
#
# DESCRIPTION
#
#    Returns number of descendants granted to $args{User}. If that is not given, $object->User() will be used.
#
sub descendant_count_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $iterator = $self->descendants_granted( @_ );
    return undef unless defined $iterator;
    return $iterator->getLength();
}


##
#
# SYNOPSIS
#    my @objects = $object->find_objects( %args );
#    my $iterator = $object->find_objects( %args );
#
# PARAMETER
#    refactor!
#    $args{ criteria }   :
#    $args{ limit }      :
#    $args{ offset }     :
#    $args{ order }      :
#    $args{ start_here } : location_path string or XIMS Object instance from where to start searching from
#
# RETURNS
#    @objects     : Array of XIMS::Objects (list context)
#    $iterator    : Instance of XIMS::Iterator::Object created with the found ids (scalar context)
#
# DESCRIPTION
#    Returns .
#
sub find_objects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $properties = delete $args{properties};
    unless ( $properties and ref $properties and scalar @{$properties} ) {
        $properties = \@Default_Properties;
    }

    my @found_ids = $self->__find_ids( %args );
    return () unless scalar( @found_ids ) > 0 ;
    return XIMS::Iterator::Object->new( \@found_ids, 1 ) unless wantarray;

    my @object_data = $self->data_provider->getObject( id => \@found_ids, properties => $properties );
    my @objects = map { XIMS::Object->new->data( %{$_} ) } @object_data;

    #warn "objects found" . Dumper( \@objects ) . "\n";
    return @objects;
}

##
#
# SYNOPSIS
#    my $count = $object->find_objects_count( %args );
#
# PARAMETER
#    none
#
# RETURNS
#    $count    : Number of found objects
#
# DESCRIPTION
#
#
sub find_objects_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    delete $args{limit} if exists $args{limit}; # we have to get the ids of *all* matching objects
    return $self->__find_ids_count( %args );
}

##
#
# SYNOPSIS
#    my @objects = $object->find_objects_granted( %args );
#    my $iterator = $object->find_objects_granted( %args );
#
# PARAMETER
#    refactor!
#    $args{ criteria }   :
#    $args{ limit }      :
#    $args{ offset }     :
#    $args{ order }      :
#    $args{ start_here } : location_path string or XIMS Object instance from where to start searching from
#
# RETURNS
#    @objects     : Array of XIMS::Objects (list context)
#    $iterator    : Instance of XIMS::Iterator::Object created with the granted found ids (scalar context)
#
# DESCRIPTION
#    Returns .
#
sub find_objects_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->find_objects( %args ) if $user->admin();

    my $properties = delete $args{properties};
    unless ( $properties and ref $properties and scalar @{$properties} ) {
        $properties = \@Default_Properties;
    }

    $args{user_id} = $user->id();
    my @role_ids = $user->role_ids();
    $args{role_ids} = \@role_ids;

    my @found_ids = $self->__find_ids( %args );
    return () unless scalar( @found_ids ) > 0 ;
    return XIMS::Iterator::Object->new( \@found_ids, 1 ) unless wantarray;

    my @object_data = $self->data_provider->getObject( id => \@found_ids, properties => $properties );
    my @objects = map { XIMS::Object->new->data( %{$_} ) } @object_data;

    #warn "objects found" . Dumper( \@objects ) . "\n";
    return @objects;
}

##
#
# SYNOPSIS
#    my $count = $object->find_objects_granted_count( %args );
#
# PARAMETER
#    none
#
# RETURNS
#    $count    : Number of found objects
#
# DESCRIPTION
#
#
sub find_objects_granted_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    if ( not $user->admin() ) {
        $args{user_id} = $user->id();
        my @role_ids = $user->role_ids();
        $args{role_ids} = \@role_ids;
    }

    return $self->find_objects_count( %args );
}

##
#
# SYNOPSIS
#    my @referenced_by = $object->referenced_by( [ %args ] );
#    my $iterator      = $object->referenced_by( [ %args ] );
#
# PARAMETER
#    $args{ $object_property } (optional)  :  Object property like 'location', 'department_id', or 'title'
#                                             Multiple object properties can be specified in the %args hash. For example,
#                                             $object->referenced_by( published => 1 )
#    $args{ include_ancestors } (optional) :  If given, not only the objects referenced by symname_to_doc_id of the
#                                             current object, but also the ones of its ancestors will be returned.
#
# RETURNS
#    @objects    : Array of XIMS::Objects (list context)
#    $iterator   : Instance of XIMS::Iterator::Object created with the referenced by object ids (scalar context)
#
# DESCRIPTION
#    Returns all objects referenced by symname_to_doc_id. The current implementation does not check whether a
#    ancestrial Portlet high up in the hierarchy actually really includes the current object; the Portlet's "level"
#    attribute is not checked.
#    In list context an array is returned, in scalar context an iterator.
#
sub referenced_by {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $properties = delete $args{properties};
    if ( wantarray ) {
        unless ( $properties and ref $properties and scalar @{$properties} ) {
            $properties = \@Default_Properties;
        }
    }
    else {
        $properties = [ qw( object_type_id document_id ) ];
    }

    my $include_ancestors = delete $args{include_ancestors};
    if ( defined $include_ancestors ) {
        my @ancestor_docids = map { $_->{document_id} } @{$self->ancestors()};
        $args{symname_to_doc_id} = [ (@ancestor_docids, $self->document_id()) ];
    }
    else {
        $args{symname_to_doc_id} = $self->document_id();
    }

    my @referenced_by_data = $self->data_provider->getObject( %args, properties => $properties );
    return () unless scalar( @referenced_by_data ) > 0;

    if ( wantarray ) {
        my @referenced_by = map { XIMS::Object->new->data( %{$_} ) } @referenced_by_data;
        #warn "referenced_by" . Dumper( \@referenced_by ) . "\n";
        return @referenced_by;
    }
    else {
        my @docids = map { $_->{document_id} } @referenced_by_data;
        return XIMS::Iterator::Object->new( \@docids ) unless wantarray;
    }
}

##
#
# SYNOPSIS
#    my @referenced_by = $object->referenced_by_granted( [ %args ] );
#    my $iterator      = $object->referenced_by_granted( [ %args ] );
#
# PARAMETER
#    $args{ User }             (optional)  :  XIMS::User instance if you want to override the user already stored in $object
#                                             or if there is no $object->User yet.
#    $args{ $object_property } (optional)  :  Object property like 'location', 'department_id', or 'title'
#                                             Multiple object properties can be specified in the %args hash. For example,
#                                             $object->referenced_by_granted( published => 1 )
#    $args{ include_ancestors } (optional) :  If given, not only the objects referenced by symname_to_doc_id of the
#                                             current object, but also the ones of its ancestors will be returned.
#
# RETURNS
#    @objects    : Array of XIMS::Objects (list context)
#    $iterator   : Instance of XIMS::Iterator::Object created with the granted children ids (scalar context)
#
# DESCRIPTION
#    Returns all objects referenced by symname_to_doc_id granted to $args{User}. If that is not given,
#    $object->User() will be used.The current implementation does not check whether a ancestrial Portlet high
#    up in the hierarchy actually really includes the current object; the Portlet's "level" attribute is not checked.
#    In list context an array is returned, in scalar context an iterator.
#
sub referenced_by_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->referenced_by( %args ) if $user->admin();


    my $properties = delete $args{properties};
    unless ( $properties and ref $properties and scalar @{$properties} ) {
        $properties = \@Default_Properties;
    }

    my $include_ancestors = delete $args{include_ancestors};
    if ( defined $include_ancestors ) {
        my @ancestor_docids = map { $_->{document_id} } @{$self->ancestors()};
        $args{symname_to_doc_id} = [ (@ancestor_docids, $self->document_id()) ];
    }
    else {
        $args{symname_to_doc_id} = $self->document_id();
    }

    my @candidate_data = $self->data_provider->getObject( %args, properties => [ qw( object_type_id document_id ) ] );
    my @candidate_docids = map { $_->{'content.document_id'} } @candidate_data;
    return () unless scalar( @candidate_docids ) > 0;

    # not needed anymore
    delete $args{symname_to_doc_id};

    if ( not wantarray ) {
        my @ids = $self->__get_granted_ids( doc_ids => \@candidate_docids, User => $user, %args );
        return XIMS::Iterator::Object->new( \@ids, 1 );
    }

    $args{properties} = $properties; # pass the properties
    return $self->__get_granted_objects( doc_ids => \@candidate_docids, User => $user, %args );
}

# internal helper to filter out granted objects, accepts a hash as parameters, mandatory key: doc_ids => @doc_ids
# shared by children_granted and descendants_granted
# returns a list of XIMS::Objects
sub __get_granted_objects {
    my $self = shift;
    my %args = @_;

    my $properties = delete $args{properties};
    unless ( $properties and ref $properties and scalar @{$properties} ) {
        $properties = \@Default_Properties;
    }

    my @ids = $self->__get_granted_ids( %args );
    return () unless scalar( @ids ) > 0;

    my @data = $self->data_provider->getObject( id  => \@ids,
                                                properties => $properties );

    my @objects = map { XIMS::Object->new->data( %{$_} ) } @data;

    #warn "objects " . Dumper( \@objects ) . "\n";
    return @objects;
}

sub __get_granted_ids {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    my $doc_ids = delete $args{doc_ids};
    return () unless scalar( @{$doc_ids} ) > 0;

    my @candidate_data = $self->data_provider->getObject( document_id => $doc_ids,
                                                          properties => [ 'id' ],
                                                          %args );
    my @candidate_ids = map{ $_->{'content.id'} } @candidate_data;

    my @ids = $self->__filter_granted_ids( User => $user, candidate_ids => \@candidate_ids );
    return () unless scalar( @ids ) > 0;
    return @ids;
}

sub __filter_granted_ids {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    my $candidate_ids = delete $args{candidate_ids};
    my @role_ids = ( $user->role_ids(), $user->id() );

    my @priv_data = $self->data_provider->getObjectPriv( content_id => $candidate_ids,
                                                         grantee_id => \@role_ids,
                                                         properties => [ 'content_id', 'grantee_id', 'privilege_mask' ] );
    return () unless scalar( @priv_data ) > 0;

    my @ids;
    my %seen = ();
    for ( @priv_data ) {
        # check for explicit lockout of a user, where he is denied access to
        # objects where he would have privileges from a role grant but is
        # denied because of a grant with privilege_mask '0'
        if ( not ($_->{'objectpriv.grantee_id'} == $user->id() and not defined $_->{'objectpriv.privilege_mask'}) ) {
            push (@ids, $_->{'objectpriv.content_id'}) unless $seen{$_->{'objectpriv.content_id'}}++;
        }
    };

    return @ids;
}


##
#
# SYNOPSIS
#    my $siteroot = $object->siteroot();
#
# PARAMETER
#    none
#
# RETURNS
#    $siteroot    : XIMS::SiteRoot instance
#
# DESCRIPTION
#
#    Returns the SiteRoot of the object.
#
sub siteroot {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $ancestors_and_self = $self->ancestors();
    push @{$ancestors_and_self}, $self;
    my $siteroot = $ancestors_and_self->[1];
    return unless $siteroot;

    bless $siteroot, 'XIMS::SiteRoot';

    return $siteroot;
}


# internal.
# shared by 'children', 'child_count'
sub __child_ids {
    my $self = shift;
    my %args = @_;
    return $self->data_provider->get_object_id( %args, parent_id => $self->document_id() );
}

sub __find_ids {
    my $self = shift;
    my %args = @_;
    return $self->data_provider->find_object_id( %args );
}

sub __find_ids_count {
    my $self = shift;
    my %args = @_;
    return $self->data_provider->find_object_id_count( %args );
}

# internal, used by clone()
# fixup referenced object ids in all cloned objects that have reference ids
sub __fix_clone_reference {
    my $self = shift;
    my %args = @_;

    my $user = delete $args{User} || $self->{User};
    my $id_map = delete $args{ _id_map };
    my $ref_object_ids = delete $args{ _ref_object_ids };
    my $docid_map = delete $args{ _docid_map };
    my $ref_object_docids = delete $args{ _ref_object_docids };

    #warn("fixing ref ids on objects : " . Dumper( $ref_object_ids ) );
    #warn("fixing ref ids with id map: " . Dumper( $id_map ) );
    #warn("fixing ref docids on objects : " . Dumper( $ref_object_docids ) );
    #warn("fixing ref docids with docid map: " . Dumper( $docid_map ) );

    my $update_flag = 0;

    # check all copied objects that have referenced to other objects
    foreach my $document_id ( @$ref_object_docids ) {
        my $clone = XIMS::Object->new( document_id => $document_id );
        #warn("clone to fix: " . Dumper( $clone ) );
        foreach my $docid_name ( @Reference_DocId_Names ) {
            if ( defined $clone->{ $docid_name } ) {
                my $newid = $docid_map->{ $clone->{ $docid_name } };
                if ( defined $newid ) {
                    # the referenced object has also been copied, so change the reference to the copy
                    $clone->{ $docid_name } = $newid;
                    $update_flag = 1; # update of clone is needed
                }
            }
        }
        $clone->update( User => $user ) if $update_flag;
    }

    $update_flag = 0;
    foreach my $id ( @$ref_object_ids ) {
        my $clone = XIMS::Object->new( id => $id );
        #warn("clone to fix: " . Dumper( $clone ) );
        foreach my $id_name ( @Reference_Id_Names ) {
            if ( defined $clone->{ $id_name } ) {
                my $newid = $id_map->{ $clone->{ $id_name } };
                if ( defined $newid ) {
                    # the referenced object has also been copied, so change the reference to the copy
                    $clone->{ $id_name } = $newid;
                    $update_flag = 1; # update of clone is needed
                }
            }
        }

        # fix body of objectroots (departmentroots and siteroots) because their body may contain portlet ids
        if ( $clone->object_type->is_objectroot() ) {
            #warn("about to fix portlet in " . Dumper( $clone ) );
            my $body = $clone->body();
            if ( defined $body and length $body ) {
                my $parser = XML::LibXML->new();
                my $fragment;
                eval {
                    $fragment = $parser->parse_xml_chunk( $body );
                };
                if ( $@ ) {
                    XIMS::Debug( 2, "problem with the stored portlet data ($@)"  );
                }
                else {
                    my @nodes = $fragment->childNodes;
                    my $node;
                    my $update_body_flag = 0;
                    foreach $node ( @nodes ) {
                        my $newid = $id_map->{ $node->string_value() };
                        if ( defined $newid ) {
                            $node->firstChild->setData( $newid );
                            $update_body_flag = 1;
                        }
                    }
                    if ( $update_body_flag ) {
                        $clone->body( $fragment->toString() );
                        $update_flag = 1; # update of clone is needed
                    }
                }
            }
        }
        $clone->update( User => $user ) if $update_flag;
    }
}

# "static"-method
#
sub __decide_department_id {
    my %args = @_;
    my $object= XIMS::Object->new( document_id => $args{document_id} );
    if ( $object->object_type->is_objectroot() ) {
        return $object->document_id();
    }
    else {
        return $object->department_id();
    }
}

sub User {
    my $self = shift;
    return $self->{User};
}

##################################################################
# Core data methods
##################################################################

##
#
# SYNOPSIS
#    my $id = $object->create( [ %args ] );
#
# PARAMETER
#    $args{ User }    (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user, %args ) )
#
# RETURNS
#    $id    : Content id of newly created object
#
# DESCRIPTION
#    Returns the content id of the newly created object, undef on failure. $args{User}, or, if that is not given, $object->User() will be used to set last modifier, creator, and owner metadata.
#    Before you call $object->create() at least the "parent_id", "language_id", "object_type_id", and "data_format_id" properties have to be set for the object. The latter two properties "object_type_id" and "data_format_id" will be set at object instantiation from a subclass of XIMS::Object, like XIMS::Document for example, and therefore do not have to be set explicitly.
#
# EXAMPLE
#    my $object = XIMS::Document->new( parent_id => XIMS::Object->new( path => '/xims', language_id => $lid )->document_id() );
#    $object->location( 'foodocument.html' );
#    $object->title( 'A document called Foo');
#    my $id = $object->create( User => $user );
#
sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    die "Creating an object requires an associated User" unless defined( $user );

    $self->{User} ||= $user;

    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() ) || 0;
    $self->position( $max_position + 1 );

    $self->department_id( __decide_department_id( document_id => $self->parent_id() ) );

    my $now = $self->data_provider->db_now();

    $self->last_modified_by_id( $user->id() );
    $self->last_modified_by_firstname( $user->firstname() );
    $self->last_modified_by_middlename( $user->middlename() );
    $self->last_modified_by_lastname( $user->lastname() );
    $self->last_modification_timestamp( $now );
    $self->created_by_id( $user->id() );
    $self->created_by_firstname( $user->firstname() );
    $self->created_by_middlename( $user->middlename() );
    $self->created_by_lastname( $user->lastname() );
    $self->creation_timestamp( $now );
    $self->owned_by_id( $user->id() );
    $self->owned_by_firstname( $user->firstname() );
    $self->owned_by_middlename( $user->middlename() );
    $self->owned_by_lastname( $user->lastname() );
    $self->valid_from_timestamp( $now ) unless defined $self->valid_from_timestamp();

    my ($id, $document_id) = $self->data_provider->createObject( $self->data() );
    $self->id( $id );
    $self->document_id( $document_id );
    return $id;
}

##
#
# SYNOPSIS
#    my $boolean = $object->delete( [ %args ] );
#
# PARAMETER
#    $args{ User }    (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#
# RETURNS
#    $boolean : True or False for deleting object
#
# DESCRIPTION
#    Deletes object in database and unsets properties in memory.
#
sub delete {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    die "Deleting an object requires an associated User" unless defined( $user );

    my $retval = $self->data_provider->deleteObject( $self->data() );
    if ( $retval ) {
        # TODO: reposition following siblings here
        # following sql called by a DP method?
        # $self->{Driver}->
        # do_update( table  => 'ci_documents',
        #           columns  => [ 'position' ],
        #           values   => [ "position - 1" ],
        #           criteria => "position > $pos AND parent_id = $parent" );
        map { $self->$_( undef ) } $self->fields();
        return 1;
    }
    else {
       return undef;
    }
}

##
#
# SYNOPSIS
#    my @rowcount = $object->update( [ %args ] );
#
# PARAMETER
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#    $args{ no_modder }   (optional) :  If set, last modifier and last modification timestamp properties will not be set.
#
# RETURNS
#    @rowcount : Array with one or two entries. Two if both 'Content' and 'Document' have been updated, one if only 'Document' resource type has been updated. Each entry is true if update was successful, false otherwise.
#
# DESCRIPTION
#    Updates object in database and sets last modifier properties unless $args{no_modder} has been set.
#
sub update {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    die "Updating an object requires an associated User" unless defined( $user );

    unless ( exists $args{no_modder} ) {
        $self->last_modified_by_id( $user->id() );
        $self->last_modified_by_firstname( $user->firstname() );
        $self->last_modified_by_middlename( $user->middlename() );
        $self->last_modified_by_lastname( $user->lastname() );
        $self->last_modification_timestamp( $self->data_provider->db_now() );
    }

    # Update in db
    my @rowcount = $self->data_provider->updateObject( $self->data() );

    # Invalidate cached location_path
    $self->{location_path} = undef;

    return @rowcount;
}

##
#
# SYNOPSIS
#    my @rowcount = $object->trashcan( [ %args ] );
#
# PARAMETER
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#
# RETURNS
#    @rowcount : Array with one or two entries. Two if both 'Content' and 'Document' have been updated, one if only 'Document' resource type has been updated. Each entry is true if update was successful, false otherwise.
#
# DESCRIPTION
#    Moves object including descendants to the trashcan, updates object in database.
#
sub trashcan {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    my @retval;
    $self->marked_deleted( 1 );

    if ( $self->data_provider->close_position_gap( parent_id => $self->parent_id(), position => $self->position() ) ) {
        $self->position( undef );
        @retval = $self->data_provider->updateObject( $self->data() );
    }
    else {
        XIMS::Debug( 2, "Could not close position gap" );
        return undef;
    }

    # 2 tables should have been updated
    if ( scalar @retval == 2 and defined $retval[1]  ) {
        # Set marked_deleted to '1' for all descendants
        my $descendant_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id() );
        my @doc_ids  = @{$descendant_ids_lvls->[0]};
        if ( scalar( @doc_ids ) > 0 ) {
            @retval = $self->data_provider->driver->update( properties => { 'content.marked_deleted' => 1 }, conditions => { 'content.document_id' => \@doc_ids } );
            # 1 table should have been updated
            if ( scalar @retval == 1 and defined $retval[0] ) {
                @retval = (1, $retval[0]); # Set number of updated ci_content rows for @retval
            }
        }
        else {
            @retval = (1, 1);
        }
    }

    return @retval;
}

##
#
# SYNOPSIS
#    my @rowcount = $object->undelete( [ %args ] );
#
# PARAMETER
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#
# RETURNS
#    @rowcount : Array with one or two entries. Two if both 'Content' and 'Document' have been updated, one if only 'Document' resource type has been updated. Each entry is true if update was successful, false otherwise.
#
# DESCRIPTION
#    Moves object including descendants out of the trashcan, updates object in database.
#
sub undelete {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    my @retval;
    $self->marked_deleted( undef );

    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() );
    $max_position ||= 0;
    $self->position( $max_position + 1 );
    @retval = $self->data_provider->updateObject( $self->data() );

    # 2 tables should have been updated
    if ( scalar @retval == 2 and defined $retval[1]  ) {
        # Set marked_deleted to 'undef' for all descendants
        my $descendant_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id() );
        my @doc_ids  = @{$descendant_ids_lvls->[0]};
        if ( scalar( @doc_ids ) > 0 ) {
            @retval = $self->data_provider->driver->update( properties => { 'content.marked_deleted' => undef }, conditions => { 'content.document_id' => \@doc_ids } );
            # 1 table should have been updated
            if ( scalar @retval == 1 and defined $retval[0] ) {
                @retval = (1, $retval[0]); # Set number of updated ci_content rows for @retval
            }
        }
        else {
            @retval = (1, 1);
        }
    }
}

##
#
# SYNOPSIS
#    my @rowcount = $object->move( [ %args ] );
#
# PARAMETER
#    $args{ target }                 :  document_id of the target container
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#
# RETURNS
#    @rowcount : Array with one or two entries. Two if both 'Content' and 'Document' have been updated, one if only 'Document' resource type has been updated. Each entry is true if update was successful, false otherwise.
#
# DESCRIPTION
#    Moves object in the content hierarchy, sets "parent_id" to the "target"'s document_id. Updates object in database.
#
sub move {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    # the old department this object's direct descendants belong to
    # this is either the department_id or major_id, depending on
    # whether this is a [Department|Site]Root.
    my $old_dept = __decide_department_id( document_id => $self->document_id() );

    my $parent_id = delete $args{target};
    return undef unless $parent_id;

    if ( not $self->data_provider->close_position_gap( parent_id => $self->parent_id(), position => $self->position() ) ) {
        XIMS::Debug( 2, "Could not close position gap" );
        return undef;
    }

    $self->parent_id( $parent_id );

    $self->department_id( __decide_department_id( document_id => $self->parent_id() ) );

    my @o =  $self->descendants();
    foreach( @o ) {
        # only look at objects with the old_dept of the moved object.
        # descendants of a different dept. stay unchanged. (see comment above)
        if ($_->department_id == $old_dept) {
            $_->department_id( $self->department_id() );
            $_->data_provider->updateObject( $_->data() );
        }
    }

    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() ) || 0;
    $self->position( $max_position + 1 );
    return $self->data_provider->updateObject( $self->data() );
}

##
#
# SYNOPSIS
#    my $clone = $object->clone( %args );
#
# PARAMETER
#    $args{ User }            (optional) : XIMS::User instance. Used to find granted children. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#    $args{ target_id }       (optional) : document_id of parent if it should not be $self->parent_id
#    $args{ target_location } (optional) : location of clone object; per default "copy_of_location" will be used
#    $args{ scope_subtree }   (optional) : flag, 0 ... shallow copy ( only object, not its descendants ), 1 ... full subtree copy ( object and all granted descendants )
#    $args{ _parent_id }      (private)  : document_id of parent object ( should be undef, only used in recursive call )
#    $args{ _id_map }         (private)  : hash ref with key=old object id, value=new object id ( should be undef, only used in recursive call )
#    $args{ _ref_object_ids } (private)  : array ref with all cloned objects that have references to other objects ( should be undef, only used in recursive call )
#
# RETURNS
#    undef on error, reference to cloned object on success
#
# DESCRIPTION
#    creates a copy of the object in the database ( clone has same parent as orginal ).
#    the clone is named 'copy_of_...' (location and title)
#    the clone is always unpublished and unlocked
#    references to other copied objects are updated, as are references to portlets in body of department- and siteroot
#    if scope_subtree = 1, all granted descendants are copied, too.
#
sub clone {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $user = delete $args{User} || $self->{User};
    die "cloning an object requires an associated User" unless defined( $user );

    my $scope_subtree = delete $args{ scope_subtree };

    my $target_location = delete $args{ target_location };
    my $dontcleanlocation = delete $args{ dontcleanlocation };
    my $target_id = delete $args{ target_id };
    my $parent_id = delete $args{ _parent_id };
    my $id_map = delete $args{ _id_map } || {};
    my $ref_object_ids = delete $args{ _ref_object_ids } || [];
    my $docid_map = delete $args{ _docid_map } || {};
    my $ref_object_docids = delete $args{ _ref_object_docids } || [];

    # create a copy of object data
    my %clonedata = $self->data();

    # id and document_id will be created new, path is not used
    delete $clonedata{ id };
    delete $clonedata{ document_id };
    delete $clonedata{ path };

    if ( defined $parent_id or defined $target_id ) {
        if ( defined $parent_id ) {
            $clonedata{ parent_id } = $parent_id;
        }
        elsif ( defined $target_id ) {
            $clonedata{ parent_id } = $target_id;
            my $parent = XIMS::Object->new( User => $self->User, document_id => $target_id );
            if ( defined $parent and defined $parent->id ) {
                if ( defined $target_location ) {
                    $target_location = XIMS::Importer::_clean_location( 1, $target_location ) unless $dontcleanlocation; # *cough*
                    my ($oldsuffix) = ($clonedata{ location } =~ /\.([^\.]+)$/);
                    my ($newsuffix) = ($target_location =~ /\.([^\.]+)$/);
                    if ( length $target_location and ($dontcleanlocation or $oldsuffix eq $newsuffix) ) {
                        $clonedata{ location } = $target_location;
                    }
                }
                if ( $parent->children( location => $clonedata{ location }, marked_deleted => undef ) ) {
                    XIMS::Debug( 2, "Cannot clone. Object with same location already exists in target container." );
                    return undef;
                }
            }
            else {
                XIMS::Debug( 2, "Could not resolve clone target." );
                return undef;
            }
        }
    }
    else {
        # same parent, so we have to find a new location for it
        my $newlocation = "copy_of_" . $clonedata{ location };
        my $newtitle = "Copy of " . $clonedata{ title };

        my $parent = $self->parent();
        if ( defined $parent and $parent->children( location => $newlocation, marked_deleted => undef ) ) {
            my $index = 1;
            do {
                $newlocation = "copy_(" . $index . ")_of_" . $clonedata{ location };
                $newtitle = "Copy (" . $index . ") of " . $clonedata{ title };
                $index++;
            } while ( $parent->children( location => $newlocation, marked_deleted => undef ) );
        }
        $clonedata{ location } = $newlocation;
        $clonedata{ title } = $newtitle;
    }

    # create the clone and expressly assign its body data (may be binfile)
    #warn("clone: about to create clone with data: " . Dumper( \%clonedata ) );
    my $clone = XIMS::Object->new( %clonedata );
    return unless defined $clone;
    $clone->body( $self->body() );
    my $clone_id = $clone->create( User => $user );
    return unless defined $clone_id;

    # remember old vs. new id
    $id_map->{ $self->id } = $clone->id;
    $docid_map->{ $self->document_id } = $clone->document_id;

    # check if this object need later fixup of referenced object ids
    my $objecttype = $clone->object_type;
    if ( $objecttype->is_objectroot() ) {
        push @$ref_object_ids, $clone->id;
        push @$ref_object_docids, $clone->document_id;
    }
    else {
        foreach my $id_name ( @Reference_Id_Names ) {
            if ( defined $clone->{ $id_name } ) {
                push @$ref_object_ids, $clone->id;
            }
        }
        foreach my $docid_name ( @Reference_DocId_Names ) {
            if ( defined $clone->{ $docid_name } ) {
                push @$ref_object_docids, $clone->document_id;
            }
        }
    }

    if ( defined $parent_id ) {
        # all subelements should keep their position, but they have got new ones by create(), so change this back!
        $clone->position( $self->position() );
        $clone->update();
    }

    # copy all object privileges
    my @privs = $self->data_provider->getObjectPriv( content_id => $self->id() );
    my $priv;
    my $clonepriv;
    foreach $priv ( @privs ) {
        $priv->{ content_id } = $clone->id();
        $clonepriv = XIMS::ObjectPriv->new->data( %{$priv} );
        $clonepriv->create();
    }

    if ( $clone->published() ) {
        # set clone to unpublished
        $clone->unpublish();
    }

    if ( $clone->locked() ) {
        # unlock clone
        $clone->unlock();
    }

    if ( $scope_subtree ) {
        # clone all granted children except '.diff_to_second_last'
        my @children = $self->children_granted( User => $user );
        my $child;
        foreach $child ( @children ) {
            next if $child->location() eq '.diff_to_second_last';
            return unless $child->clone( User => $user, scope_subtree => 1,
                                         _parent_id => $clone->document_id, _id_map => $id_map, _ref_object_ids => $ref_object_ids, _docid_map => $docid_map, _ref_object_docids => $ref_object_docids );
        }

        # check if we are back at top level of recursion
        if ( not defined $parent_id ) {
            # fixup referenced object ids in all cloned objects that have reference ids
            $self->__fix_clone_reference( User => $user, _id_map => $id_map, _ref_object_ids => $ref_object_ids, _docid_map => $docid_map, _ref_object_docids => $ref_object_docids );
        }
    }

    # reload the member data in case __fix_clone_references has updated it
    # in the meantime
    $clone = XIMS::Object->new( id => $clone->id() );

    # bless the instance into the correct class
    bless $clone, "XIMS::".$clone->object_type->fullname();

    return $clone;
}

##
#
# SYNOPSIS
#    my $copy = $object->copy( %args );
#
# PARAMETER
#    $args{ User }            (optional) : XIMS::User instance. Used to find granted children. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#    $args{ target }                     : document_id of container where the object should be copied to
#    $args{ target_location } (optional) : location of the copy; per default "copy_of_location" will be used
#
# RETURNS
#    undef on error, reference to copied object on success
#
# DESCRIPTION
#    Creates a copy of the object in the database in the container specified by 'target_id.
#    Per default, the copy will be named 'copy_of_...' (location). Instead of this,
#    a 'target_location' can be specified. If an object with the 'target_location' already exists in the
#    target container, copy() will return undef.
#    The copy is always unpublished and unlocked.
#    References to other copied objects are updated, as are references to portlets in body of department- and siteroot
#    copy() produces a deep copy.
#
sub copy {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $user = delete $args{User} || $self->{User};
    die "Copying an object requires an associated User" unless defined( $user );

    my $target_id = delete $args{target};
    return undef unless defined $target_id;

    return $self->clone( User => $user,
                        scope_subtree => 1,
                        target_id => $target_id,
                        target_location => $args{target_location},
                        dontcleanlocation => $args{dontcleanlocation} );
}


##
#
# SYNOPSIS
#    my $boolean = $object->reposition( %args );
#
# PARAMETER
#    $args{ position }    :  New position
#
# RETURNS
#    $boolean : True or False for repositioning object
#
# DESCRIPTION
#    Updates position of the object in its container, updates object in database.
#
sub reposition {
    my $self = shift;
    my %args = @_;

    my $new_position = delete $args{position};
    return undef unless $new_position;

    return $self->data_provider->reposition( parent_id => $self->parent_id,
                                             document_id => $self->document_id,
                                             position => $self->position,
                                             new_position => $new_position
                                           );
}


##
#
# SYNOPSIS
#    my $boolean = $object->attribute( %attrhash );
#
# PARAMETER
#    %attrhash    : the attribute hash
#
# RETURNS
#    $args{  }    :  New position
#
# DESCRIPTION
#    Attributes are stored in ";" separated key=value pairs in the attributes column
#    attribute() sets attributes through a hash.
#    If a hash value is empty, the attribute value is deleted.
#
sub attribute {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %attr = @_;
    my $text = $self->attributes();

    if ( defined $text and length $text ) {
        my %attributes = ( $text =~ /([^;\=]+)\=([^\;]+)/g );
        foreach my $key ( keys %attr ) {
            $attributes{$key} = $attr{$key};
        }
        $text = join( ';', map { $_ . "=" . (defined $attributes{$_} ? $attributes{$_} : '') } keys(%attributes) );
    }
    else {
        $text = join( ';', map { $_ . "=" . (defined $attr{$_} ? $attr{$_} : '') } keys(%attr) );
    }
    return 1 if $self->attributes( $text );
}

##
#
# SYNOPSIS
#    my $attribute = $object->attribute_by_key( $key );
#
# PARAMETER
#    $key    : Name of the attribute to be fetched
#
# RETURNS
#    $attribute : Value of the requested attribute
#
# DESCRIPTION
#    Attributes are stored in ";" separated key=value pairs in the attributes column
#
sub attribute_by_key {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $key  = shift;
    my $text = $self->attributes();

    if ( defined $text and length $text ) {
        my %attributes = ( $text =~ /([^;\=]+)\=([^\;]+)/g );
        return $attributes{$key};
    }

    return undef;
}

##################################################################
# User-priv related methods
##################################################################

##
#
# SYNOPSIS
#    my $boolean = $object->grant_user_privileges( %args );
#
# PARAMETER
#    $args{ grantee }     :  Grantee XIMS::User instance to grant privileges to
#    $args{ grantor }     :  Grantor XIMS::User instance to grant privileges from
#    $args{ privmask }    :  Privmask value. The full list of registered privmask is available via XIMS::Privileges::list(). If you want to grant multiple privileges, the values of XIMS::Privileges::* must be ORed together.
#
# RETURNS
#    $boolean : True or False for granting user privileges
#
# DESCRIPTION
#    Grants $args{privmask} to $args{grantee} on object.
#
# EXAMPLE
#  my $boolean = $object->grant_user_privileges( grantee => $grantee, grantor => $grantor, privmask => XIMS::Privileges::MODIFY|XIMS::Privileges::PUBLISH
#
sub grant_user_privileges {
    my $self = shift;
    my %args = @_;
    my $privilege_mask = defined $args{privmask} ? $args{privmask} : $args{privilege_mask};

    die "must have a grantor, a grantee and a privmask"
        unless defined( $args{grantor} ) and defined( $args{grantee}) and defined( $privilege_mask );

    # these allow the User-based args to be either a User object or the id() of one.
    my $grantee_id = ( ref( $args{grantee} ) && $args{grantee}->isa('XIMS::User') ) ? $args{grantee}->id() : $args{grantee};

    my $grantor_id = ( ref( $args{grantor} ) && $args{grantor}->isa('XIMS::User') ) ? $args{grantor}->id() : $args{grantor};


    my $serialization_method;

    if ( $self->data_provider->getObjectPriv( grantee_id => $grantee_id, content_id => $self->id() ) ) {
        $serialization_method = 'updateObjectPriv';
    }
    else {
        $serialization_method = 'createObjectPriv';
    }

    return $self->data_provider->$serialization_method( privilege_mask => $privilege_mask,
                                                        grantor_id => $grantor_id,
                                                        grantee_id => $grantee_id,
                                                        content_id => $self->id()
                                                      );
}

##
#
# SYNOPSIS
#    my $boolean = $object->lock( [ %args ] );
#
# PARAMETER
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#
# RETURNS
#    $boolean : True or False for locking the object
#
# DESCRIPTION
#    Locks the object for $args{User} (Or $object->User if $args{User} has not been specified.) Updates object in database.
#
sub lock {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    $self->locked_by_id( $user->id() );
    $self->locked_by_firstname( $user->firstname() );
    $self->locked_by_middlename( $user->middlename() );
    $self->locked_by_lastname( $user->lastname() );
    $self->locked_time( $self->data_provider->db_now() );

    return $self->data_provider->updateObject( $self->_lock_data() );
}

##
#
# SYNOPSIS
#    my $boolean = $object->unlock();
#
# PARAMETER
#    none
#
# RETURNS
#    $boolean : True or False for unlocking the object
#
# DESCRIPTION
#    Unlocks the object, updates object in database.
#
sub unlock {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    $self->locked_by_id( undef );
    $self->locked_by_firstname( undef );
    $self->locked_by_middlename( undef );
    $self->locked_by_lastname( undef );
    $self->locked_time( undef );

    return $self->data_provider->updateObject( $self->_lock_data() );
}

# Calling $self->_lock_data() instead of $self->data() causes a database
# update of the locking related fields only.
# 'Later' we could have a version of $self->data() which accepts a list
# of fields to be loaded/returned. This list of fields could be passed
# based on the current event or objecttype for example;
# also for portleting and during $object->descendants(), where
# currently, every field including the body-field is loaded for
# every single object.
sub _lock_data {
    my $self = shift;
    my %data = ();
    foreach ( qw/locked_by_id locked_by_firstname locked_by_middlename locked_by_lastname locked_time id/ ) {
        $data{$_} = $self->$_;
    }
    return %data;
}

##
#
# SYNOPSIS
#    my $boolean = $object->locked();
#
# PARAMETER
#    none
#
# RETURNS
#    $boolean : True or False is object is locked
#
# DESCRIPTION
#    Check if object is locked or not.
#
sub locked {
   my $self = shift;
   if ( $self->locked_by_id() and $self->locked_time() ) {
       return 1;
   }
   return undef;
}

##
#
# SYNOPSIS
#    my $boolean = $object->publish( [ %args ] );
#
# PARAMETER
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#    $args{ no_pubber }   (optional) :  If set, last publisher and last publication timestamp properties will not be set.
#
# RETURNS
#    $boolean : True or False for publishing the object
#
# DESCRIPTION
#    Sets the "published" property and last publisher user metadata. Updates object in database.
#
sub publish {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    $self->published( 1 );

    unless ( exists $args{no_pubber} ) {
        $self->last_published_by_id( $user->id() );
        $self->last_published_by_firstname( $user->firstname() );
        $self->last_published_by_middlename( $user->middlename() );
        $self->last_published_by_lastname( $user->lastname() );
        $self->last_publication_timestamp( $self->data_provider->db_now() );
    }

    return $self->data_provider->updateObject( $self->data() );
}

##
#
# SYNOPSIS
#    my $boolean = $object->unpublish( [ %args ] );
#
# PARAMETER
#    $args{ User }        (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user ) )
#
# RETURNS
#    $boolean : True or False for unpublishing the object
#
# DESCRIPTION
#    Unsets the "published" property and last publisher user metadata. Updates object in database.
#
sub unpublish {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    $self->published( undef );
    $self->last_published_by_id( undef );
    $self->last_published_by_firstname( undef );
    $self->last_published_by_middlename( undef );
    $self->last_published_by_lastname( undef );
    return $self->data_provider->updateObject( $self->data() );
}

# The following methods allow the more intuitive $obj->data_format() to
# work, rather than forcing XIMS::DataFormat->new( id => $obj->id() ) for example.

##
#
# SYNOPSIS
#    my $ot = $object->object_type();
#
# PARAMETER
#    none
#
# RETURNS
#    $ot : XIMS::ObjectType instance
#
# DESCRIPTION
#    Returns object type of object.
#
sub object_type {
    my $self = shift;
    return $self->{ObjectType} if defined $self->{ObjectType};
    return undef unless $self->object_type_id();
    my $ot = XIMS::ObjectType->new( id => $self->object_type_id() );
    $self->{ObjectType} = $ot;
    return $ot;
}

##
#
# SYNOPSIS
#    my $df = $object->data_format();
#
# PARAMETER
#    none
#
# RETURNS
#    $df : XIMS::DataFormat instance
#
# DESCRIPTION
#    Returns data format of object.
#
sub data_format {
    my $self = shift;
    return $self->{DataFormat} if defined $self->{DataFormat};
    return undef unless $self->data_format_id() ;
    my $df = XIMS::DataFormat->new( id => $self->data_format_id() );
    $self->{DataFormat} = $df;
    return $df;
}

##
#
# SYNOPSIS
#    my $language = $object->language();
#
# PARAMETER
#    none
#
# RETURNS
#    $ot : XIMS::Language instance
#
# DESCRIPTION
#    Returns language of object.
#
sub language {
    my $self = shift;
    return $self->{Language} if defined $self->{Language};
    return undef unless $self->language_id();
    my $lang = XIMS::Language->new( id => $self->language_id );
    $self->{Language} = $lang;
    return $lang;
}

##
#
# SYNOPSIS
#    my $stylesheet = $object->stylesheet( [ explicit => 1 ] );
#
# PARAMETER
#    %args        (optional) : hash
#       recognized key: 'explicit': If given, only explicitly assigned stylesheet objects or directories
#                                   will be returned neglecting inherited ones.
#
# RETURNS
#    $stylesheet : XIMS::Object instance (Objecttype 'XSLStylesheet' or 'Folder')
#
# DESCRIPTION
#    Returns stylesheet(-directory) assigned to the object. If a
#    stylesheet(-directory) is not assigned directly, inherited
#    ones from the objectroot objects up the hierarchy are looked for
#    unless "explicit" argument has been given.
#
sub stylesheet {
    my $self = shift;
    my %args = @_;

    return $self->{Stylesheet} if defined $self->{Stylesheet};
    my $style_id = $self->style_id();
    if ( not defined $style_id ) {
        if ( not defined $args{explicit} ) {
            # look for style_id in ancestrial objectroot objects
            foreach my $oroot ( reverse @{$self->objectroot_ancestors} ) {
                last if $style_id = $oroot->style_id();
            }
            return undef unless defined $style_id;
        }
        else {
            return undef;
        }
    }
    my $stylesheet = XIMS::Object->new( id => $style_id );
    $self->{Stylesheet} = $stylesheet;
    return $stylesheet;
}

##
#
# SYNOPSIS
#    my $css = $object->css( [ explicit => 1 ] );
#
# PARAMETER
#    %args        (optional) : hash
#       recognized key: 'explicit': If given, only explicitly assigned stylesheet objects or directories
#                                   will be returned neglecting inherited ones.
#
# RETURNS
#    $css : XIMS::Object instance
#
# DESCRIPTION
#    Returns a CSS stylesheet assigned to the object. If a
#    CSS stylesheet is not assigned directly, an inherited
#    one from the objectroot objects up the hierarchy is looked for
#    unless "explicit" argument has been given.
#
sub css {
    my $self = shift;
    my %args = @_;

    return $self->{CSS} if defined $self->{CSS};
    my $css_id = $self->css_id();
    if ( not defined $css_id ) {
        if ( not defined $args{explicit} ) {
            # look for css_id in ancestrial objectroot objects
            foreach my $oroot ( reverse @{$self->objectroot_ancestors} ) {
                last if $css_id = $oroot->css_id();
            }
            return undef unless defined $css_id;
        }
        else {
            return undef;
        }
    }
    # think of XIMS::CSS here
    my $css = XIMS::Object->new( id => $css_id );
    $self->{CSS} = $css;
    return $css;
}

##
#
# SYNOPSIS
#    my $image = $object->image( [ explicit => 1 ] );
#
# PARAMETER
#    %args        (optional) : hash
#       recognized key: 'explicit': If given, only explicitly assigned image objects
#                                   will be returned neglecting inherited ones.
#
# RETURNS
#    $image : XIMS::Object instance
#
# DESCRIPTION
#    Returns an Image assigned to the object. If an
#    Image is not assigned directly, an inherited
#    one from the objectroot objects up the hierarchy is looked for
#    unless "explicit" argument has been given.
#
sub image {
    my $self = shift;
    my %args = @_;

    return $self->{Image} if defined $self->{Image};
    my $image_id = $self->image_id();
    if ( not defined $image_id ) {
        if ( not defined $args{explicit} ) {
            # look for image_id in ancestrial objectroot objects
            foreach my $oroot ( reverse @{$self->objectroot_ancestors} ) {
                last if $image_id = $oroot->image_id();
            }
            return undef unless defined $image_id;
        }
        else {
            return undef;
        }
    }
    # think of XIMS::Image here
    my $image = XIMS::Object->new( id => $image_id );
    $self->{Image} = $image;
    return $image;
}

##
#
# SYNOPSIS
#    my $script = $object->script( [ explicit => 1 ] );
#
# PARAMETER
#    %args        (optional) : hash
#       recognized key: 'explicit': If given, only explicitly assigned script objects
#                                   will be returned neglecting inherited ones.
#
# RETURNS
#    $script : XIMS::Object instance
#
# DESCRIPTION
#    Returns a Script assigned to the object. If a
#    Script is not assigned directly, an inherited
#    one from the objectroot objects up the hierarchy is looked for
#    unless "explicit" argument has been given.
#
sub script {
    my $self = shift;
    my %args = @_;

    return $self->{Script} if defined $self->{Script};
    my $script_id = $self->script_id();
    if ( not defined $script_id ) {
        if ( not defined $args{explicit} ) {
            # look for script_id in ancestrial objectroot objects
            foreach my $oroot ( reverse @{$self->objectroot_ancestors} ) {
                last if $script_id = $oroot->script_id();
            }
            return undef unless defined $script_id;
        }
        else {
            return undef;
        }
    }
    # think of XIMS::JavaScript here
    my $script = XIMS::Object->new( id => $script_id );
    $self->{Script} = $script;
    return $script;
}

##
#
# SYNOPSIS
#    my $schema = $object->schema( [ explicit => 1 ] );
#
# PARAMETER
#    %args        (optional) : hash
#       recognized key: 'explicit': If given, only explicitly assigned schema objects
#                                   will be returned neglecting inherited ones.
#
# RETURNS
#    $schema : XIMS::Object instance
#
# DESCRIPTION
#    Returns a Schema assigned to the object. If a
#    Schema is not assigned directly, an inherited
#    one from the objectroot objects up the hierarchy is looked for
#    unless "explicit" argument has been given.
#
sub schema {
    my $self = shift;
    my %args = @_;

    return $self->{Schema} if defined $self->{Schema};
    my $schema_id = $self->schema_id();
    if ( not defined $schema_id ) {
        if ( not defined $args{explicit} ) {
            # look for schema_id in ancestrial objectroot objects
            foreach my $oroot ( reverse @{$self->objectroot_ancestors} ) {
                last if $schema_id = $oroot->schema_id();
            }
            return undef unless defined $schema_id;
        }
        else {
            return undef;
        }
    }
    my $schema = XIMS::Object->new( id => $schema_id );
    $self->{Schema} = $schema;
    return $schema;
}

##
#
# SYNOPSIS
#    my $creator = $object->creator( [ $user ] );
#
# PARAMETER
#    $user    (optional) : XIMS::User instance which shall set as creator
#
# RETURNS
#    $creator : XIMS::User instance
#
# DESCRIPTION
#    Returns creator of object. If $user is given as parameter, creator of object is updated.
#
sub creator {
    my $self = shift;
    my $creator = shift;

    if ( $creator ) {
        $self->created_by_id( $creator->id() );
        $self->created_by_firstname( $creator->firstname() );
        $self->created_by_middlename( $creator->middlename() );
        $self->created_by_lastname( $creator->lastname() );
    }
    else {
        return $self->{Creator} if defined $self->{Creator};
        return undef unless $self->created_by_id();
        $creator = XIMS::User->new( id => $self->created_by_id );
    }
    $self->{Creator} = $creator;
    return $creator;
}

##
#
# SYNOPSIS
#    my $owner = $object->owner( [ $user ] );
#
# PARAMETER
#    $user    (optional) : XIMS::User instance which shall set as owner
#
# RETURNS
#    $owner : XIMS::User instance
#
# DESCRIPTION
#    Returns owner of object. If $user is given as parameter, owner of object is updated.
#
sub owner {
    my $self = shift;
    my $owner = shift;

    if ( $owner ) {
        $self->owned_by_id( $owner->id() );
        $self->owned_by_firstname( $owner->firstname() );
        $self->owned_by_middlename( $owner->middlename() );
        $self->owned_by_lastname( $owner->lastname() );
    }
    else {
        return $self->{Owner} if defined $self->{Owner};
        return undef unless $self->owned_by_id();
        $owner = XIMS::User->new( id => $self->owned_by_id );
    }
    $self->{Owner} = $owner;
    return $owner;
}

##
#
# SYNOPSIS
#    my $last_modifier = $object->last_modifier( [ $user ] );
#
# PARAMETER
#    $user    (optional) : XIMS::User instance which shall set as creator
#
# RETURNS
#    $last_modifier : XIMS::User instance
#
# DESCRIPTION
#    Returns last modifier of object. If $user is given as parameter, last modifier of object is updated.
#
sub last_modifier {
    my $self = shift;
    my $modder = shift;

    if ( $modder ) {
        $self->last_modified_by_id( $modder->id() );
        $self->last_modified_by_firstname( $modder->firstname() );
        $self->last_modified_by_middlename( $modder->middlename() );
        $self->last_modified_by_lastname( $modder->lastname() );
    }
    else {
        return $self->{LastModifier} if defined $self->{LastModifier};
        return undef unless $self->last_modified_by_id();
        $modder = XIMS::User->new( id => $self->last_modified_by_id );
    }
    $self->{LastModifier} = $modder;
    return $modder;
}

##
#
# SYNOPSIS
#    my $last_publisher = $object->last_publisher( [ $user ] );
#
# PARAMETER
#    $user    (optional) : XIMS::User instance which shall set as creator
#
# RETURNS
#    $last_publisher : XIMS::User instance
#
# DESCRIPTION
#    Returns last publisher of object. If $user is given as parameter, last publisher of object is updated.
#
sub last_publisher {
    my $self = shift;
    my $pubber = shift;

    if ( $pubber ) {
        $self->last_published_by_id( $pubber->id() );
        $self->last_published_by_firstname( $pubber->firstname() );
        $self->last_published_by_middlename( $pubber->middlename() );
        $self->last_published_by_lastname( $pubber->lastname() );
    }
    else {
        return $self->{LastPublisher} if defined $self->{LastPublisher};
        return undef unless $self->last_published_by_id();
        $pubber = XIMS::User->new( id => $self->last_published_by_id );
    }
    $self->{LastPublisher} = $pubber;
    return $pubber;
}

##
#
# SYNOPSIS
#    my $locker = $object->locker();
#
# PARAMETER
#    none
#
# RETURNS
#    $locker : XIMS::User instance
#
# DESCRIPTION
#    Returns locker of object if its locked.
#
sub locker {
    my $self = shift;
    return $self->{Locker} if defined $self->{Locker};
    return undef unless $self->locked();
    my $locker = XIMS::User->new( id => $self->locked_by_id );
    $self->{Locker} = $locker;
    return $locker;
}

##
#
# SYNOPSIS
#    my $location_path = $object->location_path();
#
# PARAMETER
#    none
#
# RETURNS
#    $location_path : Location path of object
#
# DESCRIPTION
#    Returns location path of object. The location path is the virtual path of the object
#    in the hierarchy without '/root'. An object with the location 'index.html' and the parent 'foo',
#    which itself has the default 'xims' SiteRoot as parent, will have the location path '/xims/foo/index.html'.
#
#    Note that location_paths are set by a database trigger and are read-only for the application!
#    Note that location_paths are stored in memory after object initialization and will not be updated
#    if the location_path of a ancestor object has changed (e.g. by changing the location or parent_id of an ancestor
#    For that cases, the object has to be reinitialized to get the correct value for the location_path!
#
sub location_path {
    my $self = shift;
    my $id = $self->{id};
    if ( defined $id and $id != 1 ) { # root has no location_path
        if ( defined $self->{location_path} ) {
            return $self->{location_path};
        }
        else {
            # If an object has just been created, we have to fetch the location_path from the dp
            $self->{location_path} = $self->data_provider->location_path( id => $id );
            return $self->{location_path};
        }
    }
    return '';
}

##
#
# SYNOPSIS
#    my $location_path_relative = $object->location_path_relative();
#
# PARAMETER
#    none
#
# RETURNS
#    $location_path : Location path relative to the SiteRoot of the object
#
# DESCRIPTION
#    Returns the location path relative to the SiteRoot of the object. The 'index.html' object example given in the location_path() description above will have a relative location path of '/foo/index.html'.
#
sub location_path_relative {
    my $self = shift;
    my $id = $self->{id};
    if ( defined $id and $id != 1 ) { # root has no location_path
        my $relative_path = $self->location_path();
        $relative_path =~ s/^\/[^\/]+//;
        return $relative_path;
    }
    return '';
}

##
#
# SYNOPSIS
#    my $boolean = $object->store_diff_to_second_last( $oldbody, $newbody );
#
# PARAMETER
#    $oldbody : Old body string
#    $newbody : New body string
#
# RETURNS
#    $boolean : True or False for storing diff
#
# DESCRIPTION
#    When given two strings store_diff_to_second_last() stores the unified diff of them
#    in a child XIMS::Text object called '.diff_to_second_last'. This may
#    be useful to track the most recent changes to a text-based object,
#    and will co-exist with the upcoming versioning implementation, which
#    will only explicitly save versions and will allow reviewing the changes
#    not only between the latest and second to last modification of objects.
#
sub store_diff_to_second_last {
    XIMS::Debug( 5, "called");
    my $self = shift;
    my $oldbody = shift;
    my $newbody = shift;

    # do not store anything for objects that have not been created yet
    return undef unless $self->id();

    # check for params
    return undef unless (defined $oldbody and length $oldbody and defined $newbody);

    my $diffobject_location = '.diff_to_second_last';

    # not i18n'd :-|
    # could be be filled with edit trail auditing information after that will be
    # implemented (http://sourceforge.net/tracker/index.php?func=detail&aid=824274&group_id=42250&atid=432508)
    my %diffoptions = ( FILENAME_A  => $self->location() . " (" . ($self->last_modifier->firstname ? $self->last_modifier->firstname : '') . " " . $self->last_modifier->lastname . ", " . $self->last_modification_timestamp . ")",
                        FILENAME_B  => $self->location() . " (" . ($self->User->firstname ? $self->User->firstname : '') . " " . $self->User->lastname . ", " . $self->data_provider->db_now . ")",
                      );

    my $diff = diff \$oldbody, \$newbody, \%diffoptions;

    # check for ".diff_to_second_last"
    my @children = $self->children( location => $diffobject_location );
    my $diffobject = $children[0];
    if ( $diffobject and $diffobject->id() ) {
        $diffobject->body( XIMS::xml_escape( $diff ) );
        return $diffobject->update( User => $self->User );
    }
    else {
        my $oimporter = XIMS::Importer::Object->new( User => $self->User, Parent => $self, IgnoreCreatePriv => 1 );
        $diffobject = XIMS::Text->new( User => $self->User, location => $diffobject_location );
        $diffobject->body( XIMS::xml_escape( $diff ) );

        my $id = $oimporter->import( $diffobject );
        if ( not $id ) {
            XIMS::Debug( 2, "could not create diff-object" );
            return undef;
        }
    }

    return 1;
}

###
#
# Helpers
#
###

##
#
# SYNOPSIS
#    my $doc = $object->balanced_string( $CDATAstring, [$params] );
#
# PARAMETER
#    $CDATAstring : input string
#    %args        :  hash
#       recognized keys: nochunk     : if set, $CDATAstring is assumed to be a document with a root-element
#                                      and will be parsed with parse_string() instead of the default parse_xml_chunk()
#                                      useful for importing
#                        verbose_msg : if set, XML::LibXML'S error string instead of undef is returned on parse-error
#                        encoding    : can be optionally given if a chunk is to be parsed; defaults to 'UTF-8'
#
# RETURN
#    $doc : XML::LibXML::Document instance if string is well-formed and 'nochunk' is given
#           XML::LibXML::DocumentFragment instance if string is well-balanced
#           undef if string is not given and 'verbose_msg' is ommitted
#           error string if string is well-formed and 'nochunk' is given
#
# DESCRIPTION
#    tests if input string is wellbalanced
#    useful for testing wellbalancedness of object abstracts or document-based bodies for example
#
sub balanced_string {
    XIMS::Debug( 5, "called" );
    my $self        = shift;
    my $CDATAstring = shift;
    my %args        = @_;
    my $doc;

    my $retval      = undef; # return value

    if ( $CDATAstring and length $CDATAstring ) {
        my $parser = XML::LibXML->new();
        if ( exists $args{nochunk} ) {
            eval { $doc = $parser->parse_string( $CDATAstring ) };
            if ( $@ ) {
                XIMS::Debug( 2, "string not well-formed" );
                XIMS::Debug( 6, "LibXML returned $@" );
                $@ =~ s/at \/.*$//;
                $retval = $@ if exists $args{verbose_msg};
            }
            else {
                $retval = $doc;
            }
        }
        else {
            my $encoding;
            $encoding = $args{encoding} if defined $args{encoding};
            $encoding ||= ( XIMS::DBENCODING() || 'UTF-8' );
            eval { $doc = $parser->parse_xml_chunk( $CDATAstring, $encoding ) };
            if ( !$doc or $@ ) {
                XIMS::Debug( 2, "string not well-balanced" );
                XIMS::Debug( 6, "LibXML returned $@" );
                $@ =~ s/at \/.*$//;
                $retval = $@  if exists $args{verbose_msg};
            }
            else {
                $retval = $doc;
            }
        }
    }

    return $retval;
}


##
#
# SYNOPSIS
#    my $wbCDATAstring = $object->balance_string( $CDATAstring, [$params] );
#
# PARAMETER
#    $CDATAstring : input string
#    %args        : hash
#       recognized keys: keephtmlheader : per default, the html-header tidy generates is stripped of the return
#                                         string and only the part between the "body" tag is returned
#                                         in case of importing legacy html documents it may be useful to keep
#                                         the meta information in the html header - the keephtmlheader flag is
#                                         your friend for that.
#
# RETURNS
#    $wbCDATAstring : well balanced outputstring or undef in case of error
#
# DESCRIPTION
#    takes a string and tries tidy, or if that fails XML::LibXML to well-balance it
#
sub balance_string {
    XIMS::Debug( 5, "called" );
    my $self        = shift;
    my $CDATAstring = shift;
    my %args        = @_;

    return undef unless defined $CDATAstring;

    my $wbCDATAstring = undef; # return value

    # as long as there is no libtidy and no XS based HTML::Tidy, it looks like we have to
    # deal with the forking and temorary file handling...:/
    my $tidy        = XIMS::TIDYPATH();
    my $tidyOptions = XIMS::TIDYOPTIONS();
    my $tmppath = "/tmp/";
    my $tmpfile = 'formwell' . $$ * int(rand 42) . '.tmp';
    my $tmp = $tmppath . $tmpfile;

    my $tmp_fh = IO::File->new( $tmp, 'w' );
    if ( defined $tmp_fh ) {
        binmode $tmp_fh, ":utf8";
        print $tmp_fh XIMS::encode($CDATAstring);
        $tmp_fh->close;
        XIMS::Debug( 4, "Temporary file written" );
    }
    else {
        XIMS::Debug( 2, "Error writing file '$tmp': $!" );
        return undef;
    }

    eval {
        $wbCDATAstring = `$tidy $tidyOptions $tmp`;
    };
    if ( $@ ) {
        XIMS::Debug( 2, "Could not execute '$tidy $tidyOptions $tmp': $@" );
        return undef;
    }

    unlink $tmp;

    if ( not $self->balanced_string( $wbCDATAstring, nochunk => 1 ) ) {
        # tidy cleans better, but we want the following as fallback
        XIMS::Debug( 3, "tidy did not return a wellformed string, using LibXML" );

        my $parser = XML::LibXML->new();
        # pepl: todo - check if that is still current parse_html_string() behaviour
        #
        # parse_html_string() is broken: does not recognize encoding and has
        # no fallback-encoding, so it croaks at the very first non-ascii-char
        # adding ctxt->charset = XML_CHAR_ENCODING_UTF8; before returning at
        # htmlCreateDocParserCtxt() in htmlParser.c
        # gives a workaround fallback encoding setting
        $CDATAstring = XIMS::encode( $CDATAstring );
        my $doc;
        eval {
            $doc = $parser->parse_html_string( $CDATAstring );
        };
        if ( $@ ) {
            XIMS::Debug( 2, "LibXML could not parse string either: $@" );
            return undef;
        }
        else {
            my $encoding = XIMS::DBEncoding() ? XIMS::DBEncoding() : 'UTF-8';
            $doc->setEncoding( $encoding ); # needed. otherwise, toString() produces one-byte numeric entities or double-byte chars !?
            $wbCDATAstring = XIMS::decode( $doc->toString() );
        }
    }
    else {
        # tidy returns utf-8, so we may have to decode...
        $wbCDATAstring = XIMS::decode( $wbCDATAstring );
    }

    if ( not exists $args{keephtmlheader} ) {
        # strip everything before <BODY> and after </BODY>
        $wbCDATAstring =~ s/^.*<body[^>]*>\n?//si;
        $wbCDATAstring =~ s\</body[^>]*>.*$\\si;
    }

    if ( length $wbCDATAstring ) {
        return $wbCDATAstring;
    }
    else {
        return undef;
    }
}

sub content_field {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $df;
    if ( defined( $self->{DataFormat} ) and defined( $self->{DataFormat}->id ) ) {
       $df = $self->{DataFormat};
    }
    else {
        my $df_id = $self->{data_format_id} || $self->{'document.data_format_id'};
        $df = XIMS::DataFormat->new( id => $df_id );
        $self->{DataFormat} = $df;
    }
    # pepl: departmentroot portlet info is stored in its body
    # return undef if $df->name() eq 'Container';
    return 'binfile' if ( $df->mime_type and $df->mime_type =~ /^(application|image)\//i and $df->mime_type !~ /container|xsp/i );
    return 'body';
}


#workflow implementation#
sub forward {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->data_provider->updateObject( status => 'pending', id => $self->id() );
}

sub reject {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return $self->data_provider->updateObject( status => 'rejected', id => $self->id() );
}
#end workflow implementation#

1;
