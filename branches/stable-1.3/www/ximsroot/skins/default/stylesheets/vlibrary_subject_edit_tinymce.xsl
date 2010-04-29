<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="exslt">

  <xsl:import href="vlibrary_subject_edit.xsl"/>
  <xsl:import href="common_tinymce_scripts.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title>
          <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n/l/subjects)"/>
        </title>
        <xsl:call-template name="css"/>
        <xsl:call-template name="script_head"/>
      </head>
      <body>
        <div style="margin:0.66em;padding:0.33em;background-color:#eeeeee;">
          <form action="{$xims_box}{$goxims_content}"
                name="eform"
                method="get">
            <input type="hidden" 
                   name="id" 
                   id="id" 
                   value="{@id}"/>
            <xsl:apply-templates select="/document/context/object/children"/>
          </form>
        </div>
        <xsl:call-template name="script_bottom"/>
        <xsl:call-template name="tinymce_load"/>
    <xsl:call-template name="jqtinymce_load"/>
        <xsl:call-template name="tinymce_simple"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="children/object">
    <fieldset>
      <legend>
        <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/subject)"/>
      </legend>
      <table>
        <tr>
          <td>
          <label for="vlsubject_name">
            Name
          </label>
          </td>
          <td colspan="2">
            <input tabindex="40" 
                   type="text" 
                   id="vlsubject_name" 
                   name="vlsubject_name" 
                   size="25" 
                   value="{name}" 
                   class="text" 
                   title="{$i18n_vlib/l/name}"/>
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <label for="vlsubject_description">
              <xsl:value-of select="$i18n_vlib/l/description"/>
            </label>
            <br />
            <textarea tabindex="40" 
                      id="vlsubject_description" 
                      name="vlsubject_description" 
                      cols="90"
                      rows="20"
                      class="mceEditor" 
                      title="{$i18n_vlib/l/description}">
              <xsl:value-of select="description"/>
            </textarea>
          </td>
        </tr>
      </table>
    </fieldset>
    <p>
      <input type="hidden"
             name="vlsubject_id"
             id="vlsubject_id"
             value="{@id}"/>
      <input type="hidden"
             name="property"
             id="property"
             value="subject"/>
      <input type="submit"
             name="property_store"
             value="{$i18n/l/save}"
             class="control"
             accesskey="S"/>
      <input type="submit"
             name="cancel"
             value="{$i18n/l/cancel}"
             class="control"
             accesskey="C"
             onclick="self.close();"/>
    </p>
  </xsl:template>

</xsl:stylesheet>