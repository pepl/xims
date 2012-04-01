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

<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-import"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" enctype="multipart/form-data">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-importsourcetype"/>
                    <xsl:call-template name="tr-body-import"/>
                    <xsl:call-template name="tr-bodyfromfile-import"/>
                </table>
                <xsl:call-template name="import"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-importsourcetype">
    <tr>
        <td valign="top" colspan="3">Input Format:
            <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="importformat">
                <option value="BibTeX">BibTeX</option>
                <option value="RIS">RIS</option>
                <option value="Endnote">Endnote</option>
                <option value="Pubmed">Pubmed</option>
                <option value="MODS">MODS</option>
                <option value="ISI">ISI Web of Science</option>
                <option value="COPAC">COPAC</option>
            </select>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import Source Type')" class="doclink">(?)</a>
        </td>
        </tr>
</xsl:template>

<xsl:template name="tr-body-import">
    <tr>
        <td colspan="3">
            Input import file body,
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import')" class="doclink">(?)</a>
            <br/>

            <div id="bodymain">
                <div id="bodycon">
                    <textarea tabindex="30" name="body" id="body" rows="15" cols="90">&#160;</textarea>
                </div>
            </div>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-bodyfromfile-import">
    <tr>
        <td valign="top" colspan="2">or import references from file:
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="import">
    <input type="hidden" name="id" value="{@id}"/>
    <xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
        <input name="sb" type="hidden" value="date"/>
        <input name="order" type="hidden" value="desc"/>
    </xsl:if>
    <input type="submit" name="import" value="{$i18n_vlib/l/Import}" class="control" accesskey="S"/>
</xsl:template>

<xsl:template name="table-import">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0" style="margin: 0px; padding: 2px">
        <tr>
            <td valign="top">
                <strong>Import items into &#160;'<xsl:value-of select="title"/>' (<xsl:value-of select="$absolute_path"/>)</strong>
            </td>
            <td align="right" valign="top">
                <xsl:call-template name="cancelform">
                    <xsl:with-param name="with_save">yes</xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="title">
    Import items into &#160;'<xsl:value-of select="title"/>' (<xsl:value-of select="$absolute_path"/>) - XIMS
</xsl:template>

</xsl:stylesheet>
