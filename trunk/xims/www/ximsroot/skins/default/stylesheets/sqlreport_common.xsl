<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="skeys">
    <tr>
        <td colspan="3">
            Search Keys <xsl:value-of select="$i18n/l/Search_Keys"/>
            <input name="skeys" type="text" value="{attributes/skeys}" class="text" size="50"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('skeys')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
