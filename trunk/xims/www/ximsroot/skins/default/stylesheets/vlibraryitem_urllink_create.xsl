<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_urllink_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="vlibraryitem_common.xsl"/>
<xsl:import href="create_common.xsl"/>

<xsl:param name="vlib" select="true()"/>

<xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<div class="form-div block">
	<xsl:call-template name="form-subtitle"/>	
	<xsl:call-template name="tr-publisher"/>
	<xsl:call-template name="form-chronicle_from"/>
	<xsl:call-template name="form-chronicle_to"/>
	</div>
</xsl:template>

<xsl:template name="keywords"/>

<xsl:template name="tr-subject-create">
    <div>
        <div class="label-std"><label for="input-subject">Thema</label></div>
            <input type="text" name="subject" size="60" class="text" maxlength="256" id="input-subject"/>
            <xsl:text>&#160;</xsl:text>
<!--            <a href="javascript:openDocWindow('Subject')" class="doclink">(?)</a> -->
    </div>
</xsl:template>

<xsl:template name="tr-publisher-create">
    <div>
        <div class="label-std"><label for="input-publisher">Institution</label></div>
            <input type="text" name="publisher" size="60" class="text" maxlength="256" id="input-publisher" />
            <xsl:text>&#160;</xsl:text>
<!--            <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
    </div>
</xsl:template>


</xsl:stylesheet>
