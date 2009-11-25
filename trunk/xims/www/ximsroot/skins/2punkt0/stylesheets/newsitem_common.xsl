<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="document_common.xsl"/>
<xsl:import href="common_jscalendar_scripts.xsl"/>
<xsl:variable name="i18n_news" select="document(concat($currentuilanguage,'/i18n_newsitem.xml'))" />
<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

<xsl:template name="tr-leadimage-create">
	<xsl:call-template name="tr-leadimage">
		<xsl:with-param name="mode">create</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="tr-leadimage">
<xsl:param name="mode"/>
<div id="tr-lead">
			<div id="label-lead">
				<label for="input-lead">
					<xsl:value-of select="$i18n/l/Lead"/>
				</label>
							</div>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
			<br/>
			<textarea id="input-lead" name="lead" rows="3" cols="79" onkeyup="keyup(this)">
				<xsl:apply-templates select="abstract"/>
			</textarea>
			<script type="text/javascript">document.getElementsByName("lead")[0].value = '';</script>
            <xsl:text>&#160;</xsl:text><span id="charcount"><xsl:text>&#160;</xsl:text></span>
            <xsl:call-template name="charcountcheck"/>
		</div>
		
		<xsl:if test="$mode='edit'">
			<xsl:call-template name="tr-image-edit"/>
		</xsl:if>
		<xsl:if test="$mode='create'">
			<xsl:call-template name="tr-image-create"/>
			
			 <div id="tr-image-title">
        <div id="label-image-title"> <label for="input-image-title">
            <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="$i18n/l/Title"/>
        </label></div>
            <input type="text" name="imagetitle" size="60" class="text" id="input-image-title"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ImageTitle')" class="doclink">(?)</a>
      </div>

    <div id="tr-image-description">
        <div id="label-image-description"> <label for="input-image-description">
            <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="$i18n/l/Description"/>
            </label></div>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ImageDescription')" class="doclink">(?)</a>
            <br/>
            <textarea name="imagedescription" rows="3" cols="79" class="text" id="input-image-description"><xsl:text>&#160;</xsl:text></textarea>
            <script type="text/javascript">document.getElementsByName("imagedescription")[0].value = '';</script>
      </div>

<div id="tr-image-target">
        <div id="label-image-target"> <label for="input-image-target">
            <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="$i18n/l/target"/>
            </label>
         </div>
            <input type="text" name="imagefolder" size="60" class="text" id="input-image-target">
                <!--  Provide an "educated-guess" default value -->
                <xsl:attribute name="value">
                    <xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="location"/>
                    </xsl:for-each><xsl:text>/images</xsl:text>
                </xsl:attribute>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};to={$parentid};otfilter=Folder,DepartmentRoot,SiteRoot;contentbrowse=1;sbfield=eform.imagefolder')" class="doclink"><xsl:value-of select="$i18n/l/browse_target"/></a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('NewsItemImage')" class="doclink">(?)</a>
        </div>
      
		</xsl:if>
		</xsl:template>

<xsl:template name="tr-leadimage-edit">
<xsl:call-template name="tr-leadimage">
<xsl:with-param name="mode">edit</xsl:with-param>
</xsl:call-template>
</xsl:template>

<xsl:template name="charcountcheck">
    <script type="text/javascript">
    var str_of  = '<xsl:value-of select="$i18n_news/l/of"/>';
    var str_entered = '<xsl:value-of select="$i18n_news/l/Characters_entered"/>';
    var str_charlimit  = '<xsl:value-of select="$i18n_news/l/Charlimit_reached"/>';
    var maxKeys = 390; // Should this be a config.xsl value?
    
    //keyup( document.getElementsByName("abstract")[0] );
    </script>

</xsl:template>

</xsl:stylesheet>
