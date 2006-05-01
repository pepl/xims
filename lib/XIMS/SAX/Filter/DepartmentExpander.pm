# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::DepartmentExpander;

# departments usually contain more information than dumb
# folders. Since this information is stored within the department's
# body, it has to be expanded before it can be published.

use strict;
use base qw( XML::SAX::Base );
use XIMS::Portlet;
use XML::LibXML;
use XML::Generator::PerlData;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

sub end_element {
    my $self = shift;
    my $data = shift;
    $self->SUPER::end_element( $data );
    if ( defined $data->{LocalName} and $data->{LocalName} eq "context" ) {
        my $ol = {LocalName => "objectlist" };
        $ol->{NamespaceURI} = $data->{NamespaceURI};
        $ol->{Prefix} = $data->{Prefix};
        if ( defined $data->{Prefix} && length $data->{Prefix} ) {
            $ol->{Name} = $data->{Prefix} . ":" . $ol->{LocalName};
        }
        else {
            $ol->{Name} = $ol->{LocalName};
        }
        $self->SUPER::start_element( $ol );
        $self->handle_data;
        $self->SUPER::end_element( $ol );
    }
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
#
#    This is the heart of the filter. it writes a list of objects to
#    the SAX Pipeline
#
sub handle_data {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my %keys = ();
    my $fragment = $self->{Object}->body();
    my $parser = XML::LibXML->new;
    my $frag ;
    eval {
        $frag = $parser->parse_xml_chunk( $fragment );
    };
    unless ( defined $frag ) {
        XIMS::Debug( 3, "no valid body fragment found" );
        return ;
    }
    my $generator = XML::Generator::PerlData->new( Handler => $self->{Handler} );
    my @portlets = grep { $_->nodeType == XML_ELEMENT_NODE
                          and $_->nodeName eq "portlet" }
      $frag->childNodes;

    foreach my $p ( @portlets ) {
        my $oid = $p->string_value();
        next unless (defined $oid and $oid > 0);
        my $object = XIMS::Portlet->new( id => $oid, User => $self->{User}, marked_deleted => undef );

        if ( not defined $object ) {
            XIMS::Debug( 4, "portlet id could not be resolved, deleting" );
            # We workaround the portlet_ids not being in a relational structure here
            #
            # Instead of being stored in the body, the portlet assignments should probably
            # be stored in a table like
            # ci_object_relations ( id (pk), from (fk ci_documents.id), to (fk ci_documents.id) )
            #
            # Objects "related" to non-containers (like Documents for example) could still be stored
            # as children of the respective object.
            # From this, that table could also be called 'ci_deptroot_portlets'...
            #
            $frag->removeChild( $p );
            my $newbody = $frag->toString();
            $newbody ||= ' '; # needs length > 0 (maybe change that in DP?)
            $self->{Object}->body( $newbody );
            $self->{Object}->update( User => $self->{User}, no_modder => 1 );
            next;
        }

        if ( $self->{Export} ) {
            next unless $object->published();
        }

        # expand the object's path
        my $path;
        if ( XIMS::RESOLVERELTOSITEROOTS() eq '1' ) {
            $path = $object->location_path_relative();
        }
        else {
            my $siteroot = $object->siteroot();
            my $siteroot_url;
            $siteroot_url = $object->siteroot->url() if $siteroot;
            if ( $siteroot_url =~ m#/# ) {
                $path .= $siteroot_url . $object->location_path_relative();
            }
            else {
               $path .= XIMS::PUBROOT_URL() . $object->location_path();
            }
        }

        $object = {$object->data()};
        $object->{location_path} = $path;
        $generator->parse_chunk( {object => $object } );
    }
}
1;
