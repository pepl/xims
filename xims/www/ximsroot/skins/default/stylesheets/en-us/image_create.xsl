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
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>
    
<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform.abstract.value=''">
        <p class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" method="POST" enctype="multipart/form-data" name="eform">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-image-create"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="uploadaction"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="cancelaction"/>
    </body>
</html>
</xsl:template>
</xsl:stylesheet>
