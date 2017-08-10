<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_default.xsl 2241 2009-08-03 14:02:50Z susannetober $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml">

		
    <xsl:import href="container_common.xsl"/>
    
    <xsl:import href="referencelibraryitem_common.xsl"/>
    <xsl:import href="view_common.xsl"/>

    <xsl:param name="onepage"/>
    <xsl:param name="date"/>
    <xsl:param name="author_id"/>
    <xsl:param name="serial_id"/>
    <xsl:param name="author_lname"/>
    <xsl:param name="reference_type_id"/>
    <xsl:param name="workgroup_id"/>
    <xsl:param name="reflibsearch"/>
    <!--<xsl:param name="reflib">true</xsl:param>-->
	<xsl:param name="reflib" select="true()"/>
	<xsl:param name="createwidget">default</xsl:param>

    <xsl:variable name="objectitems_count"><xsl:choose><xsl:when test="/document/context/object/children/@totalobjects"><xsl:value-of select="/document/context/object/children/@totalobjects"/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:variable>
   
		<!-- #TODO put pagerowlimit in config-file-->
    <xsl:variable name="objectitems_rowlimit" select="'20'"/>
    <xsl:variable name="totalpages" select="ceiling($objectitems_count div $objectitems_rowlimit)"/>

    <!--<xsl:variable name="subjectcolumns" select="'3'"/>-->
    
	<xsl:variable name="pagenavurl">
		<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?date=',$date,'&amp;serial_id=',$serial_id,'&amp;author_id=',$author_id,'&amp;author_lname=',$author_lname,'&amp;workgroup_id=',$workgroup_id,'&amp;')"/>
		<xsl:if test="$reflibsearch != ''"><xsl:value-of select="concat('&amp;reflibsearch=',$reflibsearch,'&amp;')"/></xsl:if>
	</xsl:variable>
	
	<!--<xsl:variable name="reflib" select="true()"/>-->
	<xsl:template name="view-content">
		<div id="search-filter">
			<xsl:call-template name="reflib.authorsearch"/>
			<xsl:call-template name="reflib.options"/>			
		</div>
		<div id="reflib_resulttitle">
			<xsl:if test="$date != '' or $author_id != '' or $reference_type_id != '' or $serial_id != '' or $author_lname != ''">
				<strong>Filtered View</strong>:
                            <xsl:if test="$date != ''">
                                <span class="reflib_filter">Date '<xsl:value-of select="$date"/>'</span></xsl:if>
                            <xsl:if test="$serial_id != ''"><xsl:if test="$date != ''">, </xsl:if>
                                <span class="reflib_filter">Serial '<xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>'</span></xsl:if>
                            <xsl:if test="$reference_type_id != ''"><xsl:if test="$date != '' or $serial_id != ''">, </xsl:if>
                                <span class="reflib_filter">Reference Type '<xsl:value-of select="/document/reference_types/reference_type[@id=$reference_type_id]/name"/>'</span></xsl:if>
                            <xsl:if test="$author_id != ''"><xsl:if test="$date != '' or $serial_id != '' or $reference_type_id != ''">, </xsl:if>
                                <span class="reflib_filter">Author '<xsl:value-of select="concat(children/object/authorgroup/author[id=$author_id]/firstname, ' ', children/object/authorgroup/author[id=$author_id]/lastname)" />'</span></xsl:if>
                            <xsl:if test="$author_lname != ''"><xsl:if test="$date != '' or $serial_id != '' or $author_id != ''">, </xsl:if>
                                <span class="reflib_filter">Author lastname '<xsl:value-of select="$author_lname"/>'</span></xsl:if>.
                            <a href="{$xims_box}{$goxims_content}{$absolute_path}">Reset filter</a>
			</xsl:if>
			<xsl:call-template name="items_page_info"/>
        </div>
                    <xsl:call-template name="pagenav">
                        <xsl:with-param name="totalitems" select="$objectitems_count"/>
                        <xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
                        <xsl:with-param name="currentpage" select="$page"/>
                        <xsl:with-param name="url" select="$pagenavurl"/>
                    </xsl:call-template>
                    <xsl:call-template name="childrenlist"/>
                    <xsl:call-template name="pagenav">
                        <xsl:with-param name="totalitems" select="$objectitems_count"/>
                        <xsl:with-param name="itemsperpage" select="$objectitems_rowlimit"/>
                        <xsl:with-param name="currentpage" select="$page"/>
                        <xsl:with-param name="url" select="$pagenavurl"/>
                    </xsl:call-template>

    </xsl:template>

<xsl:template name="create-widget">
		<div id="create-widget">
			<button>				
				<xsl:value-of select="$i18n/l/Create"/>
			</button>
			<ul style="position:absolute !important; overflow-y: auto; z-index:100;">
				<li><a href="{$xims_box}{$goxims_content}{$absolute_path}?import_prompt=1"><xsl:value-of select="$i18n/l/Import"/>...</a></li>
				<xsl:apply-templates select="/document/reference_types/reference_type" mode="getoptions"/>
			</ul>
    <noscript>
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" id="reftype_creator" name="reftype_creator">
				
        <select name="reftype" id="reftype">
        	<option><a href="{$xims_box}{$goxims_content}{$absolute_path}?import_prompt=1"><xsl:value-of select="$i18n/l/Import"/>...</a></option>
            <xsl:apply-templates select="/document/reference_types/reference_type" mode="selectoptions">
                <xsl:sort select="name" order="ascending"/>
            </xsl:apply-templates>
        </select>
            <input type="submit" name="create" title="{$i18n/l/Create}">
                    <xsl:attribute name="value"><xsl:value-of select="$i18n/l/Create"/></xsl:attribute>
            </input>
            <input name="page" type="hidden" value="{$page}"/>
            <input name="r" type="hidden" value="{/document/context/object/@id}"/>
            <input name="objtype" type="hidden" value="ReferenceLibraryItem"/>
            <xsl:if test="$defsorting != 1">
                <input name="sb" type="hidden" value="{$sb}"/>
                <input name="order" type="hidden" value="{$order}"/>
            </xsl:if>
    </form>
    </noscript>
    </div>
</xsl:template>

<xsl:template match="reference_type" mode="getoptions">
    <li><a href="{$xims_box}{$goxims_content}{$absolute_path}?reftype={@id}&amp;create=1&amp;r={/document/context/object/@id}&amp;objtype=ReferenceLibraryItem"><xsl:value-of select="name"/></a></li>
</xsl:template>

<xsl:template match="reference_type" mode="selectoptions">
    <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<xsl:template match="reference_type" mode="descriptions">
    <div id="reftype{@id}" style="display: none;"><xsl:value-of select="description"/></div>
</xsl:template>

<xsl:template name="childrenlist">
    <div id="vlchildrenlist">
        <xsl:apply-templates select="children/object" mode="divlist">
            <xsl:sort select="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second)" order="descending"/>
        </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="children/object" mode="divlist">
    <xsl:variable name="date" select="reference_values/reference_value[property_id=$daterefpropid]/value"/>
    <xsl:variable name="btitle" select="reference_values/reference_value[property_id=$btitlerefpropid]/value"/>
    <xsl:variable name="serial_id" select="serial_id"/>
    <div class="vlchildrenlistitem ui-widget-content ui-corner-all">
        <div class="reflib_authortitle">
            <xsl:choose>
                <xsl:when test="authorgroup/author">
                    <xsl:apply-templates select="authorgroup/author">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>Anonymous</xsl:otherwise>
            </xsl:choose>:
            <xsl:call-template name="reftitle"/>
            (<a href="{$xims_box}{$goxims_content}{$absolute_path}?reference_type_id={current()/reference_type_id}"><xsl:value-of select="/document/reference_types/reference_type[@id=current()/reference_type_id]/name"/></a>)
        </div>
        <div class="reflib_published">
            <strong><xsl:value-of select="$i18n/l/Published"/></strong>:
            <xsl:if test="$date != ''">
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?date={$date}">
                <xsl:value-of select="$date"/>
            </a>
            </xsl:if>
            <xsl:if test="$serial_id != '' or $btitle != ''">&#160;
                <strong><xsl:value-of select="$i18n/l/in"/></strong>:
                <xsl:choose>
                    <xsl:when test="$serial_id != ''">
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?serial_id={$serial_id}">
                            <xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$btitle"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </div>
        <xsl:if test="editorgroup/author">
            <div class="reflib_editors">
                <strong><xsl:value-of select="$i18n_vlib/l/editors"/></strong>:
                    <xsl:apply-templates select="editorgroup/author">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
            </div>
        </xsl:if>
        
        <div>
        <xsl:call-template name="last_modified"/>
        
        <xsl:call-template name="state-toolbar"/>
		<xsl:call-template name="options-toolbar">
			<xsl:with-param name="email-disabled" select="true()"/>
			<xsl:with-param name="copy-disabled" select="true()"/>
			<xsl:with-param name="move-disabled" select="true()"/>
			<xsl:with-param name="forcepurge" select="true()"/>
		</xsl:call-template>
       </div>
        <div class="vlabstract"><xsl:comment/>
            <xsl:apply-templates select="abstract"/>
        </div>
    </div>
</xsl:template>

<xsl:template name="last_modified">
        <strong>
            <xsl:value-of select="$i18n/l/Last_modified"/>:
        </strong>
        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
</xsl:template>

<xsl:template name="reftitle">
	<xsl:param name="reftitle"><xsl:value-of select="reference_values/reference_value[property_id=$titlerefpropid]/value"/></xsl:param>
<xsl:if test="$reftitle != ''">
    <span class="reftitle">
        <a  title="{location}" href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
            <xsl:value-of select="$reftitle"/>
        </a>
    </span>
    </xsl:if>
</xsl:template>

<xsl:template name="items_page_info">
	<div id="itemsinfo">
    (<xsl:value-of select="$objectitems_count"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="decide_plural"/>
    <xsl:if test="$onepage = '' and $totalpages > 0">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$i18n_vlib/l/Page"/>
        <xsl:text> </xsl:text><xsl:value-of select="$page"/>/<xsl:value-of select="$totalpages"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
    </div>
</xsl:template>

<xsl:template name="decide_plural">
    <xsl:choose>
        <xsl:when test="number($objectitems_count) = 1">
            <xsl:value-of select="$i18n_vlib/l/item"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$i18n_vlib/l/items"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="reflib.authorsearch">
	<div id="reflib_authorsearch">
		<form action="{$xims_box}{$goxims_content}{$absolute_path}" name="rlsearch">
			<label for="reflibsearch"><strong><xsl:value-of select="$i18n/l/Search"/></strong></label>&#160;&#160;
			<input type="text" name="reflibsearch" id="reflibsearch" size="45" maxlength="200">
				<xsl:if test="$reflibsearch != ''">
					<xsl:attribute name="value"><xsl:value-of select="$reflibsearch"/></xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$reflibsearch != ''">
						<xsl:attribute name="value"><xsl:value-of select="$reflibsearch"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value">[Example: <em>zoller serial:"Phys. Rev" date:2005</em>]</xsl:attribute>
						<xsl:attribute name="onfocus">document.rlsearch.reflibsearch.value=&apos;&apos;;</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<xsl:text>&#160;</xsl:text>
			<button class="button-search" type="submit" name="submit" title="{$i18n/l/Search}">
				<xsl:value-of select="$i18n/l/Search"/>
			</button>
			<!--&#160;&#160;<a href="javascript:openDocWindow('SearchingReferenceLibraries')" class="doclink">(?)</a>-->
		</form>
	</div>
</xsl:template>

<xsl:template name="reflib.options">
	<div id="reflib-options">
		<xsl:call-template name="reflib_citationview"/>
		<xsl:call-template name="reflib_exportwidget"/>
		&#160;
    </div>
</xsl:template>

<xsl:template name="reflib_exportwidget">
 <div id="expmods">
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" id="export" name="export">
        <xsl:if test="$reflibsearch != ''">
            <input type="hidden" name="reflibsearch" value="{$reflibsearch}"/>
        </xsl:if>
        <input type="hidden" name="author_lname" value="{$author_lname}"/>
        <input type="hidden" name="author_id" value="{$author_id}"/>
        <input type="hidden" name="serial_id" value="{$serial_id}"/>
        <input type="hidden" name="date" value="{$date}"/>
        <input type="hidden" name="style" value="export_mods"/>
        <button type="submit" class="button" name="export"><xsl:value-of select="$i18n/l/ExpMODS"/></button>
    </form>
    </div> 
</xsl:template>

<xsl:template name="reflib_citationview">
<div id="citstyle">
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" id="citation_view" name="citation_view">
    <label for="style"><xsl:value-of select="$i18n/l/ViewCit"/></label>&#160;
        <select name="style" id="style">
            <option value="cv_defaultstyle" selected="selected">default style</option>
            <option value="cv_printstyle">print style</option>
            <option value="cv_wordmlstyle">WordML</option>
        </select>&#160;
        <xsl:if test="$reflibsearch != ''">
            <input type="hidden" name="reflibsearch" value="{$reflibsearch}"/>
        </xsl:if>
        <input type="hidden" name="author_lname" value="{$author_lname}"/>
        <input type="hidden" name="author_id" value="{$author_id}"/>
        <input type="hidden" name="serial_id" value="{$serial_id}"/>
        <input type="hidden" name="date" value="{$date}"/>
        <button type="submit" class="button" name="citations">ok</button>
    </form>
    &#160;
    </div>
</xsl:template>

</xsl:stylesheet>
