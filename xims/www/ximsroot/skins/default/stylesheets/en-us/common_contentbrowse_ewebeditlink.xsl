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
<xsl:param name="editorName"/>
<xsl:param name="id"/>
<xsl:param name="parid"/>
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
    <script type="text/javascript">
      <![CDATA[
        var objQuery = new Object();
        var selectedText;
        var selectedHTML;
        var strQuery = location.search.substring(1);
        var aryQuery = strQuery.split(";");
        var pair = [];
        for (var i = 0; i < aryQuery.length; i++) {
            pair = aryQuery[i].split("=");
            if (pair.length == 2)
            {
                objQuery[unescape(pair[0])] = unescape(pair[1]);
            }

        }

        function loadselectedtext() {
            var testimage;
            if (document.selectform.linktext.value == '') {
                selectedText = window.opener.eWebEditPro[objQuery["editorName"]].getSelectedText();
                selectedHTML = window.opener.eWebEditPro[objQuery["editorName"]].getSelectedHTML();
                testimage = selectedHTML.substring(0, 4);
                if (testimage.toLowerCase() == "<img"){
                  document.selectform.linktext.value = selectedHTML;
                }
                else
                {
                  document.selectform.linktext.value = selectedText;
                }
            }
        }
        function inserthyperlink() {
            if (window.opener.closed) {
                alert("Your hyperlink could not be inserted because the editor page has been closed.");
            }
            else if (document.selectform.linktext.value == '') {
                alert("Your hyperlink text is blank and would create an empty link.");
            }
            else{
                var hyperlinkvalue;
                var pastevalue;
                var targetvalue;
                var targetvaluepaste
                targetvalue = document.selectform.Target.options[document.selectform.Target.selectedIndex].value;
                if (targetvalue == "") {
                    targetvaluepaste = "";
                }
                else {
                    targetvaluepaste = "target=" + targetvalue;
                }
                hyperlinkvalue = document.selectform.httpLink.value
                pastevalue = '<A HREF="' + hyperlinkvalue + '" ' + targetvaluepaste +'>' + document.selectform.linktext.value + '</a>';
                window.opener.eWebEditPro[objQuery["editorName"]].pasteHTML(pastevalue);
                window.close();
            }
        }
        function storeBack(target, linktext) {
      ]]>
            re = new RegExp("<xsl:choose><xsl:when test="$parid=''"><xsl:value-of select="$parent_path_nosite"/></xsl:when><xsl:otherwise><xsl:value-of select="$absolute_path_nosite"/></xsl:otherwise></xsl:choose>/");
      <![CDATA[
            re.test(target);
            if (RegExp.rightContext.length > 0) {
                document.selectform.httpLink.value=RegExp.rightContext;
            }
            else {
      ]]>
                document.selectform.httpLink.value=target;
      <![CDATA[
            }
            document.selectform.linktext.value=linktext;
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
                    Type in a URL
                </td>
                <td>
                    <input type="text" name="httpLink" size="60">
                        <xsl:choose>
                            <xsl:when test="$parid = '' and $target_path = $parent_path_nosite">
                                <xsl:attribute name="value"><xsl:value-of select="'.'"/></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$parid != '' and $target_path = $absolute_path_nosite">
                                <xsl:attribute name="value"><xsl:value-of select="'.'"/></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$parid = '' and contains($target_path, concat($parent_path_nosite, '/'))">
                                <xsl:attribute name="value"><xsl:value-of select="substring-after($target_path, concat($parent_path_nosite, '/'))"/></xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$parid != '' and contains($target_path, concat($absolute_path_nosite, '/'))">
                                <xsl:attribute name="value"><xsl:value-of select="substring-after($target_path, concat($parent_path_nosite, '/'))"/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="value"><xsl:value-of select="$target_path"/></xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </input>
                </td>
            </tr>
            <tr>
                <td>
                    Enter a title
                </td>
                <td>
                    <input type="text" name="linktext" size="60">
                        <xsl:choose>
                            <xsl:when test="/document/context/object/targetparents/object[position()=last()]/title != title">
                                <xsl:attribute name="value"><xsl:value-of select="/document/context/object/targetparents/object[position()=last()]/title"/></xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                    </input>
                </td>
            </tr>
            <tr>
                <td>
                    Optionally select a link target:
                </td>
                <td>
                    <select name="Target">
                        <option value="" selected="selected"></option>
                        <option value="_blank">New Window (_blank)</option>
                        <option value="_self">Same Window (_self)</option>
                        <option value="_parent">Parent Window (_parent)</option>
                        <option value="_top">Browser Window (_top)</option>
                    </select>
                    <input class="control" type="button" value="Store Back" onClick="inserthyperlink();"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    Or browse for a XIMS-Object:
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
  <!-- the following needs to happen after form definition -->
  <script type="text/javascript">
    loadselectedtext();
  </script>
</html>
</xsl:template>

<xsl:template name="targetpath">
    <xsl:for-each select="/document/context/object/targetparents/object[@parent_id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template match="targetparents/object">
  / <xsl:choose><xsl:when test="position()!=last()"><a class="" href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorName={$editorName}"><xsl:value-of select="location"/></a></xsl:when><xsl:otherwise><xsl:value-of select="location"/></xsl:otherwise></xsl:choose>
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
                    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};style={$style};editorName={$editorName}"><xsl:value-of select="title"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$otfilter = '' or /document/object_types/object_type[@id=$objecttype]/name = $otfilter">
                (Click <a href="#" onClick="storeBack('{$target_path}/{location}', '{title}');">here</a> to use this object)
            </xsl:if>
    </td></tr>
</xsl:template>

</xsl:stylesheet>
