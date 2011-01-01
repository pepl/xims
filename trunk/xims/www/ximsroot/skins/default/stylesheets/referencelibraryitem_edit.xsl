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

<xsl:variable name="i18n_reflib" select="document(concat($currentuilanguage,'/i18n_reflibrary.xml'))"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">
                    <xsl:call-template name="reftypes_select"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="tr-vlauthors"/>
                    <xsl:call-template name="tr-vleditors"/>
                    <xsl:call-template name="tr-vlserials"/>
                    <xsl:apply-templates select="/document/reference_properties/reference_property">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>

                    <!-- Add Fulltext (->XIMS::File object as child ?) -->
                    <xsl:call-template name="tr-abstract"/>
                    <xsl:call-template name="tr-notes"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <form action="{$xims_box}{$goxims_content}" name="reftypechangeform" method="get" style="display:none">
            <input type="hidden" name="id" value="{@id}"/>
            <input type="hidden" name="change_reference_type" value="1"/>
            <input type="hidden" name="reference_type_id" value=""/>
            <xsl:call-template name="rbacknav"/>
        </form>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

    <xsl:template name="reftypes_select">
        <tr>
            <td valign="top"><xsl:value-of select="$i18n_reflib/l/ChangeRefType"/></td>
            <td colspan="2">
                <select name="reftypes_select" id="reftypes_select" onchange="return submitReferenceTypeUpdate(this.value);">
                    <xsl:apply-templates select="/document/reference_types/reference_type"/>
                </select>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="/document/reference_types/reference_type">
        <option value="{@id}">
            <xsl:if test="@id = /document/context/object/reference_type_id">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="name"/>
        </option>
    </xsl:template>

</xsl:stylesheet>
