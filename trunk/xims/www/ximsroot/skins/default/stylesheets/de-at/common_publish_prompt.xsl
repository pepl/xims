<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<!-- $Id$ -->
<xsl:import href="common.xsl"/>
<xsl:import href="../common_publish_prompt.xsl"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head"/>
        <body style="margintop:0; marginleft:0; marginwidth:0; marginheight:0; background:url('{$skimages}body_bg.png')" onload="disableIt(document.forms[1].autopublish,'objids');">
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>

            <form name="objPublish" id="objPublish" action="{$xims_box}{$goxims_content}" method="get" style="margin-top: 0px; margin-left: 5px;">
                <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
                    <tr>
                        <td align="center">

                            <br />
                            <!-- begin widget table -->
                            <table width="400" cellpadding="2" cellspacing="2" border="0">
                                <tr>
                                    <td class="bluebg">Optionen zum Veröffentlichen für das Objekt '<xsl:value-of select="title"/>'</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Status: Dieses Objekt ist zur Zeit
                                            <xsl:if test="published!='1'">
                                                <xsl:text> NICHT </xsl:text>
                                            </xsl:if>
                                            veröffentlicht
                                        </strong>
                                        <xsl:if test="published='1'">
                                            unter <br/><a href="{$published_path}" target="_new">
                                                <xsl:value-of select="$published_path"/></a>
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
                                                <xsl:when test="published='1'">
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
                                            <xsl:when test="published='1'">
                                                'Wiederveröffentlichen'
                                            </xsl:when>
                                            <xsl:otherwise>
                                                'Veröffentlichen'
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        um das aktuelle Objekt zu exportieren,
                                        <xsl:if test="published='1'">
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
                                                        <div style="margin-bottom: 3px;">Die folgenden <strong>verwandten Objekte</strong> (Kinder, Links) wurden gefunden:</div>
                                                    </td>
                                                </tr>
                                                <xsl:apply-templates select="/document/objectlist/object"/>
                                                <tr>
                                                    <td colspan="3">
                                                        <table style="margin-top: 15px;">
                                                            <xsl:choose>
                                                                <xsl:when test="/document/objectlist/object[location != '']">
                                                                    <tr>
                                                                        <td>
                                                                            Alle Aus/Abwählen
                                                                        </td>
                                                                        <td>
                                                                            <input type="checkbox" name="selector" value="1" onclick="switcher(this,'objids') ? document.forms[1].autopublish.checked = true : document.forms[1].autopublish.checked = false;"/>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            Ausgewählte Objekte automatisch (wieder)veröffentlichen?
                                                                        </td>
                                                                        <td>
                                                                            <input type="checkbox" name="autopublish" value="1" disabled="disabled"/>
                                                                        </td>
                                                                    </tr>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <tr>
                                                                        <td colspan="2">Es wurden keine verwandten Objekte (Kinder, Links) zum (Wieder)Veröffentlichen gefunden.</td>
                                                                    </tr>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </xsl:if>
                                        <!-- end link table -->
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Abhängigkeiten aktualisieren (verwandte Portlets, Auto-Indices, ...)
                                    </td>
                                    <td>
                                        <input type="checkbox" name="update_dependencies" value="1" checked="checked" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Details des Veröffentlichungsvorgangs anzeigen
                                    </td>
                                    <td>
                                        <input type="checkbox" name="verbose_result" value="1"/>
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
                                                            <xsl:when test="published='1'">
                                                                <xsl:attribute name="value">Wiederveröffentlichen</xsl:attribute>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:attribute name="value">Veröffentlichen</xsl:attribute>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </input>
                                                    <input name="id" type="hidden" value="{$id}"/>
                                                    <xsl:call-template name="rbacknav"/>
                                                </td>
                                                <xsl:if test="published='1'">
                                                    <td>
                                                        <input name="unpublish" type="submit" value="Veröffentlichen rückgängig machen" class="control"/>
                                                    </td>
                                                </xsl:if>
                                                <td>
                                                    <input name="default" type="button" value="Abbrechen" onclick="javascript:history.go(-1)" class="control"/>
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
        <td valign="top">
            <input type="checkbox" name="objids" value="{@id}">
                <xsl:choose>
                    <xsl:when test="string-length(location) &lt;= 0">
                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &gt; concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                        <xsl:attribute name="disabled">disabled</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published != '1'">
                        <xsl:attribute name="onclick">isChecked('objids') ? document.forms[1].autopublish.checked = true : document.forms[1].autopublish.checked = false </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </input>
        </td>
        <td valign="top">
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

            <div style="margin-top: 3px; margin-bottom: 8px;">
            <xsl:choose>
                <xsl:when test="string-length(location) &lt;= 0">
                    <xsl:text>Dies ist kein XIMS Objekt oder konnte nicht aufgelöst werden.</xsl:text>
                </xsl:when>
                <xsl:when test="published != '1'">
                    <xsl:text>Dieses Objekt ist zur Zeit nicht veröffentlicht.</xsl:text>
                </xsl:when>
                <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                    <xsl:text>Dieses Objekt wurde zuletzt um </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/><xsl:text> veröffentlicht und seither nicht mehr verändert.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Dieses Objekt wurde seit seiner letzten Veröffentlichung um </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> geändert
                </xsl:otherwise>
            </xsl:choose>
            </div>
        </td>
    </tr>
</xsl:template>
</xsl:stylesheet>

