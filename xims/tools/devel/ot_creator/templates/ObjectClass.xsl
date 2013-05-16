<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
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

XIMS::<xsl:value-of select="object_type_name"/>.

=head1 VERSION

$Id$

=head1 SYNOPSIS

    use XIMS::<xsl:value-of select="object_type_name"/>;

=head1 DESCRIPTION

Write me.

=head1 SUBROUTINES/METHODS

=cut

package XIMS::<xsl:value-of select="object_type_name"/>;

use common::sense;
use parent qw( <xsl:value-of select="o_isa"/> );
use XIMS::DataFormat;

our ($VERSION) = ( q$Revision$ =~ /\s+(\d+)\s*$/ );


=head2 new()

=head3 Parameter
    $args{ User }                  (optional) :  XIMS::User instance
    $args{ path }                  (optional) :  Location path to a XIMS Object, For example: '/xims'
    $args{ $object_property_name } (optional) :  Object property like 'id', 'document_id', or 'title'.
                                                 To fetch existing objects either 'path', 'id' or 'document_id' has to be specified.
                                                 Multiple object properties can be specified in the %args hash.
                                                 For example: XIMS::<xsl:value-of select="object_type_name"/>->new( id => $id )

=head3 Returns
    $<xsl:value-of select="translate(object_type_name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>: Instance of XIMS::<xsl:value-of select="object_type_name"/>

=head3 Description
    Fetches existing objects or creates a new instance of XIMS::<xsl:value-of select="object_type_name"/> for object creation.

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my %args = @_;

    if ( not ( defined($args{path}) or defined($args{id}) or defined($args{document_id}) ) ) {
        $args{data_format_id} = XIMS::DataFormat->new( name => '<xsl:value-of select="data_format_name"/>' )->id() unless defined $args{data_format_id};
    }

    return $class-&gt;SUPER::new( %args );
}

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
