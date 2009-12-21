<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: departmentroot_edit.xsl 2239 2009-08-03 09:35:54Z haensel $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <xsl:import href="container_common.xsl"/>
    <xsl:import href="departmentroot_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default">
    <xsl:with-param name="mode">edit</xsl:with-param>
    </xsl:call-template>
    <body>
    <xsl:call-template name="header"/>
        <div class="edit">
            <div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-edit"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" id="create-edit-form">

                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="tr-css-edit"/>
                    <xsl:call-template name="tr-script-edit"/>
                    <!--<xsl:call-template name="tr-imagedepartmentroot-edit"/>-->
                    <xsl:call-template name="tr-image-edit"/>
                    <xsl:call-template name="tr-feed-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="autoindex"/>
                    <xsl:call-template name="tr-pagerowlimit-edit"/>
                    <xsl:call-template name="defaultsorting"/>
                    <!--<xsl:call-template name="defaultprivmask-edit"/>-->
                    <xsl:call-template name="tr-deptportlets-edit"/>

                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
        </div>
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

<!--<xsl:template name="tr-imagedepartmentroot-edit">
    <div id="tr-image">
        <div id="label-image"><label for="input-image"><xsl:value-of select="$i18n/l/Image"/></label></div>
            <input type="text" name="image" size="60" value="{image_id}" class="text" id="input-image"/>
            <xsl:text>&#160;</xsl:text>
                    <a href="javascript:openDocWindow('DepartmentImage')" class="doclink">(?)</a>
                    <xsl:text>&#160;</xsl:text>
                 <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
            </div>
</xsl:template>-->

<xsl:template name="tr-deptportlets-edit">
    <div id="deptportlets">

                <p>
                    DepartmentRoot Portlets
                </p>
                <xsl:apply-templates select="/document/objectlist"/>
                <div id="tr-createportlet">
                    <div id="label-createportlet"><label for="input-createportlet"><xsl:value-of select="$i18n/l/create_portlet"/></label></div>
                        <input type="text" name="portlet" size="40" class="text" value="{portlet_id}" id="input-createportlet"/> <xsl:text>&#160;</xsl:text>
                        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="doclink"><xsl:value-of select="$i18n/l/Browse_for"/></a>
                        
                        </div>
                        <div id="tr-createportlet-button">
													<button type="submit" name="add_portlet" class="fg-button ui-state-default ui-corner-all" id="input-add_portlet"><xsl:value-of select="$i18n/l/add_portlet"/></button>
														<!--<input type="submit" name="add_portlet" value="{$i18n/l/add_portlet}" class="control fg-button ui-state-default ui-corner-all" id="input-add_portlet"/>-->
                        </div>
    </div>
</xsl:template>

</xsl:stylesheet>
