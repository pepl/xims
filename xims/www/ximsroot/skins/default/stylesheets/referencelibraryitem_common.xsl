<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<!--<xsl:import href="common.xsl"/>-->
<xsl:import href="libraryitem_common.xsl"/>

<xsl:param name="reflib" select="true()"/>
<xsl:param name="reftype"><xsl:value-of select="/document/context/object/reference_type_id"/></xsl:param>
<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
<xsl:variable name="titlerefpropid" select="/document/reference_properties/reference_property[name='title']/@id"/>
<xsl:variable name="daterefpropid" select="/document/reference_properties/reference_property[name='date']/@id"/>
<xsl:variable name="btitlerefpropid" select="/document/reference_properties/reference_property[name='btitle']/@id"/>

<xsl:output method="xml"
            encoding="utf-8"
            media-type="text/html"
            doctype-system="about:legacy-compat"
            omit-xml-declaration="yes"
            indent="no"/>

<!--<xsl:template name="cttobject.options.purge_or_delete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
        <xsl:when test="user_privileges/delete and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
            --><!-- note: get seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( --><!--
            --><!-- <form style="margin:0px;" name="delete" method="post" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onsubmit="return confirmDelete()"> --><!--
            <form name="delete" method="get" action="{$xims_box}{$goxims_content}">
                <input type="hidden" name="delete_prompt" value="1"/>
                <input type="hidden" name="id" value="{$id}"/>
                <xsl:if test="$currobjmime='application/x-container'">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="page" type="hidden" value="{$page}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                    <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                </xsl:if>
                <button class="xims-sprite sprite-option_purge"
                    name="delete{$id}"
                    title="{$l_purge}"
                    ><span><xsl:value-of select="$l_purge"/>&#xa0;</span></button>
            </form>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="cttobject.options.spacer"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>-->


<xsl:template match="reference_property">
	<xsl:variable name="propid" select="@id"/>
	<xsl:variable name="propname"><xsl:call-template name="get-prop-name"><xsl:with-param name="id" select="$propid"/></xsl:call-template></xsl:variable>
	<div class="ref-property">
		<div class="label-prop">
			<label><xsl:attribute name="for">input-<xsl:value-of select="$propid"/></xsl:attribute><xsl:value-of select="$propname"/></label>
		</div>
		<input type="text" class="text" name="{name}" size="50"  value="{/document/context/object/reference_values/reference_value[property_id=$propid]/value}">
			<xsl:attribute name="onfocus">javascript:initPropDescription('#prop-desc_<xsl:value-of select="$propid"/>', '#input-<xsl:value-of select="$propid"/>');</xsl:attribute>
			<xsl:attribute name="onblur">javascript:destroyInfoBox('#prop-desc_<xsl:value-of select="$propid"/>');</xsl:attribute>
			<xsl:attribute name="id">input-<xsl:value-of select="$propid"/></xsl:attribute></input>
		<div class="ui-state-highlight ui-corner-all prop-desc" id="prop-desc_{$propid}">
			<p>
				<span class="ui-icon ui-icon-info"><xsl:comment/></span><strong><xsl:value-of select="$propname"/></strong><br/>
				<xsl:value-of select="description"/>
			</p>
		</div>
		<!-- <xsl:value-of select="description"/>-->
	</div>
</xsl:template>

<xsl:template name="get-prop-name">
<xsl:param name="id" select="$id"/>
	<xsl:choose>
		<xsl:when test="$id=1"><xsl:value-of select="$i18n/l/rl_title"/></xsl:when>
		<xsl:when test="$id=2"><xsl:value-of select="$i18n/l/rl_btitle"/></xsl:when>
		<xsl:when test="$id=3"><xsl:value-of select="$i18n/l/rl_date"/></xsl:when>
		<xsl:when test="$id=4"><xsl:value-of select="$i18n/l/rl_chron"/></xsl:when>
		<xsl:when test="$id=5"><xsl:value-of select="$i18n/l/rl_ssn"/></xsl:when>
		<xsl:when test="$id=6"><xsl:value-of select="$i18n/l/rl_quarter"/></xsl:when>
		<xsl:when test="$id=7"><xsl:value-of select="$i18n/l/rl_volume"/></xsl:when>
		<xsl:when test="$id=8"><xsl:value-of select="$i18n/l/rl_part"/></xsl:when>
		<xsl:when test="$id=9"><xsl:value-of select="$i18n/l/rl_issue"/></xsl:when>
		<xsl:when test="$id=10"><xsl:value-of select="$i18n/l/rl_spage"/></xsl:when>
		<xsl:when test="$id=11"><xsl:value-of select="$i18n/l/rl_epage"/></xsl:when>
		<xsl:when test="$id=12"><xsl:value-of select="$i18n/l/rl_pages"/></xsl:when>
		<xsl:when test="$id=13"><xsl:value-of select="$i18n/l/rl_artnum"/></xsl:when>
		<xsl:when test="$id=14"><xsl:value-of select="$i18n/l/rl_isbn"/></xsl:when>
		<xsl:when test="$id=15"><xsl:value-of select="$i18n/l/rl_coden"/></xsl:when>
		<xsl:when test="$id=16"><xsl:value-of select="$i18n/l/rl_sici"/></xsl:when>
		<xsl:when test="$id=17"><xsl:value-of select="$i18n/l/rl_place"/></xsl:when>
		<xsl:when test="$id=18"><xsl:value-of select="$i18n/l/rl_pub"/></xsl:when>
		<xsl:when test="$id=19"><xsl:value-of select="$i18n/l/rl_edition"/></xsl:when>
		<xsl:when test="$id=20"><xsl:value-of select="$i18n/l/rl_tpages"/></xsl:when>
		<xsl:when test="$id=21"><xsl:value-of select="$i18n/l/rl_series"/></xsl:when>
		<xsl:when test="$id=22"><xsl:value-of select="$i18n/l/rl_issn"/></xsl:when>
		<xsl:when test="$id=23"><xsl:value-of select="$i18n/l/rl_bici"/></xsl:when>
		<xsl:when test="$id=24"><xsl:value-of select="$i18n/l/rl_co"/></xsl:when>
		<xsl:when test="$id=25"><xsl:value-of select="$i18n/l/rl_inst"/></xsl:when>
		<xsl:when test="$id=26"><xsl:value-of select="$i18n/l/rl_advisor"/></xsl:when>
		<xsl:when test="$id=27"><xsl:value-of select="$i18n/l/rl_degree"/></xsl:when>
		<xsl:when test="$id=28"><xsl:value-of select="$i18n/l/rl_identifier"/></xsl:when>
		<xsl:when test="$id=29"><xsl:value-of select="$i18n/l/rl_status"/></xsl:when>
		<xsl:when test="$id=30"><xsl:value-of select="$i18n/l/rl_conf_venu"/></xsl:when>
		<xsl:when test="$id=31"><xsl:value-of select="$i18n/l/rl_conf_date"/></xsl:when>
		<xsl:when test="$id=32"><xsl:value-of select="$i18n/l/rl_conf_title"/></xsl:when>
		<xsl:when test="$id=33"><xsl:value-of select="$i18n/l/rl_conf_sponsor"/></xsl:when>
		<xsl:when test="$id=34"><xsl:value-of select="$i18n/l/rl_conf_url"/></xsl:when>
		<xsl:when test="$id=35"><xsl:value-of select="$i18n/l/rl_url"/></xsl:when>
		<xsl:when test="$id=36"><xsl:value-of select="$i18n/l/rl_access_timestamp"/></xsl:when>
		<xsl:when test="$id=37"><xsl:value-of select="$i18n/l/rl_citekey"/></xsl:when>
		<xsl:when test="$id=38"><xsl:value-of select="$i18n/l/rl_url2"/></xsl:when>
		<xsl:when test="$id=39"><xsl:value-of select="$i18n/l/rl_workgroup"/></xsl:when>
		<xsl:when test="$id=40"><xsl:value-of select="$i18n/l/rl_preprint_identifier"/></xsl:when>
		<xsl:when test="$id=41"><xsl:value-of select="$i18n/l/rl_project"/></xsl:when>
		<xsl:when test="$id=42"><xsl:value-of select="$i18n/l/rl_preprint_submitdate"/></xsl:when>
		<xsl:when test="$id=43"><xsl:value-of select="$i18n/l/rl_thesis_inprocess"/></xsl:when>
		<!--<xsl:when test="$id=44"><xsl:value-of select="$i18n/l/rl_preprint_identifier"/></xsl:when>-->
		<xsl:when test="$id=44"><xsl:value-of select="$i18n/l/rl_quality_criterion"/></xsl:when>
    <xsl:when test="$id=47"><xsl:value-of select="$i18n/l/rl_local_restricted_url"/></xsl:when>
		<xsl:otherwise>error</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="tr-vlauthors">
<div class="ui-widget-content ui-corner-all" id="vlauthors">
<h2><xsl:value-of select="$i18n_vlib/l/authors"/></h2>
    <div>
            <div id="label-authors"><label for="vlauthor"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/authors"/></label></div>
            <input type="text" name="vlauthor" size="50" value="" class="text" id="vlauthor">
							<xsl:attribute name="onfocus">javascript:initAuthDescription('#auth-desc','#vlauthor');</xsl:attribute>
							<xsl:attribute name="onblur">javascript:destroyInfoBox('#auth-desc');</xsl:attribute>
            </input>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>-->
            <xsl:if test="/document/context/vlauthors/author/id">
                <xsl:text>&#160;</xsl:text>
                <xsl:apply-templates select="/document/context/vlauthors"/>
            </xsl:if>      
            <xsl:if test="@id != ''">
                <xsl:text>&#160;</xsl:text>
                <input type="submit" name="create_author_mapping" value="{$i18n_vlib/l/Create_mapping}" class="button ui-state-default ui-corner-all fg-button"/>
            </xsl:if>         
            <div class="ui-state-highlight ui-corner-all auth-desc" id="auth-desc">
								<p>
									<span class="ui-icon ui-icon-info"/><strong><xsl:value-of select="$i18n_vlib/l/authors"/></strong><br/>
									<xsl:value-of select="$i18n_vlib/l/AuthorStringFormat"/>.<br/><xsl:value-of select="$i18n_vlib/l/Split_by_semicolon"/>
								</p>
							</div>   
            <!--<xsl:value-of select="$i18n_vlib/l/AuthorStringFormat"/>.<br/><xsl:value-of select="$i18n_vlib/l/Split_by_semicolon"/>.-->
        </div>    
                <xsl:if test="@id != '' and authorgroup/author/id">
        <div>
            <div class="default-label"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/authors"/><xsl:text>&#160;</xsl:text></div>
                <xsl:apply-templates select="authorgroup/author" mode="edit">
                    <xsl:sort select="./position" order="ascending" data-type="number"/>
                </xsl:apply-templates>
        </div>
    </xsl:if>
    </div>
</xsl:template>

<xsl:template name="tr-vleditors">
<div class="ui-widget-content ui-corner-all" id="vleditors">
<h2><xsl:value-of select="$i18n_vlib/l/editors"/></h2>
    <div>
        <div id="label-editors"><label for="vleditor"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/editors"/></label></div>
            <input type="text" name="vleditor" size="50" value="" class="text" id="vleditor"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>-->
            <xsl:if test="/document/context/vlauthors/author/id">
                <xsl:text>&#160;</xsl:text>
                <xsl:apply-templates select="/document/context/vlauthors"><xsl:with-param name="svlauthor" select="'svleditor'"/></xsl:apply-templates>
            </xsl:if>
            <xsl:if test="@id != ''">
                <xsl:text>&#160;</xsl:text>
                <input type="submit" name="create_editor_mapping" value="{$i18n_vlib/l/Create_mapping}" class="ui-state-default ui-corner-all fg-button"/>
            </xsl:if>
        </div>
     <xsl:if test="@id != '' and editorgroup/author/id">
            <div>
							<div class="default-label"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/editors"/></div>
                <xsl:apply-templates select="editorgroup/author" mode="edit">
                    <xsl:sort select="./position" order="ascending" data-type="number"/>
                </xsl:apply-templates>
        </div>
    </xsl:if>
    </div>
</xsl:template>

<xsl:template name="tr-vlserials">
<div class="ui-widget-content ui-corner-all" id="vlserials">
<h2><xsl:value-of select="$i18n_vlib/l/Serial"/></h2>

    <xsl:if test="/document/reference_types/reference_type/name = 'Article' and not(serial)">
        <div>
            <div id="label-serials"><label for="vlserial"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/Serial"/></label></div>
                <input type="text" name="vlserial" size="50" value="" class="text" id="vlserial"/>
                <!--<xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('VLSerial')" class="doclink">(?)</a>-->
                <xsl:if test="/document/context/vlserials/serial/@id">
                    <xsl:text>&#160;</xsl:text>
                    <xsl:apply-templates select="/document/context/vlserials"/>
                </xsl:if>
                <xsl:if test="@id != ''">
                    <xsl:text>&#160;</xsl:text>
                    <input type="submit" name="create_serial_mapping" value="{$i18n_vlib/l/Create_mapping}" class="ui-state-default ui-corner-all fg-button"/>
                </xsl:if>
        </div>
    </xsl:if>
        <xsl:if test="/document/reference_types/reference_type/name = 'Article' and @id != '' and serial/@id">
        <div>
            <div class="default-label"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/Serial"/></div>

                <xsl:apply-templates select="serial" mode="edit"/>

        </div>
    </xsl:if>
    </div>
</xsl:template>

<xsl:template name="head-create">
    <head>
        <title><xsl:value-of select="$i18n/l/create"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
		<xsl:call-template name="objtype_name">
			<xsl:with-param name="ot_name">
				<xsl:value-of select="$objtype"/>
			</xsl:with-param>
		</xsl:call-template>
		&#160;(<xsl:value-of select="/document/reference_types/reference_type[@id=$reftype]/name"/>)&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS </title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
    </head>
</xsl:template>

<xsl:template name="head-edit">
    <head>
        <title><xsl:value-of select="$l_Edit"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
		<xsl:call-template name="objtype_name">
			<xsl:with-param name="ot_name">
				<xsl:value-of select="$objtype"/>
			</xsl:with-param>
		</xsl:call-template>
		&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
    </head>
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
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?reposition_author=1&amp;author_id={id}&amp;role={$role}&amp;old_position={$current_pos}&amp;new_position={$current_pos - 1}&amp;date={$date}&amp;title={$title}"
           title="{i18n/l/Reposition}">&lt;</a>
        <xsl:text> </xsl:text>
    </xsl:if>
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1&amp;{concat(name(),'_id')}={id}" target="_blank" title="{$i18n/l/Opens_in_new_window}">
        <xsl:call-template name="authorfullname"/>
    </a>
    <xsl:text> </xsl:text>
    <a href="{$xims_box}{$goxims_content}{$absolute_path}?remove_author_mapping=1&amp;property={name()}&amp;property_id={id}&amp;role={$role}&amp;date={$date}&amp;title={$title}"
       title="{i18n_vlib/l/Delete_mapping}">(x)</a>
    <xsl:if test="position()!=last()">
        <xsl:text> </xsl:text>
        <a href="{$xims_box}{$goxims_content}{$absolute_path}?reposition_author=1&amp;author_id={id}&amp;role={$role}&amp;old_position={$current_pos}&amp;new_position={$current_pos + 1}&amp;date={$date}&amp;title={$title}"
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
	<a class="option-delete ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only" href="{$xims_box}{$goxims_content}{$absolute_path}?remove_serial_mapping=1&amp;serial_id={@id}" role="button" aria-disabled="false" >
		<xsl:attribute name="title"><xsl:value-of select="$i18n_vlib/l/Delete_mapping"/></xsl:attribute>
		<span class="ui-button-icon-primary ui-icon sprite-option_delete xims-sprite"><xsl:comment/></span>
		<span class="ui-button-text"><xsl:value-of select="$i18n_vlib/l/Delete_mapping"/></span>
	</a>
</xsl:template>

<xsl:template name="authorfullname">
    <xsl:value-of select="firstname"/><xsl:if test="middlename !=''"><xsl:text> </xsl:text><xsl:value-of select="middlename"/></xsl:if><xsl:text> </xsl:text><xsl:value-of select="lastname"/><xsl:if test="suffix !=''">, <xsl:value-of select="suffix"/></xsl:if>
</xsl:template>

<xsl:template match="vlserials">
    <xsl:param name="svlserial" select="'svlserial'"/>
    <select name="{$svlserial}" id="{$svlserial}">
        <xsl:apply-templates select="/document/context/vlserials/serial">
            <xsl:sort select="translate(title,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                      order="ascending"/>
        </xsl:apply-templates>
    </select>
</xsl:template>

<xsl:template name="th-size">
    <td></td>
</xsl:template>


<xsl:template name="form-keywordabstract">
		<div class="form-div ui-corner-all block">
			<h2><xsl:value-of select="$i18n/l/Metadata"/></h2>
			<xsl:call-template name="form-keywords"/>
			<xsl:call-template name="form-abstract"/>
		</div>
	</xsl:template>
	
<xsl:template name="form-abstract">
		<div id="tr-abstract">
			<div id="label-abstract">
				<label for="input-abstract">
					<xsl:value-of select="$i18n/l/Abstract"/>
				</label>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Reflib.Abstract')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Abstract"/></xsl:attribute>(?)</a>-->
			</div>
			<br/>
			<textarea id="input-abstract" name="abstract" rows="3" cols="79"><xsl:comment/>
				<xsl:apply-templates select="abstract"/>
                <xsl:comment/>
			</textarea>
		</div>
</xsl:template>

<!--<xsl:template name="head_default">
    <head>
        <title><xsl:call-template name="title"/></title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
    </head>
</xsl:template>-->

<xsl:template name="publish-on-save"/>

<!--
<xsl:template name="cttobject.content_length"/>
<xsl:template name="cttobject.options.copy"/>
<xsl:template name="cttobject.options.move"/>-->

</xsl:stylesheet>
