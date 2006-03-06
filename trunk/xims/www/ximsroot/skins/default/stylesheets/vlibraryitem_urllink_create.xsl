<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform.body.value=''; document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-subject-create"/>
                    <xsl:call-template name="tr-publisher-create"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
            </div>
            <br />
            <xsl:call-template name="cancelaction"/>
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
