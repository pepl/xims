<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:str="http://exslt.org/strings"
        xmlns:math="http://exslt.org/math"
        extension-element-prefixes="str math">

<xsl:import href="simpledb_common.xsl"/>

<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
<xsl:param name="property_id"/>
<xsl:param name="message" select="/document/context/session/message"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body onload="checkPropertyType(document.eform.sdbp_type)">
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-stylesheet-edit"/>
                    <xsl:call-template name="tr-pagerowlimit-edit"/>
                    <xsl:call-template name="markednew"/>
                    <tr>
                        <td colspan="3">
                            <div style="border: 1px solid black; padding: 5px;">
                                <table>
                                    <xsl:if test="$message != ''">
                                        <tr>
                                            <td colspan="2">
                                                <span class="message"><xsl:value-of select="$message"/></span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$property_id != ''">
                                            <tr>
                                                <td colspan="2">
                                                    <strong><xsl:value-of select="$i18n_simpledb/l/Edit_property"/><xsl:text> </xsl:text>'<xsl:value-of select="/document/member_properties/member_property[@id=$property_id]/name"/>'</strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <xsl:call-template name="tr-property_properties"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <input type="hidden" name="property_id" value="{$property_id}"/>
                                                    <input type="submit" name="update_property_mapping" value="{$i18n_simpledb/l/Save_changes}" class="control"/>
                                                    <input type="button" name="discard" value="{$i18n_simpledb/l/Stop_editing}" onclick="window.location.href='{$xims_box}{$goxims_content}{$absolute_path}?edit=1'; return true;" class="control"/>
                                                </td>
                                            </tr>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <tr>
                                                <td colspan="2">
                                                    <strong><xsl:value-of select="$i18n_simpledb/l/Create_property"/>:</strong>
                                                </td>
                                            </tr>
                                            <xsl:call-template name="tr-property_properties"/>
                                            <tr>
                                                <td colspan="2">
                                                    <input type="submit" name="create_property_mapping" value="{$i18n_simpledb/l/Create_property}" class="control" accesskey="c"/>
                                                </td>
                                            </tr>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:call-template name="tr-current_propertymappings"/>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-property_properties">
    <xsl:variable name="maxposition">
        <xsl:choose>
            <xsl:when test="/document/member_properties/member_property[1]">
                <xsl:value-of select="math:max(/document/member_properties/member_property/position)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Name"/></td>
        <td>
            <input id="sdbp_name" tabindex="50" type="text" name="sdbp_name" value="{/document/member_properties/member_property[@id=$property_id]/name}" size="40" class="text"/>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Type"/></td>
        <td>
            <xsl:choose>
                <xsl:when test="/document/member_properties/member_property[@id=$property_id]/type">
                    <input type="text" name="sdbp_type" value="{/document/member_properties/member_property[@id=$property_id]/type}" size="40" readonly="readonly" class="readonlytext"/>
                </xsl:when>
                <xsl:otherwise>
                    <select id="sdbp_type" tabindex="51" name="sdbp_type" onchange="checkPropertyType(this)">
                        <option value="string">String</option>
                        <option value="stringoptions">String options</option>
                        <option value="textarea">Textarea</option>
                        <option value="boolean">Boolean</option>
                        <option value="integer">Integer</option>
                        <option value="datetime">Datetime</option>
                        <option value="float">Float</option>
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
    <tr id="tr-regex">
        <xsl:if test="$property_id != '' and /document/member_properties/member_property[@id=$property_id]/type = 'stringoptions'">
            <xsl:attribute name="style">display: none</xsl:attribute>
        </xsl:if>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Regex"/></td>
        <td>
            <input id="sdbp_regex" tabindex="52" type="text" name="sdbp_regex" value="{/document/member_properties/member_property[@id=$property_id]/regex}" size="40" class="text"/>
        </td>
    </tr>
    <tr id="tr-stringoptions">
        <xsl:if test="$property_id = '' or /document/member_properties/member_property[@id=$property_id]/type != 'stringoptions'">
            <xsl:attribute name="style">display: none</xsl:attribute>
        </xsl:if>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/String_options"/></td>
        <td>
            <select id="sdbp_regex_select" name="sdbp_regex_select">
                <xsl:for-each select="str:split(substring-before(substring-after(/document/member_properties/member_property[@id=$property_id]/regex,'^('),')$'), '|')">
                    <option value="{.}"><xsl:value-of select="translate(.,'\','')"/></option>
                </xsl:for-each>
            </select>
            <xsl:text> </xsl:text>
            <input type="button" value="&lt;--" title="{$i18n_simpledb/l/Add_to_selection}" onclick="addSelection(sdbp_regex_add,sdbp_regex_select);" />
            <xsl:text> </xsl:text>
            <input id="sdbp_regex_add" tabindex="52" type="text" name="sdbp_regex_add" class="text" size="40" />
            <xsl:text> </xsl:text>
            <input type="button" value="{$i18n_simpledb/l/Remove_selected}" onclick="removeSelection(sdbp_regex_select);" />
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Description"/></td>
        <td>
            <textarea id="sdbp_description" tabindex="53" rows="3" cols="38" name="sdbp_description" class="text"><xsl:apply-templates select="/document/member_properties/member_property[@id=$property_id]/description"/></textarea>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Part_of_title"/></td>
        <td>
            <input id="sdbp_part_of_title" tabindex="53" type="checkbox" name="sdbp_part_of_title" value="1" size="40" class="text">
                <xsl:if test="/document/member_properties/member_property[@id=$property_id]/part_of_title = '1'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
            </input>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Mandatory"/></td>
        <td>
            <input id="sdbp_mandatory" tabindex="53" type="checkbox" name="sdbp_mandatory" value="1" size="40" class="text">
                <xsl:if test="/document/member_properties/member_property[@id=$property_id]/mandatory = '1'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
            </input>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/gopublic"/></td>
        <td>
            <input id="sdbp_gopublic" tabindex="53" type="checkbox" name="sdbp_gopublic" value="1" size="40" class="text">
                <xsl:if test="$property_id = '' or /document/member_properties/member_property[@id=$property_id]/gopublic = '1'">
                    <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
            </input>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/Position"/></td>
        <td>
            <xsl:choose>
                <xsl:when test="$property_id = ''">
                    <input id="sdbp_position" type="text" size="4" name="sdbp_position" readonly="readonly" class="readonlytext" value="{$maxposition+1}"/>
                </xsl:when>
                <xsl:otherwise>
                    <select id="sdbp_position" tabindex="54" name="sdbp_position" class="text">
                        <xsl:for-each select="/document/member_properties/member_property/position">
                            <option>
                                <xsl:if test=". = /document/member_properties/member_property[@id=$property_id]/position">
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="."/>
                            </option>
                        </xsl:for-each>
                    </select>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>

<xsl:template name="tr-current_propertymappings">
    <xsl:if test="/document/member_properties/member_property[1]">
        <tr>
            <td valign="top"><strong><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>:</strong></td>
            <td colspan="2">
                <ul style="margin-top: 0px">
                    <xsl:apply-templates select="/document/member_properties/member_property" mode="entry">
                        <xsl:sort select="position"
                              order="ascending" data-type="number"/>
                        <xsl:sort select="name"
                              order="ascending"/>
                    </xsl:apply-templates>
                </ul>
            </td>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="member_property" mode="entry">
    <li>
        <div style="white-space: nowrap">
            <xsl:value-of select="position"/>
            <xsl:text> </xsl:text>
            <xsl:choose>
                <xsl:when test="mandatory = 1 and part_of_title=1">
                    <strong><span class="compulsory"><xsl:value-of select="name"/></span></strong>
                </xsl:when>
                <xsl:when test="mandatory = 1">
                    <span class="compulsory"><xsl:value-of select="name"/></span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name"/>
                </xsl:otherwise>
            </xsl:choose>
            <table style="display: inline; vertical-align: text-bottom">
                <tr>
                    <td>
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?edit=1;property_id={@id}">
                            <img src="{$skimages}option_edit.png"
                                alt="{$l_Edit}"
                                title="{$l_Edit}"
                                name="eiedit{@id}"
                                width="32"
                                height="19"
                            />
                        </a>
                    </td>
                    <td>
                        <xsl:if test="/document/context/object/user_privileges/delete">
                            <xsl:text> </xsl:text>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?property_id={@id};delete_property_mapping=1" onclick="javascript:rv=confirm('{$i18n_simpledb/l/Sure_to_delete}'); if ( rv == true ) location.href='{$xims_box}{$goxims_content}{$absolute_path}?property_id={@id};delete_property_mapping=1'; return false;">
                                <input
                                    type="image"
                                    name="property_delete{@id}"
                                    src="{$skimages}option_delete.png"
                                    alt="{$l_delete}"
                                    title="{$l_delete}"
                                />
                            </a>
                        </xsl:if>
                    </td>
                </tr>
            </table>
        </div>
    </li>
</xsl:template>

<xsl:template name="tr-stylesheet-edit">
<xsl:variable name="parentid" select="parents/object[/document/context/object/@parent_id=@document_id]/@id"/>
<tr>
    <td valign="top"><xsl:value-of select="$i18n/l/Stylesheet"/></td>
    <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="{style_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=Folder;sbfield=eform.stylesheet')" class="doclink">Browse for Stylesheet directory</a>
    </td>
</tr>
</xsl:template>

<xsl:template name="tr-pagerowlimit-edit">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_simpledb/l/PageRowLimit"/></td>
        <td colspan="2">
            <input tabindex="35" type="text" name="pagerowlimit" size="2" maxlength="2" value="{attributes/pagerowlimit}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PageRowLimit')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
