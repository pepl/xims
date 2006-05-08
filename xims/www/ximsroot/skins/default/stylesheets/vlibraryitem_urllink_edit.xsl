<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">

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
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
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

<xsl:template name="tr-publisher-edit">
    <tr>
        <td valign="top">Institution</td>
        <td colspan="2">
            <input tabindex="20" type="text" name="publisher" size="60" class="text" maxlength="256" value="{meta/publisher}" />
            <xsl:text>&#160;</xsl:text>
<!--            <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-date-edit">
    <tr>
        <td valign="top">Datum</td>
        <td colspan="2">
            <input tabindex="20" type="text" name="date" size="10" class="text" maxlength="10" value="{meta/date_from}" /> (JJJJ-MM-TT)
            <xsl:text>&#160;</xsl:text>
<!--            <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> -->
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-vlkeywords-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/existing_keywords"/></td>
        <td colspan="2">
            <xsl:apply-templates select="keywordset/keyword">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    order="ascending"/>
            </xsl:apply-templates>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/assign_new_keywords"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="vlkeyword" size="50" value="" class="text" title="VLKeyword"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <input type="button" value="&lt;--" onClick="return addVLProperty( 'keyword' );"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:apply-templates select="/document/context/vlkeywords"/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="create_mapping" value="{$i18n_vlib/l/create_mapping}" class="control" onClick="return submitOnValue(do\
cument.eform.vlkeyword, 'Please fill in a value for', document.eform.svlkeyword);"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-vlsubjects-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/existing_subjects"/></td>
        <td colspan="2">
            <xsl:apply-templates select="subjectset/subject">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    order="ascending"/>
            </xsl:apply-templates>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/assign_new_subjects"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="vlsubject" size="50" value="" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <input type="button" value="&lt;--" onClick="return addVLProperty( 'subject' );"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:apply-templates select="/document/context/vlsubjects"/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="create_mapping" value="{$i18n_vlib/l/create_mapping}" class="control"/>
        </td>
    </tr>
</xsl:template>

<xsl:template match="keywordset/keyword|subjectset/subject">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="Browse in a new window\
"><xsl:value-of select="name"/></a>
    <xsl:text> </xsl:text>
    <a href="{$xims_box}{$goxims_content}?id={$id};remove_mapping=1;property={name()};property_id={id}" title="Delete Mapping">(x)</a>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>


</xsl:stylesheet>
