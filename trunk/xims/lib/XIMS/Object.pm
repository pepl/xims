# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::Object;

use strict;
use warnings;
no warnings 'redefine';

use vars qw($VERSION @ISA @Fields @Default_Properties);
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r; };

use XIMS;
use XIMS::ObjectType;
use XIMS::DataFormat;
use XIMS::User;
use XIMS::AbstractClass;
@ISA = qw( XIMS::AbstractClass );

use HTML::Entities qw(decode_entities); # for abstract()
use XML::LibXML; # for balanced_string(), balance_string()
use IO::File; # for balanced_string()
use XIMS::User;
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

sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    my $self = bless {}, $class;
    $self->{User} = delete $args{User} if defined $args{User};
    my $real_object;
    my ( $package, $file, $line ) = caller(1);
    #warn "Object init called by $package line $line, passed " . Dumper( \%args ) . "\n";

    if ( scalar( keys(%args)) > 0 ) {
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
            $self->data( %args );
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
# object (parent, children, descendents, etc.)
##################################################################

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

    my @children = $self->__get_granted_objects( doc_ids => \@child_candidate_docids, User => $user ) ;

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
                                                             properties => \@Default_Properties );

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

    my @descendants = $self->__get_granted_objects( doc_ids => \@candidate_doc_ids, User => $user ) ;
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

# "static"-method
#
sub __decide_department_id {
    my %args = @_;
    my $object= XIMS::Object->new( id => $args{id} );
    if ( ($object->object_type->name() eq 'DepartmentRoot') or ($object->object_type->name() eq 'SiteRoot') ) {
            return $object->id();
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

    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() );
    $self->position( $max_position + 1 );

    $self->department_id( __decide_department_id( id => $self->parent_id() ) );

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

    $self->last_modified_by_id( $user->id() );
    $self->last_modified_by_firstname( $user->firstname() );
    $self->last_modified_by_middlename( $user->middlename() );
    $self->last_modified_by_lastname( $user->lastname() );
    $self->last_modification_timestamp( $self->data_provider->db_now() );

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
    my $old_dept = __decide_department_id( id => $self->id() );

    my $parent_id = delete $args{target};
    return undef unless $parent_id;

    $self->parent_id( $parent_id );

    $self->department_id( __decide_department_id( id => $self->parent_id() ) );

    my @o =  $self->descendants();
    foreach( @o ) {
        # only look at objects with the old_dept of the moved object.
        # descendants of a different dept. stay unchanged. (see comment above)
        if ($_->department_id == $old_dept) {
            $_->department_id( __decide_department_id( id => $_->parent_id() ) );
            $_->data_provider->updateObject( $_->data() );
        }
    }

   # warn Dumper(\@o);

    my $max_position = $self->data_provider->max_position( parent_id => $self->parent_id() );
    $self->position( $max_position + 1 );
    return $self->data_provider->updateObject( $self->data() );
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

    if ( length $text ) {
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

    if ( length $text ) {
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
    return $self->data_provider->updateObject( $self->data() );
}

# ubu: should this require a User to check the locked_by_id?
sub unlock {
    my $self = shift;
    my %args = @_;
    my $user = delete $args{User} || $self->{User};
    $self->locked_by_id( undef );
    $self->locked_by_firstname( undef );
    $self->locked_by_middlename( undef );
    $self->locked_by_lastname( undef );
    $self->locked_time( undef );
    return $self->data_provider->updateObject( $self->data() );
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
    return $self->{Creator} if defined $self->{Creator};
    return undef unless $self->created_by_id();
    my $creator = XIMS::User->new( id => $self->created_by_id );
    $self->{Creator} = $creator;
    return $creator;
}

sub owner {
    my $self = shift;
    return $self->{Owner} if defined $self->{Owner};
    return undef unless $self->owned_by_id();
    my $owner = XIMS::User->new( id => $self->owned_by_id );
    $self->{Owner} = $owner;
    return $owner;
}

sub last_modifier {
    my $self = shift;
    return $self->{LastModifier} if defined $self->{LastModifier};
    return undef unless $self->last_modified_by_id();
    my $modder = XIMS::User->new( id => $self->last_modified_by_id );
    $self->{LastModifier} = $modder;
    return $modder;
}

sub last_publisher {
    my $self = shift;
    return $self->{LastPublisher} if defined $self->{LastPublisher};
    return undef unless $self->last_published_by_id();
    my $pubber = XIMS::User->new( id => $self->last_published_by_id );
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
            my $encoding = $args{encoding} || 'ISO-8859-1'; # hardcoded default encoding
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
    # because we assume that sth like HTML::Tidy will be available soon, the following paths
    # remain hardcoded
    my $tidy        = "/usr/local/bin/tidy";
    my $tidyOptions = " -config /usr/local/xims/conf/ximstidy.conf -quiet -f /dev/null";
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
        $CDATAstring = XML::LibXML::encodeToUTF8('ISO-8859-1', $CDATAstring );
        my $doc;
        eval {
            $doc = $parser->parse_html_string( $CDATAstring );
        };
        if ( $@ ) {
            XIMS::Debug( 2, "LibXML could not parse string either: $@" );
            return undef;
        }
        else {
            $wbCDATAstring = XML::LibXML::decodeFromUTF8('ISO-8859-1', $doc->toString());
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
    if ( defined( $self->{DataFormat} ) ) {
       $df = $self->{DataFormat};
    }
    else {
        my $df_id = $self->{data_format_id} || $self->{'content.data_format_id'};
        $df = XIMS::DataFormat->new( id => $df_id );
        $self->{DataFormat} = $df;
    }
    # pepl: departmentroot portlet info is stored in its body
    # return undef if $df->name() eq 'Container';
    return 'binfile' if ( $df->mime_type =~ /^(application|image)\//i and $df->mime_type !~ /container/i );
    return 'body';
}

1;
