<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <!--$Id$-->

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml"/>

    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
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
                    <dc:creator><xsl:call-template name="creatorfullname"/></dc:creator>
                    <dc:subject><xsl:value-of select="keywords"/></dc:subject>
                    <dc:description><xsl:value-of select="abstract"/></dc:description>
                    <dc:publisher><xsl:call-template name="ownerfullname"/></dc:publisher>
                    <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
                    <dc:date>
                        <dcq:created>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="creation_time" mode="ISO8601"/></rdf:value>
                            </rdf:Description>
                        </dcq:created>
                        <dcq:modified>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/></rdf:value>
                            </rdf:Description>
                        </dcq:modified>
                    </dc:date>
                    <!-- should be mime-type here -->
                    <dc:format><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/></dc:format>
                    <!-- still to come -->
                    <!--           <dc:language></dc:language> -->
                </rdf:Description>
            </rdf:RDF>
            <body>
                <h1><xsl:value-of select="title"/></h1>
                <ul>
                    <xsl:apply-templates select="children/object[published=1]">
                        <xsl:sort select="position"
                        order="ascending"
                        data-type="number"/>
                    </xsl:apply-templates>
                </ul>
            </body>
        </page>
    </xsl:template>


    <xsl:template match="children/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <li class="list_{/document/data_formats/data_format[@id=$dataformat]/name}">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="location"/>
                </xsl:attribute>
                <xsl:value-of select="title"/>
            </a>
        </li>
    </xsl:template>

</xsl:stylesheet>
