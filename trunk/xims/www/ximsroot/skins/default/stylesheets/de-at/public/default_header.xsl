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

<xsl:template name="header">
    <xsl:param name="no_navigation_at_all">false</xsl:param>
    <tr>
        <td bgcolor="#123853" colspan="2"><span style="color:#ffffff; font-size:14pt;">The eXtensible Information Management System</span></td>
        <td bgcolor="#123853" align="right"><xsl:text>&#160;</xsl:text></td>
    </tr>
    <tr>
        <td class="pathinfo" colspan="2">
            <xsl:apply-templates select="/document/context/object/parents/object[position() != 1]">
                <xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all" />
            </xsl:apply-templates>
        </td>
        <td class="pathinfo" align="right">
            <a href="{$request.uri}?style=textonly">[textonly]</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
