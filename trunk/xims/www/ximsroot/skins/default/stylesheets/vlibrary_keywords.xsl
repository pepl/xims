<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_keywords.xsl 2203 2009-04-29 10:46:36Z haensel $
-->

<!DOCTYPE stylesheet [
<!ENTITY  fromchars "'aÄäbcdefghijklmnoÖöpqrsßtuÜüvwxyz@„&quot;'">
<!ENTITY    tochars "'AAABCDEFGHIJKLMNOOOPQRSSTUUUVWXYZ___'">
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:exslt="http://exslt.org/common"
                extension-element-prefixes="exslt">

    <xsl:import href="vlibrary_default.xsl"/>
		
		<xsl:param name="mo" select="'keyword'"/>
		
		<xsl:variable name="properties">
    <xsl:for-each select="/document/context/vlkeywordinfo/keyword">
      <xsl:copy>
        <xsl:copy-of select="*"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="vlib_ots">
    <xsl:for-each select="/document/object_types/object_type[parent_id !='']">
      <xsl:copy>
        <xsl:copy-of select="name|@id"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:variable>

    <xsl:template match="vlkeywordinfo">
        <xsl:variable name="sortedkeywords">
            <xsl:for-each select="/document/context/vlkeywordinfo/keyword[object_count &gt; 0]">
                <xsl:sort select="translate(name,&fromchars;,&tochars;)"
                          order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="unmappedkeywords">
          <xsl:for-each select="/document/context/vlkeywordinfo/keyword[object_count = 0]">
            <xsl:sort select="translate(name,&fromchars;,&tochars;)"
                      order="ascending"/>
            <xsl:copy>
              <xsl:copy-of select="*"/>
            </xsl:copy>
          </xsl:for-each>
        </xsl:variable>
        
        <xsl:call-template name="vlpropertyinfo">
			<xsl:with-param name="sortedproperties" select="$sortedkeywords"/>
			<xsl:with-param name="unmappedproperties" select="$unmappedkeywords"/>
			<xsl:with-param name="mo" select="'keyword'"/>
    </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
