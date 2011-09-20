<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_default.xsl 2387 2009-12-17 14:07:58Z susannetober $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="document_default.xsl"/>
<xsl:import href="common_jscalendar_scripts.xsl"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body onload="stringHighlight(getParamValue('hls'))">
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
            
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <tr>
                    <td>
                        <table>
                            <tr><td colspan="2"><h1 class="newstitle"><xsl:value-of select="title"/></h1></td></tr>
                            <xsl:choose>
                                <xsl:when test="string-length(image_id)">
                                    <tr>
                                        <td width="180">
                                            <img src="{$goxims_content}{image_id}" width="170" height="130" alt="{image_id}" title="{image_id}"/>
                                        </td>
                                        <td valign="top">
                                            <div class="newsdate" id="newsdate">
                                                <script type="text/javascript">
                                                		
                                                    current_date = Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
                                                    document.getElementById("newsdate").innerHTML = current_date;
                                                </script>
                                            </div>
                                            <div class="newslead">
                                                <xsl:apply-templates select="abstract"/>
                                            </div>
                                        </td>
                                    </tr>
                                </xsl:when>
                                <xsl:otherwise>
                                    <tr>
                                        <td valign="top" colspan="2">
                                            <div class="newsdate" id="newsdate">
                                                <script type="text/javascript">
                                                		var Date = new Date();
                                                    current_date = Date.parseDate("<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>", "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
                                                    document.getElementById("newsdate").innerHTML = current_date;
                                                </script>
                                            </div>
                                            <div class="newslead">
                                                <xsl:apply-templates select="abstract"/>
                                            </div>
                                        </td>
                                    </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td bgcolor="#ffffff" colspan="2">
                        <xsl:apply-templates select="body"/>
                    </td>
                </tr>
                <tr>
                    <td valign="top" width="40%" style="border:1px solid;">
                        <table width="100%" border="0">
                            <tr>
                                <td width="60%" colspan="2"><strong><xsl:value-of select="$i18n/l/Document_links"/></strong></td>
                                <xsl:if test="$m='e' and user_privileges/create">
                                    <td width="40%" align="right">
                                        <a href="{$goxims_content}{$absolute_path}?create=1;objtype=URLLink"><xsl:value-of select="$i18n/l/Add_link"/></a>
                                        <xsl:text>&#160;&#160;</xsl:text>
                                    </td>
                                </xsl:if>
                            </tr>
                           <xsl:apply-templates select="children/object" mode="link">
                                <xsl:sort select="position" data-type="number"/>
                           </xsl:apply-templates>
                        </table>
                    </td>
                    <td valign="top" width="60%" style="border:1px solid;">
                        <table width="100%" border="0">
                            <tr>
                                <td><strong>Annotation</strong></td>
                                <td colspan="2">
                                    <xsl:if test="$m='e' and user_privileges/create">
                                        <!--<a href="{$goxims_content}{$absolute_path}?create=1;objtype=Annotation">-->Annotation hinzufügen<!--</a>-->
                                        <xsl:text>&#160;&#160;</xsl:text>
                                    </xsl:if>
                                </td>
                            </tr>

                            <xsl:apply-templates select="children/object" mode="comment"/>
                        </table>
                    </td>
                </tr>
            </table>
            
            <table align="center" width="98.7%" class="footer">
                <xsl:call-template name="user-metadata"/>
                <xsl:call-template name="document-options"/>
                <xsl:call-template name="footer"/>
            </table>
            <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

<xsl:template name="head_default">
		<head>
			<title>
				<xsl:call-template name="title"/>
			</title>
			<xsl:call-template name="css"/>
			<xsl:call-template name="script_head"/>
			<xsl:call-template name="jscalendar_scripts"/>
		</head>
	</xsl:template>

</xsl:stylesheet>

