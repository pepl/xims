<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">
    <!-- $Id$ -->

    <xsl:import href="common.xsl"/>
    
    <xsl:param name="publish"/>

    <xsl:variable name="objecttype">
        <xsl:value-of select="/document/context/object/object_type_id"/>
    </xsl:variable>
    <xsl:variable name="parent_id">
        <xsl:value-of select="/document/context/object/@parent_id"/>
    </xsl:variable>
    <xsl:variable name="publish_gopublic">
        <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
    </xsl:variable>
    <xsl:variable name="object_path">
        <xsl:choose>
            <xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
                <xsl:value-of select="$absolute_path_nosite"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$absolute_path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="published_path">
        <xsl:choose>
            <xsl:when test="$publish_gopublic = 0">
                <xsl:value-of select="concat($publishingroot,$object_path)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(/document/context/session/serverurl,$gopublic_content,$object_path)"/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:variable>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="noncontent">true</xsl:with-param>
                </xsl:call-template>

                <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
                    <tr>
                        <td align="center">

                            <br/>
                            <!-- begin widget table -->
                            <table width="200" cellpadding="2" cellspacing="0" border="0">
                                <tr>
                                    <td class="bluebg">
                                        <xsl:value-of select="$i18n/l/Publishing_success"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <xsl:call-template name="message"/>
                                    </td>
                                </tr>
                                <xsl:if test="$publish='Publish' or $publish='Republish'">
                                    <tr>
                                        <td><xsl:value-of select="$i18n/l/Object_available_at"/><br/>
                                            <a href="{$published_path}"
                                               target="_new">
                                            <xsl:value-of select="$published_path"/>
                                            </a><br/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <xsl:call-template name="exitredirectform"/>
                                    </td>
                                </tr>
                            </table>
                            <!-- end widget table -->
                            <br/>

                        </td>
                    </tr>
                </table>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template name="title">
        <xsl:value-of select="$i18n/l/Publishing_success"/> - <xsl:value-of select="title"/> - XIMS 
    </xsl:template>

</xsl:stylesheet>
