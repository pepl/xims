<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <p class="edit">
            <xsl:call-template name="table-edit"/>
                <form action="{$goxims_content}{$absolute_path}?objtype=portal" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveedit"/>
                </form>
        </p>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>
</xsl:stylesheet>
