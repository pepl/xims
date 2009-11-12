<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: xml_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:param name="msie" select="0"/>

<xsl:variable name="sfe"><xsl:if test="/document/context/object/schema_id != '' and contains(/document/context/object/attributes, 'sfe=1')">1</xsl:if></xsl:variable>

<xsl:variable name="bxe"><xsl:if test="/document/context/object/schema_id != '' and /document/context/object/css_id != '' 
                                       and contains(/document/context/object/attributes, 'bxeconfig_id')
                                       and contains(/document/context/object/attributes, 'bxexpath')
                                       and contains(/document/context/object/attributes, 'sfe=1')">1</xsl:if></xsl:variable>

<xsl:variable name="i18n_xml" select="document(concat($currentuilanguage,'/i18n_xml.xml'))"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body onLoad="stringHighlight(getParamValue('hls'))">
            <xsl:call-template name="header"/>
            <xsl:call-template name="toggle_hls"/>
            
            <div id="main-content" class="ui-corner-all">
						<xsl:call-template name="options-menu-bar"/>
						<div id="content-container" class="ui-corner-bottom ui-corner-tr">
							<div id="docbody">
                        <span id="body">
                                                     <xsl:choose>
                                <xsl:when test="$msie=0">
                                    <xsl:apply-templates select="body"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <pre>
                                        <xsl:apply-templates select="body"/>
                                    </pre>
                                </xsl:otherwise>
                            </xsl:choose>
                       <!--     <xsl:apply-templates select="body"/>-->
                        </span>
							</div>
           <div id="metadata-options">
							<div id="user-metadata">
								<xsl:call-template name="user-metadata"/>
							</div>
							<div id="document-options">
                <xsl:if test="$sfe = '1' or $bxe = '1'">
                            <xsl:if test="$sfe = '1'">
                                <a href="{$xims_box}{$goxims_content}?id={@id};simpleformedit=1">
                                    <xsl:value-of select="$i18n_xml/l/Edit_with_SFE"/>
                                </a>
                                <xsl:text> </xsl:text>
                            </xsl:if>

                            <xsl:if test="$bxe = '1'">
                                <a href="{$xims_box}{$goxims_content}?id={@id};edit=bxe">
                                    <xsl:value-of select="$i18n_xml/l/edit_with_BXE"/>
                                </a>
                            </xsl:if>
                </xsl:if>
							</div>
						</div>
					</div>
				</div>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
