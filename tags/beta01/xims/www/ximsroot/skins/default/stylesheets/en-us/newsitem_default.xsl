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
    <xsl:import href="newsitem_common.xsl"/>
    
    <!-- firstlevel folders are considered to be 'sites' -->
    <xsl:variable name="site_location">/<xsl:value-of select="/document/context/object/parents/object[@parent_id='1']/location"/></xsl:variable>

    <xsl:output method="html" encoding="UTF-8"/>
    
    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>
    
    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">                <!-- poor man's stylechooser -->
                <xsl:choose>
                    <xsl:when test="$printview != '0'">
                        <xsl:call-template name="document-metadata"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="header"/>
                    </xsl:otherwise>
                </xsl:choose>
                <h1 class="documenttitle"><xsl:value-of select="title"/></h1>
                <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                    <xsl:choose>
                        <xsl:when test="string-length(image_id)">
                            <tr>
                                <td>
                                    <img src="{$goxims_content}{image_id}"/>
                                </td>
                                <td bgcolor="#dddddd">
                                    <!-- should be class newslead! -->
                                    <xsl:apply-templates select="abstract"/>
                                </td>
                            </tr>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td bgcolor="#dddddd" colspan="2">
                                    <!-- should be class newslead! -->
                                    <xsl:apply-templates select="abstract"/>
                                </td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                    <tr>
                        <td bgcolor="#ffffff" colspan="2">
                            <xsl:apply-templates select="body"/>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" width="40%" style="border:1px solid;">
                            <p><b>Document Links</b></p>                            
                            <table>
                                <xsl:if test="$m='e' and user_privileges/create">
                                    <tr>
                                        <td colspan="2">
                                            <a href="{$goxims_content}{$absolute_path}?create=1;parid={@document_id};objtype=urllink">add link</a>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:apply-templates select="children/object" mode="link"/>
                            </table>
                        </td>
                        <td valign="top" width="60%" style="border:1px solid;">
                            <table width="100%" border="0">
                                <tr>
                                    <td><b>Comments</b></td>
                                    <td colspan="2">
                                        <xsl:if test="$m='e' and user_privileges/create">
                                            <a href="{$goxims_content}{$absolute_path}?create=1;parid={@document_id};objtype=annotation">comment this</a>
                                        </xsl:if>
                                    </td>
                                </tr>
                                
                                <xsl:apply-templates select="children/object" mode="comment"/>
                            </table>
                        </td>
                    </tr>
                </table>
                <table align="center" width="98.7%" class="footer">
                    <xsl:call-template name="user-metadata"/>
                    <xsl:call-template name="footer">
                        <xsl:with-param name="link_pub_preview">true</xsl:with-param>
                    </xsl:call-template>
                </table>
                <a href="{$goxims_content}{$absolute_path}?edit=1;plain=1">Edit without WYSIWYG-Editor</a>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="children/object" mode="link">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <xsl:variable name="objecttype">
            <xsl:value-of select="object_type_id"/>
        </xsl:variable>
        <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name='URL' or /document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
            
            <tr>
                <td bgcolor="#ffffff">
                    <!-- icon -->
                    <!-- link -->
                    <a>
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                                    <xsl:value-of select="concat(location,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($goxims_content,symname_to_doc_id,'?m=',$m)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="title" />
                    </a>
                </td>
                <xsl:if test="$m='e'">
                    <td>
                        <xsl:choose>
                            <xsl:when test="user_privileges/write and locked_time = '' or locked_by = /document/session/user/@id">
                                <a href="{$goxims_content}?id={@id};edit=1">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/option_edit.png" 
                                         border="0" 
                                         alt="Edit" 
                                         title="Edit this document"
                                         width="32" height="19" 
                                         align="left" 
                                         onmouseover="pass('edit{@id}','edit','h'); return true;" 
                                         onmouseout="pass('edit{@id}','edit','c'); return true;" 
                                         onmousedown="pass('edit{@id}','edit','s'); return true;" 
                                         onmouseup="pass('edit{@id}','edit','c'); return true;" 
                                         name="edit{@id}" 
                                         />
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="{$ximsroot}images/spacer_white.gif" 
                                     width="32" 
                                     height="19" 
                                     border="0" 
                                     alt="" 
                                     align="left" 
                                     />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="user_privileges/grant|user_privileges/grant_all">
                                <a href="{$goxims_content}?id={@id};obj_acllist=1">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/option_acl.png" 
                                         border="0" 
                                         alt="Access Control" 
                                         title="Access Control"
                                         align="left" 
                                         width="32" 
                                         height="19"
                                         />
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="{$ximsroot}images/spacer_white.gif" 
                                     width="32" 
                                     height="19" 
                                     border="0" 
                                     alt="" 
                                     align="left" 
                                     />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="user_privileges/delete">
                                <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                                <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
                                <form style="margin:0px;" name="delete" method="GET" action="{$xims_box}{$goxims_content}">
                                    <input type="hidden" name="del_prompt" value="1"/>
                                    <input type="hidden" name="id" value="{@id}"/>
                                    <input type="image" 
                                           name="del{@id}" 
                                           src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" 
                                           border="0" 
                                           width="37" 
                                           height="19"
                                           />
                                </form>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="{$ximsroot}images/spacer_white.gif" width="37" height="19" border="0" alt="" align="left" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </xsl:if>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="children/object" mode="comment">
        <xsl:variable name="objecttype">
            <xsl:value-of select="object_type_id"/>
        </xsl:variable>
        
        <!-- <xsl:if test="/document/object_types/object_type[@id=$objecttype]/name='Annotation'"> -->
        <!-- 
             pepl: This hardcoded OT would not be neccessary if the Annotations would be loaded via -getchildren!!! 
             (I guess its time to change the "definition" regarding Annotations and their granted privs)
         -->
        <xsl:if test="$objecttype=28">
            <tr>
                <td colspan="3">
                    <img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level}" height="10"/>
                    <img src="{$ximsroot}images/icons/list_HTML.gif" alt="" width="20" height="18"/>
                    <a href="{$goxims_content}{$absolute_path}?id={@id};view=1;m={$m}">
                        <xsl:value-of select="title"/>
                    </a>
                </td>
            </tr>
            <tr>
                <td width="96%">
                    <img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level+20}" height="10"/>
                    <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
                </td>
                <xsl:if test="$m='e'">
                    <td width="2%">
                        <xsl:choose>
                            <xsl:when test="/document/context/object/user_privileges/write and locked_time = '' or locked_by = /document/session/user/@id">
                                <a href="{$goxims_content}?id={@id};edit=1">
                                    <img src="{$ximsroot}skins/{$currentskin}/images/option_edit.png" 
                                         border="0" 
                                         alt="Edit"
                                         title="Edit this Document" 
                                         width="32" height="19" 
                                         align="left" 
                                         onmouseover="pass('edit{@id}','edit','h'); return true;" 
                                         onmouseout="pass('edit{@id}','edit','c'); return true;" 
                                         onmousedown="pass('edit{@id}','edit','s'); return true;" 
                                         onmouseup="pass('edit{@id}','edit','c'); return true;" 
                                         name="edit{@id}" 
                                         />
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="{$ximsroot}images/spacer_white.gif" 
                                     width="32" 
                                     height="19" 
                                     border="0" 
                                     alt="" 
                                     align="left" 
                                     />
                            </xsl:otherwise>

                        </xsl:choose>
                    </td><td width="2%">
                        <xsl:choose>
                            <xsl:when test="/document/context/object/user_privileges/delete">
                                <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                                <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
                                <form style="margin:0px;" name="delete" method="GET" action="{$xims_box}{$goxims_content}">
                                    <input type="hidden" name="del_prompt" value="1"/>
                                    <input type="hidden" name="id" value="{@id}"/>
                                    <input type="image" 
                                           name="del{@id}" 
                                           src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" 
                                           border="0" 
                                           width="37" 
                                           height="19"
                                           />
                                </form>
                            </xsl:when>
                            <xsl:otherwise>
                                <img src="{$ximsroot}images/spacer_white.gif" width="37" height="19" border="0" alt="" align="left" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </xsl:if>
                
            </tr>
            <!-- <tr><td colspan="4"><xsl:apply-templates select="body/*"/></td> -->
        </xsl:if>
    </xsl:template>

    <xsl:template match="a">
        <a>
            <xsl:choose>
                <xsl:when test="$printview != '0'">
                    <xsl:value-of select="."/><xsl:text>&#160;</xsl:text>[<xsl:value-of select="@href"/>]
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@href != ''">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="not(starts-with(@href,'/')) and not(starts-with(@href,$goxims_content) or contains( @href, '://'))">
                                    <xsl:value-of select="concat($goxims_content,$site_location,@href)"/>
                                </xsl:when>
                                <xsl:when test="starts-with(@href,'/') and not(starts-with(@href,$goxims_content))">
                                    <xsl:value-of select="concat($goxims_content,@href)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@href"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="title">
                        <xsl:choose>
                            <xsl:when test="@title != ''">
                                <xsl:value-of select="@title"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="@target != ''">
                        <xsl:attribute name="target">
                            <xsl:value-of select="@target"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@name != ''">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@name"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@id != ''">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@class != ''">
                        <xsl:attribute name="class">
                            <xsl:value-of select="@class"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>

    <xsl:template match="img">
        <img>
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="starts-with(@src,'/') and not(starts-with(@src,$goxims_content))">
                        <xsl:value-of select="concat($goxims_content,$site_location,@src)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@src"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="@title != ''">
                <xsl:attribute name="title">
                    <xsl:value-of select="@title"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@alt != ''">
                <xsl:attribute name="alt">
                    <xsl:value-of select="@alt"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@width != ''">
                <xsl:attribute name="width">
                    <xsl:value-of select="@width"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@height != ''">
                <xsl:attribute name="height">
                    <xsl:value-of select="@height"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@border != ''">
                <xsl:attribute name="border">
                    <xsl:value-of select="@border"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@align != ''">
                <xsl:attribute name="align">
                    <xsl:value-of select="@align"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="@class"/>
                </xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>

</xsl:stylesheet>

