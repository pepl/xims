<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: gallery_create.xsl 2239 2009-08-03 09:35:54Z haensel $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="create_common.xsl"/>
<xsl:import href="container_common.xsl"/>
<xsl:import href="gallery_common.xsl"/>

<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

<xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
    <xsl:call-template name="form-nav-options"/>
	<xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="form-obj-specific"/>
	<xsl:call-template name="form-grant"/>
	<br class="clear"/>
</xsl:template>

</xsl:stylesheet>
