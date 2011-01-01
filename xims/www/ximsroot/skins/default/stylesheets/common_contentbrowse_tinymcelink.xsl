<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id:$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common_contentbrowse_tinymceimage.xsl"/>

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
    <tr><td>
        <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" alt="" width="20" height="18"/>
        <xsl:choose>
            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type = 'application/x-container'">
                <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorname={$editorname}"><xsl:value-of select="title"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="title"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$otfilter = '' or /document/object_types/object_type[@id=$objecttype]/name = $otfilter">
            (<xsl:value-of select="$i18n/l/Click"/>&#160;<a href="#" onclick="storeBack('{$gopublic}{$target_path}/{location}', '{title}');"><xsl:value-of select="$i18n/l/here"/></a>&#160;<xsl:value-of select="$i18n/l/to_store_back"/>)
        </xsl:if>
    </td></tr>
</xsl:template>

<xsl:template name="scripts">
  <xsl:call-template name="mk-inline-js">
     <xsl:with-param name="code">
        <![CDATA[
        var agt = navigator.userAgent.toLowerCase();
        var is_ie = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
        var gotselection;

        var objQuery = new Object();
        var selectedText;
        var selectedHTML;
        var strQuery = location.search.substring(1);
        var aryQuery = strQuery.split(";");
        var pair = [];
        for ( var i = 0; i < aryQuery.length; i++ ) {
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
            win.document.getElementById("target_list").value = targetvalue;
            tinyMCEPopup.close();
        }

        function storeBack(target, linktext) {
      ]]>
            var re = new RegExp("^<xsl:value-of select="$absolute_path_nosite"/>/");
            var re_gopublic = new RegExp("<xsl:value-of select="concat($xims_box,$gopublic_content)"/>/");
      <![CDATA[
            if (re.test(target) && RegExp.rightContext.length > 0 && !target.match(re_gopublic)) {
                document.selectform.httpLink.value=RegExp.rightContext;
            }
            else {
      ]]>
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
