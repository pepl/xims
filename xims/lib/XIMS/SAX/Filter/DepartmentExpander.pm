# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::DepartmentExpander;

# departments usually contain more information than dumb
# folders. Since this information is stored within the department's
# body, it has to be expanded before it can be published.
use warnings;
use strict;
use vars qw( @ISA );

use XIMS::Object;

use XML::LibXML;
use XML::Generator::PerlData;
use XML::SAX::Base;
@ISA = qw(XML::SAX::Base);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

sub end_element {
    my $self = shift;
    my $data = shift;
    $self->SUPER::end_element( $data );
    if ( $data->{Name} eq "context" ) {
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
        XIMS::Debug( 2, "no fragment found!!!! " . $@ );
        return ;
    }
    my $generator = XML::Generator::PerlData->new( Handler => $self->{Handler} );
    my @portlets = grep { $_->nodeType == XML_ELEMENT_NODE
                          and $_->nodeName eq "portlet" }
      $frag->childNodes;
    foreach my $p ( @portlets ) {
        my $oid = $p->string_value();
        next unless (defined $oid and $oid > 0);
        my $object = XIMS::Object->new( id  => $oid, User => $self->{User} );

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
