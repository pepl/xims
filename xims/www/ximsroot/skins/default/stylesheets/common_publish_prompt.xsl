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
                        function disableIt(obj,ename) {
                            var objids = window.document.forms[1].elements[ename];
                            if (!objids) {
                                return;
                            }
                            if ( objids.length ) {
                                var i;
                                for (i = 0; i < objids.length; i++) {
                                    if ( !(objids[i].disabled) ) {
                                        obj.disabled = false;
                                        return true;
                                    }
                                }
                            }
                            else if ( !(objids.disabled) ) {
                                obj.disabled = false;
                                return true;
                            }
                        }
                        function switcher(selector,ename){
                            var ids = window.document.forms[1].elements[ename];
                            xstate = selector.checked ? 1 : 0;
                            if ( ids.length ) {
                                var i;
                                for (i = 0; i < ids.length; i++) {
                                    if ( !(ids[i].disabled) ) {
                                        ids[i].checked = xstate;
                                    }
                                }
                            }
                            else {
                                if ( !(ids.disabled) ) {
                                    ids.checked = xstate;
                                }
                            }
                            return xstate;
                        }
                        function isChecked(ename){
                            var ids = window.document.forms[1].elements[ename];
                            if ( ids.length ) {
                                var i;
                                for (i = 0; i < ids.length; i++) {
                                    if (ids[i].checked ) {
                                        return true;
                                    }
                                }
                            }
                            else {
                                if (ids.checked ) {
                                    return true;
                                }
                            }
                            return false;
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

