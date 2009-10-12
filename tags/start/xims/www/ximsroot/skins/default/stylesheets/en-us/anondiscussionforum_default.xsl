<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="common.xsl"/>
<xsl:import href="../../../anondiscussionforum_common.xsl"/>
<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
   <head>
    <title><xsl:value-of select="title"/> - Anonymous Discussion Forum - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript" />
   </head>
   <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
      <xsl:call-template name="header">
          <!-- we need a more flexible header-template; for now, there is no nocreatewidget-param -->
          <xsl:with-param name="nocreatewidget">true</xsl:with-param>
      </xsl:call-template>
      <h1 class="documenttitle"><xsl:value-of select="title" /></h1>
      <h3 style="margin-left:8px;">
            <xsl:apply-templates select="abstract"/>
        </h3>
        <br />
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" style="margin-left:5px; margin-bottom: 0px;">
        <input type="hidden" name="objtype" value="anondiscussionforumcontrib"/>
            <input type="hidden" name="parid" value="{@document_id}" />
            <xsl:if test="user_privileges/create">
                    <input type="submit" name="create" value="Create new topic" class="control" /><br /><br />
            </xsl:if>
        </form>
   
        <xsl:choose>
        <xsl:when test="$sb='position'">
        <!--<xsl:when test="$sb='name'">-->
            <xsl:choose>
                <xsl:when test="$order='asc'">
                    <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                        <tr>
                            <td class="lightblue">
                                   <a href="{$goxims_content}{$absolute_path}?sb=position&amp;order=desc">
                                    <!--<a href="{$goxims_content}{$absolute_path}?sb=name&amp;order=desc">-->
                                    Topic
                                    <img src="{$ximsroot}skins/{$currentskin}/images/arrow_ascending.gif" width="10" height="10" border="0" alt="sort descending"/>
                                    </a>
                            </td>
                            <td class="lightblue" width="120" nowrap="nowrap">
                                    <a href="?sb=date">
                                    Created
                                    </a>
                            </td>
                            <td class="lightblue" width="134">Author</td>
                            <td class="lightblue" width="50">Replies</td>
                            <td class="lightblue" width="134">Last Reply</td>
                            <td></td>
                        </tr>
                        <xsl:apply-templates select="children/object">
                                <xsl:sort select="title" order="ascending" case-order="lower-first"/>
                        </xsl:apply-templates>
                    </table>
                </xsl:when>
                <xsl:when test="$order='desc'">
                    <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                        <tr> 
                            <td class="lightblue">
                                    <a href="{$goxims_content}{$absolute_path}?sb=position&amp;order=asc">
                                    <!--<a href="{$goxims_content}{$absolute_path}?sb=name&amp;order=asc">-->
                                    Topic
                                    <img src="{$ximsroot}skins/{$currentskin}/images/arrow_descending.gif" width="10" height="10" border="0" alt="sort ascending"/>
                                    </a>
                            </td>
                            <td class="lightblue" width="120" nowrap="nowrap">
                                    <a href="?sb=date">
                                    Created
                                    </a>
                            </td>
                            <td class="lightblue" width="134">Author</td>
                            <td class="lightblue" width="50">Replies</td>
                            <td class="lightblue" width="134">Last Reply</td>
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
                <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                    <tr> 
                        <td class="lightblue">
                            <a href="?sb=position">
                            <!--<a href="?sb=name">-->
                            Topic
                            </a>
                        </td>
                        <td class="lightblue" width="120" nowrap="nowrap">
                                <a href="?sb=date&amp;order=desc">
                                Created
                                <img src="{$ximsroot}skins/{$currentskin}/images/arrow_ascending.gif" width="10" height="10" border="0" alt="sort descending"/>
                            </a>
                        </td>
                        <td class="lightblue" width="134">Author</td>
                        <td class="lightblue" width="50">Replies</td>
                        <td class="lightblue" width="134">Last Reply</td>
                  </tr>
                    <xsl:apply-templates select="children/object">
                            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="ascending"/>
                    </xsl:apply-templates>
               </table>
               </xsl:when>
                <xsl:when test="$order='desc'">
                <table class="10left" border="0" cellpadding="3" cellspacing="0" width="800">
                    <tr> 
                        <td class="lightblue">
                            <a href="?sb=position">
                            <!--<a href="?sb=name">-->
                            Topic
                            </a>
                        </td>
                        <td class="lightblue" width="120">
                            <a href="?sb=date&amp;order=asc">
                            Created
                            <img src="{$ximsroot}skins/{$currentskin}/images/arrow_descending.gif" width="10" height="10" border="0" alt="sort ascending"/>
                               </a>
                        </td>
                        <td class="lightblue" width="134">Author</td>
                        <td class="lightblue" width="50">Replies</td>
                        <td class="lightblue" width="134">Last Reply</td>
                  </tr>
                    <xsl:apply-templates select="children/object">
                            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute)" order="descending"/>
                    </xsl:apply-templates>
                </table>
                </xsl:when>
            </xsl:choose>
        </xsl:when>
    </xsl:choose>
    </body>
</html>
</xsl:template>


<xsl:template match="children/object">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>

    <tr height="25">
        <xsl:choose>
           <xsl:when test="$sb='position'">
            <!--<xsl:when test="$sb='name'">-->
                <td bgcolor="#eeeeee" valign="bottom">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$goxims_content}{$absolute_path}/{location}">
                    <xsl:value-of select="title" /></a>
                </td>
                <td nowrap="nowrap" valign="middle" align="center">
                    <xsl:apply-templates select="creation_time" mode="datetime"/>
                </td>
            </xsl:when>
            <xsl:when test="$sb='date'">
                <td valign="middle">
                    <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif" border="0" alt="{/document/data_formats/data_format[@id=$dataformat]}"/>
                    <xsl:text> </xsl:text>
                    <a href="{$goxims_content}{$absolute_path}/{location}">
                    <xsl:value-of select="title" /></a>
                </td>
                <td nowrap="nowrap" bgcolor="#eeeeee" valign="middle" align="center">
                    <xsl:apply-templates select="creation_time" mode="datetime"/>
                </td>
            </xsl:when>
        </xsl:choose>
        <td align="left" valign="middle">
            <a>
                <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/email"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                <xsl:value-of select="attributes/author"/>
            </a>
            <xsl:choose>
                  <xsl:when test="attributes/coemail">, 
                    <a>
                        <xsl:attribute name="href">mailto:<xsl:value-of select="attributes/coemail"/>?subject=RE: <xsl:value-of select="title"/></xsl:attribute>
                        <xsl:value-of select="attributes/coauthor"/>
                    </a>
                </xsl:when>
                <xsl:when test="attributes/coauthor">,<br/> <xsl:value-of select="attributes/coauthor"/>
                </xsl:when>
            </xsl:choose>
        </td>
        <td valign="middle" align="center">
            <xsl:value-of select="children_count"/>
        </td>
        <td nowrap="nowrap" valign="middle" align="center">
            <xsl:value-of select="child_last_modified"/>
        </td>
        <td valign="bottom">
        <xsl:if test="user_privileges/delete">
            <form style="margin:0px;" name="delete" method="GET" action="{/document/session/serverurl}{$goxims_content}">
                <input type="hidden" name="del_prompt" value="1"/>
                <input type="hidden" name="id" value="{@id}"/>
                <input type="image" src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" border="0" width="37" height="19" title="delete" alt="delete"/>
            </form>
        </xsl:if>
        </td>
    </tr>    
</xsl:template>

</xsl:stylesheet>