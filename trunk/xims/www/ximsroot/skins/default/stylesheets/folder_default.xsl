<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:variable name="deleted_children"><xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])" /></xsl:variable>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
            <xsl:call-template name="header">
                <xsl:with-param name="createwidget">true</xsl:with-param>
            </xsl:call-template>

            <xsl:call-template name="childrentable"/>

            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="deleted_objects"/>
                <xsl:call-template name="footer"/>
            </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
