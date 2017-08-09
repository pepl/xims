<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="newsitem_edit_tinymce.xsl"/>
  <xsl:import href="vlibraryitem_document_edit.xsl"/>

  <xsl:param name="testlocation" select="true()"/>
  <xsl:param name="tinymce_version" select="4"/>
  <xsl:param name="selEditor">wysiwyg</xsl:param>
  <xsl:param name="tinymce">1</xsl:param>

  <xsl:template name="edit-content">
	<xsl:call-template name="form-locationtitlesubtitle-edit"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
    <xsl:call-template name="form-leadimage-edit"/>
    <xsl:choose>
      <xsl:when test="document_role='newslink'">
        <xsl:call-template name="form-link"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="form-body-edit_tinymce"/>
        <xsl:call-template name="social-bookmarks"/> 
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="expandrefs"/>
	<xsl:call-template name="form-metadata"/>
		
	<div class="form-div block">
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'keyword'"/>
	  </xsl:call-template>
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'subject'"/>
	  </xsl:call-template>
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'author'"/>
	  </xsl:call-template>
	  <xsl:call-template name="form-vlproperties">
		<xsl:with-param name="mo" select="'publication'"/>
	  </xsl:call-template>
	</div>

	<xsl:call-template name="form-obj-specific"/>
       
	<xsl:call-template name="xmlhttpjs"/>

  </xsl:template>
 
  <xsl:template name="form-vlproperties">
	<xsl:param name="mo"/>
	<xsl:param name="property"><xsl:value-of select="$i18n_vlib/l/*[name()=$mo]"/></xsl:param>
	<div class="form-div block">
	  <div class="block">
		<div class="label-large">
		  <xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
		  <xsl:text>&#160;</xsl:text>
		  <xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>:
		</div>
		<div id="mapped_{$mo}s">
		  <xsl:choose>
			<xsl:when test="$mo='author'">
			  <xsl:apply-templates select="authorgroup/author"/>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:apply-templates select="*[name()=concat($mo, 'set')]/*[name()=$mo]"/>
			</xsl:otherwise>
		  </xsl:choose>
		  <span id="message_{$mo}"><xsl:comment/></span>
		  <xsl:text>&#160;</xsl:text>
		</div>
	  </div>
	  <div>
		<div class="label-large">
		  <label for="vl{$mo}">
			<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
			<xsl:text>&#160;</xsl:text>
			<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>
		  </label>
		</div>
		<xsl:if test="/document/context/*[name()=concat('vl', $mo,'s')]">
		  <span id="svl{$mo}container">
			<xsl:apply-templates select="/document/context/*[name()=concat('vl', $mo,'s')]"/>
		  </span>
		  <xsl:text>&#160;</xsl:text>
		  <button type="button" name="create_mapping" class="button" onclick="createMapping('{$mo}', $('#svl{$mo}').val(), '{$i18n_vlib/l/select_name}')"><xsl:value-of select="$i18n_vlib/l/Create_mapping" /></button>
		  <xsl:text>&#160;</xsl:text>
		</xsl:if>
		<xsl:choose>
		  <xsl:when test="$mo='subject'">
			<a class="button" href="javascript:createTinyMCEDialog('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1&amp;property={$mo}&amp;objid={@id}','default-dialog','{$i18n/l/create} {$property}','vlsubject_description')">
			  <xsl:value-of select="concat($i18n/l/create, ' ', $property)"/>
			</a>
		  </xsl:when>
		  <xsl:otherwise>
			<a class="button" href="javascript:createDialog('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1&amp;property={$mo}&amp;objid={@id}','default-dialog','{$i18n/l/create} {$property}')">
			  <xsl:value-of select="concat($i18n/l/create, ' ', $property)"/>
			</a>
		  </xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#160;</xsl:text>
	  </div>
	</div>
  </xsl:template>
 
  <xsl:template name="form-metadata">
    <div class="form-div block">
	  <h2><xsl:value-of select="$i18n/l/Metadata"/></h2>
	  <xsl:call-template name="form-valid_from"/>
	  <xsl:call-template name="form-valid_to"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
