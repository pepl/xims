<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
	
	<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template name="tan-list">
	<xsl:value-of select="$i18n_qn/l/TAN_number" />:<xsl:value-of select="attributes/number" /><br/>
	<form action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" style="margin-left:5px; margin-bottom: 0px;">
    	<input type="hidden" name="parid" value="{@document_id}" />
		<input type="submit" name="download" value="CSV" />&#160;
<!--		<input type="submit" name="download" value="Download Excel" />-->
	</form>
</xsl:template>

</xsl:stylesheet>

