<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
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
					<xsl:value-of select="concat($i18n/l/edit, ' ', $i18n/l/keywords)"/>
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
		<!--<h1><xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/author)"/></h1>-->
		
    <div>
      <div class="label-std">
        <label for="vlauthor_firstname"><xsl:value-of select="$i18n_vlib/l/firstname"/></label>
       </div>
       <input type="text" id="vlauthor_firstname" name="vlauthor_firstname" size="40" value="{firstname}" />
    </div>
    
    <div>
			<div class="label-std">
				<label for="vlauthor_middlename"><xsl:value-of select="$i18n_vlib/l/middlename"/></label>
			</div>
      <input type="text" id="vlauthor_middlename" name="vlauthor_middlename" size="40" value="{middlename}" />
    </div>
    
		<div>
			<div class="label-std">
			<label for="vlauthor_lastname"><xsl:value-of select="$i18n_vlib/l/lastname"/></label>
			</div>
				<input type="text" id="vlauthor_lastname" name="vlauthor_lastname" size="40" value="{lastname}"/>
		</div>
		
    <div>
			<div class="label-std">
        <label for="vlauthor_suffix"><xsl:value-of select="$i18n_vlib/l/suffix"/></label>
      </div>
      <input type="text" id="vlauthor_suffix" name="vlauthor_suffix" size="5" value="{suffix}"/>
    </div>
    
    <div>
			<div class="label-std">
        <label for="vlauthor_email">E-Mail</label>
      </div>
      <input type="text" id="vlauthor_email" name="vlauthor_email" size="40" value="{email}"/>
    </div>
    
    <div>
			<div class="label-std">
            <label for="vlauthor_url">URL</label>
      </div>
      <input type="text" id="vlauthor_url" name="vlauthor_url" size="40" value="{url}"/>
    </div>
    
    <div>
			<div class="label-std">
            <label for="vlauthor_image_url">Image URL</label>
      </div>
      <input type="text" id="vlauthor_image_url" name="vlauthor_image_url" size="40" value="{image_url}"/>
    </div>
    
    <div>
			<div class="label-std">
            <label for="vlauthor_object_type"><xsl:value-of select="$i18n_vlib/l/orgauthor"/></label>
      </div>
      <input type="checkbox" id="vlauthor_object_type" name="vlauthor_object_type" value="1">
				<xsl:if test="object_type=1">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
      </input>
    </div>
    
    <br/>
    <p>
			<input type="hidden" name="vlauthor_id" id="vlauthor_id" value="{@id}"/>
			<input type="hidden" name="property" id="property" value="author"/>
	    <button type="submit" name="property_store" class="button" accesskey="S"><xsl:value-of select="$i18n/l/save"/></button>&#160;
		<button type="button" name="cancel" class="button" accesskey="C" onclick="closeDialog('default-dialog');"><xsl:value-of select="$i18n/l/cancel"/></button>
		</p>
  </xsl:template>

</xsl:stylesheet>
