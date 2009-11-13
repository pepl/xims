<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_create_htmlarea.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="document_common.xsl"/>
<xsl:import href="document_create_tinymce.xsl"/>
<xsl:import href="newsitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default">
				<xsl:with-param name="calendar">true</xsl:with-param>
				<xsl:with-param name="mode">create</xsl:with-param>
    </xsl:call-template>
    <!--<body onload="document.eform['abstract'].value=''; document.eform.title.focus()">-->
    <body>
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
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" enctype="multipart/form-data" id="create-edit-form">
                <input type="hidden" name="objtype" value="{$objtype}"/>

                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-leadimage-create"/>
                    <xsl:call-template name="tr-body-create_tinymce"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-valid_from"/>
                    <xsl:call-template name="tr-valid_to"/>
                    <xsl:call-template name="markednew"/>
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
        <xsl:call-template name="tinymce_scripts"/>
    </body>
</html>
</xsl:template>

<!--<xsl:template name="title">
    <xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
</xsl:template>

<xsl:template name="script_head">
    <xsl:call-template name="jscalendar_scripts"/>
</xsl:template>-->

</xsl:stylesheet>
