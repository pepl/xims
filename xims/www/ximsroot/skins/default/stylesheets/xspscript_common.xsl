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

<xsl:import href="common.xsl"/>

<xsl:template name="processxsp">
    <tr>
        <td colspan="3">
        XSP process body per default:
        <input name="processxsp" type="radio" value="true">
          <xsl:if test="attributes/processxsp = '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/Yes"/>
        <input name="processxsp" type="radio" value="false">
          <xsl:if test="attributes/processxsp != '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/No"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('processxsp')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
