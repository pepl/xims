<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
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
                            <h1><xsl:value-of select="title"/> (<xsl:value-of select="/document/reference_types/reference_type[@id=/document/context/object/reference_type_id]/name"/>)</h1>
                                <xsl:if test="abstract != ''">
                                    <div id="abstract">
                                        <xsl:value-of select="$i18n/l/Abstract"/>: <xsl:apply-templates select="abstract"/>
                                    </div>
                                </xsl:if>
                                <xsl:if test="notes != ''">
                                    <div id="notes">
                                        <xsl:value-of select="$i18n/l/Notes"/>: <xsl:apply-templates select="notes"/>
                                    </div>
                                </xsl:if>
                                <table id="reference_values">
                                    <xsl:apply-templates select="reference_values/reference_value">
                                        <xsl:sort select="/document/reference_properties/reference_property[@id=current()/property_id]/position" order="ascending" data-type="number"/>
                                    </xsl:apply-templates>
                                </table>
                                <div id="authors">
                                    <xsl:value-of select="$i18n_vlib/l/authors"/>:<br/>
                                    <xsl:apply-templates select="authorgroup/author">
                                        <xsl:sort select="position" order="ascending" data-type="number"/>
                                    </xsl:apply-templates>
                                </div>
                                <xsl:if test="editorgroup/author">
                                    <div id="editors">
                                        <xsl:value-of select="$i18n_vlib/l/editors"/>:<br/>
                                        <xsl:apply-templates select="editorgroup/author">
                                            <xsl:sort select="position" order="ascending" data-type="number"/>
                                        </xsl:apply-templates>
                                    </div>
                                </xsl:if>
                                <xsl:if test="serial != ''">
                                    <div id="serials">
                                        Journal:<br/>
                                        <xsl:apply-templates select="serial"/>
                                    </div>
                                </xsl:if>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template match="reference_value">
    <xsl:variable name="property_id" select="property_id"/>
    <tr class="reference_value">
        <td>
            <xsl:value-of select="/document/reference_properties/reference_property[@id=$property_id]/name"/>:
        </td>
        <td>
            <xsl:value-of select="value"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
