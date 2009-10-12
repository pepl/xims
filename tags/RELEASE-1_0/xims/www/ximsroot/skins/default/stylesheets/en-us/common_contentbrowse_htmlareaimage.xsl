<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>
<xsl:import href="../common_contentbrowse_htmlareaimage.xsl"/>
<xsl:output method="html" encoding="utf-8"/>

<xsl:template name="selectform">
    <form action="{$xims_box}{$goxims_content}" method="POST" name="selectform">
        <table>
            <tr>
                <td>
                    Type in a path to an image
                </td>
                <td>
                    <input type="text" name="imgpath" size="60">
<!--
                        <xsl:choose>
                            <xsl:when test="$save_path = $absolute_path_nosite">
                                <xsl:attribute name="value"></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="contains($save_path, concat($absolute_path_nosite, '/'))">
                                <xsl:attribute name="value"><xsl:value-of select="substring-after($target_path, concat($absolute_path_nosite, '/'))"/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value"><xsl:value-of select="concat('..',$save_path)"/></xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
-->

                    </input>
                </td>
            </tr>
            <tr>
                <td>
                    Enter a title
                </td>
                <td>
                    <input type="text" name="imgtext" size="60"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input class="control" type="button" value="Store Back" onClick="insertfile(window.opener.editor);"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    Or browse for an image:
                    <br/>
                    <xsl:apply-templates select="targetparents/object[@id !='1']"/>
                    <xsl:apply-templates select="target/object"/>
                    <table>
                        <xsl:apply-templates select="targetchildren/object">
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