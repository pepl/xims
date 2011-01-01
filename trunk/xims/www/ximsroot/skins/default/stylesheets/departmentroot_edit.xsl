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

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="tr-css-edit"/>
                    <xsl:call-template name="tr-script-edit"/>
                    <xsl:call-template name="tr-imagedepartmentroot-edit"/>
                    <xsl:call-template name="tr-feed-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="autoindex"/>
                    <xsl:call-template name="tr-pagerowlimit-edit"/>
                    <xsl:call-template name="defaultsorting"/>
                    <!--<xsl:call-template name="defaultprivmask-edit"/>-->
                    <xsl:call-template name="tr-deptportlets-edit"/>
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

<xsl:template name="defaultprivmask-edit">
    <tr>
        <td valign="top">Default Privilege Mask</td>
           <td>
            <input tabindex="30" type="text" name="defaultprivmask" size="40" value="{attributes/defaultprivmask}" class="text"/>
            <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('defaultprivmask')" class="doclink">(?)</a>
            </td>
    </tr>
</xsl:template>

<xsl:template name="tr-imagedepartmentroot-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/></td>
           <td>
            <input tabindex="30" type="text" name="image" size="40" value="{image_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
                    <a href="javascript:openDocWindow('DepartmentImage')" class="doclink">(?)</a>
                    <xsl:text>&#160;</xsl:text>
                 <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
            </td>
    </tr>
</xsl:template>

<xsl:template name="tr-deptportlets-edit">
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
                        <input type="text" name="portlet" size="40" class="text" value="{portlet_id}"/> <xsl:text>&#160;</xsl:text>
                        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="doclink"><xsl:value-of select="$i18n/l/Browse_for"/></a>
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
