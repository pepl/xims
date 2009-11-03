<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: portlet_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:include href="portlet_common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
    <xsl:call-template name="head_default">
    <xsl:with-param name="mode">edit</xsl:with-param>
    </xsl:call-template>
    <!--<body onLoad="document.eform.body.value=''; document.eform['abstract'].value=''; document.eform.name.focus();">-->
    <body>
    	<xsl:call-template name="header"/>
        <div class="edit">
					<div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-edit"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="table-container" class="ui-corner-bottom ui-corner-tr">
          <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST" id="create-edit-form">
                
              <xsl:call-template name="tr-locationtitletarget-edit"/>
              <xsl:call-template name="tree_depth"/>
							<xsl:call-template name="add_documentlinks"/>
              <xsl:call-template name="tr-abstract-edit"/>
              <xsl:call-template name="markednew"/>

                  <xsl:call-template name="extra_properties"/>
                 <!-- <xsl:call-template name="contentoptions"/>-->
                  <xsl:call-template name="contentfilters"/>


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

