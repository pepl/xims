<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforumcontrib_default.xsl 2191 2009-01-07 20:04:18Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../anondiscussionforumcontrib_default.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:template match="/document/objectlist/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr>
        <td class="10left">
            <img src="{$ximsroot}images/spacer_white.gif"
                alt="spacer"
                width="{20*(number(@level)-ceiling(number(/document/objectlist/object/@level)))+1}"
                height="10"
            />
            <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif"
                alt=""
                width="20"
                height="18"
            />
            <a href="{$goxims_content}?id={@id}"><xsl:value-of select="title"/></a>
            (<xsl:choose>
                <xsl:when test="attributes/email">
                    <a href="#" title="{$goxims_content}?id={@id};mt=1;subject={title}" target="hiddenIframe" onClick="this.href=this.title;"><xsl:value-of select="attributes/author"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="attributes/author"/>
                </xsl:otherwise>
            </xsl:choose>
            ,
            <xsl:apply-templates select="creation_timestamp" mode="datetime"/>)
        </td>
        <td valign="bottom" height="25">
            <xsl:if test="/document/context/object/user_privileges/delete">
                <a href="{$goxims_content}?id={@id};delete_prompt=1;">
                    <img src="{$skimages}option_delete.png" border="0" width="37" height="19" title="{$i18n/l/delete}" alt="{$i18n/l/delete}"/>
                </a>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
