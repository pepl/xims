<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="document_default.xsl"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
            <!-- poor man's stylechooser -->
            <xsl:choose>
                <xsl:when test="$printview != '0'">
                    <xsl:call-template name="document-metadata"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="header"/>
                </xsl:otherwise>
            </xsl:choose>
            <h1 class="documenttitle"><xsl:value-of select="title"/></h1>
            <table align="center" width="98.7%" style="border: 1px solid; margin-top: 0px; padding: 0.5px">
                <xsl:choose>
                    <xsl:when test="string-length(image_id)">
                        <tr>
                            <td>
                                <img src="{$goxims_content}{image_id}"/>
                            </td>
                            <td bgcolor="#dddddd">
                                <!-- should be class newslead! -->
                                <xsl:apply-templates select="abstract"/>
                            </td>
                        </tr>
                    </xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td bgcolor="#dddddd" colspan="2">
                                <!-- should be class newslead! -->
                                <xsl:apply-templates select="abstract"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
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
                                        <a href="{$goxims_content}{$absolute_path}?create=1;parid={@document_id};objtype=URLLink"><xsl:value-of select="$i18n/l/Add_link"/></a>
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
                                        <!--<a href="{$goxims_content}{$absolute_path}?create=1;parid={@document_id};objtype=Annotation">-->Annotation hinzufügen<!--</a>-->
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
                <xsl:call-template name="footer">
                    <xsl:with-param name="link_pub_preview">true</xsl:with-param>
                </xsl:call-template>
            </table>
        <xsl:call-template name="edit-without-wysiwyg"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

