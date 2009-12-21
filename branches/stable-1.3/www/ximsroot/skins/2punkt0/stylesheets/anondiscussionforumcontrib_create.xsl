<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforumcontrib_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>
  <xsl:import href="anondiscussionforum_common.xsl"/>

  <xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

  <xsl:template match="/document/context/object">
    <html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">create</xsl:with-param>
			</xsl:call-template>
			
		<body>
		
			<xsl:call-template name="header">
			<xsl:with-param name="containerpath">true</xsl:with-param>
			</xsl:call-template>
            
        <div class="edit">
				<div id="tab-container" class="ui-corner-top">
				<div id="create-title"><h1><xsl:value-of select="$i18n/l/Create_topic"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$i18n/l/Discussionforum"/>&#160;'<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/title"/>'
				</h1></div>
				</div>
				<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
				<div id="content-container" class="ui-corner-bottom ui-corner-tr">
        <!--<xsl:call-template name="forum"/>-->
        <xsl:call-template name="write-topic"/>
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

<xsl:template name="title-create"><xsl:value-of select="$i18n/l/Create_topic"/> - XIMS</xsl:template>
<xsl:template name="head-create_discussionforum">
    <head>
        <title><xsl:value-of select="$i18n/l/Create_topic"/> - XIMS</title>
        <xsl:call-template name="css"/>
    </head>
</xsl:template>

</xsl:stylesheet>
