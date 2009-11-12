<?xml version="1.0"?>
<!--
 # Copyright (c) 2002-2009 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id: text_create.xsl 2188 2009-01-03 18:24:00Z pepl $
 -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      			<xsl:call-template name="head_default">
			<xsl:with-param name="mode">create</xsl:with-param>
    </xsl:call-template>
      <body onLoad="document.eform.body.value=''; document.eform['abstract'].value=''; document.eform.name.focus();">
				<xsl:call-template name="header">
					<xsl:with-param name="create">true</xsl:with-param>				
				</xsl:call-template>
        <div class="edit">
            <div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-create"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
          <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" enctype="multipart/form-data" id="create-edit-form">
                
            <input type="hidden" name="objtype" value="{$objtype}"/>
              <xsl:call-template name="tr-locationtitle-create"/>
              <xsl:call-template name="tr-body-create"/>
              <xsl:call-template name="tr-bodyfromfile-create"/>
              <xsl:call-template name="tr-keywords-create"/>
              <xsl:call-template name="tr-abstract-create"/>
              <xsl:call-template name="tr-minify"/>
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
  
  <xsl:template name="tr-minify"/>
  
</xsl:stylesheet>

