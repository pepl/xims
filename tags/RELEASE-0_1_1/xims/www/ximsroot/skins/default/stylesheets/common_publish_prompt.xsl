<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
    <!-- $Id$ -->
<xsl:param name="id"/>

<xsl:template name="head">
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Confirm_publishing"/> - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script type="text/javascript">
                <xsl:comment>
                    <![CDATA[
                        function disableIt(obj) {
                            var autoexport = window.document.forms[1].elements['autoexport'];
                            if (!autoexport) {
                                return;
                            }
                            var i;
                            if ( autoexport.length ) {
                                for (i = 0; i < autoexport.length; i++) {
                                    if ( !(autoexport[i].disabled) ) {
                                        obj.disabled = false;
                                        return true;
                                    }
                                }
                            }
                            else if ( !(autoexport.disabled) ) {
                                obj.disabled = false;
                                return true;
                            }
                        }
                    ]]>
                </xsl:comment>
            </script>
        </head>
</xsl:template>

<xsl:template name="csv2ul">
    <xsl:param name="list"/>
    <ul>
        <xsl:call-template name="csv2li">
            <xsl:with-param name="list" select="$list"/>
        </xsl:call-template>
    </ul>
</xsl:template>

<xsl:template name="csv2li">
    <xsl:param name="list"/>
    <xsl:variable name="item" select="substring-before($list, ',')"/>
    <xsl:variable name="rest" select="substring-after($list, ',')"/>
    <xsl:choose>
        <xsl:when test="$item">
            <li>
                <xsl:value-of select="$item"/>
            </li>
        </xsl:when>
        <xsl:otherwise>
            <li>
                <xsl:value-of select="$list"/>
            </li>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$rest">
        <xsl:call-template name="csv2li">
            <xsl:with-param name="list" select="$rest"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>

