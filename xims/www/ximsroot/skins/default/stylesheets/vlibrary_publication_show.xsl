<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="dyn">

  <xsl:import href="common.xsl"/>

  <xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
  <xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title>
          <xsl:value-of select="$i18n_vlib/l/publication"/>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <div id="content-container">
          <form action="" name="eform" method="get" id="create-edit-form">
            <input type="hidden" name="id" id="id" value="{@id}"/>
            <xsl:apply-templates select="/document/context/object/children"/>
          </form>
        </div>
        <xsl:call-template name="script_bottom"/>
        <xsl:call-template name="script_head"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="children/object">
    <h1><xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/publication)"/></h1>
<div>
			<div class="label-std">
				<label for="vlpublication_name">
					<xsl:value-of select="$i18n/l/Name"/>
				</label>
			</div>
			<input type="text" id="vlpublication_name" name="vlpublication_name" size="40" value="{name}" readonly="readonly"/>
		</div>
    <div>
			<div class="label-std">
        <label for="vlpublication_volume"><xsl:value-of select="$i18n_vlib/l/publication_volume"/></label>
      </div>
      <input type="text" size="15" id="vlpublication_volume" name="vlpublication_volume" value="{volume}" readonly="readonly"/>
    </div>
    <div>
			<div class="label-std">
				<label for="vlpublication_isbn">ISBN</label>
			</div>
			<input type="text" id="vlpublication_isbn" name="vlpublication_isbn" size="15" value="{isbn}" readonly="readonly"/>
     </div>
     <div>
			<div class="label-std">
        <label for="vlpublication_issn">ISSN</label>
      </div>
      <input type="text" id="vlpublication_issn" name="vlpublication_issn" size="15" value="{issn}" readonly="readonly"/>
    </div>
    <div>
			<div class="label-std">
        <label for="vlpublication_url">URL</label>
      </div>
      <input type="text" id="vlpublication_url" name="vlpublication_url" size="40" value="{url}" readonly="readonly"/>
    </div>
    <div>
			<div class="label-std">
        <label for="vlpublication_image_url">Image URL</label>
      </div>
        <input type="text" id="vlpublication_image_url" name="vlpublication_image_url" size="40" value="{image_url}" readonly="readonly"/>
      </div>
<br/>
    <p>
      <button type="submit"
             onclick="window.opener.refresh('publication');self.close();return false;"
             class="button"
             accesskey="S">OK, <xsl:value-of select="$i18n/l/close_window"/></button>
      &#160;
      <!-- The simple solution history.go(-1) would lead to a stale -->
      <!-- second entry, if we wanted tho fix a freshly created publication. -->
      <button type="submit" onclick="location.replace('{$xims_box}{$goxims_content}' + '?id={/document/context/object/@id}' + ';property_edit=1;property=publication;property_id={@id}'); return false;" class="button" accesskey="B"><xsl:value-of select="$i18n/l/Back"/></button> </p>
  </xsl:template>

</xsl:stylesheet>
