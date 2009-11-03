<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: symboliclink_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="link_common.xsl"/>

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
					<div id="table-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST" id="create-edit-form">

                    <xsl:call-template name="tr-location-edit"/>
                    <xsl:call-template name="tr-target-edit"/>
                    <div id="tr-title">
                        <div id="label-title">
                            <xsl:value-of select="$i18n/l/Title"/>
                        </div>
                        <xsl:value-of select="title"/>
                    </div>
                    <xsl:call-template name="markednew"/>

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

<xsl:template name="tr-target-edit">
    <div id="tr-target">
        <div id="label-target"><span class="compulsory"><label for="input-target"><xsl:value-of select="$i18n/l/Target"/></label></span></div>
            <input type="text" name="target" size="60" value="{symname_to_doc_id}" class="text" id="input-target"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">
							<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Target"/></xsl:attribute>
							(?)
						</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;sbfield=eform.target')" class="doclink"><xsl:value-of select="$i18n/l/browse_target"/></a>
        </div>
</xsl:template>

</xsl:stylesheet>
