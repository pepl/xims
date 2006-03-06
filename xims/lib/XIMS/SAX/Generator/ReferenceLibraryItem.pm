# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::ReferenceLibraryItem;

use strict;
# use warnings;

our $VERSION;
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

use base qw(XIMS::SAX::Generator::Content);

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

    my $reference_library = $ctxt->object->parent();
    bless $reference_library, 'XIMS::ReferenceLibrary'; # parent isa XIMS::Object
    my @reference_types = $reference_library->reference_types( id => $ctxt->object->reference->reference_type_id );
    $doc_data->{reference_types} = { reference_type => \@reference_types };

    my @property_list = $ctxt->object->property_list();
    $doc_data->{reference_properties} = { reference_property => \@property_list };

    my @authors = $ctxt->object->vleauthors();
    $doc_data->{context}->{object}->{authorgroup} = { author => \@authors };

    my @editors = $ctxt->object->vleeditors();
    $doc_data->{context}->{object}->{editorgroup} = { author => \@editors };

    my $serial = $ctxt->object->vleserial();
    $doc_data->{context}->{object}->{serial} = $serial if defined $serial;

    my @property_values = $ctxt->object->property_values();
    $doc_data->{context}->{object}->{reference_values} = { reference_value => \@property_values };

    $doc_data->{context}->{object}->{reference_type_id} = $ctxt->object->reference->reference_type_id();

    my @vlauthors = $reference_library->vlauthors();
    $doc_data->{context}->{vlauthors} = { author => \@vlauthors } if scalar @vlauthors;

    my @vlserials = $reference_library->vlserials();
    $doc_data->{context}->{vlserials} = { serial => \@vlserials } if scalar @vlserials;


    return $doc_data;
}

sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my %opts = $self->SUPER::get_config();
    $opts{attrmap}->{reference_type} = 'id';
    $opts{attrmap}->{reference_property} = 'id';
    $opts{attrmap}->{reference_value} = 'id';
    $opts{attrmap}->{serial} = 'id';

    return %opts;
}


1;
