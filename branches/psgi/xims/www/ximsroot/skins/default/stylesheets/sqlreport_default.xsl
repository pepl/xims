<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: sqlreport_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common_search_result.xsl"/>

<xsl:import href="view_common.xsl"/>

<xsl:variable name="pagesize"><xsl:value-of select="document(concat($xims_home,'/conf/conf.d/sqlreportconfig.xml'))/Config/General/SQLReportPagesize"/></xsl:variable>

<xsl:param name="navparam"/>
<xsl:param name="onepage"/>
<xsl:variable name="totalpages" select="ceiling($objectitems_count div $pagesize)"/>

<xsl:template name="view-content">
<xsl:if test="abstract/text() != ''">
							<div><strong><xsl:apply-templates select="abstract"/></strong></div>
                </xsl:if>
							<div id="docbody"><xsl:comment/>
                        <span id="body">
                            <xsl:apply-templates select="body"/>
                        </span>
							</div>
							<xsl:if test="$onepage = '' and $totalpages &gt; 1">
								<div id="pagenav">
                            <xsl:call-template name="pagenav">
                                <xsl:with-param name="totalitems" select="/document/context/session/searchresultcount"/>
                                <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
                                <xsl:with-param name="currentpage" select="$page"/>
                                <xsl:with-param name="url"
                                                select="concat($xims_box,$goxims_content,$absolute_path,'?',$navparam)"/>
                            </xsl:call-template>
							 </div>
            </xsl:if>
</xsl:template>

</xsl:stylesheet>

