<?xml version="1.0" encoding="iso-8859-1"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:variable name="bodycontent">
        <xsl:call-template name="body"/>
    </xsl:variable>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>
    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>Edit document '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/> - XIMS</title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
                <script src="{$ximsroot}scripts/default.js" type="text/javascript">
                    <xsl:text>&#160;</xsl:text>
                </script>
                <script src="{$ximsroot}ewebedit/ewebeditpro.js" type="text/javascript">
                    <xsl:text>&#160;</xsl:text>
                </script>
                <base href="{$xims_box}{$goxims_content}{$parent_path}/"/>
                <script type="text/javascript">
                    <![CDATA[
                    function setEWProperties(sEditorName) {
                        eWebEditPro.instances[sEditorName].editor.setProperty("BaseURL", "]]><xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/><![CDATA[");
                        eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty("TransferMethod","]]><xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'/')"/><![CDATA[?contentbrowse=1;style=ewebeditimage;otfilter=Image");
                    }
                    ]]>
                </script>
            </head>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="no_navigation_at_all">true</xsl:with-param>
                </xsl:call-template>
                <p class="edit">
                    <table border="0" align="center" width="98%">
                        <tr>
                            <td>Edit document '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/>
                            </td>
                            <td align="right">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!</td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <a href="{$goxims_content}{$absolute_path}?edit=1;plain=1">Edit without WYSIWYG-Editor</a>
                            </td>
                        </tr>
                    </table>
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST" name="eform">
                        <table border="0" width="95%">
                            <tr>
                                <td valign="top">
                                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                                    <span class="compulsory">Location</span>
                                </td>
                                <td>
                                    <input tabindex="1" type="text" class="text" name="name" size="40" value="{substring-before(location, concat('.', /document/data_formats/data_format
                                           [@id = /document/data_formats/data_format]/suffix))}"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    Title
                                </td>
                                <td>
                                    <input tabindex="2" type="text" name="title" size="60" value="{title}" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    Body
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
                                    <br/>
                                    <!--<textarea tabindex="3" name="body" rows="15" cols="100" class="text">
                                <xsl:apply-templates select="body"/>
                                </textarea>-->
                                    <input tabindex="3" type="hidden" name="body" value="{$bodycontent}" width="100%"/>
                                    <script language="JavaScript1.2">
                                        <!-- for ewebedit: pull parent_id into a JavaScript variable --><![CDATA[ var parentID="]]><xsl:apply-templates select="@parent_id"/><![CDATA[";]]><![CDATA[ var documentID="]]><xsl:apply-templates select="@id"/><![CDATA[";]]><![CDATA[
                                        var sEditorName = "body";
                                        eWebEditPro.create(sEditorName, "99.5%", "450");
                                        eWebEditPro.onready = "setEWProperties(sEditorName)";
                                        ]]></script>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">Keywords</td>
                                <td>
                                    <input tabindex="4" type="text" name="keywords" size="60" value="{keywords}" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" colspan="2">
                                    Abstract
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
                                    <br/>
                                    <textarea tabindex="5" name="abstract" rows="5" cols="100" class="text">
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
                            <tr>
                                <td colspan="2">
                                    <xsl:call-template name="markednew"/>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <xsl:call-template name="expandrefs"/>
                                </td>
                            </tr>
                        </table>
                        <xsl:call-template name="saveedit"/>
                    </form>
                </p>
                <br/>
                <xsl:call-template name="canceledit"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="body">
        <xsl:apply-templates select="/document/context/object/body"/>
    </xsl:template>
</xsl:stylesheet>
