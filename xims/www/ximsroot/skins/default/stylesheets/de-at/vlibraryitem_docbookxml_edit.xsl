<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="common.xsl"/>
<xsl:import href="../vlibraryitem_docbookxml_edit.xsl"/>

<xsl:output method="xml"
            encoding="utf-8"
            media-type="text/html"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
            doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            indent="no"/>


<xsl:template name="tr-vlkeywords-edit">
    <tr>
        <td valign="top">Dzt. zugewiesene <xsl:value-of select="$i18n/l/Keywords"/></td>
        <td colspan="2">
            <xsl:apply-templates select="keywordset/keyword">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
            </xsl:apply-templates>
        </td>
    </tr>
    <tr>
        <td valign="top">Zuweisung neuer Schlagworte</td>
        <td colspan="2">
            <input tabindex="40" type="text" name="vlkeyword" size="50" value="" class="text" title="VLKeyword"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <input type="button" value="&lt;--" onClick="return addVLProperty( 'keyword' );"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:apply-templates select="/document/context/vlkeywords"/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="create_mapping" value="Zuweisen" class="control" onClick="return submitOnValue(document.eform.vlkeyword, 'Please fill in a value for', document.eform.svlkeyword);"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-vlsubjects-edit">
    <tr>
        <td valign="top">Dzt. zugewiesene Themenbereiche<xsl:value-of select="$i18n/l/Subjects"/></td>
        <td colspan="2">
            <xsl:apply-templates select="subjectset/subject">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
            </xsl:apply-templates>
        </td>
    </tr>
    <tr>
        <td valign="top">Zuweisung neuer Themenbereiche</td>
        <td colspan="2">
            <input tabindex="40" type="text" name="vlsubject" size="50" value="" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <input type="button" value="&lt;--" onClick="return addVLProperty( 'subject' );"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:apply-templates select="/document/context/vlsubjects"/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="create_mapping" value="Zuweisen" class="control"/>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
