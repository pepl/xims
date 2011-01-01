<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_contentbrowse_htmlareaimage.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>
<xsl:import href="../common_contentbrowse_tinymceimage.xsl"/>

<xsl:template name="selectform">
    <form action="{$xims_box}{$goxims_content}" method="post" name="selectform">
        <table>
            <tr>
                <td>
                    Geben Sie einen Pfad zu einem Bild ein
                </td>
                <td>
                    <input type="text" name="imgpath" size="60"/>
                </td>
            </tr>
            <tr>
                <td>
                    Geben Sie einen Titel ein
                </td>
                <td>
                    <input type="text" name="imgtext" size="60"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input class="control" type="button" value="Store Back" onclick="insertfile();"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    Oder durchsuchen Sie den XIMS Objektbaum nach einem Bild:
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
