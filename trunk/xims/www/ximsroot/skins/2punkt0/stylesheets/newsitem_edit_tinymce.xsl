<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_edit_tinymce.xsl 1589 2006-10-11 09:38:47Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="edit_common.xsl"/>
	<xsl:import href="document_edit_tinymce.xsl"/>
	<xsl:import href="document_common.xsl"/>
	<xsl:import href="newsitem_common.xsl"/>
	
	<xsl:param name="selEditor" select="true()"/>
	
	<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-leadimage-edit"/>
		<xsl:call-template name="form-body-edit_tinymce"/>
		<xsl:call-template name="form-metadata"/>
		<xsl:call-template name="expandrefs"/>
	</xsl:template>

</xsl:stylesheet>
