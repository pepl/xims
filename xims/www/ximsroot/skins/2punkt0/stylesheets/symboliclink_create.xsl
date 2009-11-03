<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: symboliclink_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="link_common.xsl"/>

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

                    <xsl:call-template name="tr-location-create"/>
                    <xsl:call-template name="tr-target-create"/>
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
    </body>
</html>
</xsl:template>

<xsl:template name="tr-target-create">
    <div id="tr-target">
        <div id="label-target"><span class="compulsory"><label for="input-target"><xsl:value-of select="$i18n/l/Target"/></label></span></div>
            <input type="text" name="target" size="60" class="text" id="input-target"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">
							<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Target"/></xsl:attribute>
							(?)
						</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}?contentbrowse=1;sbfield=eform.target')" class="doclink"><xsl:value-of select="$i18n/l/browse_target"/></a>
        </div>
</xsl:template>
</xsl:stylesheet>
