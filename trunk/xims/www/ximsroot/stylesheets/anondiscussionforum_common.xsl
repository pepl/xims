<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:param name="sb" select="'date'"/>
<xsl:param name="order" select="'desc'"/>

<xsl:template match="br|a|b|i|p|strong|em|dd|dl|li|ul|ol|hr|font|span|div">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
</xsl:template>

<xsl:template name="path2topics">
    <xsl:for-each select="/document/context/object/parents/object[object_type_id != /document/object_types/object_type[name='AnonDiscussionForumContrib']/@id and @id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
