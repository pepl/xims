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
   
<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td bgcolor="#ffffff" colspan="2">
                        <pre>
                            <xsl:apply-templates select="body"/>
                        </pre>
                    </td>
                </tr>
            </table>
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
