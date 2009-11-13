<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_contentbrowse_tinymceimage.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:variable name="target_path"><xsl:call-template name="targetpath"/></xsl:variable>
<xsl:variable name="target_path_nosite"><xsl:call-template name="targetpath_nosite"/></xsl:variable>
<xsl:param name="otfilter"/>
<xsl:param name="notfilter"/>
<xsl:param name="style"/>
<xsl:param name="editorname"/>

<xsl:key name="object-by-dataformat" match="targetchildren/object" use="data_format_id" />

<xsl:template match="/document/context/object">
<html>
  <head>
    <title><xsl:value-of select="$i18n/l/Browse_for"/>
      <xsl:choose>
        <xsl:when test="$otfilter != ''">
          '<xsl:value-of select="$otfilter"/>'
        </xsl:when>
        <xsl:otherwise>
          '<xsl:value-of select="$i18n/l/Object"/>'
        </xsl:otherwise>
      </xsl:choose>
    - XIMS</title>
    <xsl:call-template name="css"/>
    <script language="javascript" type="text/javascript" src="{$ximsroot}tinymce/jscripts/tiny_mce/tiny_mce_popup.js"></script>
    <xsl:call-template name="scripts"/>
  </head>
  <body onload="createThumbs();">
    <p align="right"><a href="#" onclick="popupClose()"><xsl:value-of select="$i18n/l/close_window"/></a></p>
    <p><xsl:call-template name="selectform"/> </p>
    <xsl:call-template name="script_bottom"/>
  </body>
</html>
</xsl:template>

<xsl:template match="targetparents/object|target/object">
 / <a class="" href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorname={$editorname}"><xsl:value-of select="location"/></a>
</xsl:template>

<xsl:template match="targetchildren/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr><td>
        <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" name = "spacer" width="{10*@level}" height="10"/>
        <xsl:choose>
            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type = 'application/x-container'">
                <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" alt="" name="icon" width="20" height="18"/>
                <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorname={$editorname}"><xsl:value-of select="title"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="/document/object_types/object_type[@id=$objecttype]/name = $otfilter">
                    <img src="{$xims_box}{$goxims_content}{$target_path}/{location}" width="50" height="50"/>
                    <img src="{$ximsroot}images/spacer_white.gif" name="spacer" width="20" height="10"/>
                    <xsl:value-of select="title"/>
                    (<xsl:value-of select="$i18n/l/Click"/>&#160;<a href="#" onclick="storeBack('{$target_path_nosite}/{location}', '{title}');"><xsl:value-of select="$i18n/l/here"/></a>&#160;<xsl:value-of select="$i18n/l/to_store_back"/>)
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </td></tr>
</xsl:template>

<xsl:template name="scripts">
    <script type="text/javascript">
      <![CDATA[

function popupClose() {
    if (tinyMCEPopup) tinyMCEPopup.close();
    else window.close();
}

function insertfile() {
    var URL = document.selectform.imgpath.value;
    var win = tinyMCEPopup.getWindowArg("window");
    var title = document.selectform.imgtext.value;
    win.document.getElementById(tinyMCEPopup.getWindowArg("input")).value = URL;
    win.document.getElementById("alt").value = title;
    // for image browsers: update image dimensions
    tinyMCEPopup.close();
}

     
        function storeBack(target, imgtext) {
      ]]>
            var re = new RegExp("<xsl:value-of select="$absolute_path_nosite"/>/");
      <![CDATA[
            if (re.test(target) && RegExp.rightContext.length > 0) {
                document.selectform.imgpath.value=RegExp.rightContext;
            }
            else {
      ]]>
                <!-- /goxims/content/siteroot will be converted to a relative path during saving -->
                document.selectform.imgpath.value='<xsl:value-of select="concat($goxims_content,'/',/document/context/object/parents/object[@parent_id=1]/location)"/>'+target;
      <![CDATA[
            }
            document.selectform.imgtext.value=imgtext;
        }

        function isIexplore() {
            agt = navigator.userAgent.toLowerCase();
            if ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1))
                return true
            else
                return false;
        }

        function createThumbs() {
            for (i=0;i< document.images.length;i++) {
                if ((document.images[i].name != "spacer")&&(document.images[i].name != "icon")){
                    if (isIexplore()) {
                        imgWidth = document.images[i].width;
                        imgHeigth = document.images[i].height;
                        rel = imgWidth/imgHeigth;
                        document.images[i].height = 50;
                        document.images[i].width = 50 * rel;
                    }
                    else {
                        document.images[i].height = 50;
                        document.images[i].width = 50;
                    }
                }
            }
        return false;
        }
      ]]>
    </script>
</xsl:template>

</xsl:stylesheet>
