<?xml version="1.0" encoding="iso-8859-1"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:import href="container_common.xsl"/>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform.name.focus()">
        <p class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="autoindex"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="cancelaction"/>
    </body>
    </html>
</xsl:template>
</xsl:stylesheet>
