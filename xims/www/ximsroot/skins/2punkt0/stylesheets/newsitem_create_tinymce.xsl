<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_create_htmlarea.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="create_common.xsl"/>
<xsl:import href="document_create_tinymce.xsl"/>
<xsl:import href="document_common.xsl"/>
<xsl:import href="newsitem_common.xsl"/>

<xsl:param name="selEditor" select="true()"/>

<xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<xsl:call-template name="form-leadimage-create"/>
	<xsl:call-template name="form-body-create_tinymce"/>
	<xsl:call-template name="jsorigbody"/>
	<xsl:call-template name="form-metadata"/>
	
	<xsl:call-template name="form-grant"/>
</xsl:template>

</xsl:stylesheet>
