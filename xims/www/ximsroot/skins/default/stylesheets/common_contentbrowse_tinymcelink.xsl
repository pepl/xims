<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_contentbrowse_tinymcelink.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common_contentbrowse_tinymceimage.xsl"/>

<xsl:template name="selectform">
  <form action="{$xims_box}{$goxims_content}" method="post" name="selectform" id="select-form">
    <div>
    <div id="label-location" class="label-std"><label for="input-path"><xsl:value-of select="$i18n/l/Path"/></label></div>
      <input type="text" name="httpLink" size="60" id="input-path">
        <xsl:choose>
         <xsl:when test="$target_path = $absolute_path_nosite">
             <xsl:attribute name="value"></xsl:attribute>
         </xsl:when>
         <xsl:when test="contains($target_path, concat($absolute_path_nosite, '/'))">
             <xsl:attribute name="value"><xsl:value-of select="substring-after($target_path, concat($absolute_path_nosite, '/'))"/></xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
             <xsl:attribute name="value"><xsl:value-of select="$target_path"/></xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>
      </input>
    </div>
    <div>
    <div id="label-title"  class="label-std"><label for="input-title"><xsl:value-of select="$i18n/l/Title"/></label></div>
      <input type="text" name="linktext" size="60" id="input-title">
        <xsl:choose>
          <xsl:when test="@id != /document/context/object/target/object/@id">
            <xsl:attribute name="value">
              <xsl:value-of select="/document/context/object/target/object/title"/>
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </input>
    </div>
    <div>
      <div id="label-target"><label for="input-target"><xsl:value-of select="$i18n/l/Opt_sel_link"/></label></div>
        <select name="Target" id="input-target">
          <option value="" selected="selected"></option>
          <option value="_blank">New Window (_blank)</option>
          <option value="_self">Same Window (_self)</option>
          <option value="_parent">Parent Window (_parent)</option>
          <option value="_top">Browser Window (_top)</option>
        </select>
      </div>
      <xsl:if test="$tinymce_version != '4'">
    	<div><button type="button" class="button" onclick="inserthyperlink();"><xsl:value-of select="$i18n/l/StoreBack"/></button></div>
	  </xsl:if>
      <p><xsl:value-of select="$i18n/l/Search_objTree_obj"/><br/>
        <xsl:apply-templates select="targetparents/object[@id !='1']"/>
        <xsl:apply-templates select="target/object"/>
      </p>
      <xsl:call-template name="form-container-sorting"></xsl:call-template>
      <xsl:call-template name="pagenav"></xsl:call-template>
      <div>
        <ul class="no-list-style">
          <xsl:apply-templates select="targetchildren/object[marked_deleted != '1']">
              <xsl:sort select="$sb" order="{concat($order,'ending')}" case-order="lower-first"/>
          </xsl:apply-templates>
        </ul>
    </div>
    <!-- test -->
    <xsl:call-template name="pagenav"></xsl:call-template>
    
    <input type="hidden" name="id" value="{@id}"/>
  </form>
  <xsl:if test="$tinymce_version != '4'">
  	<script language="javascript" type="text/javascript" src="{$ximsroot}/vendor/tinymce3/jscripts/tiny_mce/tiny_mce_popup.js"><xsl:comment/></script>
  </xsl:if>
  <xsl:call-template name="scripts"/>
</xsl:template>

<xsl:template name="title">
	<xsl:value-of select="$i18n/l/Browse_for"/>&#160;<xsl:value-of select="$i18n/l/Object"/> - XIMS
</xsl:template>

<xsl:template name="targetpath">
    <xsl:for-each select="/document/context/object/targetparents/object[@document_id != 1 and @parent_id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each><xsl:if test="/document/context/object/target/object/@parent_id != 1">/<xsl:value-of select="/document/context/object/target/object/location"/></xsl:if>
</xsl:template>

<xsl:template match="targetchildren/object">
  <xsl:variable name="dataformat">
    <xsl:value-of select="data_format_id"/>
  </xsl:variable>
  <xsl:variable name="objecttype">
    <xsl:value-of select="object_type_id"/>
  </xsl:variable>
  <xsl:variable name="gopublic">
    <xsl:if test="/document/object_types/object_type[@id=$objecttype]/publish_gopublic='1'">
      <xsl:value-of select="concat($xims_box,$gopublic_content,'/',/document/context/object/targetparents/object[@parent_id = 1]/location)"/>
    </xsl:if>
  </xsl:variable>
  <li>
    <span class="xims-sprite sprite-list sprite-list_{/document/data_formats/data_format[@id=$dataformat]/name}"><span><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/name"/></span>&#160;</span>
    <xsl:choose>
      <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type = 'application/x-container'">
          <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};tinymce_version={$tinymce_version};"><xsl:value-of select="title"/></a>
      </xsl:when>
      <xsl:otherwise>
          <xsl:value-of select="title"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$otfilter = 'Gallery' and /document/object_types/object_type[@id=$objecttype]/name = $otfilter">
        (<xsl:value-of select="$i18n/l/Click"/>&#160;<a href="#" onclick="storeBack('{$gopublic}{$target_path}/{location}/images.htm', '{title}');"><xsl:value-of select="$i18n/l/here"/></a>&#160;<xsl:value-of select="$i18n/l/to_store_back"/>)
      </xsl:when>
      <xsl:when test="$otfilter = '' or /document/object_types/object_type[@id=$objecttype]/name = $otfilter">
        (<xsl:value-of select="$i18n/l/Click"/>&#160;<a href="#" onclick="storeBack('{$gopublic}{$target_path}/{location}', '{title}');"><xsl:value-of select="$i18n/l/here"/></a>&#160;<xsl:value-of select="$i18n/l/to_store_back"/>)
      </xsl:when>
      <xsl:otherwise><xsl:comment/></xsl:otherwise>
    </xsl:choose>
  </li>
</xsl:template>

<xsl:template name="scripts">
  <xsl:call-template name="mk-inline-js">
    <xsl:with-param name="code">
      var style = "tinymcelink";
      var agt = navigator.userAgent.toLowerCase();
      var is_ie = ((agt.indexOf("msie") != -1) &amp;&amp; (agt.indexOf("opera") == -1));
      var gotselection;

      var objQuery = new Object();
      var selectedText;
      var selectedHTML;
      var strQuery = location.search.substring(1);
      var aryQuery = strQuery.split(";");
      var pair = [];
      for ( var i = 0; i &lt; aryQuery.length; i++ ) {
          pair = aryQuery[i].split("=");
          if ( pair.length == 2 ) {
              objQuery[unescape(pair[0])] = unescape(pair[1]);
          }
      }

      function inserthyperlink() {
          var title = document.selectform.linktext.value;
          var win = tinyMCEPopup.getWindowArg("window");
          var hyperlinkvalue = document.selectform.httpLink.value;
          var targetvalue = document.selectform.Target.value;
          win.document.getElementById("href").value = hyperlinkvalue;
          win.document.getElementById("linktitle").value = title;
          if(win.document.getElementById("target_list"))
          	win.document.getElementById("target_list").value = targetvalue;
          tinyMCEPopup.close();
      }

      function storeBack(target, linktext) {
          var re = new RegExp("^<xsl:value-of select="$absolute_path_nosite"/>/");
          var re_gopublic = new RegExp("<xsl:value-of select="concat($xims_box,$gopublic_content)"/>/");
          if (re.test(target) &amp;&amp; RegExp.rightContext.length > 0 &amp;&amp; !target.match(re_gopublic)) {
              document.selectform.httpLink.value=RegExp.rightContext;
          }
          else {
              document.selectform.httpLink.value=target;
          }
          if ( !gotselection ) {
              document.selectform.linktext.value=linktext;
          }
      }
      function createThumbs() {}

      function popupClose() {
        if (tinyMCEPopup) tinyMCEPopup.close();
        else window.close();
      }
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
