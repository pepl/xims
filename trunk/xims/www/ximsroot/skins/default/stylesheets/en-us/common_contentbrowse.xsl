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
<xsl:param name="sbfield"/>
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
    <script type="text/javascript">
    function storeBack(target) {
        window.opener.document.<xsl:value-of select="$sbfield"/>.value=target;
        window.close();
    }
    
    </script>
  </head>
  <body>
    <p align="right"><a href="#" onClick="window.close()">close window</a></p>
    <p>
    <form action="{$xims_box}{$goxims_content}" method="POST" name="selectform">
        <p>
            Browse to:
            <br/>&#xa0;
            <xsl:apply-templates select="targetparents/object[@document_id !=1]"/>
            <xsl:apply-templates select="target/object"/>

            <table>
                <xsl:apply-templates select="targetchildren/object">
                    <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                </xsl:apply-templates>
            </table>
        </p>
        <input type="hidden" name="id" value="{@id}"/>
    </form>
    </p>
  </body>

</html>
</xsl:template>

<xsl:template match="targetparents/object|target/object">
  / <a class="" href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};sbfield={$sbfield}"><xsl:value-of select="location"/></a>
</xsl:template>

    <xsl:template match="targetchildren/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr><td>
        <img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level}" height="10"/>
        <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" alt="" width="20" height="18"/>
            <xsl:choose>
                <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name = 'Container'">
                    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};sbfield={$sbfield}"><xsl:value-of select="title"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="title"/> 
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$otfilter = '' or contains( $otfilter ,/document/object_types/object_type[@id=$objecttype]/name )">
                (Click <a href="#" onClick="storeBack('{$target_path}/{location}');">here</a> to store back)
            </xsl:if>
    </td></tr>
</xsl:template>

</xsl:stylesheet>

