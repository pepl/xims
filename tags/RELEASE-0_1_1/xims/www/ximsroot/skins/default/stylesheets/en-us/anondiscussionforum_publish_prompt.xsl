<?xml version="1.0" encoding="iso-8859-1" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
    <!-- $Id$ -->
    <xsl:import href="config.xsl"/>
    <xsl:import href="common.xsl"/>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
    <xsl:param name="id"/>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>
                    Confirm Publishing - XIMS
                </title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
                <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            </head>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
                <xsl:call-template name="header">
                    <xsl:with-param name="noncontent">true</xsl:with-param>
                </xsl:call-template>

                <form name="objPublish" action="{$xims_box}{$goxims_content}" method="GET" style="margin-top: 0px; margin-left: 5px;">
                    <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
                        <tr>
                            <td align="center">
                                <br />
                                <!-- begin widget table -->
                                <table width="350" cellpadding="2" cellspacing="2" border="0">
                                    <tr>
                                        <td class="bluebg">Publishing Options for Forum '<xsl:value-of select="title"/>'</td>
                                    </tr>
                                    <tr>
                                        <td>&#160;</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <strong>
                                                Status: This forum is
                                                <xsl:if test="published/text()!='1'">
                                                    <xsl:text> NOT </xsl:text>
                                                </xsl:if>
                                                currently published
                                            </strong>
                                            <xsl:if test="published/text()='1'">
                                                at <br/><a href="{$xims_box}{$gopublic_content}{$absolute_path}" target="_new">
                                                    <xsl:value-of select="concat($xims_box,$gopublic_content,$absolute_path)"/></a>
                                            </xsl:if>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            Click
                                            <xsl:choose>
                                                <xsl:when test="published/text()='1'">
                                                    'Unpublish'
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    'Publish'
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            to (un)publish this forum,
                                            or 'Cancel' to return to the previous screen.
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center">
                                            <!-- begin buttons table -->
                                            <table cellpadding="2" cellspacing="0" border="0">
                                                <tr align="center">
                                                    <td>
                                                        <xsl:choose>
                                                            <xsl:when test="published/text()='1'">
                                                                <input name="unpublish" type="submit" class="control" value="Unpublish"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <input name="publish" type="submit" class="control" value="Publish"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <input name="id" type="hidden" value="{$id}"/>
                                                    </td>
                                                    <td>
                                                        <input name="default" type="button" value="Cancel" onClick="javascript:history.go(-1)" class="control"/>
                                                    </td>
                                                </tr>
                                            </table>
                                            <!-- end buttons table -->
                                        </td>
                                    </tr>
                                </table>
                                <!-- end widget table -->
                                <br />
                            </td>
                        </tr>
                    </table>
                </form>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>

