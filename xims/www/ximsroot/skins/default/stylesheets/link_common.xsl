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

<xsl:import href="common.xsl"/>

<xsl:template name="browse_target">
    <tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n/l/target"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" value="{symname_to_doc_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,SiteRoot;sbfield=eform.target')" class="doclink">
                <xsl:value-of select="$i18n/l/browse_target"/>
            </a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-locationtitletarget-create">
    <xsl:call-template name="tr-locationtitle-create"/>
    <xsl:call-template name="browse_target"/>
</xsl:template>

<xsl:template name="tr-locationtitletarget-edit">
    <xsl:call-template name="tr-locationtitle-edit"/>
    <xsl:call-template name="browse_target"/>
</xsl:template>

</xsl:stylesheet>
