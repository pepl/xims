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
                <title>Create new Portlet in <xsl:value-of select="$absolute_path"/> - XIMS</title>
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
                            <td>Create new Portlet in <xsl:value-of select="$absolute_path"/></td>
                            <td align="right">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!</td>
                        </tr>
                    </table>
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=Portlet" name="eform" method="POST">
                        <input type="hidden" name="objtype" value="Portlet"/>
                        <table border="0" width="95%">
                            <tr>
                                <td valign="top">
                                    <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
                                    <span class="compulsory">Location</span>
                                </td>
                                <td><input tabindex="1" type="text" name="name" size="40" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('PortletLocation')" class="doclink">(?)</a>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <span class="compulsory">Title</span>
                                </td>
                                <td>
                                    <input tabindex="2" type="text" class="text" name="title" size="40" />
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('PortletTitle')" class="doclink">(?)</a>   
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <span class="compulsory">Target</span>
                                </td>
                                <td>
                                    <input tabindex="3" type="text" name="target" size="40" class="text"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
                                    <xsl:text>&#160;</xsl:text>
                                    <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">Browse for Target</a>
                                </td>
                            </tr>
                        <xsl:call-template name="grantowneronly"/>
                        <xsl:call-template name="contentcolumns"/>
                        </table>
                       <xsl:call-template name="saveaction"/>
                </form>
                </p>
                <br />
                <xsl:call-template name="cancelaction"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="contentcolumns">
        <!--
        don't list common stuff like language, major/ minor ids, OTs ...
        such information is loaded everytime and is not selectable
        -->
        <tr>
            <td colspan="2">
                Besides some basic default columns, you can choose
                some <b>extra</b> information the portlet should
                contain. (Note: This information is only available if
                the particular object has such information!)
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <table border="0" cellspacing="0" cellpadding="1" width="100%">
                    <tr>
                        <td width="20%">
                            Creator
                        </td>
                        <td valign="top" width="20%">
                            <input type="checkbox" name="col_created_by_fullname" checked="checked" />
                        </td>
                        <td width="20%">
                            Creation Time
                        </td>
                        <td valign="top" width="40%">
                            <input type="checkbox" name="col_creation_timestamp" checked="checked" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Last Modifier
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_last_modified_by_fullname" checked="checked" />
                        </td>
                        <td>
                            Last Modification Time
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_last_modification_timestamp" checked="checked" />
                        </td>
                    </tr>

                    <tr>
                        <td>Owner</td>
                        <td><input type="checkbox" name="col_owned_by_fullname" checked="checked"/></td>
                        <td>
                            New Flag
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_marked_new" checked="checked" />
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Document Status
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_minor_status" checked="checked" />
                        </td>
                        <td>
                            Extra Attributes
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_attributes"/>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Abstract
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_abstract" checked="checked" />
                        </td>
                        <td>
                            Image URI
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_image_id"/>
                        </td>
                    </tr>

                    <tr>
                        <td>
                            Body
                        </td>
                        <td valign="top">
                            <input type="checkbox" name="col_body" />
                        </td>
                        <td colspan="2"><xsl:text> </xsl:text></td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>

<!-- Keep this comment at the end of the file
Local variables:
mode: xml
sgml-omittag:nil
sgml-shorttag:nil
sgml-namecase-general:nil
sgml-general-insert-case:lower
sgml-minimize-attributes:nil
sgml-always-quote-attributes:t
sgml-indent-step:4
sgml-indent-data:t
sgml-parent-document:nil
sgml-exposed-tags:nil
sgml-local-catalogs:nil
sgml-local-ecat-files:nil
End:
-->
