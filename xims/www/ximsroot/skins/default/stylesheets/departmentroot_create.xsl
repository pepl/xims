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

<xsl:import href="common.xsl"/>
<xsl:import href="container_common.xsl"/>
<xsl:import href="departmentroot_common.xsl"/>
<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onload="document.eform.name.focus()">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-stylesheet-create"/>
                    <xsl:call-template name="tr-css-create"/>
                    <xsl:call-template name="tr-script-create"/>
                    <xsl:call-template name="tr-imagedepartmentroot-create"/>
                    <xsl:call-template name="tr-feed-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="autoindex"/>
                    <xsl:call-template name="grantowneronly"/>
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

<xsl:template name="tr-imagedepartmentroot-create">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/></td>
        <td>
            <input tabindex="30" type="text" name="image" size="40" value="" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('DepartmentImage')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}?contentbrowse=1;to={$parentid};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
