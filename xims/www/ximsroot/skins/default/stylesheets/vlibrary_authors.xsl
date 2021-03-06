<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_authors.xsl 2203 2009-04-29 10:46:36Z haensel $
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
		
		<xsl:param name="mo" select="'author'"/>
		
		<xsl:variable name="properties">
    <xsl:for-each select="/document/context/vlauthorinfo/author">
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
    
    <xsl:call-template name="vlpropertyinfo">
			<xsl:with-param name="sortedproperties" select="$sortedauthors"/>
			<xsl:with-param name="unmappedproperties" select="$unmappedauthors"/>
			<xsl:with-param name="mo" select="'author'"/>
    </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
