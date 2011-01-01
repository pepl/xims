<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common.xsl"/>

<!--<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:if test="$edit != ''">
                <xsl:call-template name="heading"><xsl:with-param name="mode">edit</xsl:with-param></xsl:call-template>
                <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                        <xsl:call-template name="form-locationtitle-edit"/>
                        <xsl:call-template name="form-marknew-pubonsave"/>
                        <xsl:call-template name="tr-stylesheet-edit"/>
                        <xsl:call-template name="tr-pagerowlimit-edit"/>
                    <xsl:call-template name="saveedit"/>
                </form>
            </xsl:if>

        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>-->

<xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitle-edit"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<div class="form-div block">
		<xsl:call-template name="tr-stylesheet-edit"/>
		<xsl:call-template name="tr-pagerowlimit-edit"/>
	</div>
</xsl:template>


<xsl:template name="tr-stylesheet-edit">

<xsl:variable name="parentid" select="parents/object[/document/context/object/@parent_id=@document_id]/@id"/>
<div>
    <div class="label-std"><label for="input-stylesheet"><xsl:value-of select="$i18n/l/Stylesheet"/></label></div>
        <input type="text" name="stylesheet" size="60" value="{style_id}" class="text" id="input-stylesheet"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=Folder;sbfield=eform.stylesheet')" class="button"><xsl:value-of select="$i18n/l/Browse_stylesheet"/>&#160;(<xsl:value-of select="$i18n/l/Folder" />)</a>
</div>
</xsl:template>

<xsl:template name="tr-pagerowlimit-edit">
    <div>
        <div class="label"><label for="input-pagerowlimit"><xsl:value-of select="$i18n/l/PageRowLimit"/></label></div>&#160;
            <input type="text" name="pagerowlimit" size="2" maxlength="2" value="{attributes/pagerowlimit}" class="text" id="input-pagerowlimit"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PageRowLimit')" class="doclink">(?)</a>
    </div>
</xsl:template>


</xsl:stylesheet>
