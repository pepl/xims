<?xml version="1.0" encoding="UTF-8"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>
    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>Edit NewsItem '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/> - XIMS</title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
                <script src="{$ximsroot}scripts/default.js" type="text/javascript">
                    <xsl:text>&#160;</xsl:text>
                </script> 
                <script type="text/javascript">
                    <![CDATA[ 
                    function openTestWFWindow() {
                        var testwfwindow = window.open('','windowName',"resizable=yes,scrollbars=yes,width=550,height=400,screenX=50,screenY=200");
                        var body = document.forms['eform'].body.value;
                        testwfwindow.document.writeln('<html><head>');
                        testwfwindow.document.writeln('<link rel="stylesheet" href="]]><xsl:value-of select="concat($ximsroot,'stylesheets/',$defaultcss)"/><![CDATA[" type="text/css" />');
                        testwfwindow.document.writeln('<\/head><body onLoad="document.the_form.submit()">');
                        testwfwindow.document.writeln('<form name="the_form" action="]]><xsl:value-of select="concat($goxims_content,$absolute_path)"/><![CDATA[" method="post">');
                        testwfwindow.document.writeln('<input type="submit" name="test_wellformedness" value="Go!" size="1" class="control" \/>');
                        testwfwindow.document.writeln('<textarea name="body" cols="1" rows="1" readonly="readonly" style="visibility:hidden;">' + body + '<\/textarea>');
                        testwfwindow.document.writeln("<\/form><\/body><\/html>");
                        // testwfwindow.document.the_form.submit();
                    }
                    ]]>
                </script>
                <base href="{$xims_box}{$goxims_content}{$parent_path}/"/>
            </head>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="no_navigation_at_all">true</xsl:with-param>
                </xsl:call-template>
                <p class="edit">
                    <table width="98%">
                        <tr>
                            <td>
                                <form action="{$xims_box}{$goxims_content}" name="cform" method="GET" style="margin-top:0px; margin-bottom:5px; margin-left:-5px; margin-right:0px;">
                                    <input type="hidden" name="id" value="{@id}"/>
                                    <input type="submit" name="cancel" value="Cancel" class="control"/>
                                </form>
                            </td>
                            <td align="right" valign="top">Fields marked <span style="color:maroon">maroon</span> are mandatory!</td>
                        </tr>
                    </table>
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}" name="eform" method="POST">
                        <table border="0" width="95%" style="background-color:#ced3d6;">
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
                                <td valign="top" colspan="2">
                                    Lead
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
                                    <br/>
                                    <textarea tabindex="5" name="abstract" rows="5" cols="90" class="text">
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
                                    Body
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
                                    <br/>
                                    <textarea tabindex="3" name="body" rows="15" cols="90" class="text">
                                        <xsl:choose>
                                            <xsl:when test="string-length(body) &gt; 0">
                                                <xsl:apply-templates select="body"/>
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
                                    <a href="javascript:openTestWFWindow()">Test body's XML</a>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    Try to form body well. (If body is not well-balanced an error message will be displayed otherwise.)
                                    <input name="trytobalance" type="radio" value="true" checked="checked"/>Yes
                                    <input name="trytobalance" type="radio" value="false" />No
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
                                <td valign="top">Image</td>
                                <td>
                                    <input tabindex="3" type="text" name="image" size="40" value="{image_id}" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">Browse for an image</a>
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
        <xsl:apply-templates select="/document/body"/>
    </xsl:template>
</xsl:stylesheet>
