<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="edit_common.xsl"/>

<xsl:template name="edit-content">
		<xsl:call-template name="form-locationtitle-edit"/>
		<xsl:call-template name="form-marknew-pubonsave"/>
		<xsl:call-template name="form-stylesheet-edit"/>
		<br clear="all"/>
</xsl:template>

<xsl:template name="form-stylesheet-edit">
<xsl:variable name="parentid" select="parents/object[/document/context/object/@parent_id=@document_id]/@id"/>
<div class="form-div div-left">
	<div>
			<div class="label-std">
				<label for="input-stylesheet">
					<xsl:value-of select="$i18n/l/Stylesheet"/>
				</label>
			</div>
			<input type="text" name="stylesheet" size="60" value="{style_id}" id="input-stylesheet"/>
			<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Stylesheet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Stylesheet"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>-->
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=Folder;sbfield=eform.stylesheet','default-dialog','{$i18n/l/Browse_stylesheet}')" class="doclink"><xsl:value-of select="$i18n/l/Browse_stylesheet"/>&#160;(<xsl:value-of select="$i18n/l/Folder"/>)</a>
    </div>
</div>
</xsl:template>

</xsl:stylesheet>
