<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: sqlreport_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="create_common.xsl"/>
  <xsl:import href="sqlreport_common.xsl"/>  

<xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:call-template name="form-body-create"/>
	<xsl:call-template name="form-keywordabstract"/>
	<!--<xsl:call-template name="pagesize"/>
	<xsl:call-template name="skeys"/>
	<xsl:call-template name="dbdsn"/>
	<xsl:call-template name="dbuser"/>
	<xsl:call-template name="dbpwd"/>-->
	<xsl:call-template name="form-grant"/>
	<xsl:call-template name="form-obj-specific"/>
</xsl:template>

</xsl:stylesheet>

