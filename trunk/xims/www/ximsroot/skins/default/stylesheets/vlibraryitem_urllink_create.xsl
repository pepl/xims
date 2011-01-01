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

<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <head>
    <xsl:call-template name="common-head">
        <xsl:with-param name="mode">create</xsl:with-param>
        <xsl:with-param name="calendar" select="true()" />
    </xsl:call-template>
    <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript" ></script>
    </head>
    <body onload="document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-location-create">
                      <xsl:with-param name="testlocation" select="false()"/>
                    </xsl:call-template>
                    <xsl:call-template name="tr-subtitle"/>
                    <xsl:call-template name="tr-vlsubjects-create"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-vlkeywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>               
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-subject-create">
    <tr>
        <td valign="top">Thema</td>
        <td colspan="2">
            <input tabindex="20" type="text" name="subject" size="60" class="text" maxlength="256"/>
            <xsl:text>&#160;</xsl:text>
<!--            <a href="javascript:openDocWindow('Subject')" class="doclink">(?)</a> -->
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-publisher-create">
    <tr>
        <td valign="top">Institution</td>
        <td colspan="2">
            <input tabindex="20" type="text" name="publisher" size="60" class="text" maxlength="256"/>
            <xsl:text>&#160;</xsl:text>
<!--            <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
        </td>
    </tr>
</xsl:template>


</xsl:stylesheet>
