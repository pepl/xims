<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="document_default.xsl"/>
<xsl:import href="common_jscalendar_scripts.xsl"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default">
					<xsl:with-param name="calendar">true</xsl:with-param>
				</xsl:call-template>
        <body onLoad="stringHighlight(getParamValue('hls'))">
            <!-- poor man's stylechooser -->
            <xsl:choose>
                <xsl:when test="$printview != '0'">
                    <xsl:call-template name="document-metadata"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="header"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="toggle_hls"/>
            
          <div id="main-content" class="ui-corner-all">
					<xsl:call-template name="options-menu-bar"/>
					<div id="table-container" class="ui-corner-bottom ui-corner-tr">  
            
            <div id="docbody">
            <span id="body">
							 <xsl:choose>
									<xsl:when test="string-length(image_id)">
										<img src="{$goxims_content}{image_id}" width="170" height="130" alt="{image_id}" title="{image_id}" class="news-image"/>
										<div class="newsdate" id="newsdate">
                                                <script type="text/javascript">
                                                    current_date = Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
                                                    document.getElementById("newsdate").innerHTML = current_date;
                                                </script>
                                            </div>
                                            <div class="newslead">
                                                <xsl:apply-templates select="abstract"/>
                                            </div>
									</xsl:when>
									<xsl:otherwise>
									<div class="newsdate" id="newsdate">
                                                <script type="text/javascript">
                                                    current_date = Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
                                                    document.getElementById("newsdate").innerHTML = current_date;
                                                </script>
                                            </div>
                                            <div class="newslead">
                                                <xsl:apply-templates select="abstract"/>
                                            </div>
									</xsl:otherwise>
							</xsl:choose>
              <div id="body-content">                  
							<xsl:apply-templates select="body"/>
							</div>
							
							<div id="links">
								<p>
									<strong>
										<xsl:value-of select="$i18n/l/Document_links"/>
									</strong>
									</p>
								<p>
									<xsl:apply-templates select="children/object" mode="link">
										<xsl:sort select="position" data-type="number"/>
									</xsl:apply-templates>
								</p>
								<p>
									<xsl:if test="$m='e' and user_privileges/create">
										<a href="{$goxims_content}{$absolute_path}?create=1;objtype=URLLink">
											<xsl:value-of select="$i18n/l/Add_link"/>
										</a>
									</xsl:if>
								</p>
							</div>       
            </span>
            </div>
           <div id="metadata-options">
							<div id="user-metadata">
								<xsl:call-template name="user-metadata"/>
							</div>
							<div id="document-options">
								<xsl:call-template name="document-options"/>
							</div>
						</div>
<!--                        <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="document-options"/>
            </table>-->
            </div>
            </div>

            
<!--            <xsl:call-template name="script_bottom"/>-->
            <!--<xsl:call-template name="jscalendar_scripts"/>-->
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

