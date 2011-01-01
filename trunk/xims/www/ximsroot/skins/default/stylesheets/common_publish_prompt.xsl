<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <!-- $Id$ -->
<xsl:param name="id"/>

<xsl:variable name="objecttype">
    <xsl:value-of select="/document/context/object/object_type_id"/>
</xsl:variable>
<xsl:variable name="publish_gopublic">
    <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
</xsl:variable>
<xsl:variable name="published_path_base">
    <xsl:choose>
        <xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
            <xsl:value-of select="$absolute_path_nosite"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$absolute_path"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<xsl:variable name="object_path">
    <xsl:value-of select="$published_path_base"/>
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


<xsl:template name="head">
        <head>
            <title>
                <xsl:value-of select="$i18n/l/Confirm_publishing"/> - XIMS
            </title>
            <xsl:call-template name="css"/>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <xsl:call-template name="mk-inline-js">
              <xsl:with-param name="code">            
              <![CDATA[ function disableIt(obj,ename) {
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
                            xstate = selector.checked ? true : false;
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
                        } ]]>
                </xsl:with-param>
            </xsl:call-template>
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

