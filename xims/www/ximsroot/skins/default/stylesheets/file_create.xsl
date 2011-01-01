<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onload="document.eform['abstract'].value='';">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" style="margin-top:0px;" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <tr>
                        <td colspan="3" align="right" valign="top">
                            <xsl:call-template name="marked_mandatory"/>
                        </td>
                    </tr>
                    <xsl:call-template name="tr-file-create"/>
                    <tr>
                        <!-- TODO
                                1) I18N.alize
                                2) Hide other form fields
                                3) Only show overwrite fied when unzip contents has been checked
                        -->
                        <td valign="top">Unzip Contents</td>
                        <td colspan="2">
                            <input tabindex="35" type="checkbox" name="unzip" value="1"/>
                            <xsl:text>&#160;</xsl:text>
                            <a href="javascript:openDocWindow('Unzip Contents')" class="doclink">(?)</a>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">Overwrite existing objects when unzipping</td>
                        <td colspan="2">
                            <input tabindex="35" type="checkbox" name="overwrite" value="1"/>
                            <xsl:text>&#160;</xsl:text>
                            <a href="javascript:openDocWindow('Overwrite when unzipping contents')" class="doclink">(?)</a>
                        </td>
                    </tr>
                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="uploadaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-file-create">
    <tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n/l/File"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('File')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="uploadaction">
    <input type="hidden" name="id" value="{/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}"/>
    <input type="submit" name="store" value="{$i18n/l/save}" class="control"/>
</xsl:template>

</xsl:stylesheet>
