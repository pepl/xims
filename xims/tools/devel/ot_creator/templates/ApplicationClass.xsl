<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >

<xsl:output method="text"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document"># Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
package XIMS::CGI::<xsl:value-of select="object_type_name"/>;

use strict;
use vars qw( $VERSION @ISA );
use <xsl:value-of select="a_isa"/>;

# version string (for makemaker, so don't touch!)
$VERSION = do { my @r = (q$Revision$ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@ISA = qw( <xsl:value-of select="a_isa"/> );

# (de)register events here
sub registerEvents {
    XIMS::Debug( 5, "called" );
    my $self = shift;
    $self->SUPER::registerEvents(
                                'create',
                                'edit',
                                'store',
                                'publish',
                                'publish_prompt',
                                'unpublish',
                                'obj_acllist',
                                'obj_aclgrant',
                                'obj_aclrevoke',
                                @_
                                );
}

#
# override or add event handlers here
#

1;
</xsl:template>
</xsl:stylesheet>