<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_edit_tinymce.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="edit_common.xsl"/>
  <xsl:import href="document_common.xsl"/>
	
  <xsl:param name="tinymce" >1</xsl:param>
  <xsl:param name="selEditor">wysiwyg</xsl:param> 
  <xsl:param name="tinymce_version" select="4"/>  
	
  <xsl:template name="edit-content">
    <xsl:call-template name="form-locationtitle-edit"/>
    <xsl:call-template name="form-marknew-pubonsave"/>
    <xsl:call-template name="form-nav-options"/>
    <xsl:call-template name="form-body-edit_tinymce"/>
    <xsl:call-template name="jsorigbody"/>
    <xsl:call-template name="social-bookmarks"/>
    <xsl:call-template name="form-keywordabstract"/>
    <xsl:call-template name="expandrefs"/>
  </xsl:template>

  <xsl:template name="form-body-edit_tinymce">
    <div class="block form-div">
            <h2><label for="body">Body</label>
            <!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Body')" class="doclink">
			<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/>
				</xsl:attribute>(?)</a>--></h2>
      <textarea name="body" id="body" rows="20" cols="90">
        <xsl:value-of select="$bodycontent"/><xsl:comment/></textarea>
    </div>
  </xsl:template>

</xsl:stylesheet>
