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

<xsl:import href="../../../stylesheets/anondiscussionforum_common.xsl"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <p class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-description-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
            </p>
            <br />
            <xsl:call-template name="cancelaction"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-description-edit">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Description"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('adf_description')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
                 <xsl:choose>
                    <xsl:when test="string-length(abstract) &gt; 0">
                        <xsl:apply-templates select="abstract"/>
                     </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </textarea>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
