<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_contentbrowse.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:variable name="target_path"><xsl:call-template name="targetpath"/></xsl:variable>
<xsl:param name="otfilter"/>
<xsl:param name="notfilter"/>
<xsl:param name="sbfield"/>

<xsl:template match="/document/context/object">
<html>
	<xsl:call-template name="head_default"/>
  <body>
    <p align="right"><a href="#" onclick="window.close()"><xsl:value-of select="$i18n/l/close_window"/></a></p>
	<div id="content-container">
    <form action="{$xims_box}{$goxims_content}" method="post" name="selectform">
        <p>
            <xsl:value-of select="$i18n/l/Browse_to"/>:
            <br/>&#xa0;
            <xsl:apply-templates select="targetparents/object[@id !='1']"/>
            <xsl:apply-templates select="target/object"/>

            <table>
                <xsl:apply-templates select="targetchildren/object[marked_deleted != '1']">
                    <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                </xsl:apply-templates>
            </table>
        </p>
        <input type="hidden" name="id" value="{@id}"/>
    </form>
</div>
        <xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
    function storeBack(target) {
        window.opener.document.<xsl:value-of select="$sbfield"/>.value=target;
        window.close();
    }
			</xsl:with-param>
    </xsl:call-template>
  </body>

</html>
</xsl:template>

<xsl:template name="title">
<xsl:value-of select="$i18n/l/Browse_for"/>
      <xsl:choose>
        <xsl:when test="$otfilter != ''">
          '<xsl:value-of select="$otfilter"/>'
        </xsl:when>
        <xsl:otherwise>
          '<xsl:value-of select="$i18n/l/Object"/>'
        </xsl:otherwise>
      </xsl:choose>
    - XIMS
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
                <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type = 'application/x-container'">
                    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};sbfield={$sbfield}"><xsl:value-of select="title"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="title"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$otfilter = '' or contains( $otfilter ,/document/object_types/object_type[@id=$objecttype]/name )">
                (<xsl:value-of select="$i18n/l/Click"/>&#xa0;<a href="#" onclick="storeBack('{$target_path}/{location}');"><xsl:value-of select="$i18n/l/here"/></a>&#xa0;<xsl:value-of select="$i18n/l/to_store_back"/>)
            </xsl:if>
    </td></tr>
</xsl:template>

</xsl:stylesheet>

