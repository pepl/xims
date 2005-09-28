<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="file_create.xsl"/>

<xsl:template name="tr-file-create">
    <tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n/l/Image"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
