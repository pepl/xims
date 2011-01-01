<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_contentbrowse_htmlarealink.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>
<xsl:import href="../common_contentbrowse_tinymcelink.xsl"/>

<xsl:template name="selectform">
    <form action="{$xims_box}{$goxims_content}" method="post" name="selectform">
        <table>
            <tr>
                <td>
                    Type in a URL
                </td>
                <td>
                    <input type="text" name="httpLink" size="60">
                        <xsl:choose>
                            <xsl:when test="$target_path = $absolute_path_nosite">
                                <xsl:attribute name="value"></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="contains($target_path, concat($absolute_path_nosite, '/'))">
                                <xsl:attribute name="value"><xsl:value-of select="substring-after($target_path, concat($absolute_path_nosite, '/'))"/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value"><xsl:value-of select="$target_path"/></xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </input>
                </td>
            </tr>
            <tr>
                <td>
                    Enter a title
                </td>
                <td>
                    <input type="text" name="linktext" size="60">
                        <xsl:choose>
                            <xsl:when test="@id != /document/context/object/target/object/@id">
                                <xsl:attribute name="value"><xsl:value-of select="/document/context/object/target/object/title"/></xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </input>
                </td>
            </tr>
            <tr>
                <td>
                    Optionally select a link target:
                </td>
                <td>
                    <select name="Target">
                        <option value="" selected="selected"></option>
                        <option value="_blank">New Window (_blank)</option>
                        <option value="_self">Same Window (_self)</option>
                        <option value="_parent">Parent Window (_parent)</option>
                        <option value="_top">Browser Window (_top)</option>
                    </select>
                    <input class="control" type="button" value="Store Back" onclick="inserthyperlink();"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    Or browse for a XIMS-Object:
                    <br/>
                    <xsl:apply-templates select="targetparents/object[@id !='1']"/>
                    <xsl:apply-templates select="target/object"/>
                    <table>
                        <xsl:apply-templates select="targetchildren/object[marked_deleted != '1']">
                            <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                        </xsl:apply-templates>
                    </table>
                </td>
            </tr>
       </table>
       <input type="hidden" name="id" value="{@id}"/>
    </form>
</xsl:template>

</xsl:stylesheet>
