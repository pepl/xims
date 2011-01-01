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

<xsl:import href="departmentroot_create.xsl"/>

<xsl:template name="tr-title-create">
    <tr>
        <td valign="top">SiteRoot URL/<xsl:value-of select="$i18n/l/Path"/></td>
        <td colspan="2">
            <input tabindex="20" type="text" name="title" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('SiteRootURL')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
