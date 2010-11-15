<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>
<xsl:import href="view_common.xsl"/>

<xsl:variable name="createwidget">false</xsl:variable>
<!--<xsl:variable name="parent_id">false</xsl:variable>-->

<xsl:template name="view-content">
	<p>
                                    <strong><xsl:value-of select="$i18n_vlib/l/authors"/></strong>:<br/>
                                    <xsl:apply-templates select="authorgroup/author">
                                        <xsl:sort select="position" order="ascending" data-type="number"/>
                                    </xsl:apply-templates>
                                </p>
                                <xsl:if test="editorgroup/author">
                                    <p>
                                        <strong><xsl:value-of select="$i18n_vlib/l/editors"/></strong>:<br/>
                                        <xsl:apply-templates select="editorgroup/author">
                                            <xsl:sort select="position" order="ascending" data-type="number"/>
                                        </xsl:apply-templates>
                                    </p>
                                </xsl:if>
                                <xsl:if test="serial != ''">
                                    <p>
                                        <strong>Journal</strong>:<br/>
                                        <xsl:apply-templates select="serial"/>
                                    </p>
                                </xsl:if>
                                <xsl:if test="abstract != ''">
                                    <p>
                                        <strong><xsl:value-of select="$i18n/l/Abstract"/></strong>: <xsl:apply-templates select="abstract"/>
                                    </p>
                                </xsl:if>
                                <xsl:if test="notes != ''">
                                    <p>
                                        <strong><xsl:value-of select="$i18n/l/Notes"/></strong>: <xsl:apply-templates select="notes"/>
                                    </p>
                                </xsl:if>

                                    <xsl:apply-templates select="reference_values/reference_value">
                                        <xsl:sort select="/document/reference_properties/reference_property[@id=current()/property_id]/position" order="ascending" data-type="number"/>
                                    </xsl:apply-templates>
</xsl:template>

<xsl:template match="reference_value">
    <xsl:variable name="property_id" select="property_id"/>
    <p>
				<xsl:call-template name="get-prop-name"><xsl:with-param name="id" select="$property_id"/></xsl:call-template>:&#160;
            <!--<xsl:value-of select="/document/reference_properties/reference_property[@id=$property_id]/name"/>:-->
            <xsl:value-of select="value"/>
    </p>
</xsl:template>

</xsl:stylesheet>
