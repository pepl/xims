<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: text_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="../../../stylesheets/text_common.xsl"/>

<xsl:template match="/document/context/object">
<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
    <html>
        <xsl:call-template name="head_default"/>
        <body onLoad="stringHighlight(getParamValue('hls'))">
            <xsl:call-template name="header"/>
            <xsl:call-template name="toggle_hls"/>
            
          <div id="main-content" class="ui-corner-all">
						<xsl:call-template name="options-menu-bar"/>
						<div id="table-container" class="ui-corner-bottom ui-corner-tr">
							<div id="docbody">
                        <span id="body">
                            <xsl:apply-templates select="body"/>
                        </span>
<!--                   macht nur schmarrn...     
<xsl:call-template name="body_display_format_switcher"/>-->
							</div>
           <div id="metadata-options">
							<div id="user-metadata">
								<xsl:call-template name="user-metadata"/>
							</div>
							<div id="document-options">
<!--								<xsl:call-template name="document-options"/>-->
							</div>
						</div>
					</div>
				</div>
            
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

    <xsl:template name="body_display_format_switcher">
        <xsl:choose>
            <xsl:when test="$pre = '0'">
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=1;m={$m}">Zeige Body vorformatiert</a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?pre=0;m={$m}">Zeige Body in Standardformatierung</a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

