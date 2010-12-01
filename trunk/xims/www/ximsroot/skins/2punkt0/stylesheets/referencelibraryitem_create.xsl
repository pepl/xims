<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">


<xsl:import href="create_common.xsl"/>
<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:param name="reflib">true</xsl:param>

<xsl:template name="create-content">
	<!--<input type="hidden" name="objtype" value="{$objtype}"/>-->
	<input type="hidden" name="reftype" value="{$reftype}"/>
	
	<xsl:call-template name="form-marknew-pubonsave"/>
					
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'author'"/>
		<xsl:with-param name="mode" select="'rl'"/>
	</xsl:call-template>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'editor'"/>
		<xsl:with-param name="mode" select="'rl'"/>
	</xsl:call-template>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'serial'"/>
		<xsl:with-param name="mode" select="'rl'"/>
	</xsl:call-template>
	
	<xsl:apply-templates select="/document/reference_properties/reference_property">
		<xsl:sort select="position" order="ascending" data-type="number"/>
	</xsl:apply-templates>

	<xsl:call-template name="form-abstractnotes"/>
	
	<!--<script type="text/javascript" language="javascript">
		var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,/document/context/object/location_path)"/>';
		var parentpath = '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path)"/>';
	</script>	-->				
	<script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
	<script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
	</xsl:template>
	
</xsl:stylesheet>

