<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: css_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="text_default.xsl"/>

<!--<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body onLoad="stringHighlight(getParamValue('hls'))">
            <xsl:call-template name="header"/>
            <xsl:call-template name="toggle_hls"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td colspan="2">
                        <span id="body">
                            <xsl:apply-templates select="body"/>
                        </span>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <tr>
                    <td>
--><!--                   macht nur schmarrn...     
<xsl:call-template name="body_display_format_switcher"/>
                        |
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?parse_css=1" target="_new">
                            <xsl:value-of select="$i18n/l/Validate_CSS"/>
                        </a>--><!--
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
</xsl:template>-->

</xsl:stylesheet>

