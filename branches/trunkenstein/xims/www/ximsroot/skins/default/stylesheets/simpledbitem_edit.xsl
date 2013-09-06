<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: simpledbitem_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="edit_common.xsl"/>
	<xsl:import href="simpledb_common.xsl"/>
	
	<xsl:param name="calendar" select="true()"/>
	
	<xsl:template name="edit-content">
		<xsl:call-template name="error_msg"/>
		<xsl:apply-templates select="/document/member_properties/member_property">
					<xsl:sort select="position" order="ascending" data-type="number"/>
				</xsl:apply-templates>
		<xsl:call-template name="form-abstract"/>
	</xsl:template>
</xsl:stylesheet>
