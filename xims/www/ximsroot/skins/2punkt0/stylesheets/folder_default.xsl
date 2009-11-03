<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: folder_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="container_common.xsl"/>
	<xsl:variable name="deleted_children">
		<xsl:value-of select="count(/document/context/object/children/object[marked_deleted=1])"/>
	</xsl:variable>
	<xsl:template match="/document/context/object">
		<!--<xsl:param name="createwidget">true</xsl:param>
		<xsl:param name="parent_id"/>
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
		<xsl:variable name="dfname" select="$df/name"/>
		<xsl:variable name="dfmime" select="$df/mime_type"/>-->
		<html>
			<xsl:call-template name="head_default"/>
			<body>
				<script language="javascript" type="text/javascript" src="{$ximsroot}scripts/search_filter.js"/>
				<xsl:call-template name="header">
					<xsl:with-param name="createwidget">true</xsl:with-param>
				</xsl:call-template>
				<div id="main-content">
					<xsl:call-template name="options-menu-bar"/>
					<!--<div id="tab-container" class="ui-corner-top">
						<div id="tab-cell1">
							<xsl:call-template name="cttobject.dataformat">
								<xsl:with-param name="dfname" select="$dfname"/>
							</xsl:call-template>
							<xsl:value-of select="title"/>
						</div>
						<div id="tab-cell3">
							<xsl:call-template name="cttobject.options"/>
							<xsl:call-template name="cttobject.options.send_email"/>
						</div>
						<div id="tab-cell2">
							<xsl:call-template name="cttobject.status"/>
						</div>
						<div id="create">
						<xsl:if test="/document/context/object/user_privileges/create
                            and $createwidget = 'true'
                            and /document/object_types/object_type[can_create]">
							<xsl:call-template name="header.cttobject.createwidget">
								<xsl:with-param name="parent_id">
									<xsl:value-of select="$parent_id"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					</div>
					</div>-->
					<div id="right-empty-div-cell">&#160;</div>
					<div id="table-container" class="ui-corner-bottom ui-corner-tr">
						<xsl:call-template name="childrentable"/>
						<xsl:call-template name="pagenavtable"/>
					</div>
				</div>
				<!--<script src="{$ximsroot}skins/{$currentskin}/scripts/defcontmin.js" type="text/javascript">
					<xsl:text>&#160;</xsl:text>
				</script>-->
			</body>
		</html>
	</xsl:template>
	
<!--	<xsl:template name="head_default">
		<head>
			<title>
				<xsl:call-template name="title"/>
			</title>
			<xsl:call-template name="css">
				<xsl:with-param name="jquery-ui-smoothness">true</xsl:with-param>
				<xsl:with-param name="fg-menu">true</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="script_head">
				<xsl:with-param name="jquery">true</xsl:with-param>
				<xsl:with-param name="fg-menu">true</xsl:with-param>
				--><!--<xsl:with-param name="data-tables">false</xsl:with-param>--><!--
			</xsl:call-template>
			<script language="JavaScript" type="text/javascript">
				//var langloc = '<xsl:value-of select="concat($ximsroot,'jquery/dataTables-1.5/language/de.txt')"/>';
        $(document).ready(function(){ 
						setARIARoles();
						initCreateMenu();
						initHelpMenu();
						initMenuMenu();
						//initTabs();
						//initObjTable();
						//IE hack							
						jQuery.each(jQuery.browser, function(i) {
							if($.browser.msie){
							}
						});  
        });
        </script>
		</head>
	</xsl:template>-->
	
	<xsl:template name="deleted_objects">
		<xsl:choose>
			<xsl:when test="$hd=0 and $deleted_children > 0">
				<div class="deleted_objects">
					<a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=1">Hide deleted Objects</a>
				</div>
			</xsl:when>
			<xsl:when test="$deleted_children > 0">
				<div class="deleted_objects">
					<a href="{$xims_box}{$goxims_content}{$absolute_path}?sb={$sb};order={$order};m={$m};page={$page};hd=0">Show the  <xsl:value-of select="$deleted_children"/> deleted Object(s) in this Container</a>
				</div>
			</xsl:when>
			<xsl:otherwise>
            </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	


</xsl:stylesheet>
