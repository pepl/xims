# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::DataCollector;

#
# This is a basic SAX Filter that provides some functions that should
# make it easier to write extensions that collect data from various
# positions (such as search or portlets)
#

use strict;
use base qw( XML::Filter::GenericChunk );
use XML::Generator::PerlData;
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::SAX::Filter::DataCollector->new();
#
# PARAMETER
#    ?
#
# RETURNS
#    $self : XIMS::SAX::Filter::DataCollector instance
#
# DESCRIPTION
#    Constructor
#
sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    $self->{Columns}      ||= [];
    $self->{PreserveData} ||= 0;

    return $self;
}

##
#
# SYNOPSIS
#    $filter->preserve_data($boolean);
#
# PARAMETER
#    $boolean
#
# RETURNS
#    $self->{PreserveData}
#
# DESCRIPTION
#    sometimes it is nessecary to keep the collected data in the SAX
#    chain. this function sets (or reads) a flag, that toggels the
#    filters behaviour. If preserve_data is TRUE (1), the data will be
#    still available as the character data it was originally collected.
#
sub preserve_data {
    my $self = shift;
    $self->{PreserveData} = shift if scalar @_;
    $self->{PreserveData} ||= 0;

    return $self->{PreserveData};
}

##
#
# SYNOPSIS
#    $filter->get_data_fragment()
#
# PARAMETER
#    none
#
# RETURNS
#    $self->{Fragment}
#
# DESCRIPTION
#    get_data_fragment() overloads the version provided by
#    XML::SAX::Filter::GenericChunk. Since XML::SAX::Filter::GenericChunk
#    will forget about the fragment once it's parsed, we have to cache
#    the fragment for multiple usage.
#
sub get_data_fragment {
    my $self = shift;
    unless ( defined $self->{Fragment} ) {
        my $fragment;
        eval { $fragment = $self->SUPER::get_data_fragment(); };
        if ($@) {
            XIMS::Debug( 6, "data is not a fragment" . $@ );
            return;
        }
        $self->{Fragment} = $fragment;
    }
    return $self->{Fragment};
}

##
#
# SYNOPSIS
#    $filter->get_content()
#
# PARAMETER
#    none
#
# RETURNS
#    $self->{Content}
#
# DESCRIPTION
#    Accessor for the "content" node.
#
sub get_content {
    my $self = shift;
    unless ( defined $self->{Content} ) {
        my ($content)
            = grep { $_->nodeName eq "content" }
            $self->get_data_fragment->childNodes;
        $self->{Content} = $content;
    }
    return $self->{Content};
}

##
#
# SYNOPSIS
#    $filter->push_listobject( $object | @object );
#
# PARAMETER
#    $object, @object
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    this function will push a certain object or object list to the list
#    of objects that will be processed.
#
sub push_listobject {
    my $self = shift;

    $self->{ObjectList} = [] unless defined $self->{ObjectList};
    push @{ $self->{ObjectList} }, @_;

    return;
}

##
#
# SYNOPSIS
#    $filter->end_element()
#
# PARAMETER
#    $data
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    none yet
#
sub end_element {
    my $self = shift;
    my $data = shift;

    if ( $self->is_tag() ) {
        XIMS::Debug( 4, "is inside tag!" );
        if ( $self->preserve_data ) {
            XIMS::Debug( 6, "send data" );
            $self->{Handler}->characters( { Data => $self->get_data() } );
            $self->SUPER::end_element($data);
            $self->start_element($data);
        }
        XIMS::Debug( 6, "found data: " . $self->get_data() );
        XIMS::Debug( 6, "handle columns" );
        $self->_handle_columns();

        XIMS::Debug( 6, "handle data" );
        $self->handle_data();

        XIMS::Debug( 6, "end element" );
    }

    $self->SUPER::end_element($data);

    return;
}

##
#
# SYNOPSIS
#    $filter->characters( $data );
#
# PARAMETER
#    $data :
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    none yet
#
sub characters {
    my $self = shift;
    my $data = shift;

    if ( $self->is_tag() && defined $data->{Data} ) {
        $self->add_data( $data->{Data} );
    }
    else {
        $self->SUPER::characters($data);
    }

    return;
}

##
#
# SYNOPSIS
#    $filter->handle_data()
#
# PARAMETER
#    none
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    has to be overloaded (build the object list!)
#
sub handle_data {
    my $self = shift;

    if ( defined $self->{ObjectList} ) {
        my $generator
            = XML::Generator::PerlData->new( Handler => $self->{Handler} );

        my %keys = ();
        map { $keys{$_} = lc($_) } keys %{ $self->{ObjectList}->[0] };

        # to be conform with the schema
        $generator->keymap( \%keys );
        $generator->attrmap(
            { object => [ 'id', 'document_id', 'parent_id', 'level' ] } );
        $generator->parse_chunk( { object => $self->{ObjectList} } );
    }

    return;
}

##
#
# SYNOPSIS
#    $self->_handle_columns()
#
# PARAMETER
#    none
#
# RETURNS
#    nothing
#
# DESCRIPTION
#    This helper function will initialize the column list provided to the
#    DataProvider. If there [...???]
#
sub _handle_columns {
    my $self = shift;

    unless ( scalar @{ $self->{Columns} } ) {
        my $fragment = $self->get_data_fragment();
        return unless defined $fragment;
        $self->{Fragment} = $fragment;

        # filter the columns
        my ($cols)
            = grep { $_->nodeName() eq "content" } $fragment->childNodes();
        if ( not defined $cols ) {
            XIMS::Debug( 6, "content not defined" );
            my $filter
                = grep { $_->nodeName() eq "filter" } $fragment->childNodes();
            unless ( defined $filter ) {
                my @cols = grep { $_->nodeName() eq "column" }
                    $fragment->childNodes();
                $self->{Columns} = [ map { $_->getAttribute("name") }
                        grep { $_->nodeType == XML_ELEMENT_NODE } @cols ];
            }
        }
        else {
            my @cols = $cols->getChildrenByTagName("column");
            $self->{Columns} = [ map { $_->getAttribute("name") }
                    grep { $_->nodeType == XML_ELEMENT_NODE } @cols ];
            XIMS::Debug( 6, join( ",", @{ $self->{Columns} } ) );
        }
    }

    return;
}

1;
