# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::VLibrary;

use strict;
use base qw(XIMS::SAX::Generator::Content);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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

    # add the user's privs.
    my %userprivs = $ctxt->session->user->object_privileges( $ctxt->object() );
    $doc_data->{context}->{object}->{user_privileges} = {%userprivs} if ( grep { defined $_ } values %userprivs );

    if ( not $ctxt->parent() ) {
        if ( $ctxt->properties->application->style() eq "edit_subject" ) {
            $doc_data->{context}->{vlsubjectinfo} = { subject => $ctxt->object->vlsubjectinfo_granted() };
        } else {
            $doc_data->{context}->{vlsubjectinfo} = { subject => $ctxt->object->vlsubjectinfo_granted() };
        }
        if ( $ctxt->properties->application->style() eq "authors" ) {
            $doc_data->{context}->{vlauthorinfo} = { author => $ctxt->object->vlauthorinfo_granted() };
        }
        if ( $ctxt->properties->application->style() eq "publications" ) {
            $doc_data->{context}->{vlpublicationinfo} = { publication => $ctxt->object->vlpublicationinfo_granted() };
        }
        if ( $ctxt->properties->application->style() eq "keywords" ) {
            $doc_data->{context}->{vlkeywordinfo} = { keyword => $ctxt->object->vlkeywordinfo_granted() };
        }
    }

    if ( $ctxt->objectlist() ) {
        my @vlchildren = @{$ctxt->objectlist()};
        if ( scalar( @vlchildren ) > 0 ) {
            foreach my $child ( @vlchildren ) {
                bless $child, "XIMS::VLibraryItem";
                # added the users object privileges if he got one
                my %uprivs = $ctxt->session->user->object_privileges( $child );
                $child->{user_privileges} = {%uprivs} if ( grep { defined $_ } values %uprivs );

                # yet another superfluos db hit! this has to be changed!!!
                $child->{content_length} = $child->content_length();
                $child->{authorgroup} = { author => [$child->vleauthors()] };
                $child->{meta} = [$child->vlemeta()];
            }
            $doc_data->{context}->{object}->{children} = { object => \@vlchildren };
        }
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

    # Repositioning
    if ( defined $ctxt->properties->content->siblingscount() ) {
            $doc_data->{context}->{object}->{siblingscount} = $ctxt->properties->content->siblingscount();
    }

    my %object_types = ();
    my %data_formats = ();
    $object_types{$ctxt->object->object_type_id()} = 1;
    $data_formats{$ctxt->object->data_format_id()} = 1;

    $self->_set_formats_and_types( $ctxt, $doc_data, \%object_types, \%data_formats);

    return $doc_data;
}




1;
