# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::SimpleDB;

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
    my %object_types = ();
    my %data_formats = ();

    $self->{FilterList} = [];

    my $doc_data = { context => {} };
    $doc_data->{context}->{session} = {$ctxt->session->data()};
    $doc_data->{context}->{session}->{user} = {$ctxt->session->user->data()};

    $doc_data->{context}->{object} = {$ctxt->object->data()};

    $self->_set_parents( $ctxt, $doc_data, \%object_types, \%data_formats );

    # Add the user's privs.
    my %userprivs = $ctxt->session->user->object_privileges( $ctxt->object() );
    $doc_data->{context}->{object}->{user_privileges} = {%userprivs} if ( grep { defined $_ } values %userprivs );

    if ( $ctxt->objectlist() ) {
        my ( $child_count, $children ) = @{$ctxt->objectlist()};
        if ( scalar( @$children ) > 0 ) {
            $doc_data->{context}->{object}->{children} = { object => $children };
            $doc_data->{context}->{object}->{children}->{totalobjects} = $child_count;
        }
    }

    # Add the list of member properties if the object already has been created.
    if ( $ctxt->object->isa('XIMS::SimpleDB') ) {
        my %args;
        # Filter out member properties with gopublic==1 if the user comes in through gopublic
        $args{gopublic} = 1 if defined $ctxt->apache()->dir_config('ximsPublicUserName');
        my @property_list = $ctxt->object->mapped_member_properties( %args );
        $doc_data->{member_properties} = { member_property => \@property_list };
    }

    # for ACL management
    if ( $ctxt->userlist() ) {
        # my @user_list = map{ $_->data() ) } @{$ctxt->userlist()};
        $doc_data->{userlist} = { user => $ctxt->userlist() };
    }

    # for ACL management
    if ( $ctxt->user() ) {
        $doc_data->{context}->{user} = $ctxt->user() ;
    }

    $object_types{$ctxt->object->object_type_id()} = 1;
    $data_formats{$ctxt->object->data_format_id()} = 1;

    $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types, \%data_formats);

    return $doc_data;
}

sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    my %opts = $self->SUPER::get_config();
    $opts{attrmap}->{member_property} = 'id';

    return %opts;
}

1;
