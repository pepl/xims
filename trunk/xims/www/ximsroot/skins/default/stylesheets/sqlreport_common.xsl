<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:variable name="i18n_sqlrep" select="document(concat($currentuilanguage,'/i18n_sqlrep.xml'))"/>

<xsl:template name="skeys">
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n_sqlrep/l/Search_keys"/>
        </td>
        <td colspan="2">
            <input name="skeys" type="text" value="{attributes/skeys}" class="text" size="50"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('skeys')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="pagesize">
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n_sqlrep/l/Pagesize"/>
        </td>
        <td colspan="2">
            <input name="pagesize" type="text" value="{attributes/pagesize}" class="text" size="5"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('pagesize')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="dbdsn">
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n_sqlrep/l/Database_DSN"/>
        </td>
        <td colspan="2">
            <input name="dbdsn" type="text" value="{attributes/dbdsn}" class="text" size="50"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('dbdsn')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="dbuser">
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n_sqlrep/l/Database_User"/>
        </td>
        <td colspan="2">
            <input name="dbuser" type="text" value="{attributes/dbuser}" class="text" size="50"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('dbuser')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="dbpwd">
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n_sqlrep/l/Database_Password"/>
        </td>
        <td colspan="2">
            <input name="dbpwd" type="password" value="{attributes/dbpwd}" class="text" size="50"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('dbpwd')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
