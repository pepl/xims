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
    <xsl:template name="header">
        <xsl:param name="noncontent">false</xsl:param>
        <xsl:param name="nopath">false</xsl:param>
        <xsl:param name="containerpath">false</xsl:param>
        <xsl:param name="createwidget">false</xsl:param>
        <xsl:param name="noarrownavigation">false</xsl:param>
        <xsl:param name="nooptions">false</xsl:param>
        <xsl:param name="nostatus">false</xsl:param>
        <xsl:param name="no_navigation_at_all">false</xsl:param>

        <!-- start 'app graphic' table -->
        <table width="100%" style="margin-top: 2px;" bgcolor="#eeeeee" border="0" cellpadding="3" cellspacing="0" vspace="0" hspace="0" nowrap="nowrap">
            <tr>
                <td valign="bottom">
                    <h1 style="font-size: 14pt; color:#004080; margin-bottom: 2px"><xsl:value-of select="title"/></h1>
                </td>
                <td align="right" valign="top">
                    <a href="http://xims.uibk.ac.at/"><img src="{$ximsroot}images/xims_logo.png"/></a>
                </td>
            </tr>
        </table>
        <!-- end 'app graphic' table -->

        <!-- start 'location bar' table -->
        <table border="0" cellpadding="2" cellspacing="0" width="100%" height="20">
            <tr>
                <td width="59%" bgcolor="#ffffff" background="{$ximsroot}skins/{$currentskin}/images/tablebg_2nd_row.png" nowrap="nowrap">
                    <xsl:if test="$nopath='false'">
                        <font face="Arial, Helvetica, sans-serif" size="1" color="#004080">
                        <xsl:choose>
                            <xsl:when test="$containerpath='false'">
                                <xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1]">
                                    <xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all" />
                                </xsl:apply-templates>
                                / <a class="" href="{$goxims_content}{$absolute_path}?m={$m}"><xsl:value-of select="location"/></a>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- hardcode OT alarm (folder and dept.root -->
                                <xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1 and (preceding-sibling::object/object_type_id=1 or preceding-sibling::object/object_type_id=6)]" >
                                     <xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all" />
                                </xsl:apply-templates>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        </font>
                    </xsl:if>
                </td>
                <td background="{$ximsroot}skins/{$currentskin}/images/tablebg_2nd_row.png" nowrap="nowrap" align="right">
                    <font face="Arial, Helvetica, sans-serif" size="1" color="#004080">
                        <xsl:value-of select="/document/context/session/date/day"/>. <xsl:value-of select="/document/context/session/date/month"/>. <xsl:value-of select="/document/context/session/date/year"/>
                        <xsl:choose>
                            <xsl:when test="/document/context/session/user/name != $publicuser">
                                / <xsl:value-of select="/document/context/session/user/name" /> / <a href="{$goxims_content}{$absolute_path}?reason=logout" class="logout">logout</a>
                            </xsl:when>
                            <xsl:otherwise>
                                / <a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}" class="logout">login</a>
                            </xsl:otherwise>
                        </xsl:choose>
                        /
                        <xsl:choose>
                            <xsl:when test="$no_navigation_at_all='true'">
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$m='e'">
                                        <a href="{$goxims_content}{$absolute_path}?m=b;sb={$sb};order={$order}">switch to browse-mode</a>
        <!--                                <a href="{$goxims_content}{$absolute_path}?m=b">
                                            <img src="{$ximsroot}skins/{$currentskin}/images/switch_to_browse-mode.png"
                                                 width="106"
                                                 height="31"
                                                 border="0"
                                                 alt="Switch to browse-mode"
                                                 title="Switch to browse-mode"
                                            />
                                        </a>
        -->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$goxims_content}{$absolute_path}?m=e;sb={$sb};order={$order}">switch to edit-mode</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </font>
                </td>
            </tr>
        </table>
        <!-- end 'location bar' table -->

        <xsl:choose>
          <xsl:when test="$noncontent='true'">
            <xsl:call-template name="subheader_noncontent"/>
          </xsl:when>
          <xsl:when test="$no_navigation_at_all='true'">
             <xsl:call-template name="subheader_nonavigation"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="subheader">
                <xsl:with-param name="createwidget"><xsl:value-of select="$createwidget"/></xsl:with-param>
                <xsl:with-param name="noarrownavigation"><xsl:value-of select="$noarrownavigation"/></xsl:with-param>
                <xsl:with-param name="nooptions"><xsl:value-of select="$nooptions"/></xsl:with-param>
                <xsl:with-param name="nostatus"><xsl:value-of select="$nostatus"/></xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="subheader_noncontent">
        <table border="0" cellspacing="0" cellpadding="0" width="100%" style="margin-left: 5px; padding-right: 5px;">
            <tr>
                <td align="center" width="758" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png">
                    <!--<xsl:call-template name="message"/>-->
                </td>
                <xsl:call-template name="header.cttobject.search"/>
            </tr>
        </table>
    </xsl:template>

    <xsl:template name="subheader_nonavigation">
        <table border="0" cellspacing="0" cellpadding="5" width="100%" style="margin-left: 5px; padding-right: 5px;">
            <tr>
                <td align="center" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png">
                    <xsl:call-template name="message"/>
                </td>
            </tr>
        </table>
    </xsl:template>


    <xsl:template name="subheader">
        <xsl:param name="createwidget">false</xsl:param>
        <xsl:param name="noarrownavigation">false</xsl:param>
        <xsl:param name="nooptions">false</xsl:param>
        <xsl:param name="nostatus">false</xsl:param>

        <table border="0" cellspacing="0" cellpadding="0" width="100%" style="padding-right: 5px;">
            <tr>
                <xsl:call-template name="header.arrownavigation"/>
                <xsl:choose>
                    <xsl:when test="$m='e'">
                        <xsl:choose>
                            <xsl:when test="/document/context/object/user_privileges/create and $createwidget = 'true'">
                                <xsl:call-template name="header.cttobject.createwidget"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <td width="180" background="{$ximsroot}skins/{$currentskin}/images/options_bg.png" nowrap="nowrap">
                                    <xsl:if test="$nooptions='false'">
                                        <xsl:call-template name="header.cttobject.options"/>
                                    </xsl:if>
                                </td>
                                <td width="80" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png" nowrap="nowrap">
                                    <xsl:if test="$nostatus='false'">
                                        <xsl:call-template name="header.cttobject.status"/>
                                    </xsl:if>
                                </td>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <td width="126" background="{$ximsroot}skins/{$currentskin}/images/options_bg.png" nowrap="nowrap"><xsl:text>&#160;</xsl:text></td>
                        <td width="80" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png"><xsl:text>&#160;</xsl:text></td>
                    </xsl:otherwise>
                </xsl:choose>
                <td width="629" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png">
                    <xsl:call-template name="message"/>
                </td>
                <xsl:call-template name="header.cttobject.search"/>
            </tr>
        </table>
    </xsl:template>

    <xsl:template name="header.arrownavigation">
                <td width="57" bgcolor="#ffffff" background="{$ximsroot}skins/{$currentskin}/images/navigate_bg.png" align="center" nowrap="nowrap">
                    <a href="javascript:history.go(-1)" onmouseover="pass('back','back','h'); return true;" onmouseout="pass('back','back','c'); return true;" onmousedown="pass('back','back','s'); return true;" onmouseup="pass('back','back','s'); return true;">
                        <img src="{$ximsroot}skins/{$currentskin}/images/navigate-back.png"
                             width="28"
                             height="28"
                             border="0"
                             alt="Back"
                             title="Go Back"
                             name="back"
                        />
                    </a>
                </td>
                <td width="41" bgcolor="#ffffff" background="{$ximsroot}skins/{$currentskin}/images/navigate_bg.png" align="left" nowrap="nowrap">
                    <xsl:choose>
                        <xsl:when test="$parent_path != ''">
                            <a href="{concat($goxims_content,$parent_path)}?sb={$sb}&amp;order={$order};m={$m}"
                                 onmouseover="pass('up','up','h'); return true;"
                                 onmouseout="pass('up','up','c'); return true;"
                                 onmousedown="pass('up','up','s'); return true;"
                                 onmouseup="pass('up','up','s'); return true;">
                            <img src="{$ximsroot}skins/{$currentskin}/images/navigate-up.png"
                                 width="28"
                                 height="28"
                                 border="0"
                                 alt="One Level Up"
                                 title="One Level Up"
                                 name="up"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$ximsroot}skins/{$currentskin}/images/navigate-up.png"
                                 width="28"
                                 height="28"
                                 border="0"
                                 alt="Up"
                                 title="One Level Up"
                                 name="up"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td width="59" background="{$ximsroot}skins/{$currentskin}/images/navigate-forward_bg.png" align="left" nowrap="nowrap">
                    <a href="javascript:history.go(+1)"
                       onmouseover="pass('forward','forward','h'); return true;"
                       onmouseout="pass('forward','forward','c'); return true;"
                       onmousedown="pass('forward','forward','s'); return true;"
                       onmouseup="pass('forward','forward','forward','s'); return true;"
                    >
                        <img src="{$ximsroot}skins/{$currentskin}/images/navigate-forward.png"
                             width="28"
                             height="28"
                             border="0"
                             alt="Forward"
                             title="Forward"
                             name="forward"
                        />
                    </a>
                </td>
    </xsl:template>

    <xsl:template name="header.cttobject.createwidget">
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0;">
            <td width="126" background="{$ximsroot}skins/{$currentskin}/images/options_bg.png" nowrap="nowrap">
                <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt" name="objtype">
                    <xsl:apply-templates select="/document/object_types/object_type[can_create]"/>
                </select>
                <input type="hidden" name="parid" value="{/document/context/object/@id}" />
            </td>
            <td width="80" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png" style="padding-top: 4">
                <xsl:text>&#160;</xsl:text>
                <input type="image"
                       name="create"
                       src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/create.png"
                       width="65"
                       height="14"
                       alt="Create"
                       title="Create"
                       border="0" />
            </td>
        </form>
    </xsl:template>

    <xsl:template name="header.cttobject.options">
        <form style="margin:0px;" name="delete" id="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}">
            <xsl:choose>
                <xsl:when test="/document/context/object/user_privileges/write and /document/context/object/locked_time = '' or /document/context/object/locked_by_id = /document/context/session/user/@id">
                    <a href="{$goxims_content}?id={/document/context/object/@id};edit=1">
                      <img src="{$ximsroot}skins/{$currentskin}/images/option_edit.png"
                           alt="Edit"
                           title="Edit Object"
                           border="0"
                           onmouseover="pass('edit','edit','h'); return true;"
                           onmouseout="pass('edit','edit','c'); return true;"
                           onmousedown="pass('edit','edit','s'); return true;"
                           onmouseup="pass('edit','edit','s'); return true;"
                           name="edit"
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
                       alt=" "
                  />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="/document/context/object/user_privileges/move and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                    <a href="{$goxims_content}?id={/document/context/object/@id};move_browse=1;to={/document/context/object/@id}">
                      <img src="{$ximsroot}skins/{$currentskin}/images/option_move.png"
                           alt="Move"
                           title="Move Object"
                           border="0"
                           onmouseover="pass('move','move','h'); return true;"
                           onmouseout="pass('move','move','c'); return true;"
                           onmousedown="pass('move','move','s'); return true;"
                           onmouseup="pass('move','move','s'); return true;"
                           name="move"
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
                       alt=" "
                  />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="(/document/context/object/user_privileges/publish|/document/context/object/user_privileges/publish_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id) ">
                  <a href="{$goxims_content}?id={/document/context/object/@id};publish_prompt=1">
                    <img src="{$ximsroot}skins/{$currentskin}/images/option_pub.png"
                         border="0"
                         alt="publishing options"
                         title="publishing options"
                         name="publish{/document/context/object/@document_id}"
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
                       alt=" "
                  />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="(/document/context/object/user_privileges/grant|/document/context/object/user_privileges/grant_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                    <a href="{$goxims_content}?id={/document/context/object/@id};obj_acllist=1">
                      <img src="{$ximsroot}skins/{$currentskin}/images/option_acl.png"
                           border="0"
                           alt="Access Control"
                           title="Access Control"
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
                       alt=" "
                  />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="/document/context/object/user_privileges/delete and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
                    <input type="hidden" name="del_prompt" value="1"/>
                    <input type="hidden" name="id" value="{/document/context/object/@id}"/>
                    <input type="image" src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" border="0" width="37" height="19" name="delete" alt="delete" title="delete"/>
                </xsl:when>
                <xsl:otherwise>
                    <img src="{$ximsroot}images/spacer_white.gif"
                         width="37"
                         height="19"
                         border="0"
                         alt=" "
                    />
                </xsl:otherwise>
            </xsl:choose>
        </form>
    </xsl:template>

    <xsl:template name="header.cttobject.status">
        <xsl:choose>
            <xsl:when test="marked_new= '1'">
                <img src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/status_markednew.png"
                     border="0"
                     width="26"
                     height="19"
                     title="This object is marked as new."
                     alt="New"
                />
            </xsl:when>
            <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     width="26"
                     height="19"
                     border="0"
                     alt=""
                />
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="published = '1'">
                <a>
                    <xsl:choose>
                        <xsl:when test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name='AnonDiscussionForum'">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat($gopublic_content,$absolute_path,'/')"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat($publishingroot,$absolute_path,'/')"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <img
                        border="0"
                        width="26"
                        height="19"
                        alt="Published"
                    >
                        <xsl:choose>
                            <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                                <xsl:attribute name="title">This object has last been published at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> by <xsl:call-template name="lastpublisherfullname"/> at <xsl:value-of select="concat($publishingroot,$absolute_path)"/></xsl:attribute>
                                <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub.png</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="title">This object has been modified since the last publication by <xsl:call-template name="lastpublisherfullname"/> at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>.</xsl:attribute>
                                <xsl:attribute name="src"><xsl:value-of select="$ximsroot"/>skins/<xsl:value-of select="$currentskin"/>/images/status_pub_async.png</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                    </img>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     width="26"
                     height="19"
                     border="0"
                     alt=""
                />
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="locked_by_id != '' and locked_time != '' and locked_by_id = /document/context/session/user/@id">
                <a href="{$goxims_content}?id={@id};cancel=1;r={/document/context/object/@id}">
                    <img src="{$ximsroot}skins/{$currentskin}/images/status_locked.png"
                         width="26"
                         height="19"
                         border="0"
                         alt="Unlock"
                         title="Click here to remove your lock on this object."
                    />
                </a>
            </xsl:when>
            <xsl:when test="locked_by_id != '' and locked_time != ''">
                <img src="{$ximsroot}skins/{$currentskin}/images/status_locked.png"
                     width="26"
                     height="19"
                     border="0"
                     alt="Locked"
                >
                    <xsl:attribute name="title">This object has been locked at <xsl:apply-templates select="locked_time" mode="datetime"/> by <xsl:call-template name="lockerfullname"/>.</xsl:attribute>
                </img>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$ximsroot}images/spacer_white.gif"
                     width="26"
                     height="19"
                     border="0"
                     alt=""
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="header.cttobject.search">
        <form style="margin-bottom: 0;" action="{$xims_box}{$goxims_content}{$absolute_path}" method="GET" name="quicksearch">
            <td width="182" align="right">
                <table width="100%" border="0" height="42" background="{$ximsroot}skins/{$currentskin}/images/subheader-generic_bg.png" cellpadding="0" cellspacing="0">
                    <tr>
                        <td nowrap="nowrap">
                            <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" type="text" name="s" size="17" maxlength="200">
                            <xsl:choose>
                                <xsl:when test="$s != ''">
                                    <xsl:attribute name="value"><xsl:value-of select="$s"/></xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="value">[Search]</xsl:attribute>
                                    <xsl:attribute name="onfocus">document.quicksearch.s.value=&apos;&apos;;</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            </input>
                            <xsl:text>&#160;</xsl:text>
                            <input type="image"
                                   src="{$ximsroot}skins/{$currentskin}/images/{$currentuilanguage}/search.png"
                                   name="submit"
                                   width="65"
                                   height="14"
                                   alt="Search"
                                   title="Search"
                                   border="0"
                            />
                            <input type="hidden" name="search" value="1"/>
                        </td>
                    </tr>
                </table>
            </td>
        </form>
    </xsl:template>

    <xsl:template match="object_type">
        <option value="{name}"><xsl:value-of select="name"/></option>
    </xsl:template>

</xsl:stylesheet>
