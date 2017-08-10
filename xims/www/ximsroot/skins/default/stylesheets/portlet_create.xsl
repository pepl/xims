<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: portlet_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="portlet_common.xsl"/>	
	<xsl:import href="create_common.xsl"/>
	
	<xsl:template name="create-content">
		<!--<xsl:call-template name="tr-locationtitletarget-create"/>-->
		<xsl:call-template name="form-locationtitletarget-create"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="form-grant"/>
		<xsl:call-template name="form-obj-specific"/>
		<xsl:call-template name="contentfilters"/>
		<br class="clear"/>
	</xsl:template>
	
	<xsl:template name="add-documentlinks"/>
	
	
</xsl:stylesheet>
