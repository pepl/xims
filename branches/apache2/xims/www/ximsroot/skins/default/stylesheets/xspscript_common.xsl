<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xspscript_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:template name="processxsp">
		<div class="form-div block">
		<div>
			<div class="label">
				<label for="input-processxsp"><xsl:value-of select="$i18n/l/Process_XSP"/></label>
			</div>
				<input name="processxsp" type="checkbox" class="checkbox" id="input-processxsp">
					<xsl:if test="attributes/processxsp = '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>				
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('processxsp')" class="doclink">(?)</a>-->
				</div>
		</div>
	</xsl:template>
<!--	<xsl:template name="processxsp">
		<div>
			<fieldset>
				<legend><xsl:value-of select="$i18n/l/Process_XSP"/></legend>
				<input name="processxsp" type="radio" value="true" class="radio-button" id="process-true">
					<xsl:if test="attributes/processxsp = '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="process-true">
					<xsl:value-of select="$i18n/l/Yes"/>
				</label>
				<input name="processxsp" type="radio" value="false" class="radio-button" id="process-false">
					<xsl:if test="attributes/processxsp != '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="process-false">
					<xsl:value-of select="$i18n/l/No"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('processxsp')" class="doclink">(?)</a>
			</fieldset>
		</div>
	</xsl:template>
--></xsl:stylesheet>
