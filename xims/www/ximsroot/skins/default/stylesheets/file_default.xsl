<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/TR/xhtml1/strict">
 
    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
                <xsl:call-template name="header"/>
                <xsl:call-template name="object-metadata"/>
                <p>
                    <xsl:call-template name="user-metadata"/>
                </p>
                <p>
                    <table border="0" align="center" width="98%">
                        <tr>
                            <td>
                                <a href="{$goxims_content}{$absolute_path}"><xsl:value-of select="$i18n/l/View_download"/></a>&#160;<xsl:value-of select="$objtype"/>
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
