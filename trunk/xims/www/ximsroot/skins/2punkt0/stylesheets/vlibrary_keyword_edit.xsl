<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common">

  <xsl:import href="common.xsl"/>

  <xsl:output method="xml"
              encoding="utf-8"
              media-type="text/html"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              omit-xml-declaration="yes"
              indent="yes"/>

  <xsl:variable name="i18n_vlib"
                select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>

  <xsl:variable name="i18n"
                select="document(concat($currentuilanguage,'/i18n.xml'))"/>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title>
        <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n/l/keywords)"/>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <div style="margin:0.66em;padding:0.33em;background-color:#eeeeee;">
          <form action="{$xims_box}{$goxims_content}"
              name="eform"
              method="GET">
          <input type="hidden" name="id" id="id" value="{@id}"/>
          <xsl:apply-templates select="/document/context/object/children"/>
        </form>
        </div>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>

  
  <xsl:template match="children/object">
    <fieldset>
      <legend>
        <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/keyword)"/>
      </legend>
      <table>
        <tr>
          <td>
          <label for="vlkeyword_name">
            Name
          </label>
          </td>
          <td colspan="2">
            <input tabindex="40" 
                   type="text" 
                   id="vlkeyword_name" 
                   name="vlkeyword_name" 
                   size="25" 
                   value="{name}" 
                   class="text" 
                   title="{$i18n_vlib/l/name}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlkeyword_description">
              <xsl:value-of select="$i18n_vlib/l/description"/>
            </label>
          </td>
          <td colspan="2">
            <textarea tabindex="40" 
                      id="vlkeyword_description" 
                      name="vlkeyword_description" 
                      cols="40"
                      rows="3"
                      class="text" 
                      title="{$i18n_vlib/l/description}">
              <xsl:value-of select="description"/>
            </textarea>
          </td>
        </tr>
      </table>
    </fieldset>
    <p>
      <input type="hidden"
             name="vlkeyword_id"
             id="vlkeyword_id"
             value="{@id}"/>
      <input type="hidden"
             name="property"
             id="property"
             value="keyword"/>
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
             onClick="self.close();"/>
    </p>
  </xsl:template>

</xsl:stylesheet>
