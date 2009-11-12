<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: sqlreport_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="sqlreport_common.xsl"/>

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
            <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST" name="eform" id="create-edit-form">

                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:call-template name="tr-body-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="pagesize"/>
                    <xsl:call-template name="skeys"/>
                    <xsl:call-template name="dbdsn"/>
                    <xsl:call-template name="dbuser"/>
                    <xsl:call-template name="dbpwd"/>

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
</xsl:stylesheet>

