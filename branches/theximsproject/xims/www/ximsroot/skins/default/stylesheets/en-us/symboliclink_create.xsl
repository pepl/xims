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
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
    
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>Create new SymbolicLink in <xsl:value-of select="$absolute_path"/> - XIMS</title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
                <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            </head>
            <body>
                <xsl:call-template name="header">
                     <xsl:with-param name="no_navigation_at_all">true</xsl:with-param>
                </xsl:call-template>
                <p class="edit">
                    <table border="0" align="center" width="98%">
                        <tr>
                            <td>Create new SymbolicLink in <xsl:value-of select="$absolute_path"/></td>
                            <td align="right">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!</td>
                        </tr>
                    </table>
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=SymbolicLink" name="eform" method="POST">
                        <input type="hidden" name="objtype" value="SymbolicLink"/>
                        <table border="0" width="95%">
                            <tr>
                                <td valign="top">
                                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                                    <span class="compulsory">Location</span>
                                </td>
                                <td><input tabindex="1" type="text" name="name" size="40" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('symboliclinklocation')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <span class="compulsory">Target</span>
                                </td>
                                <td>
                                    <input tabindex="2" type="text" name="target" size="40" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('symboliclinktarget')" class="doclink">(?)</a>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;sbfield=eform.target')" class="doclink">Browse for Target</a>
                                </td>
                            </tr>
                        <xsl:call-template name="grantowneronly"/>
                        </table>
                        <xsl:call-template name="saveaction"/> 
                    </form>
                </p>
                <br/>
                <xsl:call-template name="cancelaction"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
