<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:param name="sbfield"/>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title><xsl:value-of select="$i18n/l/Position_object"/> '<xsl:value-of select="parents/object[@id=/document/context/object/@parent_id]/title"/>' - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
            <script type="text/javascript">
                function storeBack(value) {
                    window.opener.document.<xsl:value-of select="$sbfield"/>.value=value;
                    window.opener.document.<xsl:value-of select="substring-before($sbfield, '.')"/>.submit();
                    window.close();
                }
            </script>
        </head>
        <body>
            <p align="right"><a href="javascript:window.close()"><xsl:value-of select="$i18n/l/close_window"/></a></p>
            <p>
            <form name="repos">
                <table cellpadding="10">
                    <tr>
                        <td valign="top">
                            <xsl:value-of select="$i18n/l/Choose_position"/><br/>'<xsl:value-of select="title"/>' <br/><xsl:value-of select="$i18n/l/in"/>
                            Container '<xsl:value-of select="parents/object[@id=/document/context/object/@parent_id]/title"/>'.
                        </td>
                        <td valign="top">
                            <select name="new_position" onChange="storeBack(options[selectedIndex].value)">
                                <xsl:call-template name="loop-options">
                                    <xsl:with-param name="iter"><xsl:value-of select="1"/></xsl:with-param>
                                </xsl:call-template>
                            </select>
                        </td>
                    </tr>
                </table>
            </form>
            </p>
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

</xsl:stylesheet>
