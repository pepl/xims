# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Object;

use strict;
use warnings;
no warnings 'redefine';

use vars qw($VERSION @ISA @Fields @Default_Properties @Reference_Id_Names );
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

use XIMS;
use XIMS::ObjectType;
use XIMS::DataFormat;
use XIMS::User;
use XIMS::AbstractClass;
@ISA = qw( XIMS::AbstractClass );

use XML::LibXML; # for balanced_string(), balance_string()
use IO::File; # for balanced_string()

#use Data::Dumper;

sub resource_type {
    return 'Object';
}

sub fields {
    return @Fields;
}

@Reference_Id_Names = qw( symname_to_doc_id style_id script_id css_id image_id );

BEGIN {
    # the binfile field is no longer available via the method interface, but is set
    # internally in the object's HASH to allow binary object types to alias body() to the binfile
    # field. This avoids madness during data serialization.

    @Fields = grep { $_ ne 'binfile' } @{XIMS::Names::property_interface_names( resource_type() )};
    @Default_Properties = grep { $_ ne 'body' } @Fields;
}

use Class::MethodMaker
        get_set       => \@Fields;

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
        $args{document_id} = $document_id;
    }

    # check to see if we are using the constructor
    # to fetch an *existing* object by passing in it's ID
    if ( defined($args{id}) or defined($args{document_id}) ) {
        XIMS::Debug( 6, "fetching object by id: $args{id}." ) if defined($args{id});
        XIMS::Debug( 6, "fetching object by document_id: $args{document_id}." ) if defined($args{document_id});
        $real_object = $self->data_provider->getObject( %args, properties => \@Default_Properties );
        if ( defined( $real_object )) {
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
            my $otname = ( split /::/, $class )[-1];
            if ( not $args{object_type_id} ) {
                my $ot = XIMS::ObjectType->new( name => $otname );
                if ( $ot ) {
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


# specific override to the default set/get provided by Class::MethodMaker to
# avoid the memory/performance hit of loading the content data
# in cases where it is not explictly asked for.

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
        my $selected_data = $self->data_provider->getObject( id => $self->id(), properties => [$content_field] );
        my $actual_data = ( values( %{$selected_data} ) )[0];
        $self->{$content_field} = $actual_data;
        return $actual_data;
    }
}

sub content_length {
    my $self = shift;
    return $self->data_provider->content_length( id => $self->id() );
}

##################################################################
# Object selection methods based on axis relationships to the current
# object (parent, children, descendants, etc.)
##################################################################

sub parent {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    return undef unless $self->parent_id;
    return XIMS::Object->new( document_id => $self->parent_id );
}

sub children {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @child_ids = $self->__child_ids( $self->document_id() );
    return () unless scalar( @child_ids ) > 0 ;
    my @children_data = $self->data_provider->getObject( document_id => \@child_ids, %args, properties => \@Default_Properties );
    my @children = map { XIMS::Object->new->data( %{$_} ) } @children_data;
    #warn "children" . Dumper( \@children ) . "\n";
    return wantarray ? @children : $children[0];
}

sub children_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->children( %args ) if $user->admin();

    # the following is a potential performance killer, we should spare some steps here...
    # do a join in __child_ids?
    # it does not have to be the Do-it-all-in-one-query-with-Oracle way ;-)
    # SELECT d.id,c.id,location,title,object_type_id,data_format_id,privilege_mask,depth FROM ci_content c,(SELECT ci_documents.*, level depth FROM ci_documents START WITH id IN ( SELECT document_id FROM ci_content WHERE id = ?) CONNECT BY PRIOR id = parent_id AND level <= ? AND id != parent_id ORDER BY level) d,ci_object_privs_granted p,(SELECT id, level FROM ci_roles_granted START WITH grantee_id = ? CONNECT BY PRIOR id = grantee_id ORDER BY level) r WHERE c.document_id = d.id AND depth > 1 AND p.content_id = c.id AND p.content_id = c.id AND (p.grantee_id = ? OR p.grantee_id = r.id ) AND p.privilege_mask >= 1 AND (SELECT privilege_mask FROM ci_object_privs_granted WHERE content_id = c.id AND grantee_id = ? AND privilege_mask = 0) IS NULL AND marked_deleted IS NULL ORDER BY d.position
    my @child_candidate_docids = $self->__child_ids( $self->document_id() );
    return () unless scalar( @child_candidate_docids ) > 0;

    my @children = $self->__get_granted_objects( doc_ids => \@child_candidate_docids, User => $user, %args ) ;

    #warn "Granted children" . Dumper( \@children ) . "\n";
    return wantarray ? @children : $children[0];
}

sub child_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @child_ids = $self->__child_ids( $self->document_id() );
    return scalar ( @child_ids );
}

sub descendants {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $descendant_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id() );

    my @doc_ids  = @{$descendant_ids_lvls->[0]};
    my @lvls = @{$descendant_ids_lvls->[1]};

    return () unless scalar( @doc_ids ) > 0;

    my @descendants_data =  $self->data_provider->getObject( document_id => \@doc_ids,
                                                             %args,
                                                             properties => \@Default_Properties,
                                                            );

    my @descendants = map { XIMS::Object->new->data( %{$_} ) } @descendants_data;

    # getObject() returns the objects in the default sorting order, so we have to remap levels and resort descendants :-/...
    my @sorted_descendants;
    my $index;
    my $i;
    foreach my $descendant ( @descendants ) {
        for ( $i=0; $i < @doc_ids; $i++ ) {
            if ( $doc_ids[$i] == $descendant->document_id() ) {
                $index = $i;
                last;
            }
        }
        $descendant->{level} = $lvls[$index];
        $sorted_descendants[$index] = $descendant;
    }

    #warn "descendants" . Dumper( \@sorted_descendants ) . "\n";
    return wantarray ? @sorted_descendants : $sorted_descendants[0];
}

sub descendants_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->descendants( %args ) if $user->admin();

    my $descendant_candidate_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id() );

    my @candidate_doc_ids  = @{$descendant_candidate_ids_lvls->[0]};
    my @candidate_lvls = @{$descendant_candidate_ids_lvls->[1]};

    return () unless scalar( @candidate_doc_ids ) > 0;

    my @descendants = $self->__get_granted_objects( doc_ids => \@candidate_doc_ids, User => $user, %args ) ;
    return () unless scalar( @descendants ) > 0;

    # getObject() returns the objects in the default sorting order, so we have to remap levels and resort descendants :-/...
    my @sorted_descendants;
    my $index;
    my $i;
    foreach my $descendant ( @descendants ) {
        for ( $i=0; $i < @candidate_doc_ids; $i++ ) {
            if ( $candidate_doc_ids[$i] == $descendant->document_id() ) {
                $index = $i;
                last;
            }
        }
        $descendant->{level} = $candidate_lvls[$index];
        $sorted_descendants[$index] = $descendant;
    }

    # remove the empty array slots left from the sort
    @sorted_descendants = grep { defined $_ } @sorted_descendants;

    #warn "descendants" . Dumper( \@sorted_descendants ) . "\n";
    return wantarray ? @sorted_descendants : $sorted_descendants[0];
}

# returns a 2 element list: ($total_descendants, $levels)
sub descendant_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $descendant_count = 0;
    my $descendant_ids_lvls = $self->data_provider->get_descendant_id_level( parent_id => $self->document_id() );

    my @doc_ids  = @{$descendant_ids_lvls->[0]};
    my @lvls = @{$descendant_ids_lvls->[1]};

    # sort to find floor and ceiling values
    @lvls = sort { $a <=> $b } @lvls;

    return ( scalar( @doc_ids ), $lvls[-1] - $lvls[0] + 1 );
}

sub find_objects {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my @found_ids = $self->__find_ids( %args );
    return () unless scalar( @found_ids ) > 0 ;
    my @object_data = $self->data_provider->getObject( document_id => \@found_ids, properties => \@Default_Properties );
    my @objects = map { XIMS::Object->new->data( %{$_} ) } @object_data;

    #warn "objects found" . Dumper( \@objects ) . "\n";
    return @objects;
}

sub find_objects_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    return $self->__find_ids_count( %args );
}

sub find_objects_granted {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};

    return $self->find_objects( %args ) if $user->admin();

    my @found_candidate_doc_ids = $self->__find_ids( %args );
    return () unless scalar( @found_candidate_doc_ids ) > 0 ;

    my @found = $self->__get_granted_objects( doc_ids => \@found_candidate_doc_ids, User => $user ) ;

    #warn "found" . Dumper( \@found ) . "\n";
    return wantarray ? @found : $found[0];
}

sub find_objects_granted_count {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    my @role_ids = ( $user->role_ids(), $user->id() );

    return $self->find_objects_count( %args ) if $user->admin();

    delete $args{rowlimit} if exists $args{rowlimit}; # we have to get the ids of *all* matching objects
    my @found_candidate_doc_ids = $self->__find_ids( %args );
    return unless scalar( @found_candidate_doc_ids ) > 0 ;

    my @priv_data = $self->data_provider->getObjectPriv( content_id => \@found_candidate_doc_ids,
                                                         grantee_id => \@role_ids,
                                                         properties => [ 'content_id' ] );

    # extract and remove duplicate content ids
    my @ids = map{ $_->{'objectpriv.content_id'} } @priv_data;
    my %seen = ();
    my $count;
    grep { !$seen{$_}++ and $count++} @ids;

    return $count;
}

sub ancestors {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @ancestors = $self->data_provider->recurse_ancestor( $self );
    #warn "parents " . Dumper( \@ancestors ) . "\n";
    return \@ancestors;
}

# internal helper to filter out granted objects, accepts a hash as parameters, mandatory key: doc_ids => @doc_ids
# shared by children_granted, descendants_granted, and find_objects_granted
# returns a list of XIMS::Objects
sub __get_granted_objects {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    my @role_ids = ( $user->role_ids(), $user->id() );
    my $doc_ids = delete $args{doc_ids};
    return () unless scalar( @{$doc_ids} ) > 0;

    my @candidate_data = $self->data_provider->getObject( document_id => $doc_ids,
                                                          properties => [ 'document.id', 'content.id' ] );
    my @candidate_ids = map{ $_->{'content.id'} } @candidate_data;

    my @priv_data = $self->data_provider->getObjectPriv( content_id => \@candidate_ids,
                                                         grantee_id => \@role_ids,
                                                         properties => [ 'content_id' ] );

    return () unless scalar( @priv_data ) > 0;

    my @ids = map{ $_->{'objectpriv.content_id'} } @priv_data;
    my @data = $self->data_provider->getObject( id  => \@ids,
                                                %args,
                                                properties => \@Default_Properties );

    my @objects = map { XIMS::Object->new->data( %{$_} ) } @data;

    #warn "objects " . Dumper( \@objects ) . "\n";
    return @objects;
}

# internal.
# shared by 'children', 'child_count'
sub __child_ids {
    my $self = shift;
    my @ids = @_;
    my @out_ids;
    my @child_ids = $self->data_provider->get_object_id( parent_id => \@ids );
    foreach my $id ( @child_ids ) {
        next if grep { $_ == $id } @ids;
        push @out_ids, $id;
    }
    return @out_ids;
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

    #warn("fixing ref ids on objects : " . Dumper( $ref_object_ids ) );
    #warn("fixing ref ids with id map: " . Dumper( $id_map ) );

    my $clone;
    my $id_name;
    my $document_id;
    my $newid;
    my $update_flag;
    my $objecttype;

    # check all copied objects that have referenced to other objects
    foreach $document_id ( @$ref_object_ids ) {
        $clone = XIMS::Object->new( document_id => $document_id );
        # warn("clone to fix: " . Dumper( $clone ) );
        $update_flag = 0;
        foreach $id_name ( @Reference_Id_Names ) {
            if( defined $clone->{ $id_name } ) {
                $newid = $id_map->{ $clone->{ $id_name } };
                if ( defined $newid ) {
                    # the referenced object has also been copied, so change the reference to the copy
                    $clone->{ $id_name } = $newid;
                    $update_flag = 1; # update of clone is needed
                }
            }
        }

        # fix body of departmentroots and siteroots, their body contains portlet ids
        $objecttype = $clone->object_type;
        if ( $objecttype->name() eq "DepartmentRoot" or $objecttype->name() eq "SiteRoot" ) {
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
                        $newid = $id_map->{ $node->string_value() };
                        if ( defined $newid ) {
                            $node->firstChild->setData( $newid );
                            $update_body_flag = 1;
                        }
                    }
                    if ( $update_body_flag ) {
                        $clone->body( $fragment->toString());
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
    if ( ($object->object_type->name() eq 'DepartmentRoot') or ($object->object_type->name() eq 'SiteRoot') ) {
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

    my ($id, $document_id) = $self->data_provider->createObject( $self->data() );
    $self->id( $id );
    $self->document_id( $document_id );
    return $id;
}

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

    return $self->data_provider->updateObject( $self->data() );
}

sub trashcan {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    $self->marked_deleted( 1 );
    $self->position( undef );

    return $self->data_provider->updateObject( $self->data() );
}

sub undelete {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    $self->marked_deleted( undef );
    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() );
    $self->position( $max_position + 1 );
    return $self->data_provider->updateObject( $self->data() );
}

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

    $self->parent_id( $parent_id );

    $self->department_id( __decide_department_id( document_id => $self->parent_id() ) );

    my @o =  $self->descendants();
    foreach( @o ) {
        # only look at objects with the old_dept of the moved object.
        # descendants of a different dept. stay unchanged. (see comment above)
        if ($_->department_id == $old_dept) {
            $_->department_id( __decide_department_id( document_id => $_->parent_id() ) );
            $_->data_provider->updateObject( $_->data() );
        }
    }

    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() ) || 0;
    $self->position( $max_position + 1 );
    return $self->data_provider->updateObject( $self->data() );
}

##
# SYNOPSIS
#    $self->clone( %args );
#
# PARAMETER
#    $args{ User } ............. User ( used to find granted children )
#    $args{ scope_subtree } .... flag, 0 ... shallow copy ( only object, not its descendants )
#                                      1 ... full subtree copy ( object and all granted descendants )
#    $args{ _parent_id } ....... id of parent object ( should be undef, only used in recursive call )
#    $args{ _id_map } .......... hash ref with key=old object id, value=new object id
#                                ( should be undef, only used in recursive call )
#    $args{ _ref_object_ids }... array ref with all cloned objects that have references to other objects
#                                ( should be undef, only used in recursive call )
#
# RETURNS
#    undef on error, 1 on success
#
# DESCRIPTION
#    creates a copy of the object ( clone has same parent as orginal ).
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

    my $parent_id = delete $args{ _parent_id };
    my $id_map = delete $args{ _id_map } || {};
    my $ref_object_ids = delete $args{ _ref_object_ids } || [];

    # create a copy of object data
    my %clonedata = $self->data();

    # id and document_id will be created new, path is not used
    delete $clonedata{ id };
    delete $clonedata{ document_id };
    delete $clonedata{ path };

    if( defined $parent_id ) {
        $clonedata{ parent_id } = $parent_id;
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
    $id_map->{ $self->document_id } = $clone->document_id;

    # check if this object need later fixup of referenced object ids
    my $objecttype = $clone->object_type;
    if ( $objecttype->name() eq "DepartmentRoot" or $objecttype->name() eq "SiteRoot" ) {
        push @$ref_object_ids, $clone->document_id;
    }
    else {
        my $id_name;
        foreach $id_name ( @Reference_Id_Names ) {
            if( defined $clone->{ $id_name } ) {
                push @$ref_object_ids, $clone->document_id;
                last;
            }
        }
    }

    if( defined $parent_id ) {
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
        # clone all granted children
        my @children = $self->children_granted( User => $user );
        my $child;
        foreach $child ( @children ) {
            return unless $child->clone( User => $user, scope_subtree => 1,
                                         _parent_id => $clone_id, _id_map => $id_map, _ref_object_ids => $ref_object_ids );
        }

        # check if we are back at top level of recursion
        if( not defined $parent_id ) {
            # fixup referenced object ids in all cloned objects that have reference ids
            $self->__fix_clone_reference( User => $user, _id_map => $id_map, _ref_object_ids => $ref_object_ids );
        }
    }

    return 1;
}

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
#    $object->attribute( %attrhash );
#
# PARAMETER
#    %attrhash: the attribute hash
#
# RETURNS
#    1, undef
#
# DESCRIPTION
#    attributes are stored in ";" separated key=value pairs in the attributes column
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
        $text = join( ';', map { $_ . "=" . $attributes{$_} } keys(%attributes) );
    }
    else {
        $text = join( ';', map { $_ . "=" . $attr{$_} } keys(%attr) );
    }
    return 1 if $self->attributes( $text );
}

sub attribute_by_key {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $key  = shift;
    my $text = $self->attributes();

    if ( defined $text and length $text ) {
        my %attributes = ( $text =~ /([^;\=]+)\=([^\;]+)/g );
        return $attributes{$key};
    }
}

##################################################################
# User-priv related methods
##################################################################

sub grant_user_privileges {
    my $self = shift;
    my %args = @_;
    my $privilege_mask = $args{privmask} || $args{privilege_mask};
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

# accepts a User object
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

# the application layer decides whether or not an object may be unlocked
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

sub locked {
   my $self = shift;
   if ( $self->locked_by_id() and $self->locked_time() ) {
       return 1;
   }
   return undef;
}

sub publish {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    $self->published( 1 );
    $self->last_published_by_id( $user->id() );
    $self->last_published_by_firstname( $user->firstname() );
    $self->last_published_by_middlename( $user->middlename() );
    $self->last_published_by_lastname( $user->lastname() );
    $self->last_publication_timestamp( $self->data_provider->db_now() );
    return $self->data_provider->updateObject( $self->data() );
}

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

sub object_type {
    my $self = shift;
    return $self->{ObjectType} if defined $self->{ObjectType};
    return undef unless $self->object_type_id();
    my $ot = XIMS::ObjectType->new( id => $self->object_type_id() );
    $self->{ObjectType} = $ot;
    return $ot;
}


sub data_format {
    my $self = shift;
    return $self->{DataFormat} if defined $self->{DataFormat};
    return undef unless $self->data_format_id() ;
    my $df = XIMS::DataFormat->new( id => $self->data_format_id() );
    $self->{DataFormat} = $df;
    return $df;
}

sub language {
    my $self = shift;
    return $self->{Language} if defined $self->{Language};
    return undef unless $self->language_id();
    my $lang = XIMS::Language->new( id => $self->language_id );
    $self->{Language} = $lang;
    return $lang;
}

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

sub locker {
    my $self = shift;
    return $self->{Locker} if defined $self->{Locker};
    return undef unless $self->locked();
    my $locker = XIMS::User->new( id => $self->locked_by_id );
    $self->{Locker} = $locker;
    return $locker;
}

sub location_path {
    my $self = shift;
    return $self->data_provider->location_path( $self );
}

sub location_path_relative {
    my $self = shift;
    return $self->data_provider->location_path_relative( $self );
}

###
#
# Helpers
#
###

##
#
# SYNOPSIS
#    $object->balanced_string( $CDATAstring, [$params] )
#
# PARAMETERS
#    $CDATAstring : input string
#    @args        :  hash
#       recognized keys: nochunk     : if set, $CDATAstring is assumed to be a document with a root-element
#                                      and will be parsed with parse_string() instead of the default parse_xml_chunk()
#                                      useful for importing
#                        verbose_msg : if set, XML::LibXML'S error string instead of undef is returned on parse-error
#
# RETURN
#    $retval : 1 if wellformed, undef or error string otherwise
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

    my $retval      = undef; # return value

    if ( length $CDATAstring ) {
        my $parser = XML::LibXML->new();
        if ( exists $args{nochunk} ) {
            eval { $parser->parse_string( $CDATAstring ) };
            if ( $@ ) {
                XIMS::Debug( 2, "string not wellformed" );
                XIMS::Debug( 6, "LibXML returned $@" );
                $@ =~ s/at \/.*$//;
                $retval = $@ if exists $args{verbose_msg};
            }
            else {
                $retval = 1;
            }
        }
        else {
            my $encoding;
            $encoding = $args{encoding} if defined $args{encoding};
            $encoding ||= XIMS::DBENCODING() if defined XIMS::DBENCODING();
            $encoding ||= 'UTF-8';
            my $doc; # as long as parse_xml_chunk does not fill $@ on error, we have to use $doc to test for success :/
            eval { $doc = $parser->parse_xml_chunk( $CDATAstring, $encoding ) };
            if ( !$doc or $@ ) {
                XIMS::Debug( 2, "string not wellbalanced" );
                XIMS::Debug( 6, "LibXML returned $@" );
                $@ =~ s/at \/.*$//;
                $retval = $@  if exists $args{verbose_msg};
            }
            else {
                $retval = 1;
            }
        }
    }

    return $retval;
}


##
#
# SYNOPSIS
#    $object->balance_string( $CDATAstring, [$params] );
#
# PARAMETERS
#    $CDATAstring : input string
#    %args        :  hash
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
        print $tmp_fh $CDATAstring;
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
        $CDATAstring = XIMS::DBENCODING() ? XML::LibXML::encodeToUTF8(XIMS::DBENCODING(), $CDATAstring) : $CDATAstring;
        my $doc;
        eval {
            $doc = $parser->parse_html_string( $CDATAstring );
        };
        if ( $@ ) {
            XIMS::Debug( 2, "LibXML could not parse string either: $@" );
            return undef;
        }
        else {
            $wbCDATAstring = XIMS::DBENCODING() ? XML::LibXML::decodeFromUTF8(XIMS::DBENCODING(), $doc->toString()) : $doc->toString();
        }
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
        my $df_id = $self->{data_format_id} || $self->{'content.data_format_id'};
        $df = XIMS::DataFormat->new( id => $df_id );
        $self->{DataFormat} = $df;
    }
    # pepl: departmentroot portlet info is stored in its body
    # return undef if $df->name() eq 'Container';
    return 'binfile' if ( $df->mime_type and $df->mime_type =~ /^(application|image)\//i and $df->mime_type !~ /container/i );
    return 'body';
}

1;
