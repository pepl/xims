<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_cv_defaultstyle.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">


<xsl:import href="common.xsl"/>
<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:output method="xml"
            encoding="utf-8"
            media-type="text/html"
            omit-xml-declaration="yes"
            doctype-system="about:legacy-compat"
            indent="no"/>

<xsl:variable name="preprint_id" select="/document/reference_types/reference_type[name='Preprint']/@id"/>

<xsl:key name="year" match="/document/context/object/children/object" use="substring(reference_values/reference_value[property_id=3]/value,1, 4)"/>

<!-- exclude Preprints from the key, as they shall come first in the listing; xsl:key does not seem to like the $preprint_id, so use the literal hardcoded value -->
<xsl:key name="reftype_id" match="object[reference_type_id != 10]/reference_type_id" use="."/>


<!--<xsl:key name="reftype_id_by_date" match="children/object" use="concat(reference_type_id, '+', reference_values/reference_value[property_id=3]/value)" />-->

<xsl:param name="css" select="concat($ximsroot,'skins/',$currentskin,'/stylesheets/reference_library_cv_defaultstyle.css')"/>
<xsl:param name="ptitle"/>

<xsl:variable name="volumerefpropid" select="/document/reference_properties/reference_property[name='volume']/@id"/>
<xsl:variable name="issuerefpropid" select="/document/reference_properties/reference_property[name='issue']/@id"/>
<xsl:variable name="pagesrefpropid" select="/document/reference_properties/reference_property[name='pages']/@id"/>
<xsl:variable name="spagerefpropid" select="/document/reference_properties/reference_property[name='spage']/@id"/>
<xsl:variable name="epagerefpropid" select="/document/reference_properties/reference_property[name='epage']/@id"/>
<xsl:variable name="identifierrefpropid" select="/document/reference_properties/reference_property[name='identifier']/@id"/>
<xsl:variable name="pprintidentifierrefpropid" select="/document/reference_properties/reference_property[name='preprint_identifier']/@id"/>
<xsl:variable name="urlrefpropid" select="/document/reference_properties/reference_property[name='url']/@id"/>
<xsl:variable name="url2refpropid" select="/document/reference_properties/reference_property[name='url2']/@id"/>
<xsl:variable name="lrestrictedurlrefpropid" select="/document/reference_properties/reference_property[name='local_restricted_url']/@id"/>
<xsl:variable name="artnumrefpropid" select="/document/reference_properties/reference_property[name='artnum']/@id"/>
<xsl:variable name="conftitlerefpropid" select="/document/reference_properties/reference_property[name='conf_title']/@id"/>
<xsl:variable name="confdaterefpropid" select="/document/reference_properties/reference_property[name='conf_date']/@id"/>
<xsl:variable name="confvenuerefpropid" select="/document/reference_properties/reference_property[name='conf_venue']/@id"/>
<xsl:variable name="confurlrefpropid" select="/document/reference_properties/reference_property[name='conf_url']/@id"/>
<xsl:variable name="workgrouprefpropid" select="/document/reference_properties/reference_property[name='workgroup']/@id"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:if test="$ptitle != ''">
                <h1 id="reflib_ptitle"><span class="reflib_ptitle"><xsl:value-of select="$ptitle"/></span></h1>
            </xsl:if>
            <div id="reflib_citebody">
                <xsl:for-each select="children/object[substring(reference_values/reference_value[property_id=3]/value,1, 4) != '' and count(. | key('year', substring(reference_values/reference_value[property_id=3]/value,1, 4))[1]) = 1]">
                    <!--<xsl:sort select="substring(., 1,4)" order="descending"/>-->
                    <xsl:sort select="substring(reference_values/reference_value[property_id=3]/value,1, 4)" order="descending"/>
                    <xsl:variable name="date" select="substring(reference_values/reference_value[property_id=3]/value,1, 4)"/>
                    <h2>
                        <span class="reflib_year"><xsl:value-of select="$date"/></span>
                        <!--(<xsl:value-of select="count(/document/context/object/children/object[reference_values/reference_value[property_id=3 and starts-with(value,$date)]]/reference_type_id)"/>)-->
                    </h2>
                    <div class="reflib_citedivyear">
                        <xsl:call-template name="object_per_reftype">
                            <xsl:with-param name="date" select="$date"/>
                            <xsl:with-param name="reference_type_id" select="$preprint_id"/>
                        </xsl:call-template>
                        <xsl:for-each select="/document/context/object/children/object
                                      [generate-id(reference_type_id)=generate-id(key('reftype_id',reference_type_id)[1])]/reference_type_id">
                            <!-- and reference_values/reference_value[property_id=3]/value=$date -->
                            <xsl:sort select="/document/reference_types/reference_type[@id=current()]/name" order="ascending"/>
                            <xsl:variable name="reference_type_id" select="."/>
                            <xsl:call-template name="object_per_reftype">
                                <xsl:with-param name="date" select="$date"/>
                                <xsl:with-param name="reference_type_id" select="$reference_type_id"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </div>
                </xsl:for-each>

                <!-- Deal with entries without a year -->

                <xsl:if test="children/object[string-length(reference_values/reference_value[property_id=3]/value)=0]">
                    <h2><span class="reflib_year">Without Year</span></h2>
                    <div class="reflib_citedivyear">
                        <xsl:if test="/document/context/object/children/object[reference_values/reference_value[property_id=3 and string-length(value)=0] and reference_type_id = $preprint_id]">
                            <h3>
                                <xsl:value-of select="/document/reference_types/reference_type[@id=$preprint_id]/name"/>s
                            </h3>
                            <ul class="reflib_citelist">
                                <xsl:for-each select="/document/context/object/children/object[reference_values/reference_value[property_id=3 and string-length(value)=0] and reference_type_id = $preprint_id]">
                                    <xsl:sort select="title" order="ascending"/>
                                    <xsl:apply-templates select="." mode="divlist"/>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        <xsl:for-each select="/document/context/object/children/object
                            [string-length(reference_values/reference_value[property_id=3]/value)=0 and generate-id(reference_type_id)=generate-id(key('reftype_id',reference_type_id)[1])]/reference_type_id">
                            <xsl:sort select="/document/reference_types/reference_type[@id=current()]/name" order="ascending"/>
                            <xsl:variable name="reference_type_id" select="."/>
                            <h3>
                                <span class="reflib_referencetype"><xsl:value-of select="/document/reference_types/reference_type[@id=$reference_type_id]/name"/>s</span>
                            </h3>
                            <ul class="reflib_citelist">
                                <xsl:for-each select="/document/context/object/children/object[reference_values/reference_value[property_id=3 and string-length(value)=0] and reference_type_id = $reference_type_id]">
                                    <xsl:sort select="title" order="ascending"/>
                                    <xsl:apply-templates select="." mode="divlist"/>
                                </xsl:for-each>
                            </ul>
                        </xsl:for-each>
                    </div>
                </xsl:if>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template name="object_per_reftype">
    <xsl:param name="date"/>
    <xsl:param name="reference_type_id"/>
    <!-- Hmm, there must be a better way instead of doing that xsl:if here... -->
    <xsl:if test="/document/context/object/children/object[reference_values/reference_value[property_id=3 and starts-with(value,$date)] and reference_type_id = $reference_type_id]">
        <h3>
            <span class="reflib_referencetype"><xsl:value-of select="/document/reference_types/reference_type[@id=$reference_type_id]/name"/>s</span>
        </h3>
        <ul class="reflib_citelist">
            <xsl:for-each select="/document/context/object/children/object[reference_values/reference_value[property_id=3 and starts-with(value,$date)] and reference_type_id = $reference_type_id]">
                <xsl:sort select="reference_values/reference_value[property_id=3]/value" order="descending"/>
                <xsl:sort select="title" order="ascending"/>
                <xsl:apply-templates select="." mode="divlist"/>
            </xsl:for-each>
        </ul>
    </xsl:if>
</xsl:template>

<xsl:template match="children/object" mode="divlist">
    <xsl:variable name="referencenumber"><xsl:number count="object" /></xsl:variable>
    <xsl:variable name="date" select="reference_values/reference_value[property_id=$daterefpropid]/value"/>
    <xsl:variable name="btitle" select="reference_values/reference_value[property_id=$btitlerefpropid]/value"/>
    <xsl:variable name="volume" select="reference_values/reference_value[property_id=$volumerefpropid]/value"/>
    <xsl:variable name="issue" select="reference_values/reference_value[property_id=$issuerefpropid]/value"/>
    <xsl:variable name="pages" select="reference_values/reference_value[property_id=$pagesrefpropid]/value"/>
    <xsl:variable name="spage" select="reference_values/reference_value[property_id=$spagerefpropid]/value"/>
    <xsl:variable name="epage" select="reference_values/reference_value[property_id=$epagerefpropid]/value"/>
    <xsl:variable name="identifier" select="reference_values/reference_value[property_id=$identifierrefpropid]/value"/>
    <xsl:variable name="preprint_identifier" select="reference_values/reference_value[property_id=$pprintidentifierrefpropid]/value"/>
    <xsl:variable name="url" select="reference_values/reference_value[property_id=$urlrefpropid]/value"/>
    <xsl:variable name="url2" select="reference_values/reference_value[property_id=$url2refpropid]/value"/>
    <xsl:variable name="local_restricted_url" select="reference_values/reference_value[property_id=$lrestrictedurlrefpropid]/value"/>
    <xsl:variable name="artnum" select="reference_values/reference_value[property_id=$artnumrefpropid]/value"/>
    <xsl:variable name="conf_title" select="reference_values/reference_value[property_id=$conftitlerefpropid]/value"/>
    <xsl:variable name="conf_date" select="reference_values/reference_value[property_id=$confdaterefpropid]/value"/>
    <xsl:variable name="conf_venue" select="reference_values/reference_value[property_id=$confvenuerefpropid]/value"/>
    <xsl:variable name="conf_url" select="reference_values/reference_value[property_id=$confurlrefpropid]/value"/>
    <xsl:variable name="workgroup" select="reference_values/reference_value[property_id=$workgrouprefpropid]/value"/>
    <xsl:variable name="title" select="reference_values/reference_value[property_id=$titlerefpropid]/value"/>
    <xsl:variable name="serial_id" select="serial_id"/>
    <li class="reflib_citation" name="reflib_citation">
        <span class="reflib_citation">
            <span class="reflib_authors">
                <xsl:choose>
                    <xsl:when test="authorgroup/author">
                        <xsl:apply-templates select="authorgroup/author">
                            <xsl:sort select="./position" order="ascending" data-type="number"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        Anonymous</xsl:otherwise>
                </xsl:choose>
            </span>,
            <em><span class="reflib_title">
                <xsl:value-of select="$title"/>
            </span></em>
            <xsl:if test="$conf_title != ''">,
                <span class="reflib_conference_title">
                    <xsl:choose>
                        <xsl:when test="$conf_url != ''">
                            <a href="{$conf_url}">
                                <xsl:value-of select="$conf_title"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$conf_title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:if test="$conf_venue != ''">
                    <xsl:text> (</xsl:text>
                    <span class="reflib_conference_venue">
                        <xsl:value-of select="$conf_venue"/>
                    </span>
                    <xsl:if test="$conf_date != ''">,
                        <span class="reflib_conference_date">
                            <xsl:value-of select="$conf_date"/>
                        </span>
                    </xsl:if>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:if test="$serial_id != '' or $btitle != ''">,
                <span class="reflib_serial">
                    <xsl:choose>
                        <xsl:when test="$serial_id != ''">
                            <xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$btitle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:if><xsl:if test="$volume != ''">&#xa0;<span class="reflib_volume"><xsl:value-of select="$volume"/></span></xsl:if><xsl:if test="$issue != ''">&#xa0;<span class="reflib_issue"><xsl:value-of select="$issue"/></span></xsl:if>
            <xsl:if test="editorgroup/author">
                <xsl:text> (</xsl:text>
                <span class="reflib_editors">Ed<xsl:if test="count(editorgroup/author) &gt; 1">s</xsl:if>.:
                    <xsl:apply-templates select="editorgroup"/>
                </span>
                <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$spage != ''">,
                    <span class="reflib_page"><xsl:value-of select="$spage"/> <xsl:if test="$epage != ''">-<xsl:value-of select="$epage"/></xsl:if></span>
                </xsl:when>
                <xsl:when test="$pages != ''">,
                    <span class="reflib_page"><xsl:value-of select="$pages"/></span>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$artnum != ''">, <span class="reflib_artnum"><xsl:value-of select="$artnum"/></span></xsl:if>
            <xsl:if test="normalize-space(notes) != ''">, <span class="reflib_notes"><xsl:value-of select="notes"/></span></xsl:if>
            <xsl:call-template name="date">
                <xsl:with-param name="date" select="$date"/>
            </xsl:call-template>
            <xsl:call-template name="url_identifier">
                <xsl:with-param name="url" select="$url"/>
                <xsl:with-param name="url2" select="$url2"/>
                <xsl:with-param name="local_restricted_url" select="$local_restricted_url"/>
                <xsl:with-param name="identifier" select="$identifier"/>
                <xsl:with-param name="preprint_identifier" select="$preprint_identifier"/>
                <xsl:with-param name="title" select="$title"/>
                <xsl:with-param name="date" select="$date"/>
                <xsl:with-param name="workgroup" select="$workgroup"/>
                <xsl:with-param name="reflibid" select="@document_id"/>
            </xsl:call-template>
            <xsl:call-template name="abstract">
                <xsl:with-param name="referencenumber" select="$referencenumber"/>
            </xsl:call-template>
        </span>
    </li>
</xsl:template>

<xsl:template name="date">
    <xsl:param name="date"/>
    <xsl:if test="$date != ''">&#xa0;<span class="reflib_date">(<xsl:value-of select="substring($date,1,4)"/>)</span></xsl:if>
</xsl:template>

<xsl:template name="url_identifier">
    <xsl:param name="url"/>
    <xsl:param name="url2"/>
    <xsl:param name="local_restricted_url"/>
    <xsl:param name="identifier"/>
    <xsl:param name="preprint_identifier"/>
    <xsl:param name="title"/>
    <xsl:param name="date"/>
    <xsl:param name="workgroup"/>
    <xsl:param name="reflibid"/>
    <xsl:if test="$url != ''">&#xa0;<span class="reflib_url"><a href="{$url}">URL</a></span></xsl:if>
    <xsl:if test="$url2 != ''">&#xa0;<span class="reflib_url"><a href="{$url2}">Alternative URL (local copy)</a></span></xsl:if>
    <xsl:if test="$local_restricted_url = 1">&#xa0;<span class="reflib_url">
        <a>
            <xsl:attribute name="href">
            <xsl:call-template name="local_restricted_url_url_generator">
                <xsl:with-param name="date" select="$date"/>
                <xsl:with-param name="title" select="$title"/>
                <xsl:with-param name="workgroup" select="$workgroup"/>
                <xsl:with-param name="reflibid" select="$reflibid"/>
            </xsl:call-template>
            </xsl:attribute>Alternative URL (local restricted copy)
        </a></span>
    </xsl:if>
    <xsl:if test="$preprint_identifier != ''"><span class="reflib_preprint_identifier">&#xa0;<xsl:call-template name="identifier_link"><xsl:with-param name="identifier" select="$preprint_identifier"></xsl:with-param><xsl:with-param name="linktext">Preprint Identifier</xsl:with-param></xsl:call-template></span></xsl:if>
    <xsl:if test="$identifier != ''"><span class="reflib_identifier">; <xsl:call-template name="identifier_link"><xsl:with-param name="identifier" select="$identifier"></xsl:with-param></xsl:call-template></span></xsl:if>
</xsl:template>

<xsl:template name="local_restricted_url_url_generator">
    <xsl:param name="title"/>
    <xsl:param name="date"/>
    <xsl:param name="workgroup"/>
    <xsl:param name="reflibid"/>

    <xsl:variable name="quot">"</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>

    <xsl:text>intranet/reflibdocs/</xsl:text>
    <xsl:value-of select="concat(substring($date,1,4),'/')"/>
    <xsl:if test="$workgroup != ''">
        <xsl:value-of select="concat($workgroup,'/')"/>
    </xsl:if>
    <xsl:value-of select="concat($reflibid,'_')"/>
    <!-- This is no good and will only catch some chars :-(  Think of removing the title from the path here -->
    <xsl:value-of select="concat(translate(translate(translate($title,'ABCDEFGHIJKLMNOPQRSTUVWXYZöäüßÖÄÜ -()?*#,₁₂','abcdefghijklmnopqrstuvwxyz_________________'),$apos,'_'),$quot,'_'),'.pdf')"/>
</xsl:template>


<xsl:template name="identifier_link">
    <xsl:param name="identifier"/>
    <xsl:param name="linktext"/>
    <xsl:choose>
        <xsl:when test="starts-with($identifier, 'oai:arXiv.org:')">
            <a href="http://arXiv.org/abs/{substring-after($identifier,'oai:arXiv.org:')}">
                <xsl:choose>
                    <xsl:when test="$linktext != ''"><xsl:value-of select="$linktext"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$identifier"/></xsl:otherwise>
                </xsl:choose>
            </a>
        </xsl:when>
        <xsl:when test="starts-with($identifier, 'doi:')">
            <a href="http://www.crossref.org/openurl?url_ver=Z39.88-2004&amp;rft_id=info:doi/{substring-after($identifier,'doi:')}">
                <xsl:choose>
                    <xsl:when test="$linktext != ''"><xsl:value-of select="$linktext"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$identifier"/></xsl:otherwise>
                </xsl:choose>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$identifier"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="abstract">
    <xsl:param name="referencenumber"/>
    <xsl:if test="normalize-space(abstract) != ''">
        &#xa0;<a href="#" onclick="blocking('abstract{$referencenumber}'); return false;">Toggle Abstract</a>
        <div id="abstract{$referencenumber}" class="reflib_abstract" style="display: none"><xsl:apply-templates select="abstract"/></div>
    </xsl:if>
</xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author">
    <span class="reflib_author">
        <xsl:if test="firstname != ''"><xsl:choose><xsl:when test="contains(firstname,'.')"><xsl:value-of select="firstname"/></xsl:when><xsl:otherwise><xsl:value-of select="substring(firstname, 1,1)"/>.</xsl:otherwise></xsl:choose><xsl:text> </xsl:text></xsl:if><xsl:if test="middlename != ''"><xsl:choose><xsl:when test="contains(middlename,'.')"><xsl:value-of select="middlename"/></xsl:when><xsl:otherwise><xsl:value-of select="substring(middlename, 1,1)"/>.</xsl:otherwise></xsl:choose><xsl:text> </xsl:text></xsl:if><xsl:value-of select="lastname"/>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </span>
</xsl:template>


<xsl:template name="head_default">
    <head>
        <title>Publications - <xsl:if test="$ptitle != ''"><xsl:value-of select="$ptitle"/> - </xsl:if> <xsl:value-of select="title" /></title>
        <link rel="stylesheet" href="{$ximsroot}stylesheets/default.css" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
        <link rel="stylesheet" href="{$css}" type="text/css"/>
        <script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

</xsl:stylesheet>

