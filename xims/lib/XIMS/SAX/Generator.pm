# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
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
    XIMS::Debug( 4, "called" );
    XIMS::Debug( 6, "will return 'XIMS::SAX::Filter::Date'" );
    return ( "XIMS::SAX::Filter::Date" );
}


##
#
# SYNOPSIS
#
#
# PARAMETER
#
# RETURNS
#
# DESCRIPION
#    none yet
#
sub elementname_fixer {
    my $name = shift;
    $name =~ s/^-//;
    return lc( $name );
}

1;
