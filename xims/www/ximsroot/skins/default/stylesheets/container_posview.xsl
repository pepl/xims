<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>

    <xsl:param name="sbfield"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <p align="right"><a href="javascript:window.close()"><xsl:value-of select="$i18n/l/close_window"/></a></p>
            <p>
            <form name="repos" action="javascript:storeBack(document.repos.new_position.selectedIndex + 1)">
                        <p>
                            <xsl:value-of select="$i18n/l/Choose_position"/>&#160;<strong>'<xsl:value-of select="title"/>'&#160;</strong> <xsl:value-of select="$i18n/l/in"/>
                            Container '<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/title"/>'.
                        </p>
                        <p>
                        <label for="input-position"><xsl:value-of select="$i18n/l/Position"/></label>
                            <select name="new_position" class="select" id="input-position">  
                            <!-- <select name="new_position" onchange="storeBack(options[selectedIndex].value)"> -->
                                <xsl:call-template name="loop-options">
                                    <xsl:with-param name="iter"><xsl:value-of select="1"/></xsl:with-param>
                                </xsl:call-template>
                            </select>
                            <input type="submit" name="submit">
																<xsl:attribute name="value"><xsl:value-of select="$i18n/l/save"/></xsl:attribute>
                            </input>
                        </p>
            </form>
            </p>
            <xsl:call-template name="script_bottom"/>
            <script type="text/javascript">
                function storeBack(value) {
                window.opener.document.<xsl:value-of select="$sbfield"/>.value=value;
                window.opener.document.<xsl:value-of select="substring-before($sbfield, '.')"/>.submit();
                window.close();
                }
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template name="loop-options">
    <!-- This template loops over a number of position ids -->
    <xsl:param name="iter"/>

    <xsl:if test="$iter != (siblingscount+1)">
        <option value="{$iter}">
            <xsl:if test="position=$iter">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$iter"/>
        </option>

        <xsl:call-template name="loop-options">
            <xsl:with-param name="iter" select="$iter + 1"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="title">
    <xsl:value-of select="$i18n/l/Position_object"/> '<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/title"/>' - XIMS
</xsl:template>

</xsl:stylesheet>