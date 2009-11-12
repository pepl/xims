<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: file_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default">
			<xsl:with-param name="mode">create</xsl:with-param>
    </xsl:call-template>
   <!-- <body onLoad="document.eform['abstract'].value='';"> -->
    <body>                       
				<xsl:call-template name="header">
					<xsl:with-param name="create">true</xsl:with-param>				
				</xsl:call-template>
        <div class="edit">
            <div id="tab-container" class="ui-corner-top">
						<xsl:call-template name="table-create"/>
					</div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
					<div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" enctype="multipart/form-data" id="create-edit-form">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                    <xsl:call-template name="tr-file-create"/>
                        <!-- TODO
                                1) I18N.alize
                                2) Hide other form fields
                                3) Only show overwrite fied when unzip contents has been checked
                        -->
                        <div id="tr-unzip">
                        <span class="sprite-spacer">&#160;&#160;&#160;&#160;&#160;</span>
                       <label for="input-unzip"><xsl:value-of select="$i18n/l/UnzipContents"/></label>                  
                        <input type="checkbox" name="unzip" value="1" id="input-unzip" class="checkbox"/>
                            <xsl:text>&#160;</xsl:text>
                            <a href="javascript:openDocWindow('Unzip Contents')" class="doclink">(?)</a>
                        <!--</div> 
                       
												<div id="tr-overwrite">-->
												<span class="sprite-spacer">&#160;&#160;&#160;&#160;&#160;</span>
                        <label for="input-overwrite"><xsl:value-of select="$i18n/l/OverwriteUnzip"/></label>                 
                        <input type="checkbox" name="overwrite" value="1" id="input-overwrite" class="checkbox"/>
                            <xsl:text>&#160;</xsl:text>
                            <a href="javascript:openDocWindow('Overwrite when unzipping contents')" class="doclink">(?)</a>
												</div>
												
                    <xsl:call-template name="tr-title-create"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="grantowneronly"/>

                <xsl:call-template name="uploadaction"/>
            </form>
        </div>
					<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
				</div>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-file-create">
<div id="tr-file">
	<div id="label-file"><label for="input-file">
			<span class="compulsory"><xsl:value-of select="$i18n/l/File"/></span>
	</label></div>
            <input type="file" name="file" size="49" class="text input" id="input-file" />
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('File')" class="doclink">(?)</a>
  </div>
</xsl:template>

<xsl:template name="uploadaction">
    <input type="hidden" name="id" value="{/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}"/>
    <input type="submit" name="store" value="{$i18n/l/upload}" class="control hidden"/>
</xsl:template>

</xsl:stylesheet>
