<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibrary_cv_defaultstyle.xsl"/>

<xsl:template name="url_identifier">
    <xsl:param name="url"/>
    <xsl:param name="identifier"/>

    <xsl:if test="$url != ''">&#xa0;<span class="reflib_url"><a href="{$url}"><xsl:value-of select="$url"/></a></span></xsl:if>
    <xsl:if test="$identifier != ''"><span class="reflib_identifier">; identifier:
        <xsl:choose>
            <xsl:when test="starts-with($identifier, 'oai:arXiv.org:')">
                <a href="http://arXiv.org/abs/{substring-after($identifier,'oai:arXiv.org:')}"><xsl:value-of select="$identifier"/></a>
            </xsl:when>
            <xsl:when test="starts-with($identifier, 'doi:')">
                <a href="http://www.crossref.org/openurl?url_ver=Z39.88-2004&amp;rft_id=info:doi/{substring-after($identifier,'doi:')}"><xsl:value-of select="$identifier"/></a>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of select="$identifier"/>
            </xsl:otherwise>
        </xsl:choose></span>
    </xsl:if>
</xsl:template>

<xsl:template name="abstract"/>

</xsl:stylesheet>

