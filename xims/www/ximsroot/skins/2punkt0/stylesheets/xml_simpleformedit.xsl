<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xml_simpleformedit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:r="http://relaxng.org/ns/structure/1.0"
        xmlns:s="http://xims.info/ns/xmlsimpleformedit"
        xmlns:dyn="http://exslt.org/dynamic"
        extension-element-prefixes="dyn"
        xmlns:exslt="http://exslt.org/common"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="../../../stylesheets/common.xsl"/>
<xsl:import href="edit_common.xsl"/>
<!--<xsl:import href="common_jscalendar_scripts.xsl"/>-->

<xsl:param name="eid"/>
<xsl:param name="message" select="/document/context/session/message"/>

<xsl:variable name="schema_path">http://www.uibk.ac.at/test/neuertest1/xml-schema.xml
    <!--<xsl:choose>
        <xsl:when test="contains($publishingroot,':')">
            <xsl:value-of select="concat($publishingroot,'/',substring-after(substring-after(/document/context/object/schema_id,'/'),'/'))"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat($xims_box,'/ximspubroot',/document/context/object/schema_id)"/>
        </xsl:otherwise>
    </xsl:choose>-->
</xsl:variable>

<xsl:variable name="schema" select="document($schema_path)"/>
<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:variable name="currentdatetime"><xsl:apply-templates select="/document/context/session/date" mode="ISO8601-MinNoT"/></xsl:variable>
<xsl:variable name="entry_element" select="$schema/r:grammar/r:start/r:element/r:oneOrMore/r:element/@name"/>
<xsl:variable name="description_element"><xsl:for-each select="$schema/r:grammar/r:start/r:element/r:oneOrMore/r:element/r:element[s:description/@show='1']"><xsl:value-of select="@name"/><xsl:if test="position()!=last()">|</xsl:if></xsl:for-each></xsl:variable>

<xsl:variable name="entry_set">
    <xsl:variable name="entry_element_xpath" select="concat('//',$entry_element)"/>
    <xsl:for-each select="dyn:evaluate($entry_element_xpath)">
        <xsl:copy>
            <xsl:copy-of select="@*|*"/>
        </xsl:copy>
    </xsl:for-each>
</xsl:variable>

<xsl:template name="edit-content" >
<!--<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">-->
                    <xsl:call-template name="form-locationtitle-edit_xml"/>
					<xsl:call-template name="form-marknew-pubonsave"/>
                    <!--<xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>-->
                    <div class="form-div block">
                            <div style="border: 1px solid black; padding: 5px;">
                                <table>
                                    <xsl:if test="$message != ''">
                                        <tr>
                                            <td>
                                                <span class="message"><xsl:value-of select="$message"/></span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="$eid != ''">
                                            <tr>
                                                <td colspan="2">
                                                    <strong><xsl:value-of select="$i18n_xml/l/Edit_entry"/><xsl:text> </xsl:text><xsl:value-of select="$eid"/></strong>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <xsl:apply-templates select="$schema/r:grammar/r:start/r:element/r:oneOrMore/r:element/*" mode="eid"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <input type="hidden" name="eid" value="{$eid}"/>
                                                    <input type="hidden" name="seid" value="1"/>
                                                    <input type="submit" name="simpleformedit" value="{$i18n_xml/l/Save_changes}" class="control"/>
                                                    <input type="button" name="discard" value="{$i18n_xml/l/Stop_editing}" onclick="window.location.href='{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1'; return true;" class="control"/>
                                                </td>
                                            </tr>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <tr>
                                                <td colspan="2">
                                                    <strong><xsl:value-of select="$i18n_xml/l/Create_entry"/></strong>
                                                </td>
                                            </tr>
                                            <xsl:apply-templates select="$schema/r:grammar/r:start/r:element/r:oneOrMore/r:element/*"/>
                                            <tr>
                                                <td colspan="2">
                                                    <input type="hidden" name="seid" value="1"/>
                                                    <input type="submit" name="simpleformedit" value="{$i18n_xml/l/Create_entry}" class="control" accesskey="c"/>
                                                </td>
                                            </tr>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <tr>
                                        <td colspan="2">
                                            <strong><xsl:value-of select="$i18n_xml/l/Existing_entries"/></strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <ul style="margin-top: 0px">
                                                <xsl:apply-templates select="body/*/*" mode="entry"/>
                                            </ul>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <input type="submit" name="edit" value="{$i18n_xml/l/Edit_XML_source}" class="control"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                    </div>
					
		<xsl:call-template name="form-keywordabstract"/>

<!--
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>-->
</xsl:template>

<xsl:template match="/document/context/object/body//*">
    <xsl:element name="{name(.)}">
        <xsl:for-each select="@*">
            <xsl:attribute name="{name(.)}">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </xsl:for-each>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="body/*/*" mode="entry">
    <xsl:variable name="maxelements">
        <xsl:value-of select="dyn:evaluate(concat('count(//',$entry_element,')'))" />
    </xsl:variable>

    <xsl:if test="name(.) = $entry_element">
        <li>
            <div style="white-space: nowrap">
                <xsl:for-each select="dyn:evaluate($description_element)"><xsl:apply-templates/><xsl:if test="position()!=last()">, </xsl:if></xsl:for-each><xsl:text> </xsl:text>
                <table style="display: inline; vertical-align: text-bottom">
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$maxelements != @id">
                                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=moveup">
                                        <input
                                            type="image"
                                            name="eimoveup{@id}"
                                            src="{$skimages}arrow_up_activated.gif"
                                            border="0"
                                            width="10"
                                            height="10"
                                            alt="{$i18n_xml/l/Move_up}"
                                            title="{$i18n_xml/l/Move_up}"
                                            style="vertical-align: baseline;"
                                        />
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <img src="{$ximsroot}images/spacer_white.gif"
                                         width="10"
                                         height="10"
                                         border="0"
                                         alt=" "
                                         />
                                </xsl:otherwise>
                            </xsl:choose>
                            <br/>
                            <xsl:choose>
                                <xsl:when test="@id != 1">
                                    <a href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=movedown">
                                        <input
                                            type="image"
                                            name="eimovedown{@id}"
                                            src="{$skimages}arrow_down_activated.gif"
                                            border="0"
                                            width="10"
                                            height="10"
                                            alt="{$i18n_xml/l/Move_down}"
                                            title="{$i18n_xml/l/Move_down}"
                                        />
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <img src="{$ximsroot}images/spacer_white.gif"
                                         width="10"
                                         height="10"
                                         border="0"
                                         alt=" "
                                         />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <a href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id}">
                                <img src="{$skimages}option_edit.png"
                                    alt="{$l_Edit}"
                                    title="{$l_Edit}"
                                    border="0"
                                    name="eiedit{@id}"
                                    width="32"
                                    height="19"
                                />
                            </a>
                        </td>
                        <td>
                            <xsl:if test="/document/context/object/user_privileges/delete">
                                <xsl:text> </xsl:text>
                                <a href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=delete" onclick="javascript:rv=confirm('{$i18n_xml/l/Sure_to_delete}'); if ( rv == true ) location.href='{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=delete'; return false">
                                    <input
                                        type="image"
                                        name="eidelete{@id}"
                                        src="{$skimages}option_delete.png"
                                        border="0"
                                        width="37"
                                        height="19"
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
    </xsl:if>
</xsl:template>

<xsl:template match="r:element" mode="eid">
    <xsl:variable name="xpath">exslt:node-set($entry_set)//<xsl:value-of select="$entry_element"/>[@id='<xsl:value-of select="$eid"/>']/<xsl:value-of select="@name"/></xsl:variable>
    <xsl:variable name="existing_value" select="normalize-space(dyn:evaluate($xpath))"/>
    <tr>
        <td valign="top"><xsl:value-of select="s:description"/></td>
        <td>
            <xsl:choose>
                <xsl:when test="s:datatype = 'datetime'">
                    <!--<xsl:call-template name="jscalendar-selector">
                        <xsl:with-param name="timestamp_string" select="$existing_value"/>
                        <xsl:with-param name="formfield_id" select="concat('sfe_',@name)"/>
                    </xsl:call-template>-->
                </xsl:when>
                <xsl:when test="s:datatype = 'stringoptions'">
                    <select tabindex="{position()+20}" name="sfe_{@name}">
                        <option value=""> </option>
                        <xsl:for-each select="s:select/s:option">
                            <option value="{.}"><xsl:if test="$existing_value = ./text()"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="."/></option>
                        </xsl:for-each>
                    </select>
                </xsl:when>
                <xsl:when test="s:datatype = 'boolean'">
                    <input tabindex="{position()+20}" name="sfe_{@name}" type="radio" value="1">
                      <xsl:if test="$existing_value = '1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if>
                    </input><xsl:value-of select="$i18n/l/Yes"/>
                    <input tabindex="{position()+20}" name="sfe_{@name}" type="radio" value="0">
                      <xsl:if test="$existing_value != '1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if><xsl:value-of select="$i18n/l/No"/>
                    </input>
                </xsl:when>
                <xsl:otherwise>
                    <input tabindex="{position()+20}" type="text" name="sfe_{@name}" value="{$existing_value}" size="80" class="text"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>


<xsl:template match="r:element">
    <tr>
        <td valign="top"><xsl:value-of select="s:description"/></td>
        <td>
            <xsl:choose>
                <xsl:when test="s:datatype = 'datetime'">
                    <!--<xsl:call-template name="jscalendar-selector">
                        <xsl:with-param name="timestamp_string" select="$currentdatetime"/>
                        <xsl:with-param name="formfield_id" select="concat('sfe_',@name)"/>
                    </xsl:call-template>-->
                </xsl:when>
                <xsl:when test="s:datatype = 'stringoptions'">
                    <select tabindex="{position()+20}" name="sfe_{@name}">
                        <option value=""> </option>
                        <xsl:for-each select="s:select/s:option">
                            <option value="{.}"><xsl:value-of select="."/></option>
                        </xsl:for-each>
                    </select>
                </xsl:when>
                <xsl:when test="s:datatype = 'boolean'">
                    <input tabindex="{position()+20}" name="sfe_{@name}" type="radio" value="1"/><xsl:value-of select="$i18n/l/Yes"/>
                    <input tabindex="{position()+20}" name="sfe_{@name}" type="radio" value="0"/><xsl:value-of select="$i18n/l/No"/>
                </xsl:when>
                <xsl:otherwise>
                    <input tabindex="{position()+20}" type="text" name="sfe_{@name}" size="80" class="text"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>

<xsl:template name="head-edit">
    <head>
        <title><xsl:value-of select="$l_Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <!--<xsl:call-template name="jscalendar_scripts"/>-->
    </head>
</xsl:template>

<xsl:template match="s:last_modified_attr"/>
<xsl:template match="s:last_modified_attr" mode="eid"/>

</xsl:stylesheet>
