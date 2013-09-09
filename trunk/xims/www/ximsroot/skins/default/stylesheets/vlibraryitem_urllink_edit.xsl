<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_urllink_edit.xsl 2189 2009-01-04 12:16:45Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="vlibraryitem_common.xsl"/>
<xsl:import href="edit_common.xsl"/>

<xsl:param name="vlib" select="true()"/>

<xsl:template name="edit-content">
	<xsl:call-template name="tr-locationtitle-edit_urllink"/>
	<xsl:call-template name="form-marknew-pubonsave"/>

	<xsl:call-template name="form-metadata">
		<xsl:with-param name="mode">chronicle</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'subject'"/>
	</xsl:call-template>
	<xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'keyword'"/>
	</xsl:call-template>
	
	<xsl:call-template name="form-obj-specific"/>
</xsl:template>

<xsl:template name="tr-locationtitle-edit_urllink">
    <div class="form-div div-left">
    <xsl:call-template name="form-title"/>
    <div>
        <div class="label-std">
            <label for="input-location"><xsl:value-of select="$i18n/l/Location"/></label>
        </div>
            <input type="text" class="text" name="name" size="60" id="input-location">
                <xsl:choose>
                    <xsl:when test="string-length(symname_to_doc_id) > 0 ">
                        <xsl:attribute name="value"><xsl:value-of select="symname_to_doc_id"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="value"><xsl:value-of select="location"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </input>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>-->
    </div>
    
    </div>
</xsl:template>

</xsl:stylesheet>
