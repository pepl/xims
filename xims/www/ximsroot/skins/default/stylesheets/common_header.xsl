<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="header">
    <xsl:param name="noncontent">false</xsl:param>
    <xsl:param name="nopath">false</xsl:param>
    <xsl:param name="containerpath">false</xsl:param>
    <xsl:param name="createwidget">false</xsl:param>
    <xsl:param name="parent_id" />
    <xsl:param name="noarrownavigation">false</xsl:param>
    <xsl:param name="nooptions">false</xsl:param>
    <xsl:param name="nostatus">false</xsl:param>
    <xsl:param name="no_navigation_at_all">false</xsl:param>

    <!-- start 'app graphic' table -->
    <table id="titlelogo">
        <tr>
            <td class="title">
                <h1>
                    <xsl:choose>
                        <xsl:when test="title != ''">
                            <xsl:value-of select="title"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="/document/context/session/user/name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
            </td>
            <td class="logo">
                <a href="http://xims.info/">&#xa0;<span>XIMS</span></a>
            </td>
        </tr>
    </table>
    <!-- end 'app graphic' table -->

    <!-- start 'location bar' table -->
    <table id="navopt">
        <tr>
            <td class="locbar">
                <xsl:if test="$nopath='false' and $noncontent ='false'">
                    <span style="color: #004080; font-size: 10px; font-family: Arial, Helvetica, sans-serif;">
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
                    </span>
                </xsl:if>
            </td>
            <td class="date_opt">
                <span>
                <xsl:apply-templates select="/document/context/session/date" mode="date"/>
                <xsl:choose>
                    <xsl:when test="/document/context/session/public_user = '1'">
                        / <a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}" class="logout"><xsl:value-of select="$i18n/l/login"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        / <a href="{$xims_box}{$goxims}/user"><xsl:value-of select="/document/context/session/user/name" /></a> / <a href="{$goxims_content}{$absolute_path}?reason=logout" class="logout"><xsl:value-of select="$i18n/l/logout"/></a>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$no_navigation_at_all='true' or $noncontent = 'true'">
                    </xsl:when>
                    <xsl:otherwise>
                        /
                        <xsl:call-template name="mode_switcher"/>
                    </xsl:otherwise>
                </xsl:choose>
                </span>
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
            <xsl:with-param name="parent_id"><xsl:value-of select="$parent_id"/></xsl:with-param>
            <xsl:with-param name="noarrownavigation"><xsl:value-of select="$noarrownavigation"/></xsl:with-param>
            <xsl:with-param name="nooptions"><xsl:value-of select="$nooptions"/></xsl:with-param>
            <xsl:with-param name="nostatus"><xsl:value-of select="$nostatus"/></xsl:with-param>
        </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="subheader_noncontent">
    <table id="subheader">
        <tr>
            <td>
                <!--<xsl:call-template name="message"/>-->
            </td>
            <xsl:call-template name="header.cttobject.search"/>
        </tr>
    </table>
</xsl:template>

<xsl:template name="subheader_nonavigation">
    <table id="subheader">
        <tr>
            <td>
                <xsl:call-template name="message"/>
            </td>
        </tr>
    </table>
</xsl:template>


<xsl:template name="subheader">
    <xsl:param name="createwidget">false</xsl:param>
    <xsl:param name="parent_id" />
    <xsl:param name="noarrownavigation">false</xsl:param>
    <xsl:param name="nooptions">false</xsl:param>
    <xsl:param name="nostatus">false</xsl:param>

    <table id="subheader">
        <tr>
            <xsl:call-template name="header.arrownavigation"/>
            <xsl:choose>
                <xsl:when test="$m='e'">
                    <td width="215" nowrap="nowrap">
                        <xsl:if test="$nooptions='false'">
                            <xsl:call-template name="cttobject.options"/>
                            <!-- send_email is not in cttobject.options -->
                            <xsl:call-template name="cttobject.options.send_email"/>
                        </xsl:if>
                    </td>
                    <td width="80" nowrap="nowrap">
                        <xsl:if test="$nostatus='false'">
                            <xsl:call-template name="cttobject.status"/>
                        </xsl:if>
                    </td>
                    <td width="126" nowrap="nowrap">
                        <xsl:if test="/document/context/object/user_privileges/create
                            and $createwidget = 'true'
                            and /document/object_types/object_type[can_create]">
                            <xsl:call-template name="header.cttobject.createwidget">
                                <xsl:with-param name="parent_id"><xsl:value-of select="$parent_id"/></xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td width="126" nowrap="nowrap"><xsl:text>&#160;</xsl:text></td>
                    <td width="80"><xsl:text>&#160;</xsl:text></td>
                </xsl:otherwise>
            </xsl:choose>
            <td>
                <xsl:call-template name="message"/>
            </td>
            <xsl:call-template name="header.cttobject.search"/>
        </tr>
    </table>
</xsl:template>

<xsl:template name="header.arrownavigation">
    <td width="57" class="navback" align="center" nowrap="nowrap">
        <a href="javascript:history.go(-1)">
            <img src="{$skimages}navigate-back.png"
                    width="28"
                    height="28"
                    border="0"
                    alt="{$i18n/l/Back}"
                    title="{$i18n/l/Back}"
                    name="back"
            />
        </a>
    </td>
    <td width="41" class="navup" align="left" nowrap="nowrap">
        <xsl:choose>
            <xsl:when test="$parent_path != ''">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($goxims_content,$parent_path,'?m=',$m)"/>
                        <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                    </xsl:attribute>
                    <img src="{$skimages}navigate-up.png"
                            width="28"
                            height="28"
                            border="0"
                            alt="{$i18n/l/Up}"
                            title="{$i18n/l/Up}"
                            name="up"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$skimages}navigate-up.png"
                        width="28"
                        height="28"
                        border="0"
                        alt="{$i18n/l/Up}"
                        title="{$i18n/l/Up}"
                        name="up"/>
            </xsl:otherwise>
        </xsl:choose>
    </td>
    <td width="59" class="navfwd" align="left" nowrap="nowrap">
        <a href="javascript:history.go(+1)">
            <img src="{$skimages}navigate-forward.png"
                    width="28"
                    height="28"
                    border="0"
                    alt="{$i18n/l/Forward}"
                    title="{$i18n/l/Forward}"
                    name="forward"
            />
        </a>
    </td>
</xsl:template>

<xsl:template name="header.cttobject.createwidget">
    <xsl:param name="parent_id"/>
    <div id="MDME" style="display:none">
        <ul>
            <li><xsl:value-of select="$i18n/l/Create"/>
                <ul>
                    <xsl:choose>
                        <xsl:when test="/document/context/object/@id = 1">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]"/>
                        </xsl:when>
                        <xsl:when test="$parent_id != ''">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and parent_id = $parent_id]">
                                <xsl:sort select="name"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <li><xsl:value-of select="$i18n/l/More"/>
                                <ul>
                                    <!-- Only show basic object types on first page: TODO Select from object type properties and not from OT names or IDs!
                                        Do not display object types that either are not fully implemented or that are not meant to be created directly.
                                        We may consider adding an object type property for the latter types.
                                        jokar, 2006-05-03: parameter parent_id, to prevent the diret creation of e.g. VLibraryItem::Document-s
                                        jerboaa, 2007-07-19: Do not show object types which contain "Item" in their name with the only exception
					                     of "NewsItem"! 
                                    -->
                                    <xsl:apply-templates select="/document/object_types/object_type[can_create and not(@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11' or name = 'Portal' or name = 'Annotation' or ( contains(name,'Item') and not(substring-before(name, 'Item')='News') ) or name = 'SiteRoot' or parent_id != $parent_id)]">
                                        <xsl:sort select="name"/>
                                    </xsl:apply-templates>
                                </ul>
                            </li>
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and (@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11')]">
                                <xsl:sort select="name"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
            </li>
        </ul>
    </div>
    <noscript>
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0;" method="get">
                <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="objtype">
                    <xsl:choose>
                        <xsl:when test="/document/context/object/@id = 1">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]" mode="form"/>
                        </xsl:when>
                        <xsl:otherwise>
			    <!-- Do not show object types which contain "Item" in their name with the only exception of "NewsItem"! -->
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name != 'Portal' and name != 'Annotation' and not(contains(name,'Item') and not(substring-before(name, 'Item')='News')) and parent_id = $parent_id]" mode="form">
			        <xsl:sort select="name"/>
			    </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </select>
                <xsl:text>&#160;</xsl:text>
                <input type="image"
                    name="create"
                    src="{$sklangimages}create.png"
                    alt="{$i18n/l/Create}"
                    title="{$i18n/l/Create}" />
                <input name="page" type="hidden" value="{$page}"/>
                <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                <xsl:if test="$defsorting != 1">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                </xsl:if>
        </form>
    </noscript>
</xsl:template>

<xsl:template name="header.cttobject.search">
    <xsl:variable name="Search" select="$i18n/l/Search"/>
    <td class="qsearch">
        <form method="get" name="quicksearch">
            <xsl:attribute name="action">
                <xsl:choose>
                    <xsl:when test="$absolute_path != ''">
                        <xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($xims_box,$goxims,'/user')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <div>
                <label for="start_here"><xsl:value-of select="$i18n/l/From_here"/></label>
                <input id="start_here" type="checkbox" class="start_here" name="start_here" value="1">
                    <xsl:if test="$start_here != ''">
                        <xsl:attribute name="checked">true</xsl:attribute>
                    </xsl:if>
                </input>
                <input type="text" class="search" name="s" size="17" maxlength="200">
                <xsl:choose>
                    <xsl:when test="$s != ''">
                        <xsl:attribute name="value"><xsl:value-of select="$s"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="value">[<xsl:value-of select="$Search"/>]</xsl:attribute>
                        <xsl:attribute name="onfocus">document.quicksearch.s.value=&apos;&apos;;</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                </input>
                <xsl:text>&#160;</xsl:text>
                <input type="image"
                    src="{$sklangimages}search.png"
                    name="submit"
                    alt="{$Search}"
                    title="{$Search}"/>
                <input type="hidden" name="search" value="1"/>
            </div>
        </form>
    </td>
</xsl:template>

<xsl:template name="mode_switcher">
    <xsl:choose>
        <xsl:when test="$m='e'">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,$absolute_path,'?m=b')"/>
                    <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                </xsl:attribute>
                <xsl:value-of select="$i18n/l/switch_to_browse"/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,$absolute_path,'?m=e')"/>
                    <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                </xsl:attribute>
                <xsl:value-of select="$i18n/l/switch_to_edit"/>
            </a>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template match="object_type">
    <xsl:variable name="parent_id" select="parent_id"/>
    <xsl:variable name="sorting"><xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:variable>
    <xsl:variable name="fullname">
        <xsl:choose>
            <xsl:when test="$parent_id != ''">
                <xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <li><a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype={$fullname};page={$page};r={/document/context/object/@id}{$sorting}"><xsl:value-of select="$fullname"/></a></li>
</xsl:template>

<xsl:template match="object_type" mode="form">
    <xsl:variable name="parent_id" select="parent_id"/>
    <xsl:variable name="fullname">
        <xsl:choose>
            <xsl:when test="$parent_id != ''">
                <xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <option value="{$fullname}"><xsl:value-of select="$fullname"/></option>
</xsl:template>


  <xsl:template name="cttobject.options.send_email">
    <xsl:variable name="id" select="@id"/>
    <xsl:if test="marked_deleted != '1' 
                  and (user_privileges/send_as_mail = '1')  
                  and (locked_time = '' 
                       or locked_by_id = /document/context/session/user/@id)
                  and /document/object_types/object_type[
                        @id=/document/context/object/object_type_id
                      ]/is_mailable = '1'
                  and published = '1'">
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';prepare_mail=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,
                                           ';order=',$order,
                                           ';page=',$page,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          <img src="{$skimages}option_email.png"
               border="0"
               name="email{$id}"
               width="18"
               height="19"
               title="Generate Spam"
               alt="Generate Spam"/>
        </a>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
