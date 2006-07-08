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

<xsl:import href="common.xsl"/>
<xsl:import href="../../../stylesheets/anondiscussionforum_common.xsl"/>

<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-description-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
            </div>
            <br />
            <xsl:call-template name="canceledit"/>
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
