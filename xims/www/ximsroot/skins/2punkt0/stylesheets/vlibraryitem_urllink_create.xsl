<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
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
<!--	<xsl:call-template name="tr-chronicle_from"/>-->
	<xsl:call-template name="form-chronicle_from"/>
	<!--<xsl:call-template name="tr-chronicle_to"/>-->
	<xsl:call-template name="form-chronicle_to"/>
	</div>
	
	<!--For consistency with other VLib-Objects we deactivate theese fields in create-mode-->
	
	<!--<div class="form-div block">
	<xsl:call-template name="tr-vlsubjects-create"/>
	<xsl:call-template name="tr-vlkeywords-create"/>
	</div>-->
	<!--<xsl:call-template name="form-keywordabstract"/>
	<xsl:call-template name="tr-mediatype"/>
	<xsl:call-template name="tr-coverage"/>
	<xsl:call-template name="tr-audience"/>
	<xsl:call-template name="tr-legalnotice"/>
	<xsl:call-template name="tr-bibliosource"/>               -->
</xsl:template>

<xsl:template name="keywords"/>

<!--<xsl:template match="/document/context/object">
<html>
    <head>
    <xsl:call-template name="common-head">
        <xsl:with-param name="mode">create</xsl:with-param>
        <xsl:with-param name="calendar" select="true()" />
    </xsl:call-template>
    <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript" ></script>
    </head>
    <body onload="document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
           <xsl:call-template name="heading"><xsl:with-param name="mode">create</xsl:with-param></xsl:call-template>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="form-locationtitle-create"/>
                    <xsl:call-template name="tr-subtitle"/>
                    <xsl:call-template name="tr-vlsubjects-create"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-vlkeywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>               
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="publish-on-save"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>-->

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
