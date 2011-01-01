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

<xsl:import href="simpledb_common.xsl"/>
<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td bgcolor="#ffffff">
                        <!-- <span id="body"> -->
                            <h1><xsl:value-of select="title"/></h1>
                                <div id="abstract">
                                    <xsl:apply-templates select="abstract"/>
                                </div>
                                <table>
                                    <xsl:apply-templates select="member_values/member_value">
                                        <xsl:sort select="/document/member_properties/member_property[@id = current()/property_id]/position" order="ascending" data-type="number"/>
                                    </xsl:apply-templates>
                                </table>
                       <!-- </span> -->
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

<xsl:template match="member_value">
    <xsl:variable name="property_id" select="property_id"/>
    <tr>
        <td>
            <xsl:value-of select="/document/member_properties/member_property[@id=$property_id]/name"/>:
        </td>
        <td>
            <xsl:value-of select="value"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
