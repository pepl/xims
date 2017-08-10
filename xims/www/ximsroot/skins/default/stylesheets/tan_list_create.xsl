<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: tan_list_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="create_common.xsl"/>

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template name="create-content">
	 <xsl:call-template name="form-locationtitle-create"/>
	 <xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-tannumber-create"/>
		<xsl:call-template name="form-keywordabstract"/>
		<xsl:call-template name="form-grant"/>
		
</xsl:template>

<xsl:template name="form-tannumber-create">
<div class="form-div block">
    <div id="tr-tan-number">
        <div class="label-med"><label for="input-tan-number"><xsl:value-of select="$i18n_qn/l/TAN_number"/></label> *</div>
        <input type="text" name="number" size="10" class="text" id="input-tan-number"/>
    </div>
    </div>
</xsl:template>

</xsl:stylesheet>

