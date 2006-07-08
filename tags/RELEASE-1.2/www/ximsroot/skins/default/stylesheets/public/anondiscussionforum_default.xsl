<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../anondiscussionforum_default.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:output method="xml" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template name="forum">
    <h1><xsl:value-of select="title" /></h1>

    <p class="content">
        <xsl:apply-templates select="abstract"/>
    </p>

    <p>
        <xsl:if test="user_privileges/create">
          <form action="{$xims_box}{$goxims_content}" method="GET" style="margin-bottom: 0;">
            <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
            <input type="hidden" name="id" value="{@id}" />
            <input type="submit" name="create" value="{$i18n/l/Create_topic}" class="control"/><br /><br />
          </form>
        </xsl:if>
    </p>

    <xsl:call-template name="forumtable"/>
</xsl:template>

<xsl:template match="children/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    
    <tr height="25">
        <xsl:choose>
            <!-- begin sort by name -->
            <xsl:when test="$sb='name'">
                <td bgcolor="#eeeeee" valign="bottom">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
                        <xsl:value-of select="title" />
                    </a>
                </td>
                <td nowrap="nowrap" valign="middle" align="center">
                    <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </td>
            </xsl:when>
            <!-- end sort by name -->
            <!-- begin sort by date -->
            <xsl:when test="$sb='date' or $sb='position'">
                <td valign="middle">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
                        <xsl:value-of select="title" /></a>
                </td>
                <td nowrap="nowrap" bgcolor="#eeeeee" valign="middle" align="center">
                    <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </td>
            </xsl:when>
            <!-- end sort by date -->
        </xsl:choose>
        <td align="left" valign="middle">
            <a>
                <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/email"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                <xsl:value-of select="attributes/author"/>
            </a>
            <xsl:choose>
                <xsl:when test="attributes/coemail">,
                    <a>
                        <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/coemail"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                        <xsl:value-of select="attributes/coauthor"/>
                    </a>
                </xsl:when>
                <xsl:when test="attributes/coauthor">,<br/> <xsl:value-of select="attributes/coauthor"/>
                </xsl:when>
            </xsl:choose>
        </td>
        <td valign="middle" align="center">
            <xsl:value-of select="descendant_count"/>
        </td>
        <td nowrap="nowrap" valign="middle" align="center">
            <xsl:if test="descendant_count != '0'">
                <xsl:apply-templates select="descendant_last_modification_timestamp" mode="datetime"/>
            </xsl:if>
        </td>
        <td valign="bottom">
            <xsl:if test="user_privileges/delete">
                <form style="margin:0px;" name="delete" method="GET" action="{$xims_box}{$goxims_content}">
                    <input type="hidden" name="delete_prompt" value="1"/>
                    <input type="hidden" name="id" value="{@id}"/>
                    <input type="image" src="{$skimages}option_delete.png" border="0" width="37" height="19" title="delete" alt="delete"/>
                </form>
            </xsl:if>
        </td>
    </tr>
</xsl:template>
    

</xsl:stylesheet>