<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="dyn">

	<xsl:import href="common.xsl"/>
	<xsl:param name="request.uri"/>
	<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
	<xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>
	<xsl:variable name="objid">
    <xsl:value-of select="substring-after($request.uri.query,'objid=')"/>
  </xsl:variable>
	<xsl:template match="/document/context/object">
					<form action="{$xims_box}{$goxims_content}" name="eform" method="post" id="property-form">						
                      <xsl:call-template name="input-token"/>
                      <input type="hidden" name="id" id="id" value="{@id}"/>
						<xsl:if test="$objid != ''"><input type="hidden" name="objid" id="objid" value="{$objid}"/></xsl:if>
						<xsl:if test="$objid != ''"><input type="hidden" name="objid" id="objid" value="{$objid}"/></xsl:if>
						<xsl:apply-templates select="/document/context/object/children"/>
					</form>
	</xsl:template>
	
	<xsl:template match="children/object">
		<div>
			<div class="label-std">
				<label for="vlkeyword_name">
					<xsl:value-of select="$i18n/l/Name"/>
				</label>
			</div>
			<input type="text" id="vlkeyword_name" name="vlkeyword_name" size="40" value="{name}"/>
		</div>
		<br/>
		<div>
			<div class="label-std">
				<label for="vlkeyword_description">
					<xsl:value-of select="$i18n_vlib/l/description"/>
				</label>
			</div>
			<textarea id="vlkeyword_description" name="vlkeyword_description" cols="38" rows="3" class="text">
				<xsl:value-of select="description"/>
                <xsl:comment/>
			</textarea>
		</div>
		<br/>
		<div>
		<input type="hidden" name="vlkeyword_id" id="vlkeyword_id" value="{@id}"/>
		<input type="hidden" name="property" id="property" value="keyword"/>
		<input type="hidden" name="property_store" id="property_store" />
		<button type="submit" name="property_store" class="button" accesskey="S"><xsl:value-of select="$i18n/l/save"/></button>&#160;
		<button type="button" name="cancel" class="button" accesskey="C" onclick="closeDialog('default-dialog');"><xsl:value-of select="$i18n/l/cancel"/></button>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
