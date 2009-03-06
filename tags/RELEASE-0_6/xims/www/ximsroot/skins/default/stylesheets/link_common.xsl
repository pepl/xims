<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:template name="browse_target">
    <xsl:param name="browse" select="'self'"/>
    <tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n/l/target"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" value="{symname_to_doc_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <xsl:choose>
                <xsl:when test="$browse = 'self'">
                    <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">
                        <xsl:value-of select="$i18n/l/browse_target"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@parent_id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">
                        <xsl:value-of select="$i18n/l/browse_target"/>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-locationtitletarget-create">
    <xsl:call-template name="tr-locationtitle-create"/>
    <xsl:call-template name="browse_target">  
        <xsl:with-param name="browse" select="'self'"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="tr-locationtitletarget-edit">
    <xsl:call-template name="tr-locationtitle-edit"/>
    <xsl:call-template name="browse_target">
        <xsl:with-param name="browse" select="'parent'"/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>