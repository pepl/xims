<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_publish_update.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">
    <!-- $Id: common_publish_update.xsl 2188 2009-01-03 18:24:00Z pepl $ -->

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

                <div id="content-container">

                                    <h1 class="bluebg">
                                        <xsl:value-of select="$i18n/l/Publishing_success"/>
                                    </h1>
                                <p>
                                        <xsl:call-template name="message"/>
                                 </p>

                                <xsl:if test="$publish='Publish' or $publish='Republish'">
                                    <p><xsl:value-of select="$i18n/l/Object_available_at"/><br/>
                                            <a href="{$published_path}"
                                               target="_new">
                                            <xsl:value-of select="$published_path"/>
                                            </a>
                                   </p>
                                </xsl:if>
                                <br/>
                                <p>
                                        <xsl:call-template name="exitredirectform"/>
                                </p>
                            <!-- end widget table -->
                            <br/>

                </div>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template name="title">
        <xsl:value-of select="$i18n/l/Publishing_success"/> - <xsl:value-of select="title"/> - XIMS 
    </xsl:template>

</xsl:stylesheet>
