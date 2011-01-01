<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="common.xsl"/>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body background="{$skimages}body_bg.png">
                <xsl:call-template name="header">
                    <xsl:with-param name="createwidget">false</xsl:with-param>
                </xsl:call-template>

                <!-- he portlet description should be shown here -->

                <xsl:choose>
                    <xsl:when test="children/object/level">
                        <xsl:call-template name="leveledchildrentable"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="childrentable"/>
                    </xsl:otherwise>
                </xsl:choose>
                <table align="center" width="98.7%" class="footer">
                    <xsl:call-template name="footer"/>
                </table>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="leveledchildrentable">
        <table cellpadding="3" width="100%">
            <xsl:apply-templates select="children/object[level=1]" mode="ptable"/>
        </table>
    </xsl:template>


    <xsl:template name="childrentable">
        <table cellpadding="3" width="100%">
            <xsl:apply-templates select="children/object" mode="ptable"/>
        </table>
    </xsl:template>

    <xsl:template match="children/object" mode="ptable">
        <tr>
            <td>
                <table width="100%" cellpadding="0">

                    <xsl:apply-templates select="title"/>
                    <xsl:call-template name="infos"/>

                    <xsl:apply-templates select="abstract"/>
                    <xsl:apply-templates select="body"/>
                </table>

            </td>
        </tr>
    </xsl:template>

    <xsl:template match="title">
    	<tr>
        <td colspan="3" style="background-color: #123853;color:white">
            <xsl:apply-templates/>
        </td>
      </tr>
    </xsl:template>

    <xsl:template name="infos">
        <xsl:variable name="data_format_id">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <tr>
            <td width="33%">
                <strong>Location</strong>
            </td>
            <td width="33%">
                <xsl:choose>
                    <xsl:when test="owned_by_fullname">
                        <strong>Owner Name</strong>
                    </xsl:when>
                    <xsl:when test="last_modified_by_fullname">
                        <strong>Last Modifier Name</strong>
                    </xsl:when>
                    <xsl:when test="created_by_fullname">
                        <strong>Creator Name</strong>
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
                    <!-- this should test against the object type name -->
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
    </xsl:template>

    <xsl:template match="abstract">
        <tr>
            <td colspan="3">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="body">
        <tr>
            <td colspan="3">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>

