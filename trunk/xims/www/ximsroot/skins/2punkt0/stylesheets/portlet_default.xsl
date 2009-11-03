<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: portlet_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="common.xsl"/>
    <xsl:output method="html" encoding="utf-8"/>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header"/>
<!--                    <xsl:with-param name="createwidget">false</xsl:with-param>
                </xsl:call-template>-->

                <!-- he portlet description should be shown here -->
<div id="main-content" class="ui-corner-all">
						<xsl:call-template name="options-menu-bar">
							<xsl:with-param name="createwidget">false</xsl:with-param>
             </xsl:call-template>
						<div id="table-container" class="ui-corner-bottom ui-corner-tr">
							<div id="docbody">
                        <span id="body">
                <xsl:choose>
                    <xsl:when test="children/object/level">
                        <xsl:call-template name="leveledchildrentable"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="childrentable"/>
                    </xsl:otherwise>
                </xsl:choose>
                							</span></div>
           <div id="metadata-options">
							<div id="user-metadata">
								<xsl:call-template name="user-metadata"/>
							</div>
							<div id="document-options">
<!--								<xsl:call-template name="document-options"/>-->
							</div>
						</div>
					</div>
				</div>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="leveledchildrentable">
            <xsl:apply-templates select="children/object[level=1]" mode="ptable"/>
    </xsl:template>


    <xsl:template name="childrentable">
            <xsl:apply-templates select="children/object" mode="ptable"/>
    </xsl:template>

    <xsl:template match="children/object" mode="ptable">
                    <xsl:apply-templates select="title"/>
                    <xsl:call-template name="infos"/>

                    <xsl:apply-templates select="abstract"/>
                    <xsl:apply-templates select="body"/>
    </xsl:template>

    <xsl:template match="title">
    <div style="background-color: #123853;color:white">
        <!--<td colspan="3" style="background-color: #123853;color:white">-->
            <xsl:apply-templates/>
        <!--</td>-->
        </div>
    </xsl:template>

    <xsl:template name="infos">
        <xsl:variable name="data_format_id">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <div>
                <strong>Location: </strong>
                <xsl:choose>
                    <!-- this should test against the object type name -->
                    <xsl:when test="/document/data_formats/data_format[@id=$data_format_id]/name ='URL'">
                        <a href="{location}"><xsl:apply-templates select="location"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{$goxims_content}{location_path}"><xsl:apply-templates select="location"/></a>
                    </xsl:otherwise>
                </xsl:choose>
        </div>
    </xsl:template>
    
<!--    <xsl:template name="infos">
        <xsl:variable name="data_format_id">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        INFOS: 
        <tr>
            <td width="33%">
                <strong>Location:</strong>
            </td>
            <td width="33%">
                <xsl:choose>
                    <xsl:when test="owned_by_fullname">
                        <strong>Owner Name:</strong>
                    </xsl:when>
                    <xsl:when test="last_modified_by_fullname">
                        <strong>Last Modifier Name:</strong>
                    </xsl:when>
                    <xsl:when test="created_by_fullname">
                        <strong>Creator Name:</strong>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td width="33%">
                <xsl:choose>
                    <xsl:when test="last_modification_timestamp">
                        <strong>Last Modification Time</strong>
                    </xsl:when>
                    <xsl:when test="creation_time">
                        <strong>Creation Time</strong>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
        <tr>
            <td>
                <xsl:choose>
                    --><!-- this should test against the object type name --><!--
                    <xsl:when test="/document/data_formats/data_format[@id=$data_format_id]/name ='URL'">
                        <a href="{location}"><xsl:apply-templates select="location"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{$goxims_content}{location_path}"><xsl:apply-templates select="location"/></a>
                    </xsl:otherwise>
                </xsl:choose>

            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="owned_by_fullname">
                        <xsl:apply-templates select="owned_by_fullname"/>
                    </xsl:when>
                    <xsl:when test="last_modified_by_fullname">
                        <xsl:apply-templates select="last_modified_by_fullname"/>
                    </xsl:when>
                    <xsl:when test="created_by_fullname">
                        <xsl:apply-templates select="created_by_fullname"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>

            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="last_modification_timestamp">
                        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
                    </xsl:when>
                    <xsl:when test="creation_time">
                        <xsl:apply-templates select="creation_time" mode="datetime"/>
                    </xsl:when>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>-->

    <xsl:template match="abstract">
        <div id="tr-abstract">
                <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="body">
        <div>
                <xsl:apply-templates/>
        </div>
    </xsl:template>
</xsl:stylesheet>

