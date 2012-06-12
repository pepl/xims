<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="dyn">

  <xsl:import href="vlibrary_subject_edit.xsl"/>
  <xsl:import href="common_tinymce_scripts.xsl"/>
	
	<xsl:param name="request.uri"/>
  <xsl:variable name="objid">
    <xsl:value-of select="substring-after($request.uri.query,'objid=')"/>
  </xsl:variable>
	
  <xsl:template match="/document/context/object">
    <!--<html>
      <head>
        <title>
          <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n/l/subjects)"/>
        </title>
        <xsl:call-template name="css"/>
        <xsl:call-template name="script_head"/>
      </head>
      <body>
        <div id="content-container">-->
          <form action="{$xims_box}{$goxims_content}"
                name="eform"
                method="get" id="create-edit-form">
            <input type="hidden" 
                   name="id" 
                   id="id" 
                   value="{@id}"/>
            <xsl:if test="$objid != ''"><input type="hidden" name="objid" id="objid" value="{$objid}"/></xsl:if>
            <xsl:apply-templates select="/document/context/object/children"/>
          </form>
        <!--</div>
        <xsl:call-template name="script_bottom"/>
        <xsl:call-template name="tinymce_load"/>
        <xsl:call-template name="tinymce_simple"/>
      </body>
    </html>-->
		<!--<xsl:call-template name="tinymce_load"/>-->
        <!--<xsl:call-template name="tinymce_simple"/>-->
  </xsl:template>

  <xsl:template match="children/object">

        <!--<h1><xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/subject)"/></h1>
          <div>-->
			<div class="label-std">
				<label for="vlsubject_name"><xsl:value-of select="$i18n/l/Name"/></label>
			</div>
      <input type="text" id="vlsubject_name" name="vlsubject_name" size="40" value="{name}" />
    <!--</div>-->
    <div>
			<div class="label-std">
        <label for="vlsubject_description"><xsl:value-of select="$i18n_vlib/l/description"/></label>
      </div>
      <textarea id="vlsubject_description" name="vlsubject_description" cols="38" rows="10" class="mceEditor" >
        <xsl:value-of select="description"/>
      </textarea>
		</div>
    <br/>
    <p>
      <input type="hidden" name="vlsubject_id" id="vlsubject_id" value="{@id}"/>
			<input type="hidden" name="property" id="property" value="subject"/>
			<button type="submit" name="property_store" class="button" accesskey="S"><xsl:value-of select="$i18n/l/save"/></button>&#160;
      <button type="submit" name="cancel" class="button" accesskey="C" onclick="self.close();"><xsl:value-of select="$i18n/l/cancel"/></button>
    </p>
  </xsl:template>

</xsl:stylesheet>
