<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: tan_list_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="view_common.xsl"/>
	<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))"/>
	<xsl:template name="view-content">
		<div id="docbody"><xsl:comment/>
			<xsl:call-template name="tan-list"/>
		</div>
	</xsl:template>
	<xsl:template name="tan-list">
		<p>
			<xsl:value-of select="$i18n_qn/l/TAN_number"/>: <xsl:value-of select="attributes/number"/>
		</p>
		<xsl:value-of select="$i18n_qn/l/Download"/>:
    <ul>
			<li>
				<a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id}&amp;target=_blank&amp;download=HTML">HTML</a>
			</li>
			<li>
				<a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id}&amp;target=_blank&amp;download=TXT">Text</a>
			</li>
			<li>
				<a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id}&amp;target=_blank&amp;download=CSV">CSV</a>
			</li>
			<li>
				<a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id}&amp;target=_blank&amp;download=Excel">MS Excel</a>
			</li>
		</ul>
	</xsl:template>
</xsl:stylesheet>
