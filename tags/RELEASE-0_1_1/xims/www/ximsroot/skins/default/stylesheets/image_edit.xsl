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

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <p class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=image" method="POST" enctype="multipart/form-data">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-title-edit"/>
                    <xsl:call-template name="tr-image-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="canceledit"/>
        <br />
        <xsl:call-template name="preview-image"/>
    </body>
</html>
</xsl:template>

<xsl:template name="preview-image">
    <p style="padding-left:20px;">
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}')"><xsl:value-of select="$i18n/l/Preview_image"/></a>
    </p>
</xsl:template>

<xsl:template name="tr-image-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/> <xsl:value-of select="$i18n/l/replace"/></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
