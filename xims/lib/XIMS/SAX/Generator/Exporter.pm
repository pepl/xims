# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::Exporter;

use strict;
use vars qw(@ISA);
# this package could be a subclass of XIMS::SAX::Generator::Content <- think of it
@ISA = qw(XIMS::SAX::Generator XML::Generator::PerlData);

use Data::Dumper;
use XIMS::SAX::Generator;
use XML::Generator::PerlData;
use XIMS::DataProvider;
use XML::Filter::CharacterChunk;

##
#
# SYNOPSIS
#    $generator->prepare( $ctxt );
#
# PARAMETER
#    $ctxt : the appcontext object
#
# RETURNS
#    $doc_data : hash ref to be given to be mangled by XML::Generator::PerlData
#
# DESCRIPTION
#    
#
sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %object_types = ();
    my %data_formats = ();

    $self->{FilterList} = [ XML::Filter::CharacterChunk->new(Encoding => "ISO-8859-1", TagName=>[qw(body abstract)]) ];

    my $doc_data = { context => {} };

    $doc_data->{context}->{object} = {$ctxt->object->data()};

    $object_types{$ctxt->object->object_type_id()} = 1;
    $data_formats{$ctxt->object->data_format_id()} = 1;

    if ( $ctxt->properties->content->childrenbybodyfilter ) {
        $doc_data->{context}->{object}->{children} = $ctxt->object->body();
        delete $doc_data->{context}->{object}->{body};
    }
    else {
        $self->_set_children( $ctxt, $doc_data, \%object_types, \%data_formats );
    }

    $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types, \%data_formats );

    return $doc_data;
}


##
#
# SYNOPSIS
#    $generator->parse( $ctxt );
#
# PARAMETER
#    $ctxt : the appcontext object
#
# RETURNS
#    the result of the last handler after parsing
#
# DESCRIPTION
#    Used privately by XIMS::SAX to kick off the SAX event stream.
#
sub parse {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %opts = (@_, $self->get_config);
    $self->parse_start( %opts );

    $self->parse_chunk( $ctxt );

    return $self->parse_end;
}


##
#
# SYNOPSIS
#    $self->get_config();
#
# PARAMETER
#    none
#
# RETURNS
#    %opts : a plain HASH containing the PerlData parse options.
#
# DESCRIPTION
#    used internally to retrieve the XML::Generator::PerlData options for this class.
#
sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # The number of options here should become less and less as time goes on
    # and the API stablizes a bit.
    my %opts = (
                keymap  => { '*' => \&XIMS::SAX::Generator::elementname_fixer },
                attrmap => {object      => ['id', 'document_id', 'parent_id', 'level'],
                            data_format => 'id',
                            user        => 'id',
                            session     => 'id',
                            object_type => 'id' },
                skipelements => ['username', 'salt', 'objtype', 'properties', 'password'],
               );
    return %opts;
}


##
#
# SYNOPSIS
#    $generator->get_filters();
#
# PARAMETER
#    none
#
# RETURNS
#    @filters : an @array of Filter class names
#
# DESCRIPTION
#    Used internally by XIMS::SAX to allow this class to set
#    additional SAX Filters in the filter chain
#
sub get_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @filters =  $self->SUPER::get_filters();

    push @filters, @{$self->{FilterList}};

    return @filters;
}


# helper function to fetch the children.
sub _set_children {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    my $object = $ctxt->object();

    my %childrenargs = ( published => 1 ); # only get published children
    my @object_type_ids;
    if ( $ctxt->properties->content->getchildren->objecttypes and scalar @{$ctxt->properties->content->getchildren->objecttypes} > 0 ) {
        my $ot;
        foreach my $name ( @{$ctxt->properties->content->getchildren->objecttypes} ) {
            $ot = XIMS::ObjectType->new( name => $name );
            push(@object_type_ids, $ot->id()) if defined $ot;
        }
        $childrenargs{object_type_id} = \@object_type_ids;
    }

    my @children = $object->children_granted( %childrenargs );
    if ( scalar( @children ) > 0 ) {
        foreach my $child ( @children ) {
            # remember the seen objecttypes
            $object_types->{$child->object_type_id()} = 1;
            $data_formats->{$child->data_format_id()} = 1;
        }
    }

    $doc_data->{context}->{object}->{children} = {object => \@children};
}

# helper function to fetch the used dataformats and object types
sub _set_formats_and_types {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my ( $ctxt, $doc_data, $object_types, $data_formats ) = @_;

    my $used_types;
    my $used_formats;
    @{$used_types}   = grep { exists $object_types->{$_->id()} } $ctxt->data_provider->object_types() ;
    @{$used_formats} = grep { exists $data_formats->{$_->id()} } $ctxt->data_provider->data_formats() ;

    $doc_data->{object_types} = {object_type => $used_types};
    $doc_data->{data_formats} = {data_format => $used_formats};
}

1;
