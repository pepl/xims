<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_cv_wordmlstyle.xsl 1729 2007-09-13 19:42:54Z eagle74 $
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
    xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
>

<xsl:output method="xml"
    encoding="utf-8"/>

<xsl:variable name="preprint_id" select="/document/reference_types/reference_type[name='Preprint']/@id"/>

<xsl:key name="year" match="/document/context/object/children/object" use="substring(reference_values/reference_value[property_id=3]/value,1, 4)"/>

<!-- exclude Preprints from the key, as they shall come first in the listing; xsl:key does not seem to like the $preprint_id, so use the literal hardcoded value -->
<xsl:key name="reftype_id" match="object[reference_type_id != 10]/reference_type_id" use="."/>


<!--<xsl:key name="reftype_id_by_date" match="children/object" use="concat(reference_type_id, '+', reference_values/reference_value[property_id=3]/value)" />-->

<xsl:param name="ptitle"/>

<xsl:variable name="titlerefpropid" select="/document/reference_properties/reference_property[name='title']/@id"/>
<xsl:variable name="daterefpropid" select="/document/reference_properties/reference_property[name='date']/@id"/>
<xsl:variable name="btitlerefpropid" select="/document/reference_properties/reference_property[name='btitle']/@id"/>
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

<xsl:template match="/document">
    <?mso-application progid="Word.Document"?>
    <w:wordDocument xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml">
        <w:docPr>
            <w:view w:val="print"/>
        </w:docPr>
        <w:lists>
            <w:listDef w:listDefId="1">
                <w:lvl w:ilvl="0">
                    <w:start w:val="1" />
                    <w:nfc w:val="23" />
                    <w:lvlText w:val="&#x25cf;" />
                    <w:lvlJc w:val="left" />
                    <w:pPr>
                        <w:tabs>
                            <w:tab w:val="list" w:pos="360" />
                        </w:tabs>
                        <w:ind w:left="360" w:hanging="360" />
                        <w:spacing w:after="120" />
                    </w:pPr>
                </w:lvl>
            </w:listDef>
            <w:list w:ilfo="1">
                <w:ilst w:val="1" />
            </w:list>
        </w:lists>
        <w:body>
            <xsl:if test="$ptitle != ''">
                <w:p><w:r><w:rPr><w:b /></w:rPr><w:t><xsl:value-of select="$ptitle"/></w:t></w:r></w:p>
                <w:p><w:r><w:t></w:t></w:r></w:p>
            </xsl:if>
            <xsl:for-each select="context/object/children/object[substring(reference_values/reference_value[property_id=3]/value,1, 4) != '' and count(. | key('year', substring(reference_values/reference_value[property_id=3]/value,1, 4))[1]) = 1]">
                <!--<xsl:sort select="substring(., 1,4)" order="descending"/>-->
                <xsl:sort select="substring(reference_values/reference_value[property_id=3]/value,1, 4)" order="descending"/>
                <xsl:variable name="date" select="substring(reference_values/reference_value[property_id=3]/value,1, 4)"/>
                <w:p><w:r><w:rPr><w:b /></w:rPr><w:t><xsl:value-of select="$date"/>
                    <!--(<xsl:value-of select="count(/document/context/object/children/object[reference_values/reference_value[property_id=3 and starts-with(value,$date)]]/reference_type_id)"/>)-->
                    </w:t></w:r></w:p>
                <w:p><w:r><w:rPr><w:b w:val="off"/></w:rPr><w:t></w:t></w:r></w:p>
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
            </xsl:for-each>
            <!-- Deal with entries without a year -->

            <xsl:if test="context/object/children/object[string-length(reference_values/reference_value[property_id=3]/value)=0]">
                <w:p><w:r><w:rPr><w:b /></w:rPr><w:t>Without Year</w:t></w:r></w:p>
                <w:p><w:r><w:t></w:t></w:r></w:p>
                <xsl:if test="/document/context/object/children/object[reference_values/reference_value[property_id=3 and string-length(value)=0] and reference_type_id = $preprint_id]">
                    <w:p><w:r><w:rPr><w:b /></w:rPr><w:t>
                        <xsl:value-of select="/document/reference_types/reference_type[@id=$preprint_id]/name"/>s
                    </w:t></w:r></w:p>
                    <xsl:for-each select="/document/context/object/children/object[reference_values/reference_value[property_id=3 and string-length(value)=0] and reference_type_id = $preprint_id]">
                        <xsl:sort select="title" order="ascending"/>
                        <xsl:apply-templates select="." mode="divlist"/>
                    </xsl:for-each>
                </xsl:if>
                <xsl:for-each select="/document/context/object/children/object
                    [string-length(reference_values/reference_value[property_id=3]/value)=0 and generate-id(reference_type_id)=generate-id(key('reftype_id',reference_type_id)[1])]/reference_type_id">
                    <xsl:sort select="/document/reference_types/reference_type[@id=current()]/name" order="ascending"/>
                    <xsl:variable name="reference_type_id" select="."/>
                    <w:p><w:r><w:rPr><w:b /></w:rPr><w:t><xsl:value-of select="/document/reference_types/reference_type[@id=$reference_type_id]/name"/>s</w:t></w:r></w:p>
                    <xsl:for-each select="/document/context/object/children/object[reference_values/reference_value[property_id=3 and string-length(value)=0] and reference_type_id = $reference_type_id]">
                        <xsl:sort select="title" order="ascending"/>
                        <xsl:apply-templates select="." mode="divlist"/>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:if>
        </w:body>
    </w:wordDocument>
</xsl:template>

<xsl:template name="object_per_reftype">
    <xsl:param name="date"/>
    <xsl:param name="reference_type_id"/>
    <xsl:if test="/document/context/object/children/object[reference_values/reference_value[property_id=3 and starts-with(value,$date)] and reference_type_id = $reference_type_id]">
        <w:p><w:r><w:rPr><w:b /></w:rPr><w:t>
            <xsl:value-of select="/document/reference_types/reference_type[@id=$reference_type_id]/name"/>s
        </w:t></w:r></w:p>
        <w:p><w:r><w:rPr><w:b w:val="off"/></w:rPr><w:t></w:t></w:r></w:p>
        <xsl:for-each select="/document/context/object/children/object[reference_values/reference_value[property_id=3 and starts-with(value,$date)] and reference_type_id = $reference_type_id]">
            <xsl:sort select="reference_values/reference_value[property_id=3]/value" order="descending"/>
            <xsl:sort select="title" order="ascending"/>
            <xsl:apply-templates select="." mode="divlist"/>
        </xsl:for-each>
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
    <w:p>
        <w:pPr><w:listPr><w:ilvl w:val="0" /><w:ilfo w:val="1" /><wx:font wx:val="Symbol" /></w:listPr></w:pPr>
        <w:r><w:t>
            <xsl:choose>
                <xsl:when test="authorgroup/author">
                    <xsl:apply-templates select="authorgroup/author">
                        <xsl:sort select="./position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    Anonymous
                </xsl:otherwise>
            </xsl:choose>,</w:t>
            <w:rPr><w:i /></w:rPr><w:t>
                &#xa0;<xsl:value-of select="$title"/>
            </w:t><w:rPr><w:i w:val="off"/></w:rPr>
            <xsl:if test="$conf_title != ''"><w:t>,&#xa0;</w:t>
                <w:t><xsl:value-of select="$conf_title"/>
                <xsl:if test="$conf_venue != ''">
                    <xsl:text> (</xsl:text>
                        <xsl:value-of select="$conf_venue"/>
                    <xsl:if test="$conf_date != ''">,
                        <xsl:value-of select="$conf_date"/>
                    </xsl:if>
                    <xsl:text>)</xsl:text>
                </xsl:if></w:t>
            </xsl:if>
            <xsl:if test="$serial_id != '' or $btitle != ''"><w:t>,&#xa0;</w:t>
                <w:t><xsl:choose>
                    <xsl:when test="$serial_id != ''">
                        <xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$btitle"/>
                    </xsl:otherwise>
                </xsl:choose></w:t>
            </xsl:if><w:t>
            <xsl:if test="$volume != ''">&#xa0;<xsl:value-of select="$volume"/></xsl:if>
            <xsl:if test="$issue != ''">&#xa0;<xsl:value-of select="$issue"/></xsl:if>
            <xsl:if test="editorgroup/author">
                <xsl:text> (</xsl:text>
                Ed<xsl:if test="count(editorgroup/author) &gt; 1">s</xsl:if>.:
                    <xsl:apply-templates select="editorgroup"/>
                <xsl:text>)</xsl:text>
            </xsl:if></w:t>
            <xsl:choose>
                <xsl:when test="$spage != ''"><w:t>,&#xa0;</w:t>
                    <w:t><xsl:value-of select="$spage"/> <xsl:if test="$epage != ''">-<xsl:value-of select="$epage"/></xsl:if></w:t>
                </xsl:when>
                <xsl:when test="$pages != ''"><w:t>,&#xa0;</w:t>
                    <w:t><xsl:value-of select="$pages"/></w:t>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$artnum != ''"><w:t>, <xsl:value-of select="$artnum"/></w:t></xsl:if>
            <xsl:if test="normalize-space(notes) != ''"><w:t>, <xsl:value-of select="notes"/></w:t></xsl:if>
            <xsl:call-template name="date">
                <xsl:with-param name="date" select="$date"/>
            </xsl:call-template>
            <xsl:call-template name="url_identifier">
                <xsl:with-param name="url" select="$url"/>
                <xsl:with-param name="url2" select="$url2"/>
                <xsl:with-param name="identifier" select="$identifier"/>
            </xsl:call-template>
        </w:r>
    </w:p>
</xsl:template>

<xsl:template name="date">
    <xsl:param name="date"/>
    <xsl:if test="$date != ''"><w:t>&#xa0;(<xsl:value-of select="substring($date,1,4)"/>)</w:t></xsl:if>
</xsl:template>

<xsl:template name="url_identifier">
    <xsl:param name="url"/>
    <xsl:param name="url2"/>
    <xsl:param name="identifier"/>
    <xsl:if test="reference_type_id = $preprint_id and $identifier != ''"><w:t>;
        <xsl:choose>
            <xsl:when test="starts-with($identifier, 'oai:arXiv.org:')">url: <xsl:value-of select="concat('http://arXiv.org/abs/',substring-after($identifier,'oai:arXiv.org:'))" /></xsl:when>
            <xsl:when test="starts-with($identifier, 'doi:')">url: <xsl:value-of select="concat('http://dx.doi.org/',substring-after($identifier,'doi:'))" /></xsl:when>
            <xsl:otherwise>identifier: <xsl:value-of select="$identifier"/></xsl:otherwise>
        </xsl:choose></w:t>
    </xsl:if>
</xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author">
    <xsl:if test="firstname != ''"><xsl:choose><xsl:when test="contains(firstname,'.')"><xsl:value-of select="firstname"/></xsl:when><xsl:otherwise><xsl:value-of select="substring(firstname, 1,1)"/>.</xsl:otherwise></xsl:choose><xsl:text> </xsl:text></xsl:if><xsl:if test="middlename != ''"><xsl:choose><xsl:when test="contains(middlename,'.')"><xsl:value-of select="middlename"/></xsl:when><xsl:otherwise><xsl:value-of select="substring(middlename, 1,1)"/>.</xsl:otherwise></xsl:choose><xsl:text> </xsl:text></xsl:if><xsl:value-of select="lastname"/>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>


</xsl:stylesheet>

