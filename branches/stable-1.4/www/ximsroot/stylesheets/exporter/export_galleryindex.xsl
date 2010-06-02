<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: export_auto_index.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
    <!--$Id: export_auto_index.xsl 2188 2009-01-03 18:24:00Z pepl $-->

    <xsl:import href="../common.xsl"/>

    <xsl:output method="xml"/>

<xsl:param name="thumbnail-pos" select="/document/context/object/attributes/thumbpos"/>
<xsl:variable name="img-count" select="count(/document/context/object/children/object[published=1])"/>

<xsl:variable name="scroll-content-width" select="$img-count * 50 + 50"/>
<!--<xsl:variable name="img-width" select="/document/context/object/imgwidth"/>
<xsl:variable name="img-heigth" select="/document/context/object/imgheight"/>-->
<xsl:variable name="img-width" select="/document/context/object/attributes/imgwidth"/>
<xsl:variable name="img-height" select="$img-width * 0.75 "/>
<xsl:variable name="shownav" select="/document/context/object/attributes/shownavigation"/>
<xsl:variable name="showcaption" select="/document/context/object/attributes/showcaption"/>
    
	<xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <xsl:variable name="dataformat">
            <xsl:value-of select="data_format_id"/>
        </xsl:variable>
        <page>
            <xi:include xmlns:xi="http://www.w3.org/2001/XInclude">
							<xsl:attribute name="href"><xsl:call-template name="pathinfoparent_nosite"/>/ou.xml</xsl:attribute>
            </xi:include>
            <gallery>
								<xsl:copy-of select="attributes"/>
						</gallery>
            <rdf:RDF xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                     xmlns:dc  = "http://purl.org/dc/elements/1.1/"
                     xmlns:dcq = "http://purl.org/dc/qualifiers/1.0/">
                <rdf:Description about="">
                    <dc:title><xsl:value-of select="title"/></dc:title>
                    <dc:creator><xsl:call-template name="creatorfullname"/></dc:creator>
                    <dc:subject><xsl:value-of select="keywords"/></dc:subject>
                    <dc:description><xsl:value-of select="abstract"/></dc:description>
                    <dc:publisher><xsl:call-template name="ownerfullname"/></dc:publisher>
                    <dc:contributor><xsl:call-template name="modifierfullname"/></dc:contributor>
                    <dc:date>
                        <dcq:created>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="creation_time" mode="ISO8601"/></rdf:value>
                            </rdf:Description>
                        </dcq:created>
                        <dcq:modified>
                            <rdf:Description>
                                <dcq:dateScheme rdf:resource="http://www.w3.org/TR/NOTE-datetime">W3CDTF</dcq:dateScheme>
                                <rdf:value><xsl:apply-templates select="last_modification_timestamp" mode="ISO8601"/></rdf:value>
                            </rdf:Description>
                        </dcq:modified>
                    </dc:date>
                    <!-- should be mime-type here -->
                    <dc:format><xsl:value-of select="/document/data_formats/data_format[@id=$dataformat]/mime_type"/></dc:format>
                    <!-- still to come -->
                    <!--           <dc:language></dc:language> -->
                </rdf:Description>
            </rdf:RDF>
            <!--<path>
              <xsl:apply-templates select="." mode="path-element"/>
            </path>-->
            <body>
                <h1><xsl:value-of select="title"/></h1>
                <p><xsl:value-of select="abstract"/></p>
                <xsl:apply-templates select="children"/>
            </body>
        </page>
    </xsl:template>


<xsl:template match="/document/context/object/children">
	<xsl:if test="$thumbnail-pos='top'">
			
			<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all">
			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="object"/>
				</ul>
		</div>
		<div class="scroll-bar-wrap ui-widget-content ui-corner-bottom">
			<div class="scroll-bar"></div>
		</div>
	</div>
	<br clear="all"/>
	<div id="main_image">
			<xsl:if test="$shownav = 1">
				<p class="nav">
					<a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
					<a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
				</p>
			</xsl:if>
		</div>
	<br clear="all"/>
	</xsl:if>
	
	<xsl:if test="$thumbnail-pos='left'">
	<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all">
			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="object"/>
				</ul>
		</div>	
	</div>
	<div id="main_image">
		<xsl:if test="$shownav = 1">
				<p class="nav">
					<a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
					<a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
				</p>
			</xsl:if>
	</div>
	</xsl:if>
	
	<xsl:if test="$thumbnail-pos='bottom'">
	<div id="main_image">
		<xsl:if test="$shownav = 1">
				<p class="nav">
					<a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
					<a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
				</p>
			</xsl:if>
	</div>
	<br clear="all"/>	
	
	<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all">
			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="object"/>
				</ul>
		</div>
		<div class="scroll-bar-wrap ui-widget-content ui-corner-bottom">
			<div class="scroll-bar"></div>
		</div>	
	</div>
	<br clear="all"/>
	</xsl:if>
	
	<xsl:if test="$thumbnail-pos='no'">
		<div id="main_image">
			<xsl:if test="$shownav=1">
				<p class="nav">
					<a href="#" onclick="$.galleria.prev(); return false;">&lt;&lt; <!--<xsl:value-of select="$i18n/l/Back"/>--></a> | 
					<a href="#" onclick="$.galleria.next(); return false;"><!--<xsl:value-of select="$i18n/l/Forward"/>--> &gt;&gt;</a>
				</p>
			</xsl:if>
		</div>
	<br clear="all"/>
	
	<div class="div-left scroll-pane ui-widget ui-widget-header ui-corner-all hidden">
			
			<div class="scroll-content">
				<ul class="gallery_demo_unstyled">
				<xsl:apply-templates select="object"/>
				</ul>
		</div>
		<div class="scroll-bar-wrap ui-widget-content ui-corner-bottom">
			<div class="scroll-bar"></div>
		</div>	
	</div>
	<br clear="all"/>
	</xsl:if>
	
</xsl:template>

<xsl:template match="/document/context/object/children/object">
<xsl:if test="object_type_id=3 and published=1">
	<li>
	<xsl:if test="position() = 1"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
	<img src="{location}">
	<xsl:attribute name="alt"><xsl:value-of select="title"/></xsl:attribute>
	<xsl:attribute name="title"><xsl:value-of select="title"/><xsl:if test="$showcaption = '1' and abstract != ''"> : <xsl:value-of select="substring(abstract,0,200)"/></xsl:if></xsl:attribute>
	</img></li>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
