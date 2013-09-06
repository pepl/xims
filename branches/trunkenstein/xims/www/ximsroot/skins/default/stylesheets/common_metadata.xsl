<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_metadata.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="object-metadata">
    <p>
        <xsl:value-of select="$i18n/l/Metadata"/> <xsl:value-of select="$absolute_path"/>
    </p>
    <p>
                <xsl:value-of select="$i18n/l/Title"/>: <xsl:apply-templates select="title"/>
            <br/>
                <xsl:value-of select="$i18n/l/abstract"/>: <xsl:apply-templates select="abstract"/>
            <br/>
                <xsl:value-of select="$i18n/l/keywords"/>: <xsl:apply-templates select="keywords" />
            <br/>
                <xsl:value-of select="$i18n/l/Dataformat"/>: <xsl:value-of select="data_format/name" />-<xsl:value-of select="object_type/name" />&#160;<xsl:value-of select="data_format/mime_type" />
            <br/>
                <xsl:value-of select="$i18n/l/Size"/>: <xsl:value-of select="format-number(lob_length , ',###,##0')"/>&#160;Bytes
    </p>
</xsl:template>

<xsl:template name="user-metadata">
	<div id="user-metadata">
                <div id="user-metadata-create">
                    <xsl:value-of select="$i18n/l/Created_by"/>&#160;<xsl:call-template name="creatorfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                <br />
                    <xsl:value-of select="$i18n/l/Owned_by"/>&#160;<xsl:call-template name="ownerfullname"/>
                </div>
                <div id="user-metadata-publish">
                    <xsl:value-of select="$i18n/l/Last_modified_by"/>&#160;<xsl:call-template name="modifierfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>                
                <br />
                    <xsl:if test="published=1">
                        <xsl:value-of select="$i18n/l/Last_published_by"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$i18n/l/at_time"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                    </xsl:if>
                </div>
                <br class="clear"/>
  </div>
</xsl:template>

<xsl:template name="document-metadata">
    <p class="documentquote">
            Document:
            <!-- created_by should be replaced by owned_by! -->
            <xsl:call-template name="ownerfullname"/>,
            <xsl:value-of select="title"/>,
            [<xsl:value-of select="concat($goxims_content,$absolute_path)"/>],
            <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
           <br/>
           <xsl:if test="abstract != '&#160;'">
                <xsl:value-of select="$i18n/l/Abstract"/>:<br/>
                <xsl:apply-templates select="abstract"/>
            </xsl:if>
    </p>
</xsl:template>

</xsl:stylesheet>
