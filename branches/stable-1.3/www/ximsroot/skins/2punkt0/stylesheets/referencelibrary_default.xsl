<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
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

    <xsl:param name="onepage"/>
    <xsl:param name="date"/>
    <xsl:param name="author_id"/>
    <xsl:param name="serial_id"/>
    <xsl:param name="author_lname"/>
    <xsl:param name="reference_type_id"/>
    <xsl:param name="workgroup_id"/>
    <xsl:param name="reflibsearch"/>

    <xsl:variable name="objectitems_count"><xsl:choose><xsl:when test="/document/context/object/children/@totalobjects"><xsl:value-of select="/document/context/object/children/@totalobjects"/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:variable>
   
		<!-- #TODO put pagerowlimit in config-file-->
    <xsl:variable name="objectitems_rowlimit" select="'20'"/>
    <xsl:variable name="totalpages" select="ceiling($objectitems_count div $objectitems_rowlimit)"/>

    <!--<xsl:variable name="subjectcolumns" select="'3'"/>-->

    <xsl:template match="/document/context/object">
        <xsl:variable name="pagenavurl">
					<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?date=',$date,';serial_id=',$serial_id,';author_id=',$author_id,';author_lname=',$author_lname,';workgroup_id=',$workgroup_id)"/>
					<xsl:if test="$reflibsearch != ''"><xsl:value-of select="concat(';reflibsearch=',$reflibsearch)"/></xsl:if>
				</xsl:variable>
        <html>
            <xsl:call-template name="head_default"><xsl:with-param name="reflib">true</xsl:with-param></xsl:call-template>
            <body>
                <xsl:call-template name="header"/>
                <div id="main-content">
									<xsl:call-template name="options-menu-bar"/>
									<div id="content-container" class="ui-corner-bottom ui-corner-tr">
									<xsl:call-template name="reflib.options"/>
										
										<div id="docbody">
<div id="search-filter">
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
                                &#160;&#160;&#160;
                                        <xsl:call-template name="items_page_info"/>
                    </div>

                    <xsl:call-template name="reflib.authorsearch"/>
                    &#160;
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
                </div>
                <!--<xsl:call-template name="script_bottom"/>-->
                <!--<script src="{$ximsroot}skins/{$currentskin}/scripts/tooltip.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>-->
                </div>
                </div>
            </body>
        </html>
    </xsl:template>

<xsl:template name="reference_type.createwidget">
		<div>
		<a class="flyout create-widget fg-button fg-button-icon-right ui-state-default ui-corner-all" tabindex="0" href="#ref-types">
			<span class="ui-icon ui-icon-triangle-1-s"/>
			<xsl:value-of select="$i18n/l/Create"/>
		</a> 
		<div id="ref-types" class="hidden-content">
			<ul>
					<xsl:apply-templates select="/document/reference_types/reference_type" mode="getoptions"/>
			</ul>
			</div>
    <!--<xsl:apply-templates select="/document/reference_types/reference_type" mode="descriptions"/>-->
    <noscript>
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" id="reftype_creator" name="reftype_creator">
				
        <select name="reftype" id="reftype">
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
    <li><a href="{$xims_box}{$goxims_content}{$absolute_path}?reftype={@id};create=1;r={/document/context/object/@id};objtype=ReferenceLibraryItem"><xsl:value-of select="name"/></a></li>
</xsl:template>

<xsl:template match="reference_type" mode="selectoptions">
    <option value="{@id}"><xsl:value-of select="name"/></option>
</xsl:template>

<!--<xsl:template match="reference_type" mode="descriptions">
    <div id="reftype{@id}" style="display: none;"><xsl:value-of select="description"/></div>
</xsl:template>

<xsl:template name="head_default">
    <head>
        <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
        <script src="{$jquery}" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="jquery-listitems-bg">
          <xsl:with-param name="pick" select="'div.vlchildrenlistitem'"/>
        </xsl:call-template>

        <style type="text/css">
          #fixedtipdiv{
              position:absolute;
              padding: 2px;
              border:1px solid black;
              font: normal 10pt helvetica, arial, sans-serif;
              line-height: 18px;
              z-index: 100;
          }
        </style>
    </head>
</xsl:template>-->

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
                <xsl:otherwise>
                    Anonymous</xsl:otherwise>
            </xsl:choose>:
            <xsl:call-template name="reftitle"/>
            (<a href="{$xims_box}{$goxims_content}{$absolute_path}?reference_type_id={current()/reference_type_id}"><xsl:value-of select="/document/reference_types/reference_type[@id=current()/reference_type_id]/name"/></a>)
        </div>
        <div class="reflib_published">
            <strong><xsl:value-of select="$i18n/l/Published"/></strong>:
            <a href="{$xims_box}{$goxims_content}{$absolute_path}?date={$date}">
                <xsl:value-of select="$date"/>
            </a>
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
        <xsl:call-template name="cttobject.status"/>
        <xsl:call-template name="cttobject.options"/>

       </div>
        <div class="vlabstract">
            <xsl:apply-templates select="abstract"/>
        </div>
    </div>
</xsl:template>

<xsl:template name="last_modified">
    <!--<span class="vllastmodified">-->
        <strong>
            <xsl:value-of select="$i18n/l/Last_modified"/>:
        </strong>
        <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
    <!--</span>-->
</xsl:template>

<xsl:template name="reftitle">
    <span class="reftitle">
        <a  title="{location}"
            href="{$xims_box}{$goxims_content}{$absolute_path}/{location}">
            <xsl:value-of select="reference_values/reference_value[property_id=$titlerefpropid]/value"/>
        </a>
    </span>
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
                       <label for="reflibsearch"><xsl:value-of select="$i18n/l/Search"/></label>&#160;&#160;
											<!--:<br/>Example: <em>zoller serial:"Phys. Rev" date:2005</em>-->
                        <input type="text" name="reflibsearch" id="reflibsearch" size="42" maxlength="200">
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
																<xsl:attribute name="aria-label"><xsl:value-of select="$i18n/l/Search"/></xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
                        </input>
                        <xsl:text>&#160;</xsl:text>
                        
                        <button class="ui-state-default ui-corner-all fg-button fg-button-icon-left" type="submit" name="submit" title="{$i18n/l/Search}">
					<span class="ui-icon ui-icon-search"/>
					<span class="text">
						<xsl:value-of select="$i18n/l/Search"/>
					</span>
				</button>
				&#160;&#160;<a href="javascript:openDocWindow('SearchingReferenceLibraries')" class="doclink">(?)</a>
                    </form>
                    
                    </div>
</xsl:template>

<xsl:template name="reflib.options">
   
    <div id="new-ref">
			<div><xsl:value-of select="$i18n/l/CreateRef"/>&#160;&#160;</div>
			<xsl:call-template name="reference_type.createwidget"/> 
			<div>&#160;&#160;<xsl:value-of select="$i18n/l/or"/>&#160;&#160;</div>
			<div><a href="{$xims_box}{$goxims_content}{$absolute_path}?import_prompt=1" class="ui-state-default ui-corner-all fg-button"><xsl:value-of select="$i18n/l/Import"/></a></div>
			&#160;
		</div>	
<!--<br clear="all"/>-->
 <div id="reflib-options">
    
      <xsl:call-template name="reflib_citationview"/>

       <xsl:call-template name="reflib_exportwidget"/>
      &#160;
    </div>
   <!-- <br clear="all"/>-->
</xsl:template>

<xsl:template name="reflib_exportwidget">
 <div id="expmods">
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" id="export" name="export">
    <xsl:value-of select="$i18n/l/ExpMODS"/>&#160;
        <xsl:if test="$reflibsearch != ''">
            <input type="hidden" name="reflibsearch" value="{$reflibsearch}"/>
        </xsl:if>
        <input type="hidden" name="author_lname" value="{$author_lname}"/>
        <input type="hidden" name="author_id" value="{$author_id}"/>
        <input type="hidden" name="serial_id" value="{$serial_id}"/>
        <input type="hidden" name="date" value="{$date}"/>
        <input type="hidden" name="style" value="export_mods"/>
        <input type="submit" class="ui-state-default ui-corner-all fg-button" name="export" value="ok"/>
    </form>
    &#160;
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
        <input type="submit" class="ui-state-default ui-corner-all fg-button" name="citations" value="ok"/>
    </form>
    &#160;
    </div>
</xsl:template>

</xsl:stylesheet>
