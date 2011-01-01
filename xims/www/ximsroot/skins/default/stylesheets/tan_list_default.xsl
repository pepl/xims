<?xml version="1.0"?>
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

<xsl:variable name="i18n_qn" select="document(concat($currentuilanguage,'/i18n_questionnaire.xml'))" />

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td colspan="2">
                        <xsl:call-template name="tan-list"/>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>


<xsl:template name="tan-list">
    <xsl:value-of select="$i18n_qn/l/TAN_number" />: <xsl:value-of select="attributes/number" /><br/>
    <xsl:value-of select="$i18n_qn/l/Download" />:
    <ul>
        <li>
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id};download=HTML">HTML</a>
        </li>
        <li>
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id};target=_blank;download=TXT">Text</a>
        </li>
        <li>
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id};target=_blank;download=CSV">CSV</a>
        </li>
        <li>
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?id={@id};target=_blank;download=Excel">MS Excel</a>
        </li>
    </ul>
</xsl:template>

</xsl:stylesheet>

