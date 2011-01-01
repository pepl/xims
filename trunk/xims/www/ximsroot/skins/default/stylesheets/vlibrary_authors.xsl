<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<!DOCTYPE stylesheet [
<!ENTITY  fromchars "'aÄäbcdefghijklmnoÖöpqrsßtuÜüvwxyz@„&quot;'">
<!ENTITY    tochars "'AAABCDEFGHIJKLMNOOOPQRSSTUUUVWXYZ___'">
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="exslt">

    <xsl:import href="vlibrary_common.xsl"/>

    <xsl:variable name="authorcolumns" select="'3'"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
          <xsl:call-template name="header">
            <xsl:with-param name="createwidget">true</xsl:with-param>
            <xsl:with-param name="parent_id"><xsl:value-of select="/document/object_types/object_type[name='VLibraryItem']/@id" /></xsl:with-param>
          </xsl:call-template>
           
            <div id="vlbody">
                <h1><xsl:value-of select="title"/></h1>
                <div>
                    <xsl:apply-templates select="abstract"/>
                </div>
                <xsl:call-template name="search_switch">
                    <xsl:with-param name="mo" select="'author'"/>
                </xsl:call-template>
                <xsl:call-template name="chronicle_switch" />
                <xsl:apply-templates select="/document/context/vlauthorinfo"/>
            </div>
            <table align="center" width="98.7%" class="footer">
              <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="jquery-listitems-bg">
              <xsl:with-param name="pick" select="'div.vliteminfo'"/>
            </xsl:call-template>
            <xsl:call-template name="script_bottom"/>
            <script type="text/javascript">
               function refresh() {
                  window.document.location.reload();
               }; 
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template match="vlauthorinfo">
    <xsl:variable name="sortedauthors">
        <xsl:for-each select="/document/context/vlauthorinfo/author[object_count &gt; 0]">
            <xsl:sort select="translate(lastname,&fromchars;,&tochars;)"
                      order="ascending"/>
            <xsl:sort select="translate(firstname,&fromchars;,&tochars;)"
                      order="ascending"/>
            <xsl:copy>
                <xsl:copy-of select="*"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="unmappedauthors">
        <xsl:for-each select="/document/context/vlauthorinfo/author[object_count = 0]">
            <xsl:sort select="translate(lastname,&fromchars;,&tochars;)"
                      order="ascending"/>
            <xsl:sort select="translate(firstname,&fromchars;,&tochars;)"
                      order="ascending"/>
            <xsl:copy>
                <xsl:copy-of select="*"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    
    <table width="600" align="center" id="vlpropertyinfo">
      <tr>
        <th colspan="{$authorcolumns}">
          <xsl:value-of select="$i18n_vlib/l/authors"/>
        </th>
      </tr>
      <xsl:apply-templates select="exslt:node-set($sortedauthors)/author[(position()-1) mod $authorcolumns = 0]">
        <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
        <xsl:sort select="translate(lastname,&fromchars;,&tochars;)"
                  order="ascending"/>
        <xsl:sort select="translate(firstname,&fromchars;,&tochars;)"
                  order="ascending"/>
      </xsl:apply-templates>
      <xsl:if test="count(/document/context/vlauthorinfo/author[object_count = 0])&gt;0">
        <tr>
          <th colspan="{$authorcolumns}">
            <xsl:value-of select="concat($i18n_vlib/l/unmapped, ' ', $i18n_vlib/l/authors)"/>
          </th>
        </tr>
        <xsl:apply-templates select="exslt:node-set($unmappedauthors)/author[(position()-1) mod $authorcolumns = 0]">
          <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
          <xsl:sort select="translate(lastname,&fromchars;,&tochars;)"
                    order="ascending"/>
          <xsl:sort select="translate(firstname,&fromchars;,&tochars;)"
                    order="ascending"/>
        </xsl:apply-templates>
      </xsl:if>
    </table>
 
</xsl:template>

<xsl:template match="author">
    <xsl:call-template name="item">
        <xsl:with-param name="mo" select="'author'"/>
        <xsl:with-param name="colms" select="$authorcolumns"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="cttobject.options.copy"/>

</xsl:stylesheet>
