<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:import href="common.xsl"/>
<xsl:variable name="target_path"><xsl:call-template name="targetpath"/></xsl:variable>
<xsl:param name="otfilter"/>
<xsl:param name="notfilter"/>
<xsl:param name="style"/>
<xsl:param name="editorname"/> <!-- damn ewebedit - one time editorName (hyperlinkselection), the next time editorname -->
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
  <head>
    <title>Browse for
      <xsl:choose>
        <xsl:when test="$otfilter != ''">
          '<xsl:value-of select="$otfilter"/>'
        </xsl:when>
        <xsl:otherwise>
          'Object'
        </xsl:otherwise>
      </xsl:choose>
    - XIMS</title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
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
  </head>
  <body>
    <p align="right"><a href="#" onClick="window.close()">close window</a></p>
    <p>
    <form action="{$xims_box}{$goxims_content}" method="POST" name="selectform">
        <table>
            <tr>
                <td>
                    Type in a path to an image
                </td>
                <td>
                    <input type="text" name="imgpath" size="60"/>
                </td>
            </tr>
            <tr>
                <td>
                    Enter a title
                </td>
                <td>
                    <input type="text" name="imgtext" size="60"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input class="control" type="button" value="Store Back" onClick="insertfile();"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    Or browse for an image:
                    <br/>
                    <xsl:apply-templates select="targetparents/object"/>
                    <table>
                        <xsl:apply-templates select="targetchildren/object">
                            <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                        </xsl:apply-templates>
                    </table>
                </td>
            </tr>
       </table>
       <input type="hidden" name="id" value="{@id}"/>
    </form>
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
                (Click <a href="#" onClick="storeBack('{$goxims_content}{$target_path}/{location}', '{title}');">here</a> to use this object)
            </xsl:if>
    </td></tr>
</xsl:template>

</xsl:stylesheet>
