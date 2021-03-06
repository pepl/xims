<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: view_common.xsl 2188 2009-01-03 18:24:00Z susannetober $
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <xsl:import href="common.xsl"/>
  <xsl:import href="document_common.xsl"/>
  
  <xsl:param name="createwidget">false</xsl:param>
  <xsl:param name="sitestyle" select="false()"/>
  <xsl:param name="ap-pres" select="false()"/>
  <xsl:param name="reflib" select="false()"/>
  <xsl:param name="vlib" select="false()"/>
  <xsl:param name="simpledb" select="false()"/>
  <xsl:param name="questionnaire" select="false()"/>
  <xsl:param name="parent_id" />
  
  <xsl:template match="/document/context/object">

	<xsl:variable name="dataformat">
	  <xsl:value-of select="data_format_id"/>
	</xsl:variable>
	<xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
	<xsl:variable name="dfname" select="$df/name"/>
	<!--<xsl:variable name="dfmime" select="$df/mime_type"/>-->
	
	<html>
	  <xsl:call-template name="head_default">
		<xsl:with-param name="sitestyle" select="$sitestyle"/>
		<xsl:with-param name="ap-pres" select="$ap-pres"/>
		<xsl:with-param name="reflib" select="$reflib"/>
		<xsl:with-param name="vlib" select="$vlib"/>
		<xsl:with-param name="simpledb" select="$simpledb"/>
		<xsl:with-param name="questionnaire" select="$questionnaire"/>
	  </xsl:call-template>
	  <body>
		<!-- poor man's stylechooser -->
		<xsl:choose>
		  <xsl:when test="$printview != '0'">
			<xsl:call-template name="document-metadata"/>
		  </xsl:when>
		  <xsl:otherwise>
			<xsl:call-template name="header"/>
		  </xsl:otherwise>
		</xsl:choose>
		<div id="main-content">
		  <xsl:call-template name="options-menu-bar">
			<xsl:with-param name="createwidget" select="$createwidget"/>
			<xsl:with-param name="parent_id" select="$parent_id"/>
		  </xsl:call-template>
		  <div id="content-container" class="ui-corner-bottom ui-corner-tr">
					
			<xsl:call-template name="view-content"/>
            
			<div id="metadata-options">
			  <xsl:call-template name="user-metadata"/>
              <xsl:if test="$objtype='Document' or $objtype='NewsItem'">
				<div id="document-options">
				  <xsl:call-template name="document-options"/>
				</div>
			  </xsl:if>
			</div>
		  </div>
		</div>
		<xsl:call-template name="script_bottom">
		  <xsl:with-param name="simpledb" select="$simpledb"/>
		  <xsl:with-param name="reflib" select="$reflib"/>
		  <xsl:with-param name="vlib" select="$vlib"/>
		</xsl:call-template>
	  </body>
	</html>
  </xsl:template>
  
  <xsl:template name="view-content">
  </xsl:template>
  

  <xsl:template name="documentlinks">
    <div id="links">
      <p>
    	<strong><xsl:value-of select="$i18n/l/Document_links"/></strong>
      </p>
      <xsl:if test="(children/@totalobjects = 1 and children/object/location != '.diff_to_second_last' ) or children/@totalobjects > 1">
    	<table class="link-table">
    	  <thead>
    		<tr>
    		  <th><xsl:value-of select="$i18n/l/Status"/></th>
    		  <th><xsl:value-of select="$i18n/l/Position"/></th>
              <th><xsl:value-of select="$i18n/l/Role"/></th>
    		  <th><xsl:value-of select="$i18n/l/Title"/></th>
    		  <th><xsl:value-of select="$i18n/l/Options"/></th>
    		</tr>
    	  </thead>
    	  <tbody>
    		<xsl:apply-templates select="children/object" mode="link">
    		  <xsl:sort select="position" data-type="number"/>
    		</xsl:apply-templates>
    	  </tbody>
    	</table>
      </xsl:if>
      <p>
    	<br/>
    	<xsl:if test="user_privileges/create">
    	  <a href="{$goxims_content}{$absolute_path}?create=1&amp;objtype=URLLink">
    		<xsl:value-of select="$i18n/l/Add_link"/>
    	  </a>
    	</xsl:if>
      </p>
    </div>
  </xsl:template>

  <xsl:template name="summary_keywords">
	<div class="docbox">
	  <p>
		<strong><xsl:value-of select="$i18n/l/Abstract"/>:</strong>
	  </p>
	  <xsl:choose>
		<xsl:when test="abstract != ''">
		  <p>
			<xsl:copy-of select="abstract/node()"/>
		  </p>
		</xsl:when>
		<xsl:otherwise>
		  <p><span class="warning_msg"><xsl:value-of select="$i18n/l/NoAbstractProvided"/></span></p>
		</xsl:otherwise>
	  </xsl:choose>			
	</div>
	<div class="docbox">
	  <p>
		<strong><xsl:value-of select="$i18n/l/Keywords"/>:</strong>
	  </p>
	  <xsl:choose>
		<xsl:when test="keywords != ''">
		  <p>
			<xsl:value-of select="keywords"/>
		  </p>
		</xsl:when>
		<xsl:otherwise>
		  <p><span class="warning_msg"><xsl:value-of select="$i18n/l/NoKeywordsProvided"/></span></p>
		</xsl:otherwise>
	  </xsl:choose>			
	</div>
  </xsl:template>

  <xsl:template name="summary_rights">
	<div class="docbox">
	  <p>
		<strong><xsl:value-of select="$i18n/l/Rights"/>:</strong>
	  </p>
	  <xsl:choose>
		<xsl:when test="rights != ''">
		  <p>
			<xsl:copy-of select="rights/node()"/>
		  </p>
		</xsl:when>
		<!-- <xsl:otherwise> -->
		<!-- <p><span class="warning_msg"><xsl:value-of select="$i18n/l/NoAbstractProvided"/></span></p> -->
		<!-- </xsl:otherwise> -->
	  </xsl:choose>			
	</div>
   </xsl:template>
  
	
</xsl:stylesheet>
