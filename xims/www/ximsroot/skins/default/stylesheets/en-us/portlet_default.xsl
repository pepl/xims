<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:output method="html" encoding="ISO-8859-1"/>
    
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title><xsl:value-of select="title"/> - Portlet - XIMS</title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
                <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            </head>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
                <xsl:call-template name="header">
                    <xsl:with-param name="createwidget">false</xsl:with-param>
                </xsl:call-template>

                <!-- here the portlet description should be shown -->

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
        <td colspan="3" style="background-color: #123853;color:white">
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template name="infos">
        <tr>
            <td width="33%">
                <b>Location</b>
            </td>
            <td width="33%">
                <xsl:choose>
                    <xsl:when test="owned_by_fullname">
                        <b>Owner Name</b>
                    </xsl:when>
                    <xsl:when test="last_modified_by_fullname">
                        <b>Last Modifier Name</b>
                    </xsl:when>
                    <xsl:when test="created_by_fullname">
                        <b>Creator Name</b>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td width="33%">
                <xsl:choose>
                    <xsl:when test="last_modification_timestamp">
                        <b>Last Modification Time</b>
                    </xsl:when>
                    <xsl:when test="creation_time">
                        <b>Creation Time</b>
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
                    <xsl:when test="object_type = 13">
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
                        <xsl:apply-templates select="last_modification_timestamp" mode="date"/>
                    </xsl:when>
                    <xsl:when test="creation_time">
                        <xsl:apply-templates select="creation_time" mode="date"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="last_modification_timestamp" mode="date"/>
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


<!-- Keep this comment at the end of the file
Local variables:
mode: xml
sgml-omittag:nil
sgml-shorttag:nil
sgml-namecase-general:nil
sgml-general-insert-case:lower
sgml-minimize-attributes:nil
sgml-always-quote-attributes:t
sgml-indent-step:4
sgml-indent-data:t
sgml-parent-document:nil
sgml-exposed-tags:nil
sgml-local-catalogs:nil
sgml-local-ecat-files:nil
End:
-->
