<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="dyn">

  <xsl:import href="common.xsl"/>
  <xsl:param name="request.uri"/>
  <xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
  <xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>
  <xsl:variable name="objid">
    <xsl:value-of select="substring-after($request.uri.query,'objid=')"/>
  </xsl:variable>
	
  <xsl:template match="/document/context/object">
    <!--<html>
      <head>
        <title>
        <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n/l/publications)"/>
        </title>
        <xsl:call-template name="css"/>
        <xsl:call-template name="script_head"/>
      </head>
      <body style="width:auto;">
       <div id="content-container">-->
					<form action="{$xims_box}{$goxims_content}" name="eform" method="post" id="create-edit-form">
                      <xsl:call-template name="input-token"/>
						<input type="hidden" name="id" id="id" value="{@id}"/>
						<xsl:if test="$objid != ''"><input type="hidden" name="objid" id="objid" value="{$objid}"/></xsl:if>
						<xsl:apply-templates select="/document/context/object/children"/>
					</form>
				<!--</div>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>-->
  </xsl:template>
  
  <xsl:template match="children/object">
    <h1><xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/publication)"/></h1>
      <div>
			<div class="label-std">
				<label for="vlpublication_name">
					<xsl:value-of select="$i18n/l/Name"/>
				</label>
			</div>
			<input type="text" id="vlpublication_name" name="vlpublication_name" size="40" value="{name}"/>
		</div>
    <div>
			<div class="label-std">
        <label for="vlpublication_volume"><xsl:value-of select="$i18n_vlib/l/publication_volume"/></label>
      </div>
      <input type="text" size="15" id="vlpublication_volume" name="vlpublication_volume" value="{volume}" />
    </div>
    <div>
			<div class="label-std">
				<label for="vlpublication_isbn">ISBN</label>
			</div>
			<input type="text" id="vlpublication_isbn" name="vlpublication_isbn" size="15" value="{isbn}" />
     </div>
     <div>
			<div class="label-std">
        <label for="vlpublication_issn">ISSN</label>
      </div>
      <input type="text" id="vlpublication_issn" name="vlpublication_issn" size="15" value="{issn}" />
    </div>
    <div>
			<div class="label-std">
        <label for="vlpublication_url">URL</label>
      </div>
      <input type="text" id="vlpublication_url" name="vlpublication_url" size="40" value="{url}" />
    </div>
    <div>
			<div class="label-std">
        <label for="vlpublication_image_url">Image URL</label>
      </div>
        <input type="text" id="vlpublication_image_url" name="vlpublication_image_url" size="40" value="{image_url}" />
      </div>
<br/>
		<p>
			<input type="hidden" name="vlpublication_id" id="vlpublication_id" value="{@id}"/>
			<input type="hidden" name="property" id="property" value="publication"/>
			<button type="submit" name="property_store" class="button" accesskey="S"><xsl:value-of select="$i18n/l/save"/></button>&#160;
      <button type="submit" name="cancel" class="button" accesskey="C" onclick="closeDialog('default-dialog');"><xsl:value-of select="$i18n/l/cancel"/></button>
		</p>
  </xsl:template>
</xsl:stylesheet>
