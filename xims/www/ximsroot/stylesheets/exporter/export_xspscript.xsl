<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml"/>

    <xsl:template match="/document">
        <xsl:if test="string-length(context/object/style_id)">
            <xsl:processing-instruction name="xml-stylesheet"> type="application/x-xsp" href="." </xsl:processing-instruction>
            <xsl:processing-instruction name="xml-stylesheet"> type="text/xsl" href="<xsl:apply-templates select="context/object/style_id"/>" </xsl:processing-instruction>
        </xsl:if>
        <xsl:apply-templates select="context/object/body/*"/>
    </xsl:template>

    <xsl:template match="context/object/body/*">
        <xsl:copy>
         <page>
            <xsl:apply-templates select="/document/context/object"/>
           <xsl:apply-templates select="page/*"/>  
        </page>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <page>
            <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{department_id}/ou.xml"/>
            <rdf:RDF xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                     xmlns:dc  = "http://purl.org/dc/elements/1.1/"
                     xmlns:dcq = "http://purl.org/dc/qualifiers/1.0/">
                <rdf:Description about="">
                    <dc:title><xsl:value-of select="title"/></dc:title>
                    <dc:creator><xsl:call-template name="ownerfullname"/></dc:creator>
                    <dc:subject><xsl:value-of select="keywords"/></dc:subject>
                    <dc:description><xsl:value-of select="abstract"/></dc:description>
                    <dc:publisher>Universität Innsbruck</dc:publisher>
                    <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
                    <dc:date>
                        <dcq:created>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="creation_time" mode="datetime"/></rdf:value>
                            </rdf:Description>
                        </dcq:created>
                        <dcq:modified>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="last_modification_timestamp" mode="datetime"/></rdf:value>
                            </rdf:Description>
                        </dcq:modified>
                    </dc:date>
                    <!-- should be mime-type here -->
                    <dc:format><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/name"/></dc:format>
                    <!-- still to come -->
                    <dc:language></dc:language>
                </rdf:Description>
            </rdf:RDF>
            <body>
                <xsl:apply-templates select="body"/>
            </body>

            <links>
                <xsl:apply-templates select="children/object"/>
            </links>
        </page>
    </xsl:template>

    <xsl:template match="page//*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="children/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <xsl:variable name="objecttype">
            <xsl:value-of select="object_type_id"/>
        </xsl:variable>
        <!-- this should be switched to xlink spec -->
        <xsl:choose>
            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                <link type="locator" title="{title}" href="{location}"/>
            </xsl:when>
            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
                <link type="locator" title="{title}" href="{symname_to_doc_id}" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
