# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#$Id$
package XIMS::SAX::Generator;

use strict;
use XIMS;

#
# simple base class for XIMS Generator classes.  not much to see yet,
# really. mostly 'helper' functions.
#

##
#
# SYNOPSIS
#    $generator->prepare( $something );
#
# PARAMETER
#    $something
#
# RETURNS
#    $_[0] in scalar context, @_ otherwise
#
# DESCRIPION
#    none yet
#
sub prepare {
    my $self = shift;
    return wantarray ? @_ : $_[0];
}

##
#
# SYNOPSIS
#
#
# PARAMETER
#    none
#
# RETURNS
#    "XIMS::SAX::Filter::Date"
#
# DESCRIPTION
#    the date filter is always there!
#
sub get_filters {
    XIMS::Debug( 5, "called" );
    XIMS::Debug( 6, "will return 'XIMS::SAX::Filter::Date'" );
    return ( "XIMS::SAX::Filter::Date" );
}


##
#
# SYNOPSIS
#    $self->get_config();
#
# PARAMETER
#    none
#
# RETURNS
#    %opts : a plain HASH containing the PerlData parse options.
#
# DESCRIPTION
#    used internally to retrieve the XML::Generator::PerlData options for this class.
#
sub get_config {
    XIMS::Debug( 5, "called" );
    my $self = shift;

    # The number of options here should become less and less as time goes on
    # and the API stablizes a bit.

    my %opts = (
                attrmap => {object      => ['id', 'document_id', 'parent_id', 'level'],
                            data_format => 'id',
                            user        => 'id',
                            session     => 'id',
                            children    => 'totalobjects',
                            object_type => 'id' },
                skipelements => ['username', 'salt', 'objtype', 'properties', 'password', 'Provider','User'],
               );
    return %opts;
}


1;
