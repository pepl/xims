# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Filter::Children;

#
# This is a SAX Filter. This will collect all children of a certain
# object and place them into the stream
#

use strict;
use base qw( XIMS::SAX::Filter::DataCollector );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

##
#
# SYNOPSIS
#    XIMS::SAX::Filter::DataCollector->new()
#
# PARAMETER
#    ?
#
# RETURNS
#    nothing (????)
#
# DESCRIPTION
#    none yet
#
sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->set_tagname( "children" );

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
#    none yet
#
sub handle_data {
    my $self = shift;
    my $cols =  $self->get_columns();

    my $provider = $self->get_provider();
    return unless defined $provider and defined $self->{Object};


    # fetch the objects
    my %param = ( -object => $self->{Object} );

    $param{-user}      = $self->get_user()    if defined $self->get_user();
    $param{-published} = $self->export()      if defined $self->export();

    $param{-level}     = $self->{Level}       if defined $self->{Level};
    $param{-objecttypes} = $self->{ObjectTypes} if defined $self->{ObjectTypes};

    my $objects = $provider->getChildObjects( %param );
    $self->push_listobject( @{$objects} ) if defined $objects;

    $self->SUPER::handle_data();

    return;
}

1;
