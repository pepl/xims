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

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform['abstract'].value='';">
        <p class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <tr>
                        <td colspan="3" align="right" valign="top">
                            <xsl:call-template name="marked_mandatory"/>
                        </td>
                    </tr>
                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-file-create"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
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

<xsl:template name="tr-file-create">
    <tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n/l/File"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('File')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="uploadaction">
    <input type="hidden" name="parid" value="{@id}"/>
    <input type="submit" name="store" value="{$i18n/l/upload}" class="control"/>
</xsl:template>

</xsl:stylesheet>
