# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SimpleDBItem;

use strict;
use base qw( XIMS::Object );
use XIMS::DataFormat;
use XIMS::SimpleDBMember;
use XIMS::SimpleDBMemberProperty;
use XIMS::SimpleDBMemberPropertyValue;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $item = XIMS::SimpleDBItem->new( [ %args ] )
#
# PARAMETER
#    %args                  (optional) :  Takes the same arguments as its super class XIMS::Object
#
# RETURNS
#    $item    : instance of XIMS::SimpleDBMemberItem
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::SimpleDBMemberItem for object creation.
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
#    my $id = $item->create( [ %args ] );
#
# PARAMETER
#    $args{ User }    (optional) :  XIMS::User instance. If $args{User} is not given, the user has to be set at object instantiation. (Example XIMS::Object->new( User => $user, %args ) )
#
# RETURNS
#    $id    : Content id of newly created object
#
# DESCRIPTION
#    Returns the content id of the newly created object, undef on failure. $args{User}, or, if that is not given, $object->User() will be used to set last modifier, creator, and owner metadata.
#    Sets the values of the mapped SimpleDBMemberProperties where part_of_title is set to 1 as object title.
#
sub create {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $id;
    if ( $id = $self->SUPER::create( @_ ) ) {
        $self->update( no_modder => 1 );
        return $id;
    }
}


##
#
# SYNOPSIS
#    my @rowcount = $item->update( [ %args ] );
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
#    Sets the values of the mapped SimpleDBMemberProperties where part_of_title is set to 1 as object title.
#
sub update {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $member = $self->member();
    if ( defined $member ) {
        my @title_props = $self->property_list( part_of_title => 1 );
        my @property_ids = map { $_->id() } @title_props;
        my @unsorted_data = $self->data_provider->getSimpleDBMemberPropertyValue( member_id => $member->id(), property_id => \@property_ids, properties => [ qw( value property_id ) ] );

        # Prepare to sort property values by property position
        my %data = map { $_->{'simpledbmemberpropertyvalue.property_id'} => $_->{'simpledbmemberpropertyvalue.value'} } @unsorted_data;
        my @sorted_values;
        foreach my $prop ( sort { $a->position() <=> $b->position() } @title_props ) {
            push (@sorted_values, $data{$prop->id()});
        }
        
        $self->title( join(', ', @sorted_values) );
    }

    return $self->SUPER::update( @_ );
}

##
#
# SYNOPSIS
#    my @property_list = $item->property_list( [ %args ] );
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
#    Fetch mapped properties assigned to the SimpleDB where $item is part of
#
sub property_list {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my $simpledb = $self->parent();
    bless $simpledb, 'XIMS::SimpleDB'; # parent isa XIMS::Object
    return $simpledb->mapped_member_properties( @_ );
}

##
#
# SYNOPSIS
#    my @property_values = $item->property_values();
#
# PARAMETER
#    none
#
# RETURNS
#    @property_values    : Array of XIMS::SimpleDBMemberPropertyValue instances
#
# DESCRIPTION
#    Fetch property values for the current $item
#
sub property_values {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %args = @_;

    my $member = $self->member();
    my $member_id;
    return () unless ( defined $member and $member_id = $member->id );

    $args{member_id} = $member_id;
    $args{properties} = [ qw( property_id value ) ];

    my @data = $self->data_provider->getSimpleDBMemberPropertyValue( %args );
    my @out = map { XIMS::SimpleDBMemberPropertyValue->new->data( %{$_} ) } @data;
    return @out;
}

sub content_field {
    return 'binfile';
}

##
#
# SYNOPSIS
#    my $member = $item->member( [ $member ] );
#
# PARAMETER
#    $member                 (optional) :
#
# RETURNS
#    $member    : instance of XIMS::SimpleDBMember
#
# DESCRIPTION
#    Helper method to fetch the XIMS::SimpleDBMember entry for the current object
#
sub member {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $member = shift;

    if ( defined $member and $member->isa( 'XIMS::SimpleDBMember' ) ) {
        $self->{member} = $member;
        return $member;
    }
    else {
        return $self->{member} if defined $self->{member};
        $member = XIMS::SimpleDBMember->new( document_id => $self->document_id() );
        if ( defined $member ) {
            $self->{member} = $member;
            return $member;
        }
        else {
            return undef;
        }
    }
}

1;
