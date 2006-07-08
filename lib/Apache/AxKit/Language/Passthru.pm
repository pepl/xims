# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: godav.pm 1483 2006-04-23 21:46:59Z pepl $
package Apache::AxKit::Language::Passthru;

use strict;
use Apache;
use base qw( Apache::AxKit::Language );

our $VERSION = 1.0;

sub stylesheet_exists () { 0; }

sub get_mtime {
    return 3000; # TODO: sane value
}

sub handler {
    my $self = shift;
    my ($r, $xml, $style, $last_in_chain) = @_;

    # actually fetch the  
    # DOM and store it for later AxKit handlers
    $r->pnotes('dom_tree', $xml->get_dom());
    
    return Apache::Constants::OK;
}



1;
