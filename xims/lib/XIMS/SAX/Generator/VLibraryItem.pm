# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::VLibraryItem;

use strict;
use base qw(XIMS::SAX::Generator::Content);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

# code shared between XIMS::SAX::Generator::VLibraryItem 
# and XIMS::SAX::Generator::Exporter::VLibraryItem  
sub _insert_vle_common {
    my ($self, $ctxt, $doc_data) = splice(@_, 0, 3);

    my @authors = $ctxt->object->vleauthors();
    $doc_data->{context}->{object}->{authorgroup} = { author => \@authors } if ( !($authors[0] eq undef ) );

    my @keywords = $ctxt->object->vlekeywords();
    $doc_data->{context}->{object}->{keywordset} = { keyword => \@keywords } if ( !($keywords[0] eq undef ) );

    my @subjects = $ctxt->object->vlesubjects();
    $doc_data->{context}->{object}->{subjectset} = { subject => \@subjects } if ( !($subjects[0] eq undef ) );

    my @publications = $ctxt->object->vlepublications();
    $doc_data->{context}->{object}->{publicationset} = { publication => \@publications };

    my $meta = $ctxt->object->vlemeta();
    $doc_data->{context}->{object}->{meta} = $meta;

}

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
  
    # The body won't be parsed by XML::Filter::CharacterChunk with the XML decl. Might be slightly hacky but its effective ;-)
    $doc_data->{context}->{object}->{body} =~ s/^<\?xml[^>]+>//;
  
    $self->_insert_vle_common($ctxt, $doc_data);
  
    if ( $ctxt->properties->application->style() =~ /^edit/) { 
    
        my @vlsubjects = $ctxt->object->vlsubjects();
        $doc_data->{context}->{vlsubjects} = { subject => \@vlsubjects } if scalar @vlsubjects;
    
        my @vlkeywords = $ctxt->object->vlkeywords();
        $doc_data->{context}->{vlkeywords} = { keyword => \@vlkeywords } if scalar @vlkeywords;
    
        my @vlauthors = $ctxt->object->vlauthors();
        $doc_data->{context}->{vlauthors} = { author => \@vlauthors } if scalar @vlauthors;
    }

    return $doc_data;
}
    
1;
