<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="departmentroot_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform.name.focus()">
        <p class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-stylesheet-create"/>
                    <xsl:call-template name="tr-imagedepartmentroot-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="autoindex"/>
                    <xsl:call-template name="grantowneronly"/>
                    <xsl:call-template name="tr-deptportlets-create"/>
                 </table>
                 <xsl:call-template name="saveaction"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="cancelaction"/>
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
                <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">Nach einem Bild durchsuchen</a>
            </td>
    </tr>
</xsl:template>

<xsl:template name="tr-deptportlets-create">
    <tr>
        <td colspan="3">
            <table style="margin-bottom:20px; margin-top:5px; border: 1px solid; border-color: black">
                <tr>
                    <td valign="top" colspan="2">DepartmentRoot Portlets</td>
                </tr>
                <xsl:apply-templates select="/document/objectlist"/>
                <tr>
                    <td valign="top"><xsl:value-of select="$i18n/l/create_portlet"/>:</td>
                    <td>
                        <input type="text" name="portlet" size="40" class="text"/> <xsl:text>&#160;</xsl:text>
                        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="doclink">Nach Portlet durchsuchen</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="submit" name="add_portlet" value="{$i18n/l/add_portlet}" class="control"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
