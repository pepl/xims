<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: folder_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="view_common.xsl"/>
	<xsl:import href="container_common.xsl"/>
	
	<xsl:variable name="deleted_children">
		<xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])"/>
	</xsl:variable>
	<xsl:param name="createwidget">default</xsl:param>
	
	<xsl:template name="view-content">
		<xsl:call-template name="childrentable"/>
		<xsl:call-template name="pagenavtable"/>
		
	</xsl:template>
	
</xsl:stylesheet>
