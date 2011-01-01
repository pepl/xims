<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
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
          <xsl:value-of select="$i18n_vlib/l/publication"/>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <div style="margin:0.66em;padding:0.33em;background-color:#eeeeee;">
          <form action="%200"
                name="eform"
                method="">
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
        <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/publication)"/>
      </legend>
      <table>
        <tr>
          <td>
          <label for="vlpublication_name">
            Name
          </label>
          </td>
          <td colspan="2">
            <input tabindex="1" 
                   type="text" 
                   id="vlpublication_name" 
                   name="vlpublication_name" 
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   size="50" 
                   value="{name}" 
                   class="text" 
                   title="{$i18n_vlib/l/name}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlpublication_volume">
              Volume
            </label>
          </td>
          <td colspan="2">
            <input type="text"
                   size="15"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   tabindex="2" 
                   id="vlpublication_volume" 
                   name="vlpublication_volume" 
                   class="text"
                   value="{volume}" 
                   title="Volume"/>
          </td>
        </tr>
        <tr>
          <td>
          <label for="vlpublication_isbn">
            ISBN
          </label>
          </td>
          <td colspan="2">
            <input tabindex="3" 
                   type="text" 
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   id="vlpublication_isbn" 
                   name="vlpublication_isbn" 
                   size="15" 
                   value="{isbn}" 
                   class="text" 
                   title="ISBN"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlpublication_issn">
              ISSN
            </label>
          </td>
          <td colspan="4">
            <input tabindex="17" 
                   type="text" 
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   id="vlpublication_issn" 
                   name="vlpublication_issn" 
                   size="15" 
                   value="{issn}" 
                   class="text" 
                   title="ISSN"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlpublication_url">
              URL
            </label>
          </td>
          <td colspan="2">
            <input tabindex="5" 
                   type="text" 
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   id="vlpublication_url" 
                   name="vlpublication_url" 
                   size="50" 
                   value="{url}" 
                   class="text" 
                   title="URL"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlpublication_image_url">
              Image URL
            </label>
          </td>
          <td colspan="2">
            <input tabindex="6" 
                   type="text" 
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   id="vlpublication_image_url" 
                   name="vlpublication_image_url" 
                   size="50" 
                   value="{image_url}" 
                   class="text" 
                   title="Image URL"/>
          </td>
        </tr>
        
      </table>
    </fieldset>
    <p>
      <input type="submit"
             onclick="window.opener.refresh('publication');self.close();return false;"
             value="OK, {$i18n/l/close_window}"
             class="control"
             accesskey="S"/>
      
      <!-- The simple solution history.go(-1) would lead to a stale -->
      <!-- second entry, if we wanted tho fix a freshly created publication. -->
      <input type="submit"
             onclick="location.replace('{$xims_box}{$goxims_content}' +
                      '?id={/document/context/object/@id}' +
                      ';property_edit=1;property=publication;property_id={@id}'); return false;"
             value="{$i18n/l/Back}" class="control" accesskey="B"/> </p>
  </xsl:template>

</xsl:stylesheet>
