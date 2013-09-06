<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: portlet_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
                
    <xsl:import href="view_common.xsl"/>
    
    <xsl:variable name="i18n_portlet" select="document(concat($currentuilanguage,'/i18n_portlet.xml'))"/>
    
    <xsl:template name="view-content">
    <!-- the portlet description should be shown here -->
    <div id="docbody">
			<xsl:choose>
					<xsl:when test="children/object/level">
							<xsl:call-template name="leveledchildrentable"/>
					</xsl:when>
					<xsl:otherwise>
							<xsl:call-template name="childrentable"/>
					</xsl:otherwise>
			</xsl:choose>
			</div>
    </xsl:template>

    <xsl:template name="leveledchildrentable">
            <xsl:apply-templates select="children/object[level=1]" mode="ptable"/>
    </xsl:template>


    <xsl:template name="childrentable">
            <xsl:apply-templates select="children/object" mode="ptable"/>
    </xsl:template>

    <xsl:template match="children/object" mode="ptable">
			<div class="deptportlets">
				<xsl:apply-templates select="title"/>
				<xsl:call-template name="infos"/>

				<xsl:apply-templates select="abstract"/>
				<xsl:apply-templates select="body"/>
			</div>
    </xsl:template>

    <xsl:template match="title">
				<p>
        <strong><xsl:apply-templates/></strong>
        </p>
    </xsl:template>

    <xsl:template name="infos">
        <xsl:variable name="data_format_id">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <p>
                Location:
                <xsl:choose>
                    <!-- this should test against the object type name -->
                    <xsl:when test="/document/data_formats/data_format[@id=$data_format_id]/name ='URL'">
                        <a href="{location}"><xsl:apply-templates select="location"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{$goxims_content}{location_path}"><xsl:apply-templates select="location"/></a>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="owned_by_lastname">
                        <br/><xsl:value-of select="$i18n_portlet/l/Owner"/>: <xsl:call-template name="ownerfullname"/>
                  </xsl:when>
                  <xsl:when test="created_by_lastname">
                        <br/><xsl:value-of select="$i18n_portlet/l/Creator"/>: <xsl:call-template name="creatorfullname"/>
                  </xsl:when>
                  <xsl:when test="last_modified_by_lastname">
                        <br/><xsl:value-of select="$i18n_portlet/l/Last_modifier"/>: <xsl:call-template name="modifierfullname"/>
                  </xsl:when>
                  <xsl:when test="creation_timestamp != ''">
                        <br/><xsl:value-of select="$i18n_portlet/l/Creation_timestamp"/>: <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                    </xsl:when>
                    <xsl:when test="last_modification_timestamp">
                        <br/><xsl:value-of select="$i18n_portlet/l/Last_modification_timestamp"/>: <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
                    </xsl:when>
								</xsl:choose>
        </p>
    </xsl:template>

    <xsl:template match="abstract">
        <p>
                <xsl:apply-templates/><xsl:comment/>
        </p>
    </xsl:template>

    <xsl:template match="body">
        <div>
                <xsl:apply-templates/><xsl:comment/>
        </div>
    </xsl:template>
</xsl:stylesheet>

