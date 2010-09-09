<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:str="http://exslt.org/strings"
        extension-element-prefixes="str" exclude-result-prefixes="str">

<xsl:import href="common.xsl"/>
<xsl:import href="common_jscalendar_scripts.xsl"/>

<xsl:param name="error_msg"/>
<xsl:variable name="i18n_simpledb" select="document(concat($currentuilanguage,'/i18n_simpledb.xml'))"/>

<xsl:template name="cttobject.options.purge_or_delete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="user_privileges/delete and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
         <a class="xims-sprite sprite-option_purge"
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

<xsl:template match="member_property">
    <xsl:variable name="propid" select="@id"/>
    <xsl:variable name="propvalue" select="/document/context/object/member_values/member_value[property_id=$propid]/value"/>
    <tr>
        <td>
            <span>
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="mandatory='1'">compulsory</xsl:when>
                        <xsl:otherwise>text</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="name"/>:
            </span>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="type = 'datetime'">
                    <xsl:call-template name="jscalendar-selector">
                        <xsl:with-param name="timestamp_string" select="$propvalue"/>
                        <xsl:with-param name="formfield_id" select="concat('simpledb_',name)"/>
                        <xsl:with-param name="default_value" select="'none'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="type = 'stringoptions'">
                    <select tabindex="{position()+20}" name="simpledb_{name}">
                        <option value=""> </option>
                        <xsl:for-each select="str:split(substring-before(substring-after(regex,'^('),')$'), '|')">
                            <option value="{translate(.,'\','')}"><xsl:if test="$propvalue = translate(./text(),'\','')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="translate(.,'\','')"/></option>
                        </xsl:for-each>
                    </select>
                </xsl:when>
                <xsl:when test="type = 'boolean'">
                    <input tabindex="{position()+20}" name="simpledb_{name}" type="radio" value="1">
                      <xsl:if test="$propvalue = '1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if>
                    </input><xsl:value-of select="$i18n/l/Yes"/>
                    <input tabindex="{position()+20}" name="simpledb_{name}" type="radio" value="0">
                      <xsl:if test="$propvalue != '1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if>
                    </input><xsl:value-of select="$i18n/l/No"/>
                </xsl:when>
                <xsl:when test="type = 'textarea'">
                    <textarea tabindex="{position()+20}" class="text" name="simpledb_{name}" rows="5" cols="38" wrap="virtual" onKeyUp="keyup(this)">
                        <xsl:if test="$propvalue != ''">
                            <xsl:value-of select="$propvalue"/>
                        </xsl:if>
                    </textarea>
                    <script type="text/javascript">
                        keyup( document.getElementsByName("<xsl:value-of select="concat('simpledb_',name)"/>")[0] );
                    </script>
                </xsl:when>
                <xsl:otherwise>
                    <input type="text"
                           class="text"
                           name="simpledb_{name}"
                           size="40"
                           tabindex="{position()+20}"
                           value="{$propvalue}">
                        <xsl:if test="regex != ''">
                            <xsl:attribute name="onBlur">testValue('<xsl:value-of select="regex"/>',this,'<xsl:value-of select="$i18n_simpledb/l/Invalid_Data"/>');</xsl:attribute>
                        </xsl:if>
                    </input>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td style="width: 100%">
            <xsl:value-of select="description"/>
            <!--
            <xsl:call-template name="br-replace">
                <xsl:with-param name="word" select="description"/>
            </xsl:call-template>
            -->
        </td>
    </tr>
</xsl:template>

<xsl:template name="head-create">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS </title>
        <xsl:call-template name="css"/>
        <script src="{$ximsroot}scripts/simpledb.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="jscalendar_scripts"/>
        <xsl:call-template name="jstextarea_keyupcheck"/>
    </head>
</xsl:template>

<xsl:template name="head-edit">
    <head>
        <title><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <script src="{$ximsroot}scripts/simpledb.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="jscalendar_scripts"/>
        <xsl:call-template name="jstextarea_keyupcheck"/>
    </head>
</xsl:template>

<xsl:template name="th-size">
    <td></td>
</xsl:template>

<xsl:template name="tr-abstract-edit">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Abstract"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('SimpleDB.Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="5" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
                 <xsl:choose>
                    <xsl:when test="string-length(abstract) &gt; 0">
                        <xsl:apply-templates select="abstract"/>
                     </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </textarea>
        </td>
    </tr>
</xsl:template>

<xsl:template name="jstextarea_keyupcheck">
    <script type="text/javascript">
        var maxKeys = 1999;
        function keyup( what ) {
            if ( typeof what == 'undefined' )
                return false;
            var str = new String( what.value );
            if ( str.length &gt; maxKeys ) {
                alert('Maximum number of chars reached.');
                what.value = what.value.substring(0,maxKeys);
                return false;
            }
        }
    </script>
</xsl:template>

<xsl:template name="error_msg">
    <xsl:if test="$error_msg != ''">
        <p class="error_msg">
            <xsl:value-of select="$error_msg"/>
        </p>
    </xsl:if>
</xsl:template>


<xsl:template name="cttobject.content_length"/>
<xsl:template name="cttobject.options.copy"/>
<xsl:template name="cttobject.options.move"/>

</xsl:stylesheet>
