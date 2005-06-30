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
    <xsl:import href="common.xsl"/>
    <xsl:output method="html" encoding="ISO-8859-1"/>
    
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title><xsl:value-of select="title"/> - Image - XIMS</title>
               <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
                <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            </head>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
                <xsl:call-template name="header"/>
                <xsl:call-template name="object-metadata"/>
                <p>
                    <xsl:call-template name="user-metadata"/>
                </p>
                <p>
                    <table border="0" align="center" width="98%">
                        <tr>
                            <td>
                                <a href="{$goxims_content}{$absolute_path}">View / Download</a> Image 
                            </td>
                        </tr>
                    </table>
                    <form action="{$xims_box}{$goxims_content}{$parent_path}" method="POST">
                        <input type="submit" name="cancel" value="Cancel" class="control"/>
                    </form>
                </p>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
