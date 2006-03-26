# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::SAX::Generator::User;

use strict;
use base qw(XIMS::SAX::Generator::Users);

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

sub prepare {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    my $ctxt = shift;

    my $doc_data = $self->SUPER::prepare( $ctxt );
    if ( $ctxt->userobjectlist() ) {
        $doc_data->{userobjectlist}->{objectlist} = { object => $ctxt->userobjectlist() };
    }

    # add the user's bookmarks.
    my @bookmarks = $ctxt->session->user->bookmarks();
    $doc_data->{context}->{session}->{user}->{bookmarks} = { bookmark => \@bookmarks };

    my @object_types = $ctxt->data_provider->object_types();
    my @data_formats = $ctxt->data_provider->data_formats();
    $doc_data->{object_types} = {object_type => \@object_types};
    $doc_data->{data_formats} = {data_format => \@data_formats};

    return $doc_data;
}

1;
