<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_publish_prompt.xsl 2192 2009-01-10 20:07:32Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<!-- $Id: common_publish_prompt.xsl 2192 2009-01-10 20:07:32Z pepl $ -->
	<xsl:import href="common.xsl"/>
	<xsl:import href="../common_publish_prompt.xsl"/>
	<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head">
			</xsl:call-template>
			<body onLoad="disableIt(document.forms[1].autopublish,'objids');">
				<xsl:call-template name="header">
				</xsl:call-template>
				
				<div id="content-container" class="publish-dialog"> 
					<form name="objPublish" id="objPublish" action="{$xims_box}{$goxims_content}" method="GET">
						
						<h1 class="bluebg">Optionen zum Veröffentlichen</h1><!-- für das Objekt '<xsl:value-of select="title"/>'</h1>-->
						
						<p>
							<strong>Status: Das Objekt  '<xsl:value-of select="title"/>' ist zur Zeit<xsl:if test="published!='1'">
									<xsl:text> NICHT </xsl:text>
								</xsl:if>veröffentlicht</strong><br/>
							<xsl:if test="published='1'">unter <br/>
								<a href="{$published_path}" target="_new">
									<xsl:value-of select="$published_path"/>
								</a>
							</xsl:if>
						</p>

						<xsl:if test="message">
							<p>
							 Warnung: Das Objekt '<xsl:value-of select="title"/>' hat folgenden Abhängigkeiten und Sie haben daher nicht die erforderlichen Rechte zum Veröffentlichen des Objekts:
              <xsl:call-template name="csv2ul">
									<xsl:with-param name="list" select="message"/>
								</xsl:call-template>
							Diese Objekte werden während des Veröffentlichens übersprungen.
						</p>
						</xsl:if>

						<xsl:if test="contains( attributes/text(), 'autoindex=1' )">
							<p>
								<strong>Hinweis: Die Autoindexoption ist für diesen Container gesetzt.</strong>
								Wenn Sie 
								<xsl:choose>
									<xsl:when test="published='1'">'Wiederveröffentlichen'</xsl:when>
									<xsl:otherwise>'Veröffentlichen'</xsl:otherwise>
								</xsl:choose>
								 auswählen wird eine Index-Datei erstellt.
							</p>
						</xsl:if>
						
						<p>
            Klicken Sie
                                        <xsl:choose>
								<xsl:when test="published='1'">
                                                'Wiederveröffentlichen'
                                            </xsl:when>
								<xsl:otherwise>
                                                'Veröffentlichen'
                                            </xsl:otherwise>
							</xsl:choose>
                                        um das aktuelle Objekt zu exportieren oder
                                        <xsl:if test="published='1'">
                                            'Veröffentlichen rückgängig machen' um das Objekt vom Live Server zu entfernen oder
                                        </xsl:if>
                                        'Abbrechen' um zur vorigen Seite zu gelangen.
</p>

             <xsl:if test="/document/objectlist/object">
							<br/>
											<div>Die folgenden <strong>verwandten Objekte</strong> (Kinder, Links) wurden gefunden:</div>
									<xsl:apply-templates select="/document/objectlist/object"/>

												<xsl:choose>
													<xsl:when test="/document/objectlist/object[location != '']">
														<div>
                                <label for="selector">Alle Aus/Abwählen</label>
																<input type="checkbox" name="selector" value="1"  id="selector" class="checkbox" onclick="switcher(this,'objids') ? document.forms[1].autopublish.checked = 1 : document.forms[1].autopublish.checked = 0;"/>
														</div>
														<div>
                                 <label for="autopublish">Ausgewählte Objekte automatisch (wieder)veröffentlichen?</label> 
																<input type="checkbox" name="autopublish" id="autopublish" value="1" disabled="true" class="checkbox"/>
														</div>
													</xsl:when>
													<xsl:otherwise>
														<div>
															Es wurden keine verwandten Objekte (Kinder, Links) zum (Wieder)Veröffentlichen gefunden.
														</div>
													</xsl:otherwise>
												</xsl:choose>
							</xsl:if>
						
						<br/>
							<div>
							<br/>
                                        <label for="update_dependencies">Abhängigkeiten aktualisieren (verwandte Portlets, Auto-Indices, ...)</label> 
                                        <input type="checkbox" name="update_dependencies" value="1" checked="checked" id="update_dependencies" class="checkbox"/>
              </div>

						<div>
                                       <label for="verbose_result">Details des Veröffentlichungsvorgangs anzeigen</label>
                                        <input type="checkbox" name="verbose_result" value="1" id="verbose_result" class="checkbox"/>
						</div>

						<div id="confirm-buttons">
						<br/>
							<input name="publish" type="submit" class="ui-state-default ui-corner-all fg-button">
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
							<!--<xsl:call-template name="rbacknav"/>-->
							&#160;
							<xsl:if test="published='1'">
								<input name="unpublish" type="submit" value="Veröffentlichen rückgängig machen" class="ui-state-default ui-corner-all fg-button"/>
								&#160;
							</xsl:if>
							<input name="default" type="button" value="Abbrechen" onClick="javascript:history.go(-1)" class="ui-state-default ui-corner-all fg-button"/>
						</div>
					</form>
				</div>
				
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="/document/objectlist/object">
		<div>
				<input type="checkbox" name="objids" value="{@id}" class="checkbox" id="objid-{@id}">
					<xsl:choose>
						<xsl:when test="string-length(location) &lt;= 0">
							<xsl:attribute name="disabled">true</xsl:attribute>
						</xsl:when>
						<xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &gt; concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
							<xsl:attribute name="checked">true</xsl:attribute>
						</xsl:when>
						<xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
							<xsl:attribute name="disabled">true</xsl:attribute>
						</xsl:when>
						<xsl:when test="published != '1'">
							<xsl:attribute name="onClick">isChecked('objids') ? document.forms[1].autopublish.checked = 1 : document.forms[1].autopublish.checked = 0</xsl:attribute>
						</xsl:when>
					</xsl:choose>
				</input>
			
<label for="objid-{@id}">
				<a>
					<xsl:attribute name="href"><xsl:choose><xsl:when test="not(starts-with(location_path,'/')) and not(starts-with(location_path,$goxims_content))"><xsl:value-of select="concat($goxims_content,$parent_path,'/',location_path)"/></xsl:when><xsl:when test="starts-with(location_path,'/') and not(starts-with(location_path,$goxims_content))"><xsl:value-of select="concat($goxims_content,location_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="location_path"/></xsl:otherwise></xsl:choose></xsl:attribute>
					<xsl:value-of select="location_path"/>
				</a>
				<!--<div style="margin-top: 3px; margin-bottom: 8px;">-->
				<div>
					<xsl:choose>
						<xsl:when test="string-length(location) &lt;= 0">
							<xsl:text>Dies ist kein XIMS Objekt oder konnte nicht aufgelöst werden.</xsl:text>
						</xsl:when>
						<xsl:when test="published != '1'">
							<xsl:text>Dieses Objekt ist zur Zeit nicht veröffentlicht.</xsl:text>
						</xsl:when>
						<xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
							<xsl:text>Dieses Objekt wurde zuletzt um </xsl:text>
							<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
							<xsl:text> veröffentlicht und seither nicht mehr verändert.</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Dieses Objekt wurde seit seiner letzten Veröffentlichung um </xsl:text>
							<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> geändert
                </xsl:otherwise>
					</xsl:choose>
				</div>
</label>
			
		</div>
	</xsl:template>
</xsl:stylesheet>
