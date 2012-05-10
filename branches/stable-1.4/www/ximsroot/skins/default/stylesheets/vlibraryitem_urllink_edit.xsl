<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="common-head">
        <xsl:with-param name="mode">edit</xsl:with-param>
        <xsl:with-param name="calendar" select="true()" />
    </xsl:call-template>
    <body>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" enctype="multipart/form-data">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_urllink"/>
                    <xsl:call-template name="tr-vlsubjects-edit"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-vlkeywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>               
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
            </div>
            <br />
            <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-locationtitle-edit_urllink">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
        </td>
        <td>
            <input tabindex="10" type="text" class="text" name="name" size="40">
                <xsl:choose>
                    <xsl:when test="string-length(symname_to_doc_id) > 0 ">
                        <xsl:attribute name="value"><xsl:value-of select="symname_to_doc_id"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="value"><xsl:value-of select="location"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            <xsl:call-template name="marked_mandatory"/>
        </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>

<xsl:template match="keywordset/keyword|subjectset/subject">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="{$i18n/l/Opens_in_new_window}"><xsl:value-of select="name"/></a>
    <xsl:text> </xsl:text>
    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};remove_mapping=1;property={name()};property_id={id}" title="{i18n_vlib/l/Delete_mapping}">(x)</a>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="vlsubjects">
    <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt" name="svlsubject">
        <xsl:apply-templates select="/document/context/vlsubjects/subject">
            <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                      order="ascending"/>
        </xsl:apply-templates>
    </select>
</xsl:template>

<xsl:template match="vlkeywords">
    <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt" name="svlkeyword">
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