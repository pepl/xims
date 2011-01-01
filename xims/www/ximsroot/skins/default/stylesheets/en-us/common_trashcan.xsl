<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="common.xsl"/>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>
                    Trashcan - XIMS
                </title>
                <xsl:call-template name="css"/>
            </head>
            <body>
                <xsl:call-template name="header">
                    <xsl:with-param name="nooptions">true</xsl:with-param>
                    <xsl:with-param name="nostatus">true</xsl:with-param>
                </xsl:call-template>
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
<!-- title -->
                        <td width="51">
                                <img src="{$sklangimages}title.png"
                                     width="45"
                                     height="20"
                                     border="0"
                                     alt="Title"
                                     title="Title"
                                     />
                        </td>
                        <td width="100%" background="{$skimages}generic_tablebg_1x20.png">
                            <img src="{$ximsroot}images/spacer_white.gif"
                                 width="50"
                                 height="1"
                                 border="0"
                                 alt=""
                                 />
                        </td>
                        <td width="23">
                            <img src="{$skimages}generic_tablebg_1x20.png"
                                 width="23"
                                 height="20"
                                 alt=""
                                 />
                        </td>
<!-- modified -->
                    <td width="124">
                        <img src="{$sklangimages}last_modified.png"
                             width="124"
                             height="20"
                             border="0"
                             alt="Last modified"
                             title="Last modified"
                        />
                    </td>
<!-- size -->
                    <td width="80">
                        <img src="{$sklangimages}size.png"
                             width="80"
                             height="20"
                             border="0"
                             alt="Size"
                             title="Size in kB"
                        />
                    </td>
<!-- options-->
                    <td width="134">
                        <img src="{$sklangimages}options.png"
                             width="183"
                             height="20"
                             alt="Options"
                             title="Options"
                             />
                    </td>

                    </tr>
<!-- object rows -->
                    <xsl:apply-templates select="/document/objectlist/object">
                        <xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                                  order="ascending"
                                  case-order="lower-first"
                        />
                    </xsl:apply-templates>
                </table>
                <xsl:call-template name="script_bottom"/>
            </body>
        </html>
    </xsl:template>



<!-- template objectrows
     =================== -->
    <xsl:template match="objectlist/object">

        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <tr height="20">
<!-- dataformat icon -->
            <td width="34" bgcolor="#eeeeee">
                <img src="{$ximsroot}images/spacer_white.gif" width="12" height="20" border="0" alt="" />
                <img src="{$ximsroot}images/icons/list_{/document/data_formats/data_format[@id=$dataformat]/name}.gif"
                     border="0"
                     alt="{/document/data_formats/data_format[@id=$dataformat]/name}"
                     title="{/document/data_formats/data_format[@id=$dataformat]/name}"
                />
            </td>

<!-- title -->
            <td colspan="2" bgcolor="#eeeeee" background="{$skimages}containerlist_bg.gif">
                <a>
                    <xsl:choose>
                        <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='Container'">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat($goxims_content,'?id=',@id,';sb=',$sb,';order=',$order,';m=',$m)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat(location,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat($goxims_content,'?id=',@id,';m=',$m)"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="title" />
                </a>
                <br/>
                <xsl:value-of select="abstract"/>
            </td>

<!-- modification time -->
            <td>
                <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
                <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
            </td>

<!-- size -->
            <td align="right">
                <!-- we may put /document/data_formats/data_format[@id=$dataformat]/name into a var or
                find a better way to do this (OT property "hasloblength" for example)
                -->
                <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name!='Container'
                        and /document/data_formats/data_format[@id=$dataformat]/name!='URL'
                        and /document/data_formats/data_format[@id=$dataformat]/name!='SymbolicLink' ">
                    <xsl:value-of select="format-number(lob_length div 1024,'#####0.00')"/>
                    <img src="{$ximsroot}images/spacer_white.gif" width="9" border="0" alt="" />
                </xsl:if>
            </td>
<!-- options -->
            <td nowrap="nowrap" align="left">
<!-- No checking at UI level for now here... :-/ -->
<!--                <xsl:choose>
                    <xsl:when test="user_privileges/delete">
-->                        <a href="{$goxims_content}?id={@id};undelete=1">
                            <img src="{$skimages}option_undelete.png"
                                 border="0"
                                 alt="Undelete"
                                 title="Undelete"
                                 width="32"
                                 height="19"
                                 align="left"
                                 />
                        </a>
<!--                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                             border="0"
                             width="32"
                             height="19"
                             alt=""
                             align="left"
                             />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="user_privileges/delete">
-->                        <!-- note: get seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                        <!-- <form style="margin:0px;" name="delete" method="post" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onsubmit="return confirmDelete()"> -->
                        <form style="margin:0px;" name="delete"
                              method="get"
                              action="{$xims_box}{$goxims_content}">
                            <input type="hidden" name="purge_prompt" value="1"/>
                            <input type="hidden" name="id" value="{@id}"/>
                            <input
                                   type="image"
                                   name="del{@id}"
                                   src="{$skimages}option_purge.png"
                                   border="0"
                                   width="37"
                                   height="19"
                                   alt="Purge"
                                   title="Purge this object"
                                   />
                        </form>
<!--                    </xsl:when>
                    <xsl:otherwise>
                        <img src="{$ximsroot}images/spacer_white.gif"
                             border="0"
                             width="37"
                             height="19"
                             alt=""
                             />
                    </xsl:otherwise>
                </xsl:choose>
-->            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
