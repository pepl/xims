<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_export_mods.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.loc.gov/mods/v3"
                xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.0/"
                xmlns:reflib="http://xims.info/ns/ReferenceLibrary">

    <xsl:import href="common.xsl"/>

    <xsl:output method="xml"
                media-type="application/mods+xml"/>

    <xsl:param name="ptitle"/>

    <xsl:variable name="titlerefpropid" select="/document/reference_properties/reference_property[name='title']/@id"/>
    <xsl:variable name="btitlerefpropid" select="/document/reference_properties/reference_property[name='btitle']/@id"/>
    <xsl:variable name="daterefpropid" select="/document/reference_properties/reference_property[name='date']/@id"/>
    <xsl:variable name="chronrefpropid" select="/document/reference_properties/reference_property[name='chron']/@id"/>
    <xsl:variable name="ssnrefpropid" select="/document/reference_properties/reference_property[name='ssn']/@id"/>
    <xsl:variable name="quarterrefpropid" select="/document/reference_properties/reference_property[name='quarter']/@id"/>
    <xsl:variable name="volumerefpropid" select="/document/reference_properties/reference_property[name='volume']/@id"/>
    <xsl:variable name="partrefpropid" select="/document/reference_properties/reference_property[name='part']/@id"/>
    <xsl:variable name="issuerefpropid" select="/document/reference_properties/reference_property[name='issue']/@id"/>
    <xsl:variable name="spagerefpropid" select="/document/reference_properties/reference_property[name='spage']/@id"/>
    <xsl:variable name="epagerefpropid" select="/document/reference_properties/reference_property[name='epage']/@id"/>
    <xsl:variable name="pagesrefpropid" select="/document/reference_properties/reference_property[name='pages']/@id"/>
    <xsl:variable name="artnumrefpropid" select="/document/reference_properties/reference_property[name='artnum']/@id"/>
    <xsl:variable name="isbnrefpropid" select="/document/reference_properties/reference_property[name='isbn']/@id"/>
    <xsl:variable name="codenrefpropid" select="/document/reference_properties/reference_property[name='coden']/@id"/>
    <xsl:variable name="sicirefpropid" select="/document/reference_properties/reference_property[name='sici']/@id"/>
    <xsl:variable name="placerefpropid" select="/document/reference_properties/reference_property[name='place']/@id"/>
    <xsl:variable name="pubrefpropid" select="/document/reference_properties/reference_property[name='pub']/@id"/>
    <xsl:variable name="editionrefpropid" select="/document/reference_properties/reference_property[name='edition']/@id"/>
    <xsl:variable name="tpagesrefpropid" select="/document/reference_properties/reference_property[name='tpages']/@id"/>
    <xsl:variable name="seriesrefpropid" select="/document/reference_properties/reference_property[name='series']/@id"/>
    <xsl:variable name="issnrefpropid" select="/document/reference_properties/reference_property[name='issn']/@id"/>
    <xsl:variable name="bicirefpropid" select="/document/reference_properties/reference_property[name='bici']/@id"/>
    <xsl:variable name="corefpropid" select="/document/reference_properties/reference_property[name='co']/@id"/>
    <xsl:variable name="instrefpropid" select="/document/reference_properties/reference_property[name='inst']/@id"/>
    <xsl:variable name="advisorrefpropid" select="/document/reference_properties/reference_property[name='advisor']/@id"/>
    <xsl:variable name="degreerefpropid" select="/document/reference_properties/reference_property[name='degree']/@id"/>
    <xsl:variable name="identifierrefpropid" select="/document/reference_properties/reference_property[name='identifier']/@id"/>
    <xsl:variable name="statusrefpropid" select="/document/reference_properties/reference_property[name='status']/@id"/>
    <xsl:variable name="conf_venuerefpropid" select="/document/reference_properties/reference_property[name='conf_venue']/@id"/>
    <xsl:variable name="conf_daterefpropid" select="/document/reference_properties/reference_property[name='conf_date']/@id"/>
    <xsl:variable name="conf_titlerefpropid" select="/document/reference_properties/reference_property[name='conf_title']/@id"/>
    <xsl:variable name="conf_sponsorrefpropid" select="/document/reference_properties/reference_property[name='conf_sponsor']/@id"/>
    <xsl:variable name="conf_urlrefpropid" select="/document/reference_properties/reference_property[name='conf_url']/@id"/>
    <xsl:variable name="urlrefpropid" select="/document/reference_properties/reference_property[name='url']/@id"/>
    <xsl:variable name="access_timestamprefpropid" select="/document/reference_properties/reference_property[name='access_timestamp']/@id"/>
    <xsl:variable name="citekeyrefpropid" select="/document/reference_properties/reference_property[name='citekey']/@id"/>
    <xsl:variable name="url2refpropid" select="/document/reference_properties/reference_property[name='url2']/@id"/>
    <xsl:variable name="workgrouprefpropid" select="/document/reference_properties/reference_property[name='workgroup']/@id"/>
    <xsl:variable name="preprint_identifierrefpropid" select="/document/reference_properties/reference_property[name='preprint_identifier']/@id"/>
    <xsl:variable name="projectrefpropid" select="/document/reference_properties/reference_property[name='project']/@id"/>
    <xsl:variable name="preprint_submitdaterefpropid" select="/document/reference_properties/reference_property[name='preprint_submitdate']/@id"/>
    <xsl:variable name="thesis_inprocessrefpropid" select="/document/reference_properties/reference_property[name='thesis_inprocess']/@id"/>
    <xsl:variable name="quality_criterionrefpropid" select="/document/reference_properties/reference_property[name='quality_criterion']/@id"/>


<xsl:template match="/document/context/object">
    <modsCollection>
        <xsl:apply-templates select="children/object"/>
    </modsCollection>
</xsl:template>

<xsl:template match="children/object">
    <xsl:variable name="referencenumber"><xsl:number count="object" /></xsl:variable>
    <xsl:variable name="genre" select="/document/reference_types/reference_type[@id=current()/reference_type_id]/name"/>
    <xsl:variable name="title" select="reference_values/reference_value[property_id=$titlerefpropid]/value"/>
    <xsl:variable name="btitle" select="reference_values/reference_value[property_id=$btitlerefpropid]/value"/>
    <xsl:variable name="date" select="reference_values/reference_value[property_id=$daterefpropid]/value"/>
    <xsl:variable name="chron" select="reference_values/reference_value[property_id=$chronrefpropid]/value"/>
    <xsl:variable name="ssn" select="reference_values/reference_value[property_id=$ssnrefpropid]/value"/>
    <xsl:variable name="quarter" select="reference_values/reference_value[property_id=$quarterrefpropid]/value"/>
    <xsl:variable name="volume" select="reference_values/reference_value[property_id=$volumerefpropid]/value"/>
    <xsl:variable name="part" select="reference_values/reference_value[property_id=$partrefpropid]/value"/>
    <xsl:variable name="issue" select="reference_values/reference_value[property_id=$issuerefpropid]/value"/>
    <xsl:variable name="spage" select="reference_values/reference_value[property_id=$spagerefpropid]/value"/>
    <xsl:variable name="epage" select="reference_values/reference_value[property_id=$epagerefpropid]/value"/>
    <xsl:variable name="pages" select="reference_values/reference_value[property_id=$pagesrefpropid]/value"/>
    <xsl:variable name="artnum" select="reference_values/reference_value[property_id=$artnumrefpropid]/value"/>
    <xsl:variable name="isbn" select="reference_values/reference_value[property_id=$isbnrefpropid]/value"/>
    <xsl:variable name="coden" select="reference_values/reference_value[property_id=$codenrefpropid]/value"/>
    <xsl:variable name="sici" select="reference_values/reference_value[property_id=$sicirefpropid]/value"/>
    <xsl:variable name="place" select="reference_values/reference_value[property_id=$placerefpropid]/value"/>
    <xsl:variable name="pub" select="reference_values/reference_value[property_id=$pubrefpropid]/value"/>
    <xsl:variable name="edition" select="reference_values/reference_value[property_id=$editionrefpropid]/value"/>
    <xsl:variable name="tpages" select="reference_values/reference_value[property_id=$tpagesrefpropid]/value"/>
    <xsl:variable name="series" select="reference_values/reference_value[property_id=$seriesrefpropid]/value"/>
    <xsl:variable name="issn" select="reference_values/reference_value[property_id=$issnrefpropid]/value"/>
    <xsl:variable name="bici" select="reference_values/reference_value[property_id=$bicirefpropid]/value"/>
    <xsl:variable name="co" select="reference_values/reference_value[property_id=$corefpropid]/value"/>
    <xsl:variable name="inst" select="reference_values/reference_value[property_id=$instrefpropid]/value"/>
    <xsl:variable name="advisor" select="reference_values/reference_value[property_id=$advisorrefpropid]/value"/>
    <xsl:variable name="degree" select="reference_values/reference_value[property_id=$degreerefpropid]/value"/>
    <xsl:variable name="identifier" select="reference_values/reference_value[property_id=$identifierrefpropid]/value"/>
    <xsl:variable name="status" select="reference_values/reference_value[property_id=$statusrefpropid]/value"/>
    <xsl:variable name="conf_venue" select="reference_values/reference_value[property_id=$conf_venuerefpropid]/value"/>
    <xsl:variable name="conf_date" select="reference_values/reference_value[property_id=$conf_daterefpropid]/value"/>
    <xsl:variable name="conf_title" select="reference_values/reference_value[property_id=$conf_titlerefpropid]/value"/>
    <xsl:variable name="conf_sponsor" select="reference_values/reference_value[property_id=$conf_sponsorrefpropid]/value"/>
    <xsl:variable name="conf_url" select="reference_values/reference_value[property_id=$conf_urlrefpropid]/value"/>
    <xsl:variable name="url" select="reference_values/reference_value[property_id=$urlrefpropid]/value"/>
    <xsl:variable name="access_timestamp" select="reference_values/reference_value[property_id=$access_timestamprefpropid]/value"/>
    <xsl:variable name="citekey" select="reference_values/reference_value[property_id=$citekeyrefpropid]/value"/>
    <xsl:variable name="url2" select="reference_values/reference_value[property_id=$url2refpropid]/value"/>
    <xsl:variable name="workgroup" select="reference_values/reference_value[property_id=$workgrouprefpropid]/value"/>
    <xsl:variable name="preprint_identifier" select="reference_values/reference_value[property_id=$preprint_identifierrefpropid]/value"/>
    <xsl:variable name="project" select="reference_values/reference_value[property_id=$projectrefpropid]/value"/>
    <xsl:variable name="preprint_submitdate" select="reference_values/reference_value[property_id=$preprint_submitdaterefpropid]/value"/>
    <xsl:variable name="thesis_inprocess" select="reference_values/reference_value[property_id=$thesis_inprocessrefpropid]/value"/>
    <xsl:variable name="quality_criterion" select="reference_values/reference_value[property_id=$quality_criterionrefpropid]/value"/>
    <xsl:variable name="serial_id" select="serial_id"/>

<mods ID="{$citekey}" reflib:id="{@document_id}">
    <titleInfo>
        <title><xsl:value-of select="$title"/></title>
    </titleInfo>

    <originInfo>
        <dateIssued><xsl:value-of select="$date"/></dateIssued>
        <place>
            <placeTerm><xsl:value-of select="$place"/></placeTerm>
        </place>
        <publisher><xsl:value-of select="$pub"/></publisher>
        <edition><xsl:value-of select="$edition"/></edition>
    </originInfo>

    <xsl:choose>
        <xsl:when test="authorgroup/author">
            <xsl:apply-templates select="authorgroup/author">
                <xsl:sort select="position" order="ascending" data-type="number"/>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>Anonymous</xsl:otherwise>
    </xsl:choose>

    <xsl:if test="editorgroup/author">
        <xsl:apply-templates select="editorgroup/author">
            <xsl:sort select="position" order="ascending" data-type="number"/>
        </xsl:apply-templates>
    </xsl:if>

    <xsl:if test="$advisor != ''">
        <name type="personal">
            <namePart type="family"><xsl:value-of select="$advisor"/></namePart>
            <role>
                <roleTerm authority="marcrelator" type="text">Thesis advisor</roleTerm>
            </role>
        </name>
    </xsl:if>

    <xsl:if test="$inst != ''">
        <name type="corporate" authority="lcnaf">
            <namePart><xsl:value-of select="$inst"/></namePart>
            <role>
                <roleTerm authority="marcrelator" type="text">Degree grantor</roleTerm>
            </role>
        </name>
    </xsl:if>

    <xsl:if test="$degree != ''">
        <etd:degree>
              <etd:name><xsl:value-of select="$degree"/></etd:name>
              <etd:level>Doctoral</etd:level>
        </etd:degree>
    </xsl:if>

    <xsl:if test="$thesis_inprocess = '1'">
        <reflib:thesis_inprocess>1</reflib:thesis_inprocess>
    </xsl:if>

    <xsl:if test="$quality_criterion != ''">
        <reflib:quality_criterion><xsl:value-of select="$quality_criterion"/></reflib:quality_criterion>
    </xsl:if>

    <xsl:if test="$genre = 'Dissertation'">
        <genre authority="marcgt" reflib:reftype_id="{reference_type_id}">theses</genre>
    </xsl:if>

    <xsl:if test="$genre != 'Proceeding' and $genre != 'Article' and $genre != 'Dissertation'">
        <genre reflib:reftype_id="{reference_type_id}"><xsl:value-of select="translate($genre,'BCDRUIP','bcdruip')"/></genre>
    </xsl:if>

    <xsl:if test="$serial_id != '' or $btitle != '' or $conf_title != ''">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:choose>
                        <xsl:when test="$serial_id != ''">
                            <xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>
                        </xsl:when>
                        <xsl:when test="$conf_title != ''">
                            <xsl:value-of select="$conf_title"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$btitle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </title>
            </titleInfo>
            <originInfo>
                <issuance>continuing</issuance>
                <xsl:if test="$conf_venue != ''">
                    <place>
                        <placeTerm><xsl:value-of select="$conf_venue"/></placeTerm>
                    </place>
                </xsl:if>
            </originInfo>
            <xsl:if test="$genre = 'Proceeding' or $genre = 'Article'">
                <xsl:choose>
                    <xsl:when test="$genre = 'Proceeding'">
                        <genre reflib:reftype_id="{reference_type_id}">conference publication</genre>
                    </xsl:when>
                    <xsl:when test="$genre = 'Article'">
                        <genre authority="marc">periodical</genre>
                        <genre reflib:reftype_id="{reference_type_id}">academic journal</genre>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <part>
                <date><xsl:if test="$conf_date != ''"><xsl:value-of select="$conf_date"/></xsl:if></date>
                <xsl:if test="$volume != ''"><detail type="volume"><number><xsl:value-of select="$volume"/></number></detail></xsl:if>
                <xsl:if test="$issue != ''"><detail type="issue"><number><xsl:value-of select="$issue"/></number></detail></xsl:if>
                <xsl:if test="$quarter != ''"><detail type="quarter"><number><xsl:value-of select="$quarter"/></number></detail></xsl:if>
                <xsl:if test="$ssn != ''"><detail type="ssn"><number><xsl:value-of select="$ssn"/></number></detail></xsl:if>
                <extent unit="page">
                    <xsl:choose>
                        <xsl:when test="$spage != ''">
                                <start><xsl:value-of select="$spage"/></start>
                                <xsl:if test="$epage != ''">
                                    <end><xsl:value-of select="$epage"/></end>
                                </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test="$tpages != ''">
                        <total><xsl:value-of select="$tpages"/></total>
                    </xsl:if>
                </extent>
            </part>
        </relatedItem>
    </xsl:if>
    <xsl:if test="$preprint_identifier != ''">
        <relatedItem type="otherVersion">
            <identifier type="preprint"><xsl:value-of select="$preprint_identifier"/></identifier>
        </relatedItem>
    </xsl:if>
    <xsl:if test="abstract != ''"><abstract><xsl:apply-templates select="abstract"/></abstract></xsl:if>
    <xsl:if test="$isbn != ''"><identifier type="isbn"><xsl:value-of select="$isbn"/></identifier></xsl:if>
    <xsl:if test="$coden != ''"><identifier type="coden"><xsl:value-of select="$coden"/></identifier></xsl:if>
    <xsl:if test="$issn != ''"><identifier type="issn"><xsl:value-of select="$issn"/></identifier></xsl:if>
    <xsl:if test="$sici != ''"><identifier type="sici"><xsl:value-of select="$sici"/></identifier></xsl:if>
    <xsl:if test="$bici != ''"><identifier type="bici"><xsl:value-of select="$bici"/></identifier></xsl:if>
    <xsl:if test="$citekey != ''"><identifier type="citekey"><xsl:value-of select="$citekey"/></identifier></xsl:if>
    <xsl:if test="$identifier != ''">
        <identifier>
            <xsl:choose>
                <xsl:when test="starts-with($identifier, 'oai')">
                    <xsl:attribute name="type">oai</xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with($identifier, 'doi')">
                    <xsl:attribute name="type">doi</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:value-of select="$identifier"/>
        </identifier>
    </xsl:if>
    <status><xsl:value-of select="$status"/></status>
    <location>
        <xsl:if test="$url != ''">
            <url>
                <xsl:if test="$access_timestamp != ''">
                    <xsl:attribute name="dateLastAccessed"><xsl:value-of select="$access_timestamp"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$url"/>
            </url>
        </xsl:if>
        <xsl:if test="$url2 != ''"><url displayLabel="Alternative Version"><xsl:value-of select="$url2"/></url></xsl:if>
    </location>
    <xsl:if test="$workgroup != ''">
        <reflib:workgroup><xsl:value-of select="$workgroup"/></reflib:workgroup>
    </xsl:if>
    <xsl:if test="$project != ''">
        <reflib:project><xsl:value-of select="$project"/></reflib:project>
    </xsl:if>
    <xsl:if test="$preprint_submitdate != ''">
        <reflib:preprint_submitdate><xsl:value-of select="$preprint_submitdate"/></reflib:preprint_submitdate>
    </xsl:if>
</mods><xsl:text>

</xsl:text>
</xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author">
    <name type="personal" reflib:author_id="{id}">
        <xsl:if test="firstname != ''"><namePart type="given"><xsl:value-of select="firstname"/></namePart></xsl:if>
        <namePart type="family"><xsl:value-of select="lastname"/></namePart>
        <role>
            <roleTerm authority="marcrelator" type="text">
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'editorgroup'">editor</xsl:when>
                    <xsl:otherwise>author</xsl:otherwise>
                </xsl:choose>
            </roleTerm>
        </role>
    </name>
</xsl:template>

</xsl:stylesheet>
