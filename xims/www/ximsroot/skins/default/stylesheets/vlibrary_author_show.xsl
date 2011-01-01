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
          <xsl:value-of select="$i18n_vlib/l/author"/>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <div style="margin:0.66em;padding:0.33em;background-color:#eeeeee;">
          <form action="%200"
                name="eform"
                method="%200">
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
        <xsl:value-of select="$i18n_vlib/l/author"/>
      </legend>
      <table>
        <tr>
          <td>
            <label for="vlauthor_firstname">
              <xsl:value-of select="$i18n_vlib/l/firstname"/>
            </label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_firstname" 
                   name="vlauthor_firstname" 
                   size="25" 
                   value="{firstname}" 
                   class="text" 
                   title="{$i18n_vlib/l/firstname}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_middlename">
              <xsl:value-of select="$i18n_vlib/l/middlename"/>
            </label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_middlename" 
                   name="vlauthor_middlename" 
                   size="25" 
                   value="{middlename}" 
                   class="text"
                   title="{$i18n_vlib/l/middlename}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_lastname">
              <xsl:value-of select="$i18n_vlib/l/lastname"/>
            </label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_lastname" 
                   name="vlauthor_lastname"
                   size="50"
                   value="{lastname}" 
                   class="text" 
                   title="{$i18n_vlib/l/lastname}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_suffix">
              <xsl:value-of select="$i18n_vlib/l/suffix"/>
            </label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_suffix" 
                   name="vlauthor_suffix"
                   size="5"
                   value="{suffix}"
                   class="text"
                   title="{$i18n_vlib/l/suffix}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_email">E-Mail</label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_email" 
                   name="vlauthor_email"
                   size="50"
                   value="{email}"
                   class="text"
                   title="E-Mail"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_url">URL</label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_url" 
                   name="vlauthor_url"
                   size="50"
                   value="{url}"
                   class="text"
                   title="URL"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_image_url">Image URL</label>
          </td>
          <td colspan="2">
            <input tabindex="40"
                   readonly="readonly"
                   style="background-color:#eeeeee;"
                   type="text" 
                   id="vlauthor_image_url" 
                   name="vlauthor_image_url"
                   size="50"
                   value="{image_url}"
                   class="text"
                   title="Image URL"/>
          </td>
        </tr>
        <tr>
          <td>
            <label for="vlauthor_object_type">
              <xsl:value-of select="$i18n_vlib/l/orgauthor"/>
            </label>
          </td>
          <td colspan="2">
            <input tabindex="40" 
                   type="checkbox"
                   style="background-color:#eeeeee;"
                   readonly="readonly" 
                   id="vlauthor_object_type" 
                   name="vlauthor_object_type" 
                   class="text" 
                   title="{$i18n_vlib/l/orgauthor}"
                   value="1">
              <xsl:if test="object_type=1">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input>
          </td>
        </tr>
      </table>
    </fieldset>
    <p>
      <input type="submit"
             onclick="window.opener.refresh('author');self.close();return false;"
             value="OK, {$i18n/l/close_window}"
             class="control"
             accesskey="S"/>
      
      <!-- The simple solution history.go(-1) would lead to a stale -->
      <!-- second entry, if we wanted tho fix a freshly created author. -->
      <input type="submit"
             onclick="location.replace('{$xims_box}{$goxims_content}' +
                      '?id={/document/context/object/@id}' +
                      ';property_edit=1;property=author;property_id={@id}'); return false;"
             value="{$i18n/l/Back}" class="control" accesskey="B"/> 
    </p>
  </xsl:template>
  
</xsl:stylesheet>
