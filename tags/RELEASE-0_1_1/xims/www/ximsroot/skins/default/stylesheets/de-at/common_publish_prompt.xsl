<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<!-- $Id$ -->
<xsl:import href="common.xsl"/>
<xsl:import href="../common_publish_prompt.xsl"/>
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png" onLoad="disableIt(document.forms[1].autopublishlinks);">
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>

            <form name="objPublish" action="{$xims_box}{$goxims_content}" method="GET" style="margin-top: 0px; margin-left: 5px;">
                <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
                    <tr>
                        <td align="center">

                            <br />
                            <!-- begin widget table -->
                            <table width="350" cellpadding="2" cellspacing="2" border="0">
                                <tr>
                                    <td class="bluebg">Optionen zum Veröffentlichen für das Objekt '<xsl:value-of select="title"/>'</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Status: Diese Objekt ist zur Zeit
                                            <xsl:if test="published/text()!='1'">
                                                <xsl:text> NICHT </xsl:text>
                                            </xsl:if>
                                            veröffentlicht
                                        </strong>
                                        <xsl:if test="published/text()='1'">
                                            unter <br/><a href="{$publishingroot}{$absolute_path}" target="_new">
                                                <xsl:value-of select="concat($publishingroot,$absolute_path)"/></a>
                                        </xsl:if>
                                    </td>
                                </tr>

                                <!-- warn about ungranded children -->
                                <xsl:if test="message">
                                    <tr>
                                        <td>
                                            Warnung: Das Objekt '<xsl:value-of select="title"/>' hat folgenden Abhängigkeiten
                                            und Sie haben daher nicht die erforderlichen Rechte zum Veröffentlichen des Objekts:
                                            <xsl:call-template name="csv2ul">
                                                <xsl:with-param name="list" select="message"/>
                                            </xsl:call-template>
                                            Diese Objekte werden während des Veröffentlichens übersprungen.
                                        </td>
                                    </tr>
                                </xsl:if>
                                <!-- end warning -->

                                <!-- autoindex -->
                                <xsl:if test="contains( attributes/text(), 'autoindex=1' )">
                                    <tr>
                                        <td>
                                            <strong>Hinweis: Die Autoindexoption ist für diesen Container gesetzt.</strong>
                                            <xsl:choose>
                                                <xsl:when test="published/text()='1'">
                                                    Wenn Sie 'Wiederveröffentlichen' auswählen wird eine Index Datei erstellt.
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    Wenn Sie 'Veröffentlichen' auswählen wird eine Index Datei erstellt.
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <!-- end autoindex -->

                                <tr>
                                    <td>
                                        Klicken Sie
                                        <xsl:choose>
                                            <xsl:when test="published/text()='1'">
                                                'Wiederveröffentlichen'
                                            </xsl:when>
                                            <xsl:otherwise>
                                                'Veröffentlichen'
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        um das aktuelle Objekt zu exportieren,
                                        <xsl:if test="published/text()='1'">
                                            'Veröffentlichen rückgängig machen' um das Objekt vom Live Server zu entfernen,
                                        </xsl:if>
                                        'Abbrechen' um zur vorigen Seite zu gelangen.
                                    </td>
                                </tr>
                                <!-- references -->
                                <tr>
                                    <td align="center">
                                        <!-- begin link table -->
                                        &#160;
                                        <xsl:if test="/document/objectlist/object">
                                            <table cellpadding="2" cellspacing="0" border="0">
                                                <tr>
                                                    <td colspan="3">
                                                        Die folgenden Referenzen wurden im Objekt gefunden
                                                    </td>
                                                </tr>
                                                <xsl:apply-templates select="/document/objectlist/object"/>
                                                <tr>
                                                    <td colspan="3">
                                                        <xsl:text> </xsl:text>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3">
                                                        <table>
                                                            <tr>
                                                                <xsl:choose>
                                                                    <xsl:when test="/document/objectlist/object[location != '']">
                                                                        <td>
                                                                            Automatisch (wieder)veröffentlichen der ausgewählten Links?
                                                                        </td>
                                                                        <td>
                                                                            <input type="checkbox" name="autopublishlinks" value="1" disabled="true"/>
                                                                        </td>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                            <td colspan="2">Es wurden keine Referenzen, (wieder)veröffentlicht werden könnten, zu diesem Objekt gefunden.</td>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                                <!--
                                                                <td>
                                                                    remove unpublished links
                                                                </td>
                                                                <td>
                                                                    <input type="checkbox" name="removelinks" value="1"/>
                                                                </td>
                                                                -->
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </xsl:if>
                                        <!-- end link table -->
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">

                                        <!-- begin buttons table -->
                                        <table cellpadding="2" cellspacing="0" border="0">
                                            <tr align="center">
                                                <td>
                                                    <input name="publish" type="submit" class="control">
                                                        <xsl:choose>
                                                            <xsl:when test="published/text()='1'">
                                                                <xsl:attribute name="value">Wiederveröffentlichen</xsl:attribute>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:attribute name="value">Veröffentlichen</xsl:attribute>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </input>
                                                    <input name="id" type="hidden" value="{$id}"/>
                                                </td>
                                                <xsl:if test="published/text()='1'">
                                                    <td>
                                                        <input name="unpublish" type="submit" value="Veröffentlichen rückgängig machen" class="control"/>
                                                    </td>
                                                </xsl:if>
                                                <td>
                                                    <input name="default" type="button" value="Abbrechen" onClick="javascript:history.go(-1)" class="control"/>
                                                </td>
                                            </tr>
                                        </table>
                                        <!-- end buttons table -->

                                    </td>
                                </tr>
                            </table>
                            <!-- end widget table -->
                            <br />

                        </td>
                    </tr>
                </table>
            </form>
        </body>
    </html>
</xsl:template>

<xsl:template match="/document/objectlist/object">
    <tr>
        <td>
            <input type="checkbox" name="autoexport" value="{@id}">
                <xsl:choose>
                    <xsl:when test="string-length(location) &lt;= 0">
                        <xsl:attribute name="disabled">true</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published/text() = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &gt; concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                        <xsl:attribute name="checked">true</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published/text() = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                        <xsl:attribute name="disabled">true</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published/text() != '1'">
                        <xsl:attribute name="onClick">document.forms[1].autopublishlinks.checked = 1</xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </input>
        </td>
        <td>
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="not(starts-with(location_path,'/')) and not(starts-with(location_path,$goxims_content))">
                            <xsl:value-of select="concat($goxims_content,$parent_path,'/',location_path)"/>
                        </xsl:when>
                        <xsl:when test="starts-with(location_path,'/') and not(starts-with(location_path,$goxims_content))">
                            <xsl:value-of select="concat($goxims_content,location_path)"/>
                        </xsl:when>
                            <xsl:otherwise>
                            <xsl:value-of select="location_path"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="location_path"/>
            </a>
            <br/>
            <xsl:choose>
                <xsl:when test="string-length(location) &lt;= 0">
                    <xsl:text>Dies ist kein XIMS Objekt oder konnte nicht aufgelöst werden.</xsl:text>
                </xsl:when>
                <xsl:when test="published/text() != '1'">
                    <xsl:text>Dieses Objekt ist zur Zeit nicht veröffentlicht.</xsl:text>
                </xsl:when>
                <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                    <xsl:text>Dieses Objekt wurde zuletzt um </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/><xsl:text> veröffentlicht und seither nicht mehr verändert.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Dieses Objekt wurde seit seiner letzten Veröffentlichung um </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> geändert
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>
</xsl:stylesheet>

