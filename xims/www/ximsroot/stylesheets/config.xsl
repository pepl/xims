<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="goxims">/goxims</xsl:variable>
  <xsl:variable name="contentinterface">/content</xsl:variable>
  <xsl:variable name="publicuser">public</xsl:variable>
  <xsl:variable name="goxims_content">
    <xsl:choose>
        <xsl:when test="/document/context/session/user/name != $publicuser">/goxims/content</xsl:when>
        <xsl:otherwise>/gopublic/content</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="gopublic_content">/gopublic/content</xsl:variable>
  <xsl:variable name="goxims_users">/goxims/users</xsl:variable>
  <xsl:variable name="xims_box"><xsl:value-of select="/document/context/session/serverurl"/></xsl:variable>
  <xsl:variable name="ximsroot"><xsl:value-of select="$xims_box"/>/ximsroot/</xsl:variable>
  <xsl:variable name="publishingroot"><xsl:value-of select="/document/context/object/parents/object[@parent_id = '1' and @document_id != '1']/title"/></xsl:variable>
  <xsl:variable name="currentskin"><xsl:value-of select="/document/context/session/skin"/></xsl:variable>
  <xsl:variable name="defaultcss">skins/<xsl:value-of select="$currentskin"/>/stylesheets/default.css</xsl:variable>
  <xsl:variable name="resolvereltositeroots">1</xsl:variable>
  <xsl:variable name="organisation">The XIMS Project</xsl:variable>
  <xsl:variable name="searchresultrowlimit">15</xsl:variable>
</xsl:stylesheet>
