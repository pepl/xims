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

<xsl:import href="document_common.xsl"/>
<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

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
            <input tabindex="30" type="file" name="imagefile" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
      </td>
    </tr>
    <tr>
         <td valign="top">
             <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
             <xsl:value-of select="$i18n/l/target"/>
         </td>
        <td colspan="2">
            <input type="text" name="imagefolder" size="40" class="text">
                <!--  Provide an "educated-guess" default value -->
                <xsl:attribute name="value">
                    <xsl:for-each select="/document/context/object/parents/object[@document_id != 1 and @document_id != /document/context/object/@parent_id]">
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="location"/>
                    </xsl:for-each><xsl:text>/images</xsl:text>
                </xsl:attribute>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};to={$parentid};otfilter=Folder,DepartmentRoot,SiteRoot;contentbrowse=1;sbfield=eform.imagefolder')" class="doclink"><xsl:value-of select="$i18n/l/browse_target"/></a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('NewsItemImage')" class="doclink">(?)</a>
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
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={$parentid};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
