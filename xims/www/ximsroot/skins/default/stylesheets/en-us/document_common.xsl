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

<xsl:template name="publish">
    <xsl:choose>
        <xsl:when test="published = 1">
          <p>
            This document is currently published as <a href="{$publishingroot}{$absolute_path}">
            <xsl:value-of select="concat($publishingroot,$absolute_path)"/></a><br/><br/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="publish" value="Republish" class="control"/>
            <input type="submit" name="unpublish" value="Unpublish" class="control"/>
          </p>
          <p/>
        </xsl:when>
        <xsl:otherwise>
          <p>
            This document is currently not published<br/><br/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="publish" value="Publish" class="control"/>
           </p>
          <p/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
