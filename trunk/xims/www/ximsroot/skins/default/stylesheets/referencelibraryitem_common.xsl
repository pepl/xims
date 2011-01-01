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
<xsl:param name="reftype"><xsl:value-of select="/document/context/object/reference_type_id"/></xsl:param>
<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
<xsl:variable name="titlerefpropid" select="/document/reference_properties/reference_property[name='title']/@id"/>
<xsl:variable name="daterefpropid" select="/document/reference_properties/reference_property[name='date']/@id"/>
<xsl:variable name="btitlerefpropid" select="/document/reference_properties/reference_property[name='btitle']/@id"/>

<xsl:template name="cttobject.options.purge_or_delete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="user_privileges/delete and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
<a class="sprite sprite-option_purge"
           title="{$l_purge}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;<span><xsl:value-of select="$l_purge"/></span>
        </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="reference_property">
    <xsl:variable name="propid" select="@id"/>
    <tr>
        <td>
            <xsl:value-of select="name"/>:
        </td>
        <td>
            <input type="text" class="text" name="{name}" size="30" tabindex="{position() + 40}" value="{/document/context/object/reference_values/reference_value[property_id=$propid]/value}"></input>
        </td>
        <td>
            <xsl:value-of select="description"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-vlauthors">
    <xsl:if test="@id != '' and authorgroup/author/id">
        <tr>
            <td valign="top"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/authors"/></td>
            <td colspan="2">
                <xsl:apply-templates select="authorgroup/author" mode="edit">
                    <xsl:sort select="./position"
                              order="ascending"
                              data-type="number"/>
                </xsl:apply-templates>
            </td>
        </tr>
    </xsl:if>
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/authors"/>
        </td>
        <td colspan="2">
            <input tabindex="40" type="text" name="vlauthor" size="50" value="" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>
            <xsl:if test="/document/context/vlauthors/author/id">
                <xsl:text>&#160;</xsl:text>
                <input type="button" value="&lt;--" onclick="return addVLProperty( 'author' );"/>
                <xsl:text>&#160;</xsl:text>
                <xsl:apply-templates select="/document/context/vlauthors"/>
            </xsl:if>
            <xsl:if test="@id != ''">
                <xsl:text>&#160;</xsl:text>
                <input type="submit" name="create_author_mapping" value="{$i18n_vlib/l/Create_mapping}" class="control"/>
            </xsl:if>
            <table style="position: absolute; display: inline; padding: 0px; margin: 0px 0px 0px 10px; line-height: 1em;"><tr><td>
            <xsl:value-of select="$i18n_vlib/l/AuthorStringFormat"/>.<br/><xsl:value-of select="$i18n_vlib/l/Split_by_semicolon"/>.
            </td></tr></table>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-vleditors">
    <xsl:if test="@id != '' and editorgroup/author/id">
        <tr>
            <td valign="top"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/editors"/></td>
            <td colspan="2">
                <xsl:apply-templates select="editorgroup/author" mode="edit">
                    <xsl:sort select="./position"
                              order="ascending"
                              data-type="number"/>
                </xsl:apply-templates>
            </td>
        </tr>
    </xsl:if>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/editors"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="vleditor" size="50" value="" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>
            <xsl:if test="/document/context/vlauthors/author/id">
                <xsl:text>&#160;</xsl:text>
                <input type="button" value="&lt;--" onclick="return addVLProperty( 'editor' );"/>
                <xsl:text>&#160;</xsl:text>
                <xsl:apply-templates select="/document/context/vlauthors"><xsl:with-param name="svlauthor" select="'svleditor'"/></xsl:apply-templates>
            </xsl:if>
            <xsl:if test="@id != ''">
                <xsl:text>&#160;</xsl:text>
                <input type="submit" name="create_editor_mapping" value="{$i18n_vlib/l/Create_mapping}" class="control"/>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-vlserials">
    <xsl:if test="/document/reference_types/reference_type/name = 'Article' and @id != '' and serial/@id">
        <tr>
            <td valign="top"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/Serial"/></td>
            <td colspan="2">
                <xsl:apply-templates select="serial" mode="edit"/>
            </td>
        </tr>
    </xsl:if>
    <xsl:if test="/document/reference_types/reference_type/name = 'Article' and not(serial)">
        <tr>
            <td valign="top"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/Serial"/></td>
            <td colspan="2">
                <input tabindex="40" type="text" name="vlserial" size="50" value="" class="text"/>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('VLSerial')" class="doclink">(?)</a>
                <xsl:if test="/document/context/vlserials/serial/@id">
                    <xsl:text>&#160;</xsl:text>
                    <input type="button" value="&lt;--" onclick="return addVLProperty( 'serial' );"/>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:apply-templates select="/document/context/vlserials"/>
                </xsl:if>
                <xsl:if test="@id != ''">
                    <xsl:text>&#160;</xsl:text>
                    <input type="submit" name="create_serial_mapping" value="{$i18n_vlib/l/Create_mapping}" class="control"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template name="head-create">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;(<xsl:value-of select="/document/reference_types/reference_type[@id=$reftype]/name"/>)&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS </title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
    </head>
</xsl:template>

<xsl:template name="head-edit">
    <head>
        <title><xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
    </head>
</xsl:template>

<xsl:template name="table-create">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                <xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;(<xsl:value-of select="/document/reference_types/reference_type[@id=$reftype]/name"/>)&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/>
            </td>
            <td align="right" valign="top">
                <xsl:call-template name="cancelcreateform">
                    <xsl:with-param name="with_save">yes</xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="table-edit">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                <xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;(<xsl:value-of select="/document/reference_types/reference_type[@id=$reftype]/name"/>)&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/>
            </td>
            <td align="right" valign="top">
                <xsl:call-template name="cancelform">
                    <xsl:with-param name="with_save">yes</xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author" mode="edit">
    <xsl:variable name="current_pos" select="number(position)"/>
    <xsl:variable name="role">
        <xsl:choose>
            <xsl:when test="name(..) = 'authorgroup'">0</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="date" select="/document/context/object/reference_values/reference_value[property_id=/document/reference_properties/reference_property[name='date']/@id]/value"/>
    <xsl:variable name="title" select="/document/context/object/reference_values/reference_value[property_id=/document/reference_properties/reference_property[name='title']/@id]/value"/>
    <xsl:if test="$current_pos!=1">
        <xsl:text> </xsl:text>
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?reposition_author=1;author_id={id};role={$role};old_position={$current_pos};new_position={$current_pos - 1};date={$date};title={$title}"
           title="{i18n/l/Reposition}">&lt;</a>
        <xsl:text> </xsl:text>
    </xsl:if>
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="{$i18n/l/Opens_in_new_window}">
        <xsl:call-template name="authorfullname"/>
    </a>
    <xsl:text> </xsl:text>
    <a href="{$xims_box}{$goxims_content}{$absolute_path}?remove_author_mapping=1;property={name()};property_id={id};role={$role};date={$date};title={$title}"
       title="{i18n_vlib/l/Delete_mapping}">(x)</a>
    <xsl:if test="position()!=last()">
        <xsl:text> </xsl:text>
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?reposition_author=1;author_id={id};role={$role};old_position={$current_pos};new_position={$current_pos + 1};date={$date};title={$title}"
           title="{i18n/l/Reposition}">&gt;</a>
        <xsl:text>, </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author">
    <xsl:variable name="path">
        <xsl:choose>
            <xsl:when test="$objtype='ReferenceLibrary'"><xsl:value-of select="$absolute_path"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$parent_path"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="role">
        <xsl:choose>
            <xsl:when test="name(..) = 'authorgroup'">0</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <a href="{$xims_box}{$goxims_content}{$path}?{concat(name(),'_id')}={id}" target="_blank" title="{$i18n/l/Opens_in_new_window}">
        <xsl:call-template name="authorfullname"/>
    </a>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="author" mode="fullname">
    <xsl:call-template name="authorfullname"/>
</xsl:template>

<xsl:template match="object/serial">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{concat(name(),'_id')}={@id}" target="_blank" title="{$i18n/l/Opens_in_new_window}">
        <xsl:value-of select="title"/>
    </a>
</xsl:template>

<xsl:template match="serial" mode="edit">
    <xsl:value-of select="title"/>
    <xsl:text> </xsl:text>
    <a href="{$xims_box}{$goxims_content}{$absolute_path}?remove_serial_mapping=1;serial_id={@id}"
       title="{i18n_vlib/l/Delete_mapping}">(x)</a>
</xsl:template>

<xsl:template match="vlauthors">
    <xsl:param name="svlauthor" select="'svlauthor'"/>
    <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="{$svlauthor}">
        <xsl:apply-templates select="/document/context/vlauthors/author">
            <xsl:sort select="translate(lastname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                      order="ascending"/>
        </xsl:apply-templates>
    </select>
</xsl:template>

<xsl:template match="vlauthors/author">
    <xsl:variable name="fullname"><xsl:call-template name="authorfullname"/></xsl:variable>
    <option value="{$fullname}"><xsl:value-of select="$fullname"/></option>
</xsl:template>

<xsl:template name="authorfullname">
    <xsl:value-of select="firstname"/><xsl:if test="middlename !=''"><xsl:text> </xsl:text><xsl:value-of select="middlename"/></xsl:if><xsl:text> </xsl:text><xsl:value-of select="lastname"/><xsl:if test="suffix !=''">, <xsl:value-of select="suffix"/></xsl:if>
</xsl:template>

<xsl:template match="vlserials">
    <xsl:param name="svlserial" select="'svlserial'"/>
    <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="{$svlserial}">
        <xsl:apply-templates select="/document/context/vlserials/serial">
            <xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                      order="ascending"/>
        </xsl:apply-templates>
    </select>
</xsl:template>

<xsl:template match="vlserials/serial">
    <option value="{title}"><xsl:value-of select="title"/></option>
</xsl:template>

<xsl:template name="th-size">
    <td></td>
</xsl:template>


<xsl:template name="tr-abstract">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Abstract"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Reflib.Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="5" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
                <xsl:apply-templates select="abstract"/>
            </textarea>
        </td>
    </tr>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:call-template name="title"/></title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
    </head>
</xsl:template>

<xsl:template name="cttobject.content_length"/>
<xsl:template name="cttobject.options.copy"/>
<xsl:template name="cttobject.options.move"/>

</xsl:stylesheet>
