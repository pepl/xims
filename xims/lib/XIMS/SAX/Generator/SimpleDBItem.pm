# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::SimpleDBItem;

use strict;
use warnings;

#use Data::Dumper;
use base qw( XIMS::SAX::Generator::Content );

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

    my $simpledb = $ctxt->object->parent();
    bless $simpledb, 'XIMS::SimpleDB'; # parent isa XIMS::Object

    my %args = ();
    # Filter out member properties with gopublic==1 if the user comes in through gopublic
    $args{gopublic} = 1 if (defined $ctxt->apache()->dir_config('ximsPublicUserName') or $ctxt->session->user->id() == XIMS::PUBLICUSERID());
    my @property_list = $simpledb->mapped_member_properties( %args );
    $doc_data->{member_properties} = { member_property => \@property_list };

    %args = ();
    if ( defined $ctxt->apache()->dir_config('ximsPublicUserName') or $ctxt->session->user->id() == XIMS::PUBLICUSERID() ) {
        my @property_ids = map { $_->{id} } @property_list;
        $args{property_id} = \@property_ids;
    }
    my @property_values = $ctxt->object->property_values( %args );
    $doc_data->{context}->{object}->{member_values} = { member_value => \@property_values };


    return $doc_data;
}

sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my %opts = $self->SUPER::get_config();
    $opts{attrmap}->{member_property} = 'id';
    $opts{attrmap}->{member_value} = 'id';

    return %opts;
}


1;
