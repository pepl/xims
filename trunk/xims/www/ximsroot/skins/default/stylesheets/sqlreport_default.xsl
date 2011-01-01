<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common_search_result.xsl"/>

<xsl:variable name="pagesize"><xsl:value-of select="document(concat($xims_home,'/conf/conf.d/sqlreportconfig.xml'))/Config/General/SQLReportPagesize"/></xsl:variable>

<xsl:param name="navparam"/>
<xsl:param name="onepage"/>
<xsl:variable name="totalpages" select="ceiling($objectitems_count div $pagesize)"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <xsl:call-template name="header"/>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <xsl:if test="abstract/text() != ''">
                    <tr>
                        <td colspan="2">
                            <strong><xsl:apply-templates select="abstract"/></strong>
                        </td>
                    </tr>
                </xsl:if>
                <tr>
                    <td colspan="2">
                        <xsl:apply-templates select="body"/>
                    </td>
                </tr>
            </table>
            <xsl:if test="$onepage = '' and $totalpages &gt; 1">
                <table style="margin-left:5px; margin-right:10px; margin-top: 10px; margin-bottom: 10px; width: 99%; padding: 3px; border: thin solid #C1C1C1; background: #F9F9F9 font-size: small;" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <xsl:call-template name="pagenav">
                                <xsl:with-param name="totalitems" select="/document/context/session/searchresultcount"/>
                                <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
                                <xsl:with-param name="currentpage" select="$page"/>
                                <xsl:with-param name="url"
                                                select="concat($xims_box,$goxims_content,$absolute_path,'?m=',$m,';',$navparam)"/>
                            </xsl:call-template>
                        </td>
                    </tr>
                </table>
            </xsl:if>

            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>
</xsl:stylesheet>

