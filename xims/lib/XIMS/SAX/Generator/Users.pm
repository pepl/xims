# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::Users;

use strict;
use base qw(XIMS::SAX::Generator XML::Generator::PerlData);

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

    $self->{FilterList} = [];

    my $doc_data = { context => {} };
    $doc_data->{context}->{session} = {$ctxt->session->data()};
    $doc_data->{context}->{session}->{user} = {$ctxt->session->user->data()};

    # add the user's system privs.
    $doc_data->{context}->{session}->{user}->{system_privileges} = {$ctxt->session->user->system_privileges()} if $ctxt->session->user->system_privs_mask() > 0;

    if ( $ctxt->objectlist() ) {
        $doc_data->{objectlist} = { object => $ctxt->objectlist() };
    }

    if ( $ctxt->bookmarklist() ) {
        $doc_data->{bookmarklist} = { bookmark => $ctxt->bookmarklist() };
    }

    if ( $ctxt->objecttypelist() ) {
        $doc_data->{objecttypelist} = { object_type => $ctxt->objecttypelist() };
    }

    if ( $ctxt->userlist() ) {
        # my @user_list = map{ $_->data() ) } @{$ctxt->userlist()};
        $doc_data->{userlist} = { user => $ctxt->userlist() };
    }

    if ( $ctxt->user() ) {
        $doc_data->{context}->{user} = $ctxt->user();
        $doc_data->{context}->{user}->{system_privileges} = {$ctxt->user->system_privileges()} if $ctxt->user->system_privs_mask() > 0;
    }

    return $doc_data;
}

##
#
# SYNOPSIS
#    $generator->parse( $ctxt );
#
# PARAMETER
#    $ctxt : the appcontext object
#
# RETURNS
#    the result of the last Handler after parsing
#
# DESCRIPTION
#    Used privately by XIMS::SAX to kick off the SAX event stream.
#
sub parse {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;
    my %opts = (@_, $self->get_config);

    $self->parse_start( %opts );

    #warn "about to process: " . Dumper( $ctxt );
    $self->parse_chunk( $ctxt );

    return $self->parse_end;
}

##
#
# SYNOPSIS
#    $generator->get_filters();
#
# PARAMETER
#    none
#
# RETURNS
#    @filters : an @array of Filter class names
#
# DESCRIPTION
#    Used internally by XIMS::SAX to allow this class to set
#    additional SAX Filters in the filter chain
#
sub get_filters {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my @filters =  $self->SUPER::get_filters();

    push @filters, @{$self->{FilterList}};

    return @filters;
}

1;
