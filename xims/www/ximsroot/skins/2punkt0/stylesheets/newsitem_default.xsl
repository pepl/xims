<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="view_common.xsl"/>
	<xsl:import href="document_default.xsl"/>
	
	<xsl:template name="view-content">
	<div id="docbody">
							<xsl:choose>
								<xsl:when test="string-length(image_id)">
									<div>
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
								<table class="link-table">
									<thead>
										<tr>
											<th>
												<xsl:value-of select="$i18n/l/Status"/>
											</th>
											<th>
												<xsl:value-of select="$i18n/l/Position"/>
											</th>
											<th>
												<xsl:value-of select="$i18n/l/Title"/>
											</th>
											<th>
												<xsl:value-of select="$i18n/l/Options"/>
											</th>
										</tr>
									</thead>
									<tbody>
										<xsl:apply-templates select="children/object" mode="link">
											<xsl:sort select="position" data-type="number"/>
										</xsl:apply-templates>
									</tbody>
								</table>
								<p>
									<br/>
									<xsl:if test="user_privileges/create">
										<a href="{$goxims_content}{$absolute_path}?create=1;objtype=URLLink">
											<xsl:value-of select="$i18n/l/Add_link"/>
										</a>
									</xsl:if>
								</p>
							</div>
						</div>
	</xsl:template>
	
</xsl:stylesheet>
