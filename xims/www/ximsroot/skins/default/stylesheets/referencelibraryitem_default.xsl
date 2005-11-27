<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td bgcolor="#ffffff">
                        <span id="body">
                            <h1><xsl:value-of select="title"/> (<xsl:value-of select="/document/reference_types/reference_type/name"/>)</h1>
                                <div id="abstract">
                                    <xsl:apply-templates select="abstract"/>
                                </div>
                                <table>
                                    <xsl:apply-templates select="reference_values/reference_value"/>
                                    <tr><td colspan="2">
                                        <div>
                                            <xsl:value-of select="$i18n_vlib/l/authors"/>:<br/>
                                            <xsl:apply-templates select="authorgroup/author">
                                                <xsl:sort select="position" order="ascending"/>
                                            </xsl:apply-templates>
                                        </div>
                                    </td></tr>

                                    <tr><td colspan="2">
                                        <div>
                                            <xsl:value-of select="$i18n_vlib/l/editors"/>:<br/>
                                            <xsl:apply-templates select="editorgroup/author">
                                                <xsl:sort select="position" order="ascending"/>
                                            </xsl:apply-templates>
                                        </div>
                                    </td></tr>

                                    <tr><td colspan="2">
                                        <div>
                                            Journal:<br/>
                                            <xsl:apply-templates select="serial"/>
                                        </div>
                                    </td></tr>
                                </table>
                        </span>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
        </body>
    </html>
</xsl:template>

<xsl:template match="reference_value">
    <xsl:variable name="property_id" select="property_id"/>
    <tr>
        <td>
            <xsl:value-of select="/document/reference_properties/reference_property[@id=$property_id]/name"/>:
        </td>
        <td>
            <xsl:value-of select="value"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
