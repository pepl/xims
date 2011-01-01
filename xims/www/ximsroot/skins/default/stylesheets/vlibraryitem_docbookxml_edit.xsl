<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:call-template name="tr-body-edit"/>
                    <xsl:call-template name="tr-vlkeywords-edit"/>
                    <xsl:call-template name="tr-vlsubjects-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template match="keywordset/keyword|subjectset/subject">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="{$i18n/l/Opens_in_new_window}"><xsl:value-of select="name"/></a>
    <xsl:text> </xsl:text>
    <a href="{$xims_box}{$goxims_content}{$absolute_path}?remove_mapping=1;property={name()};property_id={id}" title="{i18n_vlib/l/Delete_mapping}">(x)</a>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="vlsubjects">
    <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="svlsubject">
        <xsl:apply-templates select="/document/context/vlsubjects/subject">
            <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                      order="ascending"/>
        </xsl:apply-templates>
    </select>
</xsl:template>

<xsl:template match="vlkeywords">
    <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="svlkeyword">
        <xsl:apply-templates select="/document/context/vlkeywords/keyword">
            <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                      order="ascending"/>
        </xsl:apply-templates>
    </select>
</xsl:template>


<xsl:template match="vlsubjects/subject|vlkeywords/keyword">
    <option value="{name}"><xsl:value-of select="name"/></option>
</xsl:template>

</xsl:stylesheet>
