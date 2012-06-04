<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: file_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="create_common.xsl"/>
	
	<xsl:param name="testlocation" select="false()"/>
	
	<xsl:template name="create-content">
	<xsl:call-template name="form-titlefile-create"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
		<!--<xsl:call-template name="tr-title-create"/>
		<xsl:call-template name="tr-file-create"/>-->
		<!-- TODO                          
                                2) Hide other form fields
                                3) Only show overwrite fied when unzip contents has been checked
                        -->
		<div id="tr-unzip" style="display: none;" class="block">
			<span class="sprite-spacer">&#160;&#160;</span>
			<label for="input-unzip">
				<xsl:value-of select="$i18n/l/UnzipContents"/>
			</label>
			<input type="checkbox" name="unzip" value="1" id="input-unzip" class="checkbox" />
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Unzip Contents')" class="doclink">(?)</a>
			<span class="sprite-spacer">&#160;&#160;&#160;</span>
			<label for="input-overwrite">
				<xsl:value-of select="$i18n/l/OverwriteUnzip"/>
			</label>
			<input type="checkbox" name="overwrite" value="1" id="input-overwrite" class="checkbox" disabled="disabled"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Overwrite when unzipping contents')" class="doclink">(?)</a>
		</div>
		
				<xsl:call-template name="form-keywordabstract"/>

		<!--<xsl:call-template name="tr-keywords-create"/>
		<xsl:call-template name="tr-abstract-create"/>-->
		<!--<xsl:call-template name="markednew"/>
		<xsl:call-template name="publish-on-save"/>-->
		<xsl:call-template name="form-grant"/>
		<xsl:call-template name="uploadaction"/>
	</xsl:template>
	
	<xsl:template name="file-create">
		<div id="tr-file">
			<div class="label-std">
				<label for="input-file">
					<xsl:value-of select="$i18n/l/File"/>
				</label>&#160;*</div>
			<input type="file" name="file" size="43" class="text" id="input-file" />
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('File')" class="doclink">(?)</a>
		</div>
		<script type="text/javascript">
		$(document).ready(function(){
			$('#input-file').change(function(){
			checkZIP()});
			$('#input-unzip').change(function(){
			alert("changed");
			checkUnzip()});
		});
			function checkZIP(){
				if($('#input-file').val().match(/\.zip/i)=='.zip'){
					$('#tr-unzip').show();
				}
				else{ 
					$('#tr-unzip').hide();
					}
			}
			function checkUnzip(){
				if($('#input-unzip').is(':checked')){
					$('#input-overwrite').removeAttr('disabled');
				}
				else{
					$('#input-overwrite').attr('disabled', 'disabled');
				}
			}
		</script>
	</xsl:template>
	<xsl:template name="uploadaction">
		<input type="hidden" name="id" value="{/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}"/>
		<input type="submit" name="store" value="{$i18n/l/upload}" class="control hidden" id="store"/>
	</xsl:template>
	
	<xsl:template name="saveedit"/>
	
	<xsl:template name="form-titlefile-create">
	<div class="form-div ui-corner-all div-left">
		<xsl:call-template name="form-title"/>
		<xsl:call-template name="file-create"/>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
