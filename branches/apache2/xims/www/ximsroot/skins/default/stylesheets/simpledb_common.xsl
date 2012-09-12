<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: simpledb_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:str="http://exslt.org/strings"
        extension-element-prefixes="str" exclude-result-prefixes="str">

<xsl:param name="error_msg"/>
<xsl:param name="simpledb" select="true()"/>
<xsl:variable name="i18n_simpledb" select="document(concat($currentuilanguage,'/i18n_simpledb.xml'))"/>

	<xsl:template name="cttobject.options.purge_or_delete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="user_privileges/delete and published != '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="xims-sprite sprite-option_delete" title="{$l_delete}">
					<xsl:attribute name="href">
						<xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan_prompt=1')"/>
						<xsl:if test="$currobjmime='application/x-container'">
							<xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/>
						</xsl:if>
					</xsl:attribute>
          &#xa0;<span>
						<xsl:value-of select="$l_delete"/>
					</span>
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
	<div>
		<div class="label-std">
            <!--<span>
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="mandatory='1'">compulsory</xsl:when>
                        <xsl:otherwise>text</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
									<xsl:when test="type = 'boolean'"><xsl:value-of select="name"/>:</xsl:when>
									<xsl:otherwise><label for="simpledb_{name}"><xsl:value-of select="name"/></label>:</xsl:otherwise>
								</xsl:choose>
            </span>-->
			
			<xsl:choose>
				<xsl:when test="type = 'boolean'"><xsl:value-of select="name"/>:</xsl:when>
				<xsl:otherwise><label for="simpledb_{name}"><xsl:value-of select="name"/></label>:</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="mandatory='1'">&#160;*</xsl:if>
			
								
        </div>
            <xsl:choose>
            	
                <xsl:when test="type = 'datetime'">
					<xsl:call-template name="ui-datetimepicker">
						<xsl:with-param name="formfield_id" select="concat('simpledb_',name)"></xsl:with-param>
						<xsl:with-param name="input_id" select="concat('simpledb_',name)"></xsl:with-param>
						<xsl:with-param name="xml_node"><xsl:value-of select="/document/context/object/member_values/member_value[property_id=$propid]/value"/></xsl:with-param>
						<xsl:with-param name="buttontext">Datum</xsl:with-param>
						<xsl:with-param name="mode">datetime</xsl:with-param>
						<xsl:with-param name="range">false</xsl:with-param>
					</xsl:call-template>
					<input type="text" id="simpledb_{name}" name="simpledb_{name}" readonly="readonly" size="14"><xsl:attribute name="value"><xsl:value-of select="$propvalue"/></xsl:attribute></input>
					<script type="text/javascript">
				$(document).ready(function(){					
					$('#<xsl:value-of select="concat('simpledb_',name)"/>').datetimepicker({buttonText: '<xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="name"/>'});
				});
				
			</script>
                </xsl:when>
				
                <xsl:when test="type = 'stringoptions'">
                    <select name="simpledb_{name}" id="simpledb_{name}">
                        <option value=""> </option>
                        <xsl:for-each select="str:split(substring-before(substring-after(regex,'^('),')$'), '|')">
                            <option value="{translate(.,'\','')}"><xsl:if test="$propvalue = translate(./text(),'\','')"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="translate(.,'\','')"/></option>
                        </xsl:for-each>
                    </select>
                </xsl:when>
                <xsl:when test="type = 'boolean'">
                    <input name="simpledb_{name}" id="simpledb_{name}-true" type="radio" value="1" class="radio-button">
                      <xsl:if test="$propvalue = '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input><label for="simpledb_{name}-true"><xsl:value-of select="$i18n/l/Yes"/></label>
                    <input name="simpledb_{name}" id="simpledb_{name}-false" type="radio" value="0" class="radio-button">
                      <xsl:if test="$propvalue != '1'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input><label for="simpledb_{name}-false"><xsl:value-of select="$i18n/l/No"/></label>
                </xsl:when>
                <xsl:when test="type = 'textarea'">
                    <textarea class="text" name="simpledb_{name}" id="simpledb_{name}" rows="5" cols="38" onkeyup="keyup(this)">
                        <xsl:if test="$propvalue != ''">
                            <xsl:value-of select="$propvalue"/>
                        </xsl:if>
                    </textarea>
                    <script type="text/javascript">
                        keyup( document.getElementsByName("<xsl:value-of select="concat('simpledb_',name)"/>")[0] );
                    </script>
                </xsl:when>
                <xsl:otherwise>
                    <input type="text" name="simpledb_{name}" id="simpledb_{name}" size="60" value="{$propvalue}">
                        <xsl:if test="regex != ''">
                            <xsl:attribute name="onblur">testValue('<xsl:value-of select="regex"/>',this,'<xsl:value-of select="$i18n_simpledb/l/Invalid_Data"/>');</xsl:attribute>
                        </xsl:if>
                    </input>
                </xsl:otherwise>
            </xsl:choose>
			
		<xsl:if test="description !=''">
			<em>&#160;<xsl:value-of select="description"/></em>
		</xsl:if>
	</div>
</xsl:template>

<xsl:template name="th-size">
    <td></td>
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

<xsl:template name="button.options.copy"/>
<xsl:template name="button.options.move"/>


</xsl:stylesheet>
