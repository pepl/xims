<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
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
<!--
<xsl:import href="common.xsl"/>
<xsl:import href="../../../stylesheets/common.xsl"/>-->
<xsl:import href="edit_common.xsl"/>
<!--<xsl:import href="common_jscalendar_scripts.xsl"/>-->

<xsl:param name="eid"/>
<xsl:param name="message" select="/document/context/session/message"/>

<xsl:variable name="schema_path">
    <xsl:choose>
        <xsl:when test="contains($publishingroot,':')">
            <xsl:value-of select="concat($publishingroot,'/',substring-after(substring-after(/document/context/object/schema_id,'/'),'/'))"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat($xims_box,'/ximspubroot',/document/context/object/schema_id)"/>
        </xsl:otherwise>
    </xsl:choose>
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
	<xsl:call-template name="form-locationtitle-edit_xml"/>
	<xsl:call-template name="form-marknew-pubonsave"/>
	<div class="form-div block">
		<a href="{$xims_box}{$goxims_content}?id={@id};edit=1" class="button"><xsl:value-of select="$i18n_xml/l/Edit_XML_source"/></a>
	</div>
	<div class="form-div block">
		<xsl:if test="$message != ''">
			<p><span class="message"><xsl:value-of select="$message"/></span></p>
		</xsl:if>
			<xsl:choose>
				<xsl:when test="$eid != ''">
						<h2><xsl:value-of select="$i18n_xml/l/Edit_entry"/><xsl:text> </xsl:text><xsl:value-of select="$eid"/></h2>
						<xsl:apply-templates select="$schema/r:grammar/r:start/r:element/r:oneOrMore/r:element/*" mode="eid"/>
					<div>
						<input type="hidden" name="eid" value="{$eid}"/>
						<input type="hidden" name="seid" value="1"/>
						<button type="submit" name="simpleformedit" class="control"><xsl:value-of select="$i18n_xml/l/Save_changes"/></button>&#160;
						<a type="button" name="discard" href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1" class="button"><xsl:value-of select="$i18n_xml/l/Stop_editing"/></a>
					</div>
				</xsl:when>
				<xsl:otherwise>
						<h2><xsl:value-of select="$i18n_xml/l/Create_entry"/></h2>
						<xsl:apply-templates select="$schema/r:grammar/r:start/r:element/r:oneOrMore/r:element/*"/>
					<div>
						<input type="hidden" name="seid" value="1"/>
						<button type="submit" name="simpleformedit" class="control" accesskey="c"><xsl:value-of select="$i18n_xml/l/Create_entry"/></button>
					</div>
				</xsl:otherwise>
			</xsl:choose>
			<div>
				<h2><xsl:value-of select="$i18n_xml/l/Existing_entries"/></h2>
			</div>
			<div>
				<ul>
				<xsl:apply-templates select="body/*/*" mode="entry"/>
				</ul>
			</div>
			<!--<div>
				<button type="submit" name="edit"><xsl:value-of select="$i18n_xml/l/Edit_XML_source"/></button>
			</div>-->
	</div>
					
	<xsl:call-template name="form-keywordabstract"/>
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
			<xsl:choose>
				<xsl:when test="$maxelements != @id">
					<a class="button up" href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=moveup">&#xa0;</a>
				</xsl:when>
				<xsl:otherwise>
					<a class="button option-disabled">&#160;</a>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="@id != 1">
					<a class="button down" href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=movedown">&#xa0;</a>
				</xsl:when>
				<xsl:otherwise>
					<a class="button option-disabled">&#160;</a>
				</xsl:otherwise>
			</xsl:choose>
			&#160;&#160;&#160;
			<a href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id}" class="button option-edit">
				<xsl:value-of select="$i18n/l/Edit"/>
			</a>
			<xsl:if test="/document/context/object/user_privileges/delete">
				<xsl:text> </xsl:text>
				<a class="button option-delete" href="{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=delete" onclick="javascript:rv=confirm('{$i18n_xml/l/Sure_to_delete}'); if ( rv == true ) location.href='{$xims_box}{$goxims_content}{$absolute_path}?simpleformedit=1;eid={@id};seid=delete'; return false">
					<xsl:value-of select="$i18n/l/delete"/>
				</a>
			</xsl:if>
			&#160;&#160;&#160;
			<xsl:for-each select="dyn:evaluate($description_element)"><xsl:apply-templates/><xsl:if test="position()!=last()">, </xsl:if></xsl:for-each><xsl:text> </xsl:text>
		</li>
	</xsl:if>
</xsl:template>

<xsl:template match="r:element" mode="eid">
	<xsl:variable name="xpath">exslt:node-set($entry_set)//<xsl:value-of select="$entry_element"/>[@id='<xsl:value-of select="$eid"/>']/<xsl:value-of select="@name"/></xsl:variable>
	<xsl:variable name="existing_value" select="normalize-space(dyn:evaluate($xpath))"/>
	<div>
		<div class="label-large">
			<label for="sfe_{@name}"><xsl:value-of select="s:description"/></label>
		</div>
		<xsl:choose>
			<xsl:when test="s:datatype = 'datetime'">
				<xsl:call-template name="ui-datetimepicker">
					<xsl:with-param name="formfield_id" select="concat('sfe_',@name)"></xsl:with-param>
					<xsl:with-param name="input_id" select="concat('sfe_',@name)"></xsl:with-param>
					<xsl:with-param name="xml_node"><xsl:value-of select="/document/context/object/member_values/member_value[property_id=$propid]/value"/></xsl:with-param>
					<xsl:with-param name="buttontext">Datum</xsl:with-param>
					<xsl:with-param name="mode">datetime</xsl:with-param>
					<xsl:with-param name="range">false</xsl:with-param>
				</xsl:call-template>
				<input type="text" name="sfe_{@name}" id="sfe_{@name}" value="{$existing_value}" size="14" readonly="readonly"/>
				<script type="text/javascript">
					$(document).ready(function(){					
						$('#<xsl:value-of select="concat('sfe_',@name)"/>').datetimepicker({buttonText: '<xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="name"/>'});
					});			
				</script>
			</xsl:when>
                <xsl:when test="s:datatype = 'stringoptions'">
                    <select name="sfe_{@name}" id="sfe_{@name}">
                        <option value=""> </option>
                        <xsl:for-each select="s:select/s:option">
                            <option value="{.}"><xsl:if test="$existing_value = ./text()"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="."/></option>
                        </xsl:for-each>
                    </select>
                </xsl:when>
                <xsl:when test="s:datatype = 'boolean'">
                    <input name="sfe_{@name}" id="sfe_{@name}_yes" type="radio" value="1">
                      <xsl:if test="$existing_value = '1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if>
                    </input><label for="sfe_{@name}_yes"><xsl:value-of select="$i18n/l/Yes"/></label>
                    <input name="sfe_{@name}" id="sfe_{@name}_no" type="radio" value="0">
                      <xsl:if test="$existing_value != '1'">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                      </xsl:if><label for="sfe_{@name}_no"><xsl:value-of select="$i18n/l/No"/></label>
                    </input>
                </xsl:when>
                <xsl:otherwise>
                    <input type="text" name="sfe_{@name}" id="sfe_{@name}" value="{$existing_value}" size="80" class="text"/>
                </xsl:otherwise>
            </xsl:choose>
    </div>
</xsl:template>


<xsl:template match="r:element">
	<div>
		<div class="label-large">
			<label for="sfe_{@name}"><xsl:value-of select="s:description"/></label>
		</div>
		<xsl:choose>
			<xsl:when test="s:datatype = 'datetime'">
				<xsl:call-template name="ui-datetimepicker">
					<xsl:with-param name="formfield_id" select="concat('sfe_',@name)"></xsl:with-param>
					<xsl:with-param name="input_id" select="concat('sfe_',@name)"></xsl:with-param>
					<xsl:with-param name="xml_node"><xsl:value-of select="/document/context/object/member_values/member_value[property_id=$propid]/value"/></xsl:with-param>
					<xsl:with-param name="buttontext">Datum</xsl:with-param>
					<xsl:with-param name="mode">datetime</xsl:with-param>
					<xsl:with-param name="range">false</xsl:with-param>
				</xsl:call-template>
				<input type="text" name="sfe_{@name}" id="sfe_{@name}" size="14" readonly="readonly"/>
				<script type="text/javascript">
					$(document).ready(function(){					
						$('#<xsl:value-of select="concat('sfe_',@name)"/>').datetimepicker({buttonText: '<xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="name"/>'});
					});			
				</script>
                </xsl:when>
                <xsl:when test="s:datatype = 'stringoptions'">
                    <select name="sfe_{@name}" id="sfe_{@name}">
                        <option value=""> </option>
                        <xsl:for-each select="s:select/s:option">
                            <option value="{.}"><xsl:value-of select="."/></option>
                        </xsl:for-each>
                    </select>
                </xsl:when>
                <xsl:when test="s:datatype = 'boolean'">
                    <input name="sfe_{@name}" id="sfe_{@name}_yes" type="radio" value="1"/>
                    <label for="sfe_{@name}_yes"><xsl:value-of select="$i18n/l/Yes"/></label>
                    <input name="sfe_{@name}" id="sfe_{@name}_no" type="radio" value="0"/>
                      <label for="sfe_{@name}_no"><xsl:value-of select="$i18n/l/No"/></label>
                </xsl:when>
                <xsl:otherwise>
                    <input tabindex="{position()+20}" type="text"  id="sfe_{@name}" name="sfe_{@name}" size="80" class="text"/>
                </xsl:otherwise>
            </xsl:choose>
    </div>
</xsl:template>

<xsl:template match="s:last_modified_attr"/>
<xsl:template match="s:last_modified_attr" mode="eid"/>

</xsl:stylesheet>
