<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="common.xsl"/>
<xsl:output method="html" encoding="ISO-8859-1"/>
<xsl:param name="request.uri"/>

<xsl:template match="/document/context/object">
<html>
  <head>
    <title><xsl:value-of select="title"/> - Discussion Forum - XIMS</title>
     <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
    <script src="/scripts/default.js" type="text/javascript" />
  </head>

  <body margintop="0" marginleft="0" marginwidth="0" marginheight="0">
    <table border="0" cellpadding="0" cellspacing="0" width="790">
            <xsl:call-template name="header">
                <!-- we need a more flexible header-template; for now, there is no nocreatewidget-param -->
                <xsl:with-param name="nocreatewidget">true</xsl:with-param>
            </xsl:call-template>
            <tr>
                <td class="links">
                    <!-- Begin Standard Links -->
                    <xsl:call-template name="stdlinks"/>
                    <!-- End Standard Links -->

                    <!-- Begin Department Links -->
                    <xsl:call-template name="deptlinks"/>
                    <!-- End Department Links -->

                    <!-- Begin Document Links -->
                    <!-- End Document Links -->
                </td>
             <td>

              <!-- Begin forum -->

                <h1><xsl:value-of select="title" /></h1>
                <p class="content">
                    <xsl:apply-templates select="abstract"/>
                </p>

        <p>
            <xsl:if test="user_privileges/create">
              <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" style="margin-bottom: 0;">
                <input type="hidden" name="objtype" value="anondiscussionforumcontrib"/>
                <input type="hidden" name="parid" value="{@document_id}" />
                <input type="submit" name="create" value="Create new topic" class="control" /><br /><br />
              </form>
            </xsl:if>
        </p>
            <xsl:choose>
                <xsl:when test="$sb='name'">
                        <xsl:choose>
                            <xsl:when test="$order='asc'">
                                <table border="0" cellpadding="0" cellspacing="0" width="618">
                                    <tr>
                                        <td width="240">
                                             <a href="{$goxims_content}{$absolute_path}?sb=position&amp;order=desc">
                             <!-- <a href="{$goxims_content}{$absolute_path}?sb=name&amp;order=desc"> -->
                                             <img src="{$ximsroot}images/forum/theme_act_up.gif" width="240" height="15" border="0" alt="absteigend sortieren"/>
                                            </a>
                                        </td>
                                        <td width="110">
                                            <a href="{$goxims_content}{$absolute_path}?sb=date">
                                                <img src="{$ximsroot}images/forum/created_norm.gif" width="110" height="15" border="0" alt="aufsteigend sortieren"/>
                                            </a>
                                        </td>
                                        <td width="98">
                                            <img src="{$ximsroot}images/forum/author_norm.gif" width="98" height="15" border="0" alt="Autor"/>
                                        </td>
                                        <td width="60">
                                            <img src="{$ximsroot}images/forum/answers_norm.gif" width="60" height="15" border="0" alt="Antworten"/>
                                        </td>
                                        <td width="110" nowrap="nowrap">
                                            <img src="{$ximsroot}images/forum/last_answer_norm.gif" width="110" height="15" border="0" alt="Letzte Antwort"/>
                                        </td>
                                    </tr>
                                    <xsl:apply-templates select="children/object">
                                            <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                                    </xsl:apply-templates>
                            </table>
                            </xsl:when>
                            <xsl:when test="$order='desc'">
                                <table border="0" cellpadding="0" cellspacing="0" width="618">
                                    <tr>
                                        <td width="240">
                                            <a href="{$goxims_content}{$absolute_path}?sb=position&amp;order=asc">
                            <!-- <a href="{$goxims_content}{$absolute_path}?sb=name&amp;order=asc"> -->
                                            <img src="{$ximsroot}images/forum/theme_act_down.gif" width="240" height="15" border="0" alt="aufsteigend sortieren"/>
                                            </a>
                                        </td>
                                        <td width="110">
                                            <a href="{$goxims_content}{$absolute_path}?sb=date">
                                                <img src="{$ximsroot}images/forum/created_norm.gif" width="110" height="15" border="0" alt="aufsteigend sortieren"/>
                                            </a>
                                        </td>
                                        <td width="98">
                                            <img src="{$ximsroot}images/forum/author_norm.gif" width="98" height="15" border="0" alt="Autor"/>
                                        </td>
                                        <td width="60">
                                            <img src="{$ximsroot}images/forum/answers_norm.gif" width="60" height="15" border="0" alt="Antworten"/>
                                        </td>
                                        <td width="110" nowrap="nowrap">
                                            <img src="{$ximsroot}images/forum/last_answer_norm.gif" width="110" height="15" border="0" alt="Letzte Antwort"/>
                                        </td>
                                    </tr>
                                    <xsl:apply-templates select="children/object">
                                            <xsl:sort select="title" order="descending"/>
                                    </xsl:apply-templates>
                                </table>
                            </xsl:when>
                        </xsl:choose>
                </xsl:when>

                <xsl:when test="$sb='date'">
                    <xsl:choose>
                            <xsl:when test="$order='asc'">
                                <table border="0" cellpadding="0" cellspacing="0" width="618">
                                    <tr>
                                        <td width="240">
                                                <a href="{$goxims_content}{$absolute_path}?sb=position">
                            <!-- <a href="{$goxims_content}{$absolute_path}?sb=name"> -->
                                                    <img src="{$ximsroot}images/forum/theme_norm.gif" width="240" height="15" border="0" alt="absteigend sortieren"/>
                                                </a>
                                        </td>
                                        <td width="110">
                                            <a href="{$goxims_content}{$absolute_path}?sb=date&amp;order=desc">
                                                 <img src="{$ximsroot}images/forum/created_act_down.gif" width="110" height="15" border="0" alt="aufsteigend sortieren"/>
                                            </a>
                                        </td>
                                        <td width="98">
                                            <img src="{$ximsroot}images/forum/author_norm.gif" width="98" height="15" border="0" alt="Autor"/>
                                        </td>
                                        <td width="60">
                                            <img src="{$ximsroot}images/forum/answers_norm.gif" width="60" height="15" border="0" alt="Antworten"/>
                                        </td>
                                        <td width="110" nowrap="nowrap">
                                            <img src="{$ximsroot}images/forum/last_answer_norm.gif" width="110" height="15" border="0" alt="Letzte Antwort"/>
                                        </td>
                                    </tr>
                                    <xsl:apply-templates select="children/object">
                                            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="ascending"/>
                                    </xsl:apply-templates>
                                </table>
                            </xsl:when>
                        <xsl:when test="$order='desc'">
                        <table border="0" cellpadding="0" cellspacing="0" width="618">
                                    <tr>
                                        <td width="240">
                                                <a href="{$goxims_content}{$absolute_path}?sb=position">
                            <!-- <a href="{$goxims_content}{$absolute_path}?sb=name"> -->
                                                    <img src="{$ximsroot}images/forum/theme_norm.gif" width="240" height="15" border="0" alt="absteigend sortieren"/>
                                                </a>
                                        </td>
                                        <td width="110">
                                            <a href="{$goxims_content}{$absolute_path}?sb=date&amp;order=asc">
                                               <img src="{$ximsroot}images/forum/created_act_up.gif" width="110" height="15" border="0" alt="absteigend sortieren"/>
                                            </a>
                                        </td>
                                        <td width="98">
                                            <img src="{$ximsroot}images/forum/author_norm.gif" width="98" height="15" border="0" alt="Autor"/>
                                        </td>
                                        <td width="60">
                                            <img src="{$ximsroot}images/forum/answers_norm.gif" width="60" height="15" border="0" alt="Antworten"/>
                                        </td>
                                        <td width="110" nowrap="nowrap">
                                            <img src="{$ximsroot}images/forum/last_answer_norm.gif" width="110" height="15" border="0" alt="Letzte Antwort"/>
                                        </td>
                                </tr>
                                    <xsl:apply-templates select="children/object">
                                            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
                                    </xsl:apply-templates>
                                </table>
                            </xsl:when>
                        </xsl:choose>
            </xsl:when>
            </xsl:choose>

              <!-- End forum -->

              <!-- Begin footer -->
                    <br /><br />
                    <xsl:call-template name="copyfooter"/>
              <!-- End footer -->

                </td>
           </tr>

    </table>
    </body>
</html>
</xsl:template>

<xsl:template match="children/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>

    <tr height="30">
        <xsl:choose>
            <xsl:when test="$sb='name'">
                <td bgcolor="#ced3d6" valign="middle">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$goxims_content}{$absolute_path}/{location}">
                    <xsl:value-of select="title" />
                    </a>
                </td>
                <td valign="middle" nowrap="nowrap">
                    <xsl:text>&#160;</xsl:text>
                    <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </td>
            </xsl:when>
            <xsl:when test="$sb='date'">
                <td valign="middle">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$goxims_content}{$absolute_path}/{location}">
                    <xsl:value-of select="title" />
                    </a>
                </td>
                <td bgcolor="#ced3d6" valign="middle" nowrap="nowrap">
                     <xsl:text>&#160;</xsl:text>
                     <xsl:apply-templates select="creation_timestamp" mode="datetime"/>
                </td>
            </xsl:when>
        </xsl:choose>
        <td align="left" valign="middle">
            <xsl:text>&#160;</xsl:text>
            <a>
                <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/email"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                <xsl:value-of select="attributes/author"/>
            </a>
            <xsl:choose>
                <xsl:when test="attributes/coemail">,
                    <br />
                    <a>
                        <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/coemail"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                        <xsl:value-of select="attributes/coauthor"/>
                    </a>
                </xsl:when>
                <xsl:when test="attributes/coauthor">, <xsl:value-of select="attributes/coauthor"/>
                </xsl:when>
            </xsl:choose>
        </td>
        <td valign="middle">
            <xsl:text>&#160;&#160;&#160;&#160;&#160;</xsl:text>
             <xsl:value-of select="descendant_count"/>
        </td>
        <td valign="middle" nowrap="nowrap">
            <xsl:text>&#160;</xsl:text>
             <xsl:value-of select="substring(descendant_last_modified, 1, 16)"/>
        </td>
   </tr>

</xsl:template>

</xsl:stylesheet>
