<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
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
	
	<!--<xsl:call-template name="form-vlsubjects-edit"/>
	<xsl:call-template name="form-vlkeywords-edit"/>-->
	
	
	<xsl:call-template name="form-obj-specific"/>
</xsl:template>

<!--<xsl:template name="form-keywords"/>-->


<!--<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="common-head">
        <xsl:with-param name="mode">edit</xsl:with-param>
        <xsl:with-param name="calendar" select="true()" />
    </xsl:call-template>
    <body>
        --><!-- TODO: 
            * post_async is currently not loaded
            * should be moved to a script-bottom template together with vlibrary_edit.js
            * post_async should post with OBJECT_ID and not LOCATION_PATH
            * JQuery API should be used
            * when adding or deleting a property the iframed (thickbox) page should be reloaded
        --><!--
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="heading"><xsl:with-param name="mode">edit</xsl:with-param></xsl:call-template>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" enctype="multipart/form-data">
                <table border="0" width="98%">
                    <xsl:call-template name="form-locationtitle-edit_urllink"/>
                    <xsl:call-template name="tr-vlsubjects-edit"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-vlkeywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="publish-on-save"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>-->

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
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
    </div>
    
    </div>
</xsl:template>


	
	
	
</xsl:stylesheet>
