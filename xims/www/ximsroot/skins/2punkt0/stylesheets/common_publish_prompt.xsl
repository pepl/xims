<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_publish_prompt.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<!-- $Id: common_publish_prompt.xsl 2188 2009-01-03 18:24:00Z pepl $ -->
	<xsl:import href="common.xsl"/>
	<xsl:param name="id"/>
	<xsl:variable name="objecttype">
		<xsl:value-of select="/document/context/object/object_type_id"/>
	</xsl:variable>
	<xsl:variable name="publish_gopublic">
		<xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
	</xsl:variable>
	<xsl:variable name="published_path_base">
		<xsl:choose>
			<xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
				<xsl:value-of select="$absolute_path_nosite"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$absolute_path"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="object_path">
		<xsl:value-of select="$published_path_base"/>
	</xsl:variable>
	<xsl:variable name="published_path">
		<xsl:choose>
			<xsl:when test="$publish_gopublic = 0">
				<xsl:value-of select="concat($publishingroot,$object_path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(/document/context/session/serverurl,$gopublic_content,$object_path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
		<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head">
			</xsl:call-template>
			<body onload="disableIt(document.forms[1].autopublish,'objids');">
				<xsl:call-template name="header">
				</xsl:call-template>
				
				<div id="content-container" class="publish-dialog"> 
					<form name="objPublish" id="objPublish" action="{$xims_box}{$goxims_content}" method="get">
						<h1 class="bluebg"><xsl:value-of select="$i18n/l/Publishing_options"/></h1>
						<p>
							<strong><xsl:value-of select="$i18n/l/Status"/>: <xsl:value-of select="$i18n/l/Object"/> '<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/isCurrently"/>&#160;<xsl:if test="published!='1'"><xsl:value-of select="$i18n/l/NOT"/>
								&#160;</xsl:if><xsl:value-of select="$i18n/l/published"/></strong><br/>
							<xsl:if test="published='1'">
								<xsl:value-of select="$i18n/l/under"/> 
								<br/>
								<a href="{$published_path}" target="_new">
									<xsl:value-of select="$published_path"/>
								</a>
							</xsl:if>
						</p>

						<xsl:if test="message">
							<p>
							 <xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/ObjectHasDependencies"/>:
              <xsl:call-template name="csv2ul">
									<xsl:with-param name="list" select="message"/>
								</xsl:call-template>
								<xsl:value-of select="$i18n/l/ObjSkipping"/>
						</p>
						</xsl:if>

						<xsl:if test="contains( attributes/text(), 'autoindex=1' )">
							<p>
								<strong><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/HasAutoindex"/></strong>.&#160;
								<xsl:choose>
									<xsl:when test="published='1'"><xsl:value-of select="$i18n/l/IndexIfRepublish"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$i18n/l/IndexIfPublish"/></xsl:otherwise>
								</xsl:choose>.
							</p>
						</xsl:if>
						
						<p>
            <xsl:value-of select="$i18n/l/Click"/>&#160;
            <xsl:choose>
								<xsl:when test="published='1'">'<xsl:value-of select="$i18n/l/Republish"/>'</xsl:when>
								<xsl:otherwise>'<xsl:value-of select="$i18n/l/Publish"/>'</xsl:otherwise>
						</xsl:choose>
            &#160;<xsl:value-of select="$i18n/l/toExpCurrObj"/>
            <xsl:if test="published='1'">,&#160;'<xsl:value-of select="$i18n/l/Unpublish"/>'&#160;<xsl:value-of select="$i18n/l/toRemoveFromLiveServer"/></xsl:if>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;'<xsl:value-of select="$i18n/l/cancel"/>'&#160;<xsl:value-of select="$i18n/l/toReturnPrev"/>.
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
        <label for="update_dependencies"><xsl:value-of select="$i18n/l/UpdateDepend"/></label> 
        <input type="checkbox" name="update_dependencies" value="1" checked="checked" id="update_dependencies" class="checkbox"/>
      </div>
<br clear="all"/>
			<div>
					<label for="verbose_result"><xsl:value-of select="$i18n/l/ShowDetailsOfPub"/></label>
					<input type="checkbox" name="verbose_result" value="1" id="verbose_result" class="checkbox"/>
			</div>
			
<br clear="all"/>
						<div id="confirm-buttons">
						<br/>
							<button name="publish" type="submit">
								<xsl:choose>
									<xsl:when test="published='1'">
										<xsl:value-of select="$i18n/l/Republish"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$i18n/l/Publish"/>
									</xsl:otherwise>
								</xsl:choose>
							</button>
							<input name="id" type="hidden" value="{$id}"/>
							<!--<xsl:call-template name="rbacknav"/>-->
							&#160;
							<xsl:if test="published='1'">
								<button name="unpublish" type="submit"><xsl:value-of select="$i18n/l/Unpublish"/></button>
								
								&#160;
							</xsl:if>
							<button name="default" type="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/cancel"/></button>
						</div>
					</form>
				</div>
				<xsl:call-template name="script_bottom"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="/document/objectlist/object">
		<p>
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
				</label>
				<br/>
				<span class="indented">
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
					</span>
		</p>
	</xsl:template>
	
	<xsl:template name="head">
		<head>
			<title>
				<xsl:value-of select="$i18n/l/Confirm_publishing"/> - XIMS
            </title>
			<!--<xsl:call-template name="css"/>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>-->
			<xsl:call-template name="css">
				<xsl:with-param name="jquery-ui-smoothness">true</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="script_head">
				<xsl:with-param name="jquery">true</xsl:with-param>
			</xsl:call-template>
			<script type="text/javascript">
				<xsl:comment><![CDATA[
                        function disableIt(obj,ename) {
                            var objids = window.document.forms[1].elements[ename];
                            if (!objids) {
                                return;
                            }
                            if ( objids.length ) {
                                var i;
                                for (i = 0; i < objids.length; i++) {
                                    if ( !(objids[i].disabled) ) {
                                        obj.disabled = false;
                                        return true;
                                    }
                                }
                            }
                            else if ( !(objids.disabled) ) {
                                obj.disabled = false;
                                return true;
                            }
                        }
                        function switcher(selector,ename){
                            var ids = window.document.forms[1].elements[ename];
                            xstate = selector.checked ? 1 : 0;
                            if ( ids.length ) {
                                var i;
                                for (i = 0; i < ids.length; i++) {
                                    if ( !(ids[i].disabled) ) {
                                        ids[i].checked = xstate;
                                    }
                                }
                            }
                            else {
                                if ( !(ids.disabled) ) {
                                    ids.checked = xstate;
                                }
                            }
                            return xstate;
                        }
                        function isChecked(ename){
                            var ids = window.document.forms[1].elements[ename];
                            if ( ids.length ) {
                                var i;
                                for (i = 0; i < ids.length; i++) {
                                    if (ids[i].checked ) {
                                        return true;
                                    }
                                }
                            }
                            else {
                                if (ids.checked ) {
                                    return true;
                                }
                            }
                            return false;
                        }

                    ]]></xsl:comment>
			</script>
		</head>
	</xsl:template>
	
	<xsl:template name="csv2ul">
		<xsl:param name="list"/>
		<ul>
			<xsl:call-template name="csv2li">
				<xsl:with-param name="list" select="$list"/>
			</xsl:call-template>
		</ul>
	</xsl:template>
	<xsl:template name="csv2li">
		<xsl:param name="list"/>
		<xsl:variable name="item" select="substring-before($list, ',')"/>
		<xsl:variable name="rest" select="substring-after($list, ',')"/>
		<xsl:choose>
			<xsl:when test="$item">
				<li>
					<xsl:value-of select="$item"/>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<xsl:value-of select="$list"/>
				</li>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$rest">
			<xsl:call-template name="csv2li">
				<xsl:with-param name="list" select="$rest"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
