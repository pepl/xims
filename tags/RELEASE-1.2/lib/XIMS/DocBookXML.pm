# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::DocBookXML;

use strict;
use base qw( XIMS::Document );
use XIMS::DataFormat;
use XML::LibXML;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    my $docbookxml = XIMS::DocBookXML->new( [ %args ] )
#
# PARAMETER
#    %args        (optional) :  Takes the same arguments as its super class XIMS::Document
#
# RETURNS
#    $docbookxml    : instance of XIMS::DocBookXML
#
# DESCRIPTION
#    Fetches existing objects or creates a new instance of XIMS::DocBookXML for object creation.
#
sub new {
    my $proto = shift;
    my $class = ref( $proto ) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => 'DocBookXML' )->id() unless defined $args{data_format_id};
    }

    return $class->SUPER::new( %args );
}

##
#
# SYNOPSIS
#    my $docbookxml = $docbookxml->validate( [ %args ] );
#
# PARAMETER
#    %args    (optional)
#       recognized keys: public (optional) : Used to set a custom PUBLIC identifier for a
#                                            DocBook DTD. If not set, "-//OASIS//DTD DocBook XML V4.3//EN"
#                                            will be used.
#                        system (optional) : Used to set a custom SYSTEM identifier for a
#                                            DocBook DTD. If not set, "http://www.docbook.org/xml/4.3/docbookx.dtd"
#                                            will be used.
#                        string (optional) : An XML string to be validated. If not set $self->body() will be used for
#                                            validation
# RETURNS
#    True or false
#
# DESCRIPTION
#    Validates the XIMS::DocBookXML object against a DocBook DTD
#
sub validate {
    XIMS::Debug( 5, "called" );
    my $self        = shift;
    my %args        = @_;

    my $public = $args{public} || "-//OASIS//DTD DocBook XML V4.3//EN";
    my $system = $args{system} || "http://www.docbook.org/xml/4.3/docbookx.dtd";
    my $string = $args{string} || $self->body();

    # Because XIMS::DocBookXML object bodies are stored as chunk without an
    # XML declaration, we have to manually add an XML declaration with an
    # encoding attribute if XIMS::DBEncoding() is set.
    if ( XIMS::DBENCODING() and not $string =~ /^<\?xml/ ) {
        $string = '<?xml version="1.0" encoding="' . XIMS::DBENCODING() . '"?>' . $string;
    }

    my $dtd = XML::LibXML::Dtd->new( $public, $system );
    my $doc;
    eval {
        $doc = XML::LibXML->new->parse_string( $string );
    };
    if ( $@ ) {
        XIMS::Debug( 2, "string is not well-formed" );
        return undef;
    }

    eval {
        $doc->validate( $dtd )
    };
    if ( $@ ) {
        XIMS::Debug( 3, "string is not valid: $@" );
        return undef;
    }
    else {
        return 1;
    }
}

1;

