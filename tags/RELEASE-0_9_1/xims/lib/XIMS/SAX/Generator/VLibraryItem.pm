# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::VLibraryItem;

use strict;
use vars qw(@ISA);
@ISA = qw(XIMS::SAX::Generator::Content);

#use Data::Dumper;
use XIMS::SAX::Generator::Content;

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

    my $doc_data = $self->SUPER::prepare( $ctxt );

    my @authors = $ctxt->object->vleauthors();
    $doc_data->{context}->{object}->{authorgroup} = { author => \@authors };

    my @keywords = $ctxt->object->vlekeywords();
    $doc_data->{context}->{object}->{keywordset} = { keyword => \@keywords };

    my @subjects = $ctxt->object->vlesubjects();
    $doc_data->{context}->{object}->{subjectset} = { subject => \@subjects };

    my @publications = $ctxt->object->vlepublications();
    $doc_data->{context}->{object}->{publicationset} = { publication => \@publications };

    my $meta = $ctxt->object->vlemeta();
    $doc_data->{context}->{object}->{meta} = $meta;

    my @vlsubjects = $ctxt->object->vlsubjects();
    $doc_data->{context}->{vlsubjects} = { subject => \@vlsubjects } if scalar @vlsubjects;

    my @vlkeywords = $ctxt->object->vlkeywords();
    $doc_data->{context}->{vlkeywords} = { keyword => \@vlkeywords } if scalar @vlkeywords;

    return $doc_data;
}

1;
