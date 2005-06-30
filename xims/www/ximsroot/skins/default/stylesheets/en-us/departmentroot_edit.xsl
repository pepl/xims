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
    <xsl:import href="container_common.xsl"/>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>Edit DepartmentRoot '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/> - XIMS</title>
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
                            <td>Edit DepartmentRoot '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/></td>
                            <td align="right">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!</td>
                        </tr>
                    </table>
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}" name="eform" method="POST">
                        <table border="0" width="95%">
                            <tr>
                                <td valign="top">
                                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                                    <span class="compulsory">Location</span>
                                </td>
                                <td>
                                    <input tabindex="1" type="text" name="name" size="40" value="{location}" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">Title</td>
                                <td>
                                    <input tabindex="2" type="text" name="title" size="60" value="{title}" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">Stylesheet</td>
                                <td>
                                    <input tabindex="3" type="text" name="stylesheet" size="40" value="{style_id}" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet;sbfield=eform.stylesheet')" class="doclink">Browse for a stylesheet</a>
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
                                    <xsl:call-template name="autoindex"/>
                                </td>
                            </tr>
                            <xsl:call-template name="portlets"/>
                        </table>
                        <xsl:call-template name="saveedit"/>
                    </form>
                </p>
                <br/>
                <xsl:call-template name="canceledit"/>
            </body>
        </html>
    </xsl:template>
  
    <xsl:template name="portlets">
        <tr>
            <td colspan="2">
                <table style="margin-bottom:20px; margin-top:5px; border: 1px solid; border-color: black">
                    <tr>
                        <td valign="top" colspan="2">Manage Department-Root's Portlets</td>
                    </tr>
                        <xsl:apply-templates select="/document/objectlist"/>
                    <tr>
                        <td valign="top">Add a new Portlet:</td>
                        <td>
                            <input type="text" name="portlet" size="40" class="text"/> <xsl:text>&#160;</xsl:text>
                            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="doclink">Browse for Portlet</a>

                       </td>
                   </tr>
                   <tr>
                       <td>
                           <input type="submit" name="add_portlet" value="Add Portlet" class="control"/>
                       </td>
                   </tr>
               </table>
           </td>
        </tr>
    </xsl:template>

    <xsl:template match="objectlist/object">
        <tr>
            <td valign="top">
                <a href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
            </td>
            <td>
                <a href="{$goxims_content}{$absolute_path}?portlet_id={id};rem_portlet=1">
                    <img src="{$ximsroot}skins/{$currentskin}/images/option_delete.png"
                        border="0"
                        width="37"
                        height="19"
                        alt="Delete Portlet"
                        title="Delete this portlet"
                    />
                </a>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
