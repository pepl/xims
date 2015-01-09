<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_cv_printstyle.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibrary_cv_defaultstyle.xsl"/>

<xsl:output method="xml"
    encoding="utf-8"
    media-type="text/html"
    omit-xml-declaration="yes"
    doctype-system="about:legacy-compat"
    indent="no"/>

<xsl:template name="url_identifier">
    <xsl:param name="url"/>
    <xsl:param name="url2"/>
    <xsl:param name="identifier"/>
    <xsl:if test="reference_type_id = $preprint_id and $identifier != ''"><span class="reflib_identifier">;
        <xsl:choose>
            <xsl:when test="starts-with($identifier, 'oai:arXiv.org:')">url: <a href="http://arXiv.org/abs/{substring-after($identifier,'oai:arXiv.org:')}">http://arXiv.org/abs/<xsl:value-of select="substring-after($identifier,'oai:arXiv.org:')"/></a></xsl:when>
            <xsl:when test="starts-with($identifier, 'doi:')">url: <a href="http://www.crossref.org/openurl?url_ver=Z39.88-2004&amp;rft_id=info:doi/{substring-after($identifier,'doi:')}">http://www.crossref.org/openurl?url_ver=Z39.88-2004&amp;rft_id=info:doi/<xsl:value-of select="substring-after($identifier,'doi:')"/></a></xsl:when>
            <xsl:otherwise>identifier: <xsl:value-of select="$identifier"/></xsl:otherwise>
        </xsl:choose></span>
    </xsl:if>
</xsl:template>

<xsl:template name="abstract"/>

</xsl:stylesheet>
