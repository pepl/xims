<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date">

<xsl:output method="text"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/document">

=head1 NAME

XIMS::CGI::<xsl:value-of select="object_type_name"/>.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::CGI::<xsl:value-of select="object_type_name"/>;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut


package XIMS::CGI::<xsl:value-of select="object_type_name"/>;

use common::sense;
use parent qw( <xsl:value-of select="a_isa"/> );

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );

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

__END__

=head1 DIAGNOSTICS

Look at the F&lt;error_log&gt; file for messages.

=head1 CONFIGURATION AND ENVIRONMENT

Write me.

=head1 BUGS AND LIMITATION

Grep the source file for: XXX, TODO, ITS_A_HACK_ALARM.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2002-<xsl:value-of select="date:year()"/> The XIMS Project.

See the file F&lt;LICENSE&gt; for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   cperl-close-paren-offset: -4
#   cperl-continued-statement-offset: 4
#   cperl-indent-level: 4
#   cperl-indent-parens-as-block: t
#   cperl-merge-trailing-else: nil
#   cperl-tab-always-indent: t
#   fill-column: 78
#   indent-tabs-mode: nil
# End:
# ex: set ts=4 sr sw=4 tw=78 ft=perl et :

</xsl:template>
</xsl:stylesheet>
