<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common.xsl"/>

<xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitle-edit"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<div class="form-div block">
		<xsl:call-template name="form-stylesheet-edit"/>
		<xsl:call-template name="tr-pagerowlimit-edit"/>
	</div>
</xsl:template>


<xsl:template name="form-stylesheet-edit">

<xsl:variable name="parentid" select="parents/object[/document/context/object/@parent_id=@document_id]/@id"/>
<div>
    <div class="label-std"><label for="input-stylesheet"><xsl:value-of select="$i18n/l/Stylesheet"/></label></div>
        <input type="text" name="stylesheet" size="60" value="{style_id}" class="text" id="input-stylesheet"/>
        <!--<xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>-->
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$parentid}&amp;contentbrowse=1&amp;to={$parentid}&amp;otfilter=Folder&amp;sbfield=eform.stylesheet','default-dialog','{$i18n/l/Browse_stylesheet}')" class="button">
        	<xsl:value-of select="$i18n/l/Browse_stylesheet"/>&#160;(<xsl:value-of select="$i18n/l/Folder" />)
		</a>
</div>
</xsl:template>

<xsl:template name="tr-pagerowlimit-edit">
    <div>
        <div class="label"><label for="input-pagerowlimit"><xsl:value-of select="$i18n/l/PageRowLimit"/></label></div>&#160;
            <input type="text" name="pagerowlimit" size="2" maxlength="2" value="{attributes/pagerowlimit}" class="text" id="input-pagerowlimit"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PageRowLimit')" class="doclink">(?)</a>-->
    </div>
</xsl:template>


</xsl:stylesheet>
