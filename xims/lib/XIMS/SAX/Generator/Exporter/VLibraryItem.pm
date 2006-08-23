# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: VLibraryItem.pm 1549 2006-08-04 11:55:41Z jokar $
package XIMS::SAX::Generator::Exporter::VLibraryItem;

use strict;
use base qw(XIMS::SAX::Generator::Exporter XIMS::SAX::Generator::VLibraryItem);

our ($VERSION) = ( q$Revision: 1549 $ =~ /\s+(\d+)\s*$/ );

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
    
    return $doc_data;
}

1;
