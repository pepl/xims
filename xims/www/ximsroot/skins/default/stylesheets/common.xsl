<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../../../stylesheets/common.xsl"/>
<xsl:import href="common_footer.xsl"/>
<xsl:import href="common_header.xsl"/>
<xsl:import href="common_metadata.xsl"/>
<xsl:import href="common_localized.xsl"/>
<xsl:import href="common_jscalendar_scripts.xsl"/>
<xsl:import href="common_htmlarea_scripts.xsl"/>

<xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>

<xsl:variable name="currobjmime" select="/document/data_formats/data_format[@id=/document/context/object/data_format_id]/mime_type"/>

<!-- save those strings in variables as they are called per object in object/children -->
<!-- cttobject.options -->
<xsl:variable name="l_Edit" select="$i18n/l/Edit"/>
<xsl:variable name="l_Move" select="$i18n/l/Move"/>
<xsl:variable name="l_Copy" select="$i18n/l/Copy"/>
<xsl:variable name="l_Publishing_options" select="$i18n/l/Publishing_options"/>
<xsl:variable name="l_Access_control" select="$i18n/l/Access_control"/>
<xsl:variable name="l_Undelete" select="$i18n/l/Undelete"/>
<xsl:variable name="l_purge" select="$i18n/l/purge"/>
<xsl:variable name="l_delete" select="$i18n/l/delete"/>
<!-- cttobject.status -->
<xsl:variable name="l_Object_marked_new" select="$i18n/l/Object_marked_new"/>
<xsl:variable name="l_New" select="$i18n/l/New"/>
<xsl:variable name="l_Published" select="$i18n/l/Published"/>
<xsl:variable name="l_Object_last_published" select="$i18n/l/Object_last_published"/>
<xsl:variable name="l_by" select="$i18n/l/by"/>
<xsl:variable name="l_at_place" select="$i18n/l/at_place"/>
<xsl:variable name="l_Object_modified" select="$i18n/l/Object_modified"/>
<xsl:variable name="l_at_time" select="$i18n/l/at_time"/>
<xsl:variable name="l_changed" select="$i18n/l/changed"/>
<xsl:variable name="l_Unlock" select="$i18n/l/Unlock"/>
<xsl:variable name="l_Release_lock" select="$i18n/l/Release_lock"/>
<xsl:variable name="l_Locked" select="$i18n/l/Locked"/>
<xsl:variable name="l_Object_locked" select="$i18n/l/Object_locked"/>

<xsl:template name="cancelaction">
    <table border="0" align="center" width="98%">
        <tr>
            <td>
                <xsl:call-template name="cancelcreateform"/>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="canceledit">
    <table border="0" align="center" width="98%">
    <tr>
        <td>
            <xsl:call-template name="cancelform"/>
        </td>
    </tr>
    </table>
</xsl:template>

<xsl:template name="cancelform">
    <xsl:param name="with_save" select="'no'"/>
    <!-- method GET is needed, because goxims does not handle a PUTed 'id' -->
    <form action="{$xims_box}{$goxims_content}" name="cform" method="GET" style="margin-top:0px; margin-bottom:0px; margin-left:-5px; margin-right:0px;">
        <input type="hidden" name="id" value="{@id}"/>
        <xsl:if test="$with_save = 'yes'">
            <xsl:call-template name="save_jsbutton"/>
        </xsl:if>
        <xsl:call-template name="rbacknav"/>
        <input type="submit" name="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C"/>
    </form>
</xsl:template>

<xsl:template name="cancelcreateform">
    <xsl:param name="with_save" select="'no'"/>
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST">
        <xsl:if test="$with_save = 'yes'">
            <xsl:call-template name="save_jsbutton"/>
        </xsl:if>
        <xsl:call-template name="rbacknav"/>
        <input type="submit" name="cancel_create" value="{$i18n/l/cancel}" class="control" accesskey="C"/>
    </form>
</xsl:template>

<xsl:template name="save_jsbutton">
    <script type="text/javascript">
       document.write('<input type="submit" name="submit_eform" value="{$i18n/l/save}" onClick="document.eform.store.click(); return false" class="control"/>');
    </script>
</xsl:template>

<xsl:template name="exitredirectform">
    <xsl:variable name="object_type_id" select="object_type_id"/>
    <xsl:variable name="parent_id" select="@parent_id"/>
    <form name="userConfirm" action="{$xims_box}{$goxims_content}" method="GET">
        <input class="control" name="exit" type="submit" value="Done"/>
        <xsl:choose>
            <xsl:when test="$r != ''">
                <input name="id" type="hidden" value="{$r}"/>
                <input name="page" type="hidden" value="{$page}"/>
                <input name="sb" type="hidden" value="{$sb}"/>
                <input name="order" type="hidden" value="{$order}"/>
            </xsl:when>
            <xsl:otherwise>
                <input name="id" type="hidden">
                    <xsl:choose>
                        <xsl:when test="/document/object_types/object_type[@id=$object_type_id]/redir_to_self='0'">
                            <xsl:attribute name="value"><xsl:value-of select="parents/object[@document_id=$parent_id]/@id"/></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </input>
            </xsl:otherwise>
        </xsl:choose>
    </form>
</xsl:template>

<xsl:template name="saveaction">
    <input type="hidden" name="id" value="{/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}"/>
    <xsl:if test="/document/object_types/object_type[name=$objtype]/redir_to_self='0'">
        <input name="sb" type="hidden" value="date"/>
        <input name="order" type="hidden" value="desc"/>
    </xsl:if>
    <input type="submit" name="store" value="{$i18n/l/save}" class="control" accesskey="S"/>
</xsl:template>

<xsl:template name="saveedit">
    <input type="hidden" name="id" value="{@id}"/>
    <xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
        <input name="sb" type="hidden" value="date"/>
        <input name="order" type="hidden" value="desc"/>
    </xsl:if>
    <input type="submit" name="store" value="{$i18n/l/save}" class="control" accesskey="S"/>
</xsl:template>

<xsl:template name="grantowneronly">
    <tr>
        <td valign="top" width="135"><xsl:value-of select="$i18n/l/Priv_grant_options"/></td>
        <td valign="top">
            <input name="owneronly" type="radio" value="false" checked="checked"/><xsl:value-of select="$i18n/l/Copy_parent_privs"/>
            <input name="owneronly" type="radio" value="true" onClick="document.eform.defaultroles.disabled = true;" onBlur="document.eform.defaultroles.disabled = false;"/><xsl:value-of select="$i18n/l/Grant_myself_only"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PrivilegeGrantOptions')" class="doclink">(?)</a>
            <div><xsl:text>&#160;&#160;</xsl:text><xsl:value-of select="$i18n/l/Grant_default_roles"/>: <input name="defaultroles" type="checkbox" value="true"/></div>
        </td>
    </tr>
</xsl:template>

<xsl:template name="markednew">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n/l/Mark_new"/>
            <input name="markednew" type="radio" value="true">
              <xsl:if test="marked_new = '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/Yes"/>
            <input name="markednew" type="radio" value="false">
              <xsl:if test="marked_new != '1'">
                <xsl:attribute name="checked">checked</xsl:attribute>
              </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('markednew')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="expandrefs">
<!-- Temporarily disabled until implemented by the application class
    <tr>
        <td colspan="3">
        <xsl:value-of select="$i18n/l/Publish_ref_objects"/>:
        <input name="expandrefs" type="radio" value="true">
          <xsl:if test="attributes/expandrefs = '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/Yes"/>
        <input name="expandrefs" type="radio" value="false">
          <xsl:if test="attributes/expandrefs != '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/No"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('expandrefs')" class="doclink">(?)</a>
        </td>
    </tr>
-->
</xsl:template>

<xsl:template name="common-head">
<!-- param mode to set the HTML title -->
    <xsl:param name="mode">create</xsl:param>
<!-- with the following parameters different options can be integratetd into the HTML HEAD 
    currently available:
        calendar: Integration of jscalendar (not included in xims, install seperately)
        htmlarea: Integration of the WYSIWYG Editor Htmlarea included in xims-contrib
-->
    <xsl:param name="calendar" select="false()" />
    <xsl:param name="htmlarea" select="false()" />
    <head>
        <title>
        <xsl:if test="$mode='create'"><xsl:value-of select="$i18n/l/create"/></xsl:if>
        <xsl:if test="$mode='edit'"><xsl:value-of select="$i18n/l/edit"/></xsl:if>        
        &#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS </title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:if test="$calendar">
            <xsl:call-template name="jscalendar_scripts" />
        </xsl:if>
        <xsl:if test="$htmlarea">
            <xsl:call-template name="htmlarea_scripts"/>
        </xsl:if>
    </head>
</xsl:template>

<xsl:template name="head-create">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS </title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>

<xsl:template name="head-edit">
    <head>
        <title><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>


<xsl:template name="table-create">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                <xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/>
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
                <xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/>
            </td>
            <td align="right" valign="top">
                <xsl:call-template name="cancelform">
                    <xsl:with-param name="with_save">yes</xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="tr-locationtitle-create">
    <xsl:call-template name="tr-location-create"/>
    <xsl:call-template name="tr-title-create"/>
</xsl:template>

<xsl:template name="tr-locationtitle-edit">
    <xsl:call-template name="tr-location-edit"/>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>

<xsl:template name="tr-location-create">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
        </td>
        <td>
            <input tabindex="10" type="text" name="name" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            <xsl:call-template name="marked_mandatory"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-location-edit">
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:variable name="publish_gopublic">
        <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
    </xsl:variable>
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
        </td>
        <td>
            <input tabindex="10" type="text" name="name" size="40" value="{location}">
                <xsl:choose>
                    <xsl:when test="$publish_gopublic = '0' and published = '1'">
                        <xsl:attribute name="readonly">readonly</xsl:attribute>
                        <xsl:attribute name="class">readonlytext</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">text</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            <xsl:call-template name="marked_mandatory"/>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-title-create">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Title"/></td>
        <td colspan="2">
            <input tabindex="20" type="text" name="title" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-title-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Title"/></td>
        <td colspan="2">
            <input tabindex="20" type="text" name="title" size="60" value="{title}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-locationtitle-edit_xml">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
        </td>
        <td>
            <!-- strip the suffix -->
            <input tabindex="10" type="text" class="text" name="name" size="40"
                        value="{substring-before(location, concat('.', /document/data_formats/data_format
                         [@id=/document/context/object/data_format_id]/suffix))}"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            <xsl:call-template name="marked_mandatory"/>
        </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>

<xsl:template name="tr-bodyfromfile-create">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/bodyfromfile_create"/></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('BodyFile')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-bodyfromfile-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/bodyfromfile_edit"/></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('BodyFile')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="jsorigbody">
    <script type="text/javascript">
        var origbody = document.getElementById('body').value;
    </script>
</xsl:template>

<xsl:template name="tr-body-create">
    <xsl:param name="with_origbody" select="'no'"/>
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>

            <xsl:call-template name="textarearesize_js_css"/>
            <div id="bodymain">
                <div id="bodycon">
                    <textarea tabindex="30" name="body" id="body" rows="15" cols="90">&#160;</textarea>
                    <!-- TOP DRAG BAR -->
                    <div id="T" class="brd"></div>
                    <!-- LEFT DRAG BAR -->
                    <div id="L" class="brd"></div>
                    <!-- BOTTOM DRAG BAR -->
                    <div id="B" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                    <div id="BR" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                    <!-- RIGHT DRAG BAR -->
                    <!-- When ID "R" is used here, MSIE won't scale the right drag bar correctly, using "U" therefore -->
                    <div id="U" class="brd edg v" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                    <div id="UB" class="brd edg nw" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                </div>
            </div>

            <xsl:if test="$with_origbody = 'yes'">
                <xsl:call-template name="jsorigbody"/>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-body-edit">
    <xsl:param name="with_origbody" select="'no'"/>
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>

            <xsl:call-template name="textarearesize_js_css"/>
            <div id="bodymain">
                <div id="bodycon">
                    <textarea tabindex="30" name="body" id="body" rows="15" cols="90" >
                        <xsl:choose>
                            <xsl:when test="string-length(body) &gt; 0">
                                <xsl:apply-templates select="body"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </textarea>
                    <!-- TOP DRAG BAR -->
                    <div id="T" class="brd"></div>
                    <!-- LEFT DRAG BAR -->
                    <div id="L" class="brd"></div>
                    <!-- BOTTOM DRAG BAR -->
                    <div id="B" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                    <div id="BR" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                    <!-- RIGHT DRAG BAR -->
                    <!-- When ID "R" is used here, MSIE won't scale the right drag bar correctly, using "U" therefore -->
                    <div id="U" class="brd edg v" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                    <div id="UB" class="brd edg nw" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
                </div>
            </div>

            <xsl:if test="$with_origbody = 'yes'">
                <xsl:call-template name="jsorigbody"/>
            </xsl:if>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-keywords-create">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Keywords"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="keywords" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
        </td>
        </tr>
</xsl:template>

<xsl:template name="tr-keywords-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Keywords"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="keywords" size="60" value="{keywords}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<!-- Legacy -->
<xsl:template name="tr-abstract-create">
    <xsl:call-template name="tr-abstract-edit"/>
</xsl:template>

<xsl:template name="tr-abstract-edit">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Abstract"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
                <xsl:apply-templates select="abstract"/>
            </textarea>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-notes">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Notes"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Notes')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="notes" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
                <xsl:apply-templates select="notes"/>
            </textarea>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-stylesheet-create">
<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/Stylesheet"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet')" class="doclink"><xsl:value-of select="$i18n/l/Browse_stylesheet"/></a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-stylesheet-edit">
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/Stylesheet"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="{style_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet')" class="doclink"><xsl:value-of select="$i18n/l/Browse_stylesheet"/></a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-css-create">
<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/CSS"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="css" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('CSS')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=CSS;sbfield=eform.css')" class="doclink"><xsl:value-of select="$i18n/l/Browse_css"/></a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-css-edit">
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/CSS"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="css" size="40" value="{css_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('CSS')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=CSS;sbfield=eform.css')" class="doclink"><xsl:value-of select="$i18n/l/Browse_css"/></a>
    </td>
</tr>
</xsl:template>

<xsl:template name="jscalendar-selector">
    <xsl:param name="timestamp_string"/>
    <xsl:param name="formfield_id"/>
    <xsl:param name="default_value" select="'creation_timestamp'"/>

    <input tabindex="40" type="hidden" name="{$formfield_id}" id="{$formfield_id}">
        <xsl:attribute name="value">
            <xsl:value-of select="$timestamp_string"/>
        </xsl:attribute>
    </input>
    <span id="show_vft{$formfield_id}"><xsl:value-of select="$timestamp_string"/></span>
    <xsl:text>&#160;</xsl:text>
    <img
      src="{$skimages}calendar.gif"
      id="f_trigger_vft{$formfield_id}"
      style="cursor: pointer;"
      alt="{$i18n/l/Date_selector}"
      title="{$i18n/l/Date_selector}"
      onmouseover="this.style.background='red';"
      onmouseout="this.style.background=''"
    />
    <script type="text/javascript">
        var current_datestring = "<xsl:value-of select="$timestamp_string"/>";
        var current_date;
        if ( current_datestring.length > 0 ) {
            current_date = Date.parseDate(current_datestring, "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = current_date;
        }
        else {
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = "<xsl:choose><xsl:when test="default_value='creation_timestamp'"><xsl:value-of select="$i18n/l/Valid_from_default_creation_timestamp"/></xsl:when><xsl:otherwise><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:otherwise></xsl:choose>"
        }
        Calendar.setup({
            inputField     :    "<xsl:value-of select="$formfield_id"/>",
            ifFormat       :    "%Y-%m-%d %H:%M",
            displayArea    :    "show_vft<xsl:value-of select="$formfield_id"/>",
            daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
            button         :    "f_trigger_vft<xsl:value-of select="$formfield_id"/>",
            align          :    "Tl",
            singleClick    :    true,
            showsTime      :    true,
            timeFormat     :    "24"
        });
    </script>
</xsl:template>

<xsl:template name="tr-valid_from">
    <xsl:variable name="valid_from_timestamp_tmp">
        <xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>
    </xsl:variable>
    <xsl:variable name="valid_from_timestamp">
        <xsl:if test="$valid_from_timestamp_tmp != '-- :'">
            <xsl:value-of select="$valid_from_timestamp_tmp"/>
        </xsl:if>
    </xsl:variable>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Valid_from"/></td>
        <td colspan="2">
            <xsl:call-template name="jscalendar-selector">
                <xsl:with-param name="timestamp_string" select="$valid_from_timestamp"/>
                <xsl:with-param name="formfield_id" select="'valid_from_timestamp'"/>
            </xsl:call-template>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Valid_from')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-valid_to">
    <xsl:variable name="valid_to_timestamp_tmp">
        <xsl:apply-templates select="valid_to_timestamp" mode="ISO8601-MinNoT"/>
    </xsl:variable>
    <xsl:variable name="valid_to_timestamp">
        <xsl:if test="$valid_to_timestamp_tmp != '-- :'">
            <xsl:value-of select="$valid_to_timestamp_tmp"/>
        </xsl:if>
    </xsl:variable>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Valid_to"/></td>
        <td colspan="2">
            <xsl:call-template name="jscalendar-selector">
                <xsl:with-param name="timestamp_string" select="$valid_to_timestamp"/>
                <xsl:with-param name="formfield_id" select="'valid_to_timestamp'"/>
            </xsl:call-template>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Valid_to')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="cttobject.status">
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:variable name="publish_gopublic">
        <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
    </xsl:variable>
    <xsl:variable name="published_path_base">
        <xsl:choose>
            <xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
                <xsl:value-of select="$absolute_path_nosite"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$absolute_path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="object_path">
        <xsl:choose>
            <xsl:when test="local-name(..) = 'children'">
                <xsl:value-of select="concat($published_path_base,'/',location)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$published_path_base"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="published_path">
        <xsl:choose>
            <xsl:when test="$publish_gopublic = 0">
                <xsl:value-of select="concat($publishingroot,$object_path)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($gopublic_content,$object_path)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:choose>
        <xsl:when test="marked_new= '1'">
            <img src="{$sklangimages}status_markednew.png"
                    border="0"
                    width="26"
                    height="19"
                    title="{$l_Object_marked_new}"
                    alt="{$l_New}"
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
            <a href="{$published_path}" target="_blank">
                <img
                    border="0"
                    width="26"
                    height="19"
                    alt="{$l_Published}"
                >
                    <xsl:choose>
                        <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                            <xsl:attribute name="title"><xsl:value-of select="$l_Object_last_published"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$l_at_place"/>&#160;<xsl:value-of select="$published_path"/></xsl:attribute>
                            <xsl:attribute name="src"><xsl:value-of select="$skimages"/>status_pub.png</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="title"><xsl:value-of select="$l_Object_modified"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$l_at_time"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$l_changed"/>.</xsl:attribute>
                            <xsl:attribute name="src"><xsl:value-of select="$skimages"/>status_pub_async.png</xsl:attribute>
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
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',@id,';cancel=1;r=',/document/context/object/@id)"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';page=',$page)"/></xsl:if>
                    <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}status_locked.png"
                        width="26"
                        height="19"
                        border="0"
                        alt="{$l_Unlock}"
                        title="{$l_Release_lock}."
                />
            </a>
        </xsl:when>
        <xsl:when test="locked_by_id != '' and locked_time != ''">
            <img src="{$skimages}status_locked.png"
                    width="26"
                    height="19"
                    border="0"
                    alt="{$l_Locked}"
            >
                <xsl:attribute name="title"><xsl:value-of select="$l_Object_locked"/> <xsl:apply-templates select="locked_time" mode="datetime"/> <xsl:value-of select="$l_by"/> <xsl:call-template name="lockerfullname"/>.</xsl:attribute>
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

<xsl:template name="cttobject.options">
    <xsl:call-template name="cttobject.options.edit"/>
    <xsl:call-template name="cttobject.options.copy"/>
    <xsl:call-template name="cttobject.options.move"/>
    <xsl:call-template name="cttobject.options.publish"/>
    <xsl:call-template name="cttobject.options.acl_or_undelete"/>
    <xsl:call-template name="cttobject.options.purge_or_delete"/>
</xsl:template>

<xsl:template name="cttobject.options.edit">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="marked_deleted != '1' and user_privileges/write and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',$id,';edit=1')"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}option_edit.png"
                    alt="{$l_Edit}"
                    title="{$l_Edit}"
                    border="0"
                    onmouseover="pass('edit{$id}','edit','h'); return true;"
                    onmouseout="pass('edit{$id}','edit','c'); return true;"
                    onmousedown="pass('edit{$id}','edit','s'); return true;"
                    onmouseup="pass('edit{$id}','edit','s'); return true;"
                    name="edit{$id}"
                    width="32"
                    height="19"
                />
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cttobject.options.copy">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="marked_deleted != '1' and user_privileges/copy and /document/context/object/user_privileges/create">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',$id,';copy=1')"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}option_copy.png"
                    alt="{$l_Copy}"
                    title="{$l_Copy}"
                    border="0"
                    name="copy{$id}"
                    width="32"
                    height="19"
                />
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cttobject.options.move">
    <xsl:variable name="parentid" select="@parent_id"/>
    <xsl:variable name="id" select="@id"/>
    <xsl:variable name="to">
        <xsl:choose>
            <xsl:when test="$currobjmime='application/x-container'">
                <xsl:value-of select="/document/context/object/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="/document/context/object/parents/object[@document_id=$parentid]/@id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="marked_deleted != '1' and user_privileges/move and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',$id,';move_browse=1;to=',$to)"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}option_move.png"
                    alt="{$l_Move}"
                    title="{$l_Move}"
                    border="0"
                    onmouseover="pass('move{$id}','move','h'); return true;"
                    onmouseout="pass('move{$id}','move','c'); return true;"
                    onmousedown="pass('move{$id}','move','s'); return true;"
                    onmouseup="pass('move{$id}','move','s'); return true;"
                    name="move{$id}"
                    width="32"
                    height="19"
                />
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cttobject.options.publish">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="marked_deleted != '1' and (user_privileges/publish|user_privileges/publish_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id) ">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',$id,';publish_prompt=1')"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}option_pub.png"
                    border="0"
                    alt="{$l_Publishing_options}"
                    title="{$l_Publishing_options}"
                    name="publish{$id}"
                    width="32"
                    height="19"
                />
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cttobject.options.acl_or_undelete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="marked_deleted != '1' and (user_privileges/grant|user_privileges/grant_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1')"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}option_acl.png"
                    border="0"
                    alt="{$l_Access_control}"
                    title="{$l_Access_control}"
                    name="acl{$id}"
                    width="32"
                    height="19"
                />
            </a>
        </xsl:when>
        <xsl:when test="user_privileges/delete and marked_deleted = '1'">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($goxims_content,'?id=',$id,';undelete=1')"/>
                    <xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if>
                </xsl:attribute>
                <img src="{$skimages}option_undelete.png"
                    border="0"
                    alt="{$l_Undelete}"
                    title="{$l_Undelete}"
                    name="undelete{$id}"
                    width="32"
                    height="19"
                />
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cttobject.options.purge_or_delete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="user_privileges/delete and marked_deleted = '1'">
            <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
            <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
            <form style="margin:0px; display: inline;" name="delete"
                    method="GET"
                    action="{$xims_box}{$goxims_content}">
                <input type="hidden" name="delete_prompt" value="1"/>
                <input type="hidden" name="id" value="{$id}"/>
                <xsl:if test="$currobjmime='application/x-container'">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="page" type="hidden" value="{$page}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                    <input name="hd" type="hidden" value="{$hd}"/>
                    <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                </xsl:if>
                <input
                    type="image"
                    name="delete{$id}"
                    src="{$skimages}option_purge.png"
                    border="0"
                    width="37"
                    height="19"
                    alt="{$l_purge}"
                    title="{$l_purge}"
                />
            </form>
        </xsl:when>
        <xsl:when test="user_privileges/delete and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
            <form style="margin:0px; display: inline;" name="trashcan"
                    method="GET"
                    action="{$xims_box}{$goxims_content}">
                <input type="hidden" name="trashcan_prompt" value="1"/>
                <input type="hidden" name="id" value="{$id}"/>
                <xsl:if test="$currobjmime='application/x-container'">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="page" type="hidden" value="{$page}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                    <input name="hd" type="hidden" value="{$hd}"/>
                    <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                </xsl:if>
                <input
                    type="image"
                    name="delete{$id}"
                    src="{$skimages}option_delete.png"
                    border="0"
                    width="37"
                    height="19"
                    alt="{$l_delete}"
                    title="{$l_delete}"
                />
            </form>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cttobject.options.spacer">
    <img src="{$ximsroot}images/spacer_white.gif"
        width="32"
        height="19"
        border="0"
        alt=" "
    />
</xsl:template>

<xsl:template name="toggle_hls">
    <xsl:if test="$hls != ''">
        <div id="toggle_highlight">
            <form>
                <xsl:value-of select="$i18n/l/you_searched_for"/> '<xsl:value-of select="$hls"/>'.
                <input type="button" value="{$i18n/l/toggle_hls}" onClick="toggleHighlight(getParamValue('hls'))"/>
            </form>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="textarearesize_js_css">
    <script type="text/javascript">
    /*
     * The following code is based on the discussion thread available at
     * http://www.webdeveloper.com/forum/showthread.php?t=64005
     *
    */

    var l=0;
    var t=0;
    var w=748;
    var h=260;
    var minw=w;
    var minh=h;

    var dragon=false;
    var dragsrc=null;
    var ox=0;
    var oy=0;
    var dx=0;
    var dy=0;

    var nw=0;
    var nh=0;
    var nt=0;
    var nl=0;

    function repositionAll() {
      nl=l;
      nt=t;
      nw=w;
      nh=h;
      if(dragsrc.id.indexOf("U")&gt;=0) {
        //move the right
        if((nw+dx)&gt;minw) nw+=dx;
        else nw=minw;
      }
      if(dragsrc.id.indexOf("B")&gt;=0) {
        //move the bottom
        if((nh+dy)&gt;minh) nh+=dy;
        else nh=minh;
      }
      if(nw&lt;minw) { nl=l+w-minw; nw=minw; }
      if(nh&lt;minh) { nt=t+h-minh; nh=minh; }
      window.status="("+(nl)+", "+(nt)+") ["+(nw)+"X"+(nh)+"]";
      document.getElementById("bodycon").style.width=nw+"px";
      document.getElementById("bodycon").style.height=nh+"px";

      document.getElementById("L").style.height=(nh-40)+"px";
      document.getElementById("T").style.width=(nw-40)+"px";
      document.getElementById("U").style.height=(nh-40)+"px";
      document.getElementById("B").style.width=(nw-40)+"px";


      document.getElementById("body").style.width=(nw-8)+"px";
      document.getElementById("body").style.height=(nh-8)+"px";
    }

    function MD(event, src) {
      if(event==null) event=window.event;
      dragon=true;
      dragsrc=src;
      ox=parseInt(event.clientX);
      oy=parseInt(event.clientY);
    }

    function MM(event) {
      if(!dragon) return;
      if(event==null) event=window.event;
      dx=parseInt(event.clientX)-ox;
      dy=parseInt(event.clientY)-oy;
      repositionAll();
      return false;
    }

    function MU(event, src) {
      w=nw;
      h=nh;
      t=nt;
      l=nl;
      if(event==null) event=window.event;
      dragon=false;
      dragsrc=null;
      window.status="";
    }

    document.onmousemove=MM;
    document.onmouseup=MU;
    document.ondrag=function() { return false; }
    </script>
    <style type="text/css">
    #bodymain {
      position:relative;
      display:block;
    }

    #bodycon {
      position:relative;
      top:0px;
      left:0px;
      width:748px;
      height:260px;
    }
    /* *** TOP DRAG BAR *** */
    #T {
      top:0px;
      left:20px;
      width:728px;
      height:4px;
    }
    /* *** LEFT DRAG BAR *** */
    #L {
      top:20px;
      left:0px;
      width:4px;
      height:240px;
    }
    /* *** BOTTOM DRAG BAR *** */
    #B {
      bottom:0px;
      left:20px;
      width:728px;
      height:4px;
    }
    #BR {
      bottom:0px;
      right:0px;
      width:20px;
      height:4px;
    }
    /* *** RIGHT DRAG BAR *** */
    #U {
      top:20px;
      right:0px;
      width:4px;
      height:240px;
    }
    #UB {
      bottom:0px;
      right:0px;
      width:4px;
      height:20px;
    }

    .brd {
      position:absolute;
      font-size: 1px; /* for MSIE */
    }

    .edg {
      background-color:#aaaaaa;
    }

    .v {
      cursor:w-resize;
    }

    .h {
      cursor:n-resize;
    }

    .nw {
      cursor:nw-resize;
    }

    #body {
      position:relative;
      top:0px;
      left:0px;
      margin:4px;
      width:740px;
      height:252px;
      border: 1px solid black;
      background-color:#ffffff;
      overflow:auto;
      font-family: 'Courier New','Verdana';
      font-size: 10pt;
    }
    </style>
</xsl:template>

<xsl:template name="testbodysxml">
    <xsl:call-template name="wfcheckjs"/>
    <a href="javascript:void()" onclick="return wfcheck();">
        <img src="{$skimages}option_wfcheck.png"
             border="0"
             alt="{$i18n/l/Test_body_xml}"
             title="{$i18n/l/Test_body_xml}"
             align="left"
             width="32"
             height="19"
        />
    </a>
</xsl:template>

<xsl:template name="prettyprint">
    <xsl:param name="ppmethod" select="'htmltidy'"/>

    <xsl:call-template name="prettyprintjs">
        <xsl:with-param name="ppmethod" select="$ppmethod"/>
    </xsl:call-template>

    <a href="javascript:void()" onclick="return prettyprint();">
        <img src="{$skimages}option_prettyprint.png"
             border="0"
             alt="{$i18n/l/Prettyprint}"
             title="{$i18n/l/Prettyprint}"
             align="left"
             width="32"
             height="19"
        />
    </a>
</xsl:template>

<xsl:template name="xmlhttpjs">
    var xmlhttp=false;
    /*@cc_on @*/
    /*@if (@_jscript_version &gt;= 5)
    // JScript gives us Conditional compilation, we can cope with old IE versions.
    // and security blocked creation of the objects.
    try {
        xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
    }
    catch (e) {
        try {
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        catch (E) {
            xmlhttp = false;
        }
    }
    @end @*/
    if (!xmlhttp &amp;&amp; typeof XMLHttpRequest!='undefined') {
      xmlhttp = new XMLHttpRequest();
    }
</xsl:template>

<xsl:template name="wfcheckjs">
    <script type="text/javascript">
        <xsl:call-template name="xmlhttpjs"/>

        function wfcheck() {
            var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?test_wellformedness=1')"/>";
            xmlhttp.open("POST",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not check well-formedness.")
                    }
                    else {
                        alert(xmlhttp.responseText + '\n');
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('test_wellformedness=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
    </script>
</xsl:template>

<xsl:template name="prettyprintjs">
    <xsl:param name="ppmethod" select="'htmltidy'"/>

    <script type="text/javascript">
        <xsl:call-template name="xmlhttpjs"/>

        function prettyprint() {
            var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?', $ppmethod, '=1')"/>";
            xmlhttp.open("POST",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not pretty print.")
                    }
                    else {
                        document.eform.body.value=xmlhttp.responseText;
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('<xsl:value-of select="$ppmethod"/>=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
    </script>
</xsl:template>

</xsl:stylesheet>
