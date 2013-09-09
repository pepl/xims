<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: sqlreport_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="../sqlreport_default.xsl"/>
<xsl:import href="common.xsl"/>

<xsl:output method="xml"
            encoding="utf-8"
            media-type="text/html" 
            doctype-system="about:legacy-compat" 
            indent="no"
            omit-xml-declaration="yes"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <xsl:call-template name="header"/>
        <div id="leftcontent">
            <xsl:call-template name="stdlinks"/>
            <xsl:call-template name="departmentlinks"/>
            <xsl:call-template name="documentlinks"/>
        </div>
        <div id="centercontent">
            <xsl:comment>/UdmComment</xsl:comment>
            <xsl:apply-templates select="body"/>

            <xsl:if test="$totalpages &gt; 1">
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

            <div id="footer">
                <span class="left">
                    <xsl:call-template name="copyfooter"/>
                </span>
                <span class="right">
                    <xsl:call-template name="powerdbyfooter"/>
                </span>
            </div>
        </div>
        <xsl:call-template name="script_bottom"/>
      </body>
</html>
</xsl:template>

</xsl:stylesheet>
