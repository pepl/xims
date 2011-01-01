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
  <xsl:import href="vlibraryitem_common.xsl"/>
  
 

  <xsl:template match="/document/context/object">
    <html>
			<xsl:call-template name="head_default"> <xsl:with-param name="vlib">true</xsl:with-param></xsl:call-template>
      <body>
      <div id="content-container" style="width:600px">
        <form action="{$xims_box}{$goxims_content}"
              name="eform"
              method="get"
              onsubmit="window.opener.document.location.reload();self.close();"
              id="create-edit-form">
              <h1><xsl:value-of select="$i18n_vlib/l/filter_create"/></h1>
          <input type="hidden" name="id" id="id" value="{@id}"/>
          <xsl:apply-templates select="/document/context/vlsubjectinfo"/>
          <br></br>
          <xsl:apply-templates select="/document/context/vlkeywordinfo"/>
          
          <div class="div-left">
            <xsl:apply-templates select="/document/object_types"/>
            <xsl:apply-templates select="/document/context/vlmediatypeinfo"/>
            <xsl:call-template name="vlib_filter_search" />
          </div>
          <div class="div-left">
          <xsl:call-template name="vlib_filter_chronicle" />
          </div>
          <br clear="all"/>
          <xsl:call-template name="vlib_filter_buttons" />
          
          <div style="clear:both" />
        </form>
        <xsl:call-template name="script_bottom"/>
        <script src="{$ximsroot}scripts/filter_create.js" type="text/javascript" />
        </div>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template name="title">
		<xsl:value-of select="$i18n_vlib/l/filter_create"/>
  </xsl:template>

  <xsl:template match="vlsubjectinfo">
        <h2><xsl:value-of select="$i18n_vlib/l/subject_list"/></h2>
      <div>
          <div class="div-left">
            <label for="subject1"><xsl:value-of select="$i18n_vlib/l/available"/></label><br />
            <select id="subject1" name="vlsubjects_available" size="10" ondblclick="add_item('subject');">
                <xsl:apply-templates select="subject" >
                  <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    order="ascending"/>
                </xsl:apply-templates>
            </select>
          </div>
         <div class="div-left" style="margin:20px">
						 <a class="button arrow-right" href="javascript:add_item('subject')"><xsl:text>&#160;&gt;&#160;</xsl:text></a><br /><br />
						 <a class="button arrow-left" href="javascript:remove_item('subject')"><xsl:text>&#160;&gt;&#160;</xsl:text></a>
            <!--<button type="button" onclick="add_item('subject');"><xsl:text>&#160;&gt;&#160;</xsl:text></button><br />
            <button type="button" onclick="remove_item('subject');"><xsl:text>&#160;&lt;&#160;</xsl:text></button>-->
          </div>
          <div class="div-left">
            <label for="vlsubjects_selected"><xsl:value-of select="$i18n_vlib/l/selected"/></label><br />
            <select id="subject2" name="vlsubjects_selected" size="10" ondblclick="remove_item('subject');" >
            </select>
          </div>
      </div>
      <br clear="all"/>
   <!-- </fieldset>-->
  </xsl:template>

  <xsl:template match="subject">
    <option value="{id}"><xsl:value-of select="concat(name,' (',object_count,')')" /></option>
  </xsl:template>

  <xsl:template match="vlkeywordinfo">
        <h2><xsl:value-of select="$i18n_vlib/l/keywords"/></h2>
      <div>
          <div class="div-left">
            <label for="keyword1"><xsl:value-of select="$i18n_vlib/l/available"/></label><br />
            <select id="keyword1" name="vlkeywords_available" size="10" ondblclick="add_item('keyword');">
                <xsl:apply-templates select="keyword" >
                  <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    order="ascending"/>
                </xsl:apply-templates>
            </select>
           </div>
         <div class="div-left" style="margin:20px">
						<a class="button arrow-right" href="javascript:add_item('keyword')"><xsl:text>&#160;&gt;&#160;</xsl:text></a><br /><br />
						<a class="button arrow-left" href="javascript:remove_item('keyword')"><xsl:text>&#160;&gt;&#160;</xsl:text></a>
            <!--<button type="button" onclick="add_item('keyword');"><xsl:text>&#160;&gt;&#160;</xsl:text></button><br />
            <button type="button" onclick="remove_item('keyword');"><xsl:text>&#160;&lt;&#160;</xsl:text></button>-->
          </div>
          <div class="div-left">
            <label for="vlkeywords_selected"><xsl:value-of select="$i18n_vlib/l/selected"/></label><br />
            <select id="keyword2" name="vlkeywords_selected" size="10" ondblclick="remove_item('keyword');" />
          </div>
      </div>
      <br clear="all"/>
  </xsl:template>

  <xsl:template match="keyword">
    <option value="{id}"><xsl:value-of select="concat(name,' (',object_count,')')" /></option>
  </xsl:template>

  <xsl:template match="vlmediatypeinfo">
   <div class="block">
      <div class="label-std"><label for="input-vlmediatype">
        <xsl:value-of select="$i18n_vlib/l/mediatype"/>
      </label></div>
      <!--<select name="vlmediatype_selected" size="1" >-->
       <select name="vlmediatype_selected" id="input-vlmediatype">
        <option />
        <xsl:apply-templates select="mediatype" />
      </select>
      </div>
   </xsl:template>

  <xsl:template match="mediatype">
    <option value="{mediatype}"><xsl:value-of select="concat(mediatype,' (',object_count,')')" /></option>
  </xsl:template>

  <xsl:template match="/document/object_types">
   <div class="block">
      <div class="label-std"><label for="input-vlobjecttype">
        <xsl:value-of select="$i18n_vlib/l/subject"/>
      </label></div>
      <!--<select name="vlobjecttype_selected" id="input-vlobjecttype" size="1" >-->
      <select name="vlobjecttype_selected" id="input-vlobjecttype">
        <option />
        <xsl:apply-templates select="object_type[parent_id=/document/object_types/object_type[name='VLibraryItem']/@id]" >
          <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
            order="ascending"/>
        </xsl:apply-templates>
      </select>
      </div>
  </xsl:template>

  <xsl:template match="object_type">
    <option value="{@id}"><xsl:value-of select="name" /></option>
  </xsl:template>

  <xsl:template name="vlib_filter_search">
  <div class="block">
      <div class="label-std"><label for="vls">
        <xsl:value-of select="$i18n_vlib/l/Fulltext_search"/>
      </label></div>
      <input name="vls" type="text" id="vls" />
  </div>
  </xsl:template>

  <xsl:template name="vlib_filter_chronicle">
    <div class="form-div block">
      <h2>
        <xsl:value-of select="$i18n_vlib/l/chronicle_filter"/>
      </h2>
        <xsl:call-template name="form-chronicle_from" />
        <xsl:call-template name="form-chronicle_to" />
    </div>
    
  </xsl:template>

  <xsl:template name="vlib_filter_buttons">
    <div class="cancelsave-form">
      <button name="filter_store" class="control" accesskey="S" onclick="alert(createFilterParams());" ><xsl:value-of select="$i18n/l/save"/></button>
      <button name="filter_activate" class="control" accesskey="A" onclick="opener.location.href='{$xims_box}{$goxims_content}{$absolute_path}'+createFilterParams() ; //window.close();" ><xsl:value-of select="$i18n_vlib/l/activate"/></button>
      <button name="cancel" class="control" accesskey="C" onclick="window.close();" ><xsl:value-of select="$i18n/l/cancel"/></button>
    </div>
  </xsl:template>

</xsl:stylesheet>
