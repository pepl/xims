<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:variable name="target_path"><xsl:call-template name="targetpath"/></xsl:variable>
<xsl:param name="otfilter"/>
<xsl:param name="notfilter"/>
<xsl:param name="style"/>
<xsl:param name="editorname"/> <!-- damn ewebedit - one time editorName (hyperlinkselection), the next time editorname -->

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
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <xsl:call-template name="scripts"/>
  </head>
  <body>
    <p align="right"><a href="#" onClick="window.close()"><xsl:value-of select="$i18n/l/close_window"/></a></p>
    <p>
        <xsl:call-template name="selectform"/>
    </p>
  </body>
</html>
</xsl:template>

<xsl:template match="targetparents/object">
  / <xsl:choose><xsl:when test="position()!=last()"><a class="" href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorname={$editorname}"><xsl:value-of select="location"/></a></xsl:when><xsl:otherwise><xsl:value-of select="location"/></xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="targetchildren/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr><td>
        <img src="{$ximsroot}images/spacer_white.gif" alt="spacer" width="{10*@level}" height="10"/>
        <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" alt="" width="20" height="18"/>
            <xsl:choose>
                <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name = 'Container'">
                    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorname={$editorname}"><xsl:value-of select="title"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$otfilter = '' or /document/object_types/object_type[@id=$objecttype]/name = $otfilter">
                (<xsl:value-of select="$i18n/l/Click"/> <a href="#" onClick="storeBack('{$target_path}/{location}');"><xsl:value-of select="$i18n/l/here"/></a> <xsl:value-of select="$i18n/l/to_store_back"/>)
            </xsl:if>
    </td></tr>
</xsl:template>

<xsl:template name="scripts">
    <script type="text/javascript">
      <![CDATA[
        function insertfile() {
            window.opener.eWebEditPro.instances["body"].insertMediaFile(document.selectform.imgpath.value,false,document.selectform.imgtext.value,"IMAGE",0,0);
            window.close();
        }
        function storeBack(target, imgtext) {
      ]]>
            re = new RegExp("<xsl:value-of select="concat($goxims_content,$absolute_path)"/>/");
      <![CDATA[
            re.test(target);
            if (RegExp.rightContext.length > 0) {
                document.selectform.imgpath.value=RegExp.rightContext;
            }
            else {
      ]]>
            document.selectform.imgpath.value=target;
      <![CDATA[
            }
            document.selectform.imgtext.value=imgtext;
        }
      ]]>
    </script>
</xsl:template>

</xsl:stylesheet>
