<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="document_common.xsl"/>

<xsl:template name="tr-leadimage-create">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Lead"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="30" name="abstract" rows="5" cols="100" class="text"><xsl:text>&#160;</xsl:text></textarea>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="image" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-leadimage-edit">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Lead"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="5" cols="100" class="text">
            <xsl:choose>
                <xsl:when test="string-length(abstract) &gt; 0">
                    <xsl:apply-templates select="abstract"/>
                </xsl:when>
                        <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                 </xsl:otherwise>
            </xsl:choose>
            </textarea>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/></td>
        <td colspan="2">
            <input tabindex="60" type="text" name="image" size="40" value="{image_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
