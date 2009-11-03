<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: departmentroot_create.xsl 2239 2009-08-03 09:35:54Z haensel $
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
    <xsl:call-template name="head_default">
    <xsl:with-param name="mode">create</xsl:with-param>
    </xsl:call-template>
    <body onLoad="document.eform.name.focus()">
				<xsl:call-template name="header">
					<xsl:with-param name="create">true</xsl:with-param>				
				</xsl:call-template>
        <div class="edit">
            <div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-create"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="table-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" id="create-edit-form">
                <input type="hidden" name="objtype" value="{$objtype}"/>

                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-stylesheet-create"/>
                    <xsl:call-template name="tr-css-create"/>
                    <xsl:call-template name="tr-script-create"/>
                    <!--<xsl:call-template name="tr-imagedepartmentroot-create"/>-->
                    <xsl:call-template name="tr-image-create"/>
                    <xsl:call-template name="tr-feed-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="autoindex"/>
                    <xsl:call-template name="grantowneronly"/>

                 <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
        </div>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<!--<xsl:template name="tr-imagedepartmentroot-create">
    <div id="tr-image">
        <div id="label-image"><label for="input-image"><xsl:value-of select="$i18n/l/Image"/></label></div>
            <input type="text" name="image" size="60" value="" class="text" id="input-image"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('DepartmentImage')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}?contentbrowse=1;to={$parentid};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
        </div>
</xsl:template>-->

</xsl:stylesheet>
