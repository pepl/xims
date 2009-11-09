<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_header.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<!--start from ../common.xsl-->


	<!--end from ../common.xsl	-->
	<xsl:template name="header">
		<xsl:param name="create" select="false()"/>
		<xsl:param name="noncontent">false</xsl:param>
		<xsl:param name="nopath">false</xsl:param>
		<xsl:param name="containerpath">false</xsl:param>
		<xsl:param name="createwidget">false</xsl:param>
		<xsl:param name="parent_id"/>
		<xsl:param name="noarrownavigation">false</xsl:param>
		<xsl:param name="nooptions">false</xsl:param>
		<xsl:param name="nostatus">false</xsl:param>
		<xsl:param name="no_navigation_at_all">false</xsl:param>
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
		<xsl:variable name="dfname" select="$df/name"/>
		<xsl:variable name="dfmime" select="$df/mime_type"/>
		<div id="navopt">
			<div class="locbar">
				<xsl:if test="$nopath='false' and $noncontent ='false'">
					<xsl:value-of select="$i18n/l/YouAreIn"/>
					<xsl:choose>
						<xsl:when test="$containerpath='false'">
							<xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1]">
								<xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all"/>
							</xsl:apply-templates>
							<xsl:if test="$create!='true'">
                            / <a class="" href="{$goxims_content}{$absolute_path}">
									<xsl:value-of select="location"/>
								</a>
							</xsl:if>
							<xsl:text>&#160;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<!-- hardcode OT alarm (folder and dept.root -->
							<xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1 and (preceding-sibling::object/object_type_id=1 or preceding-sibling::object/object_type_id=6)]">
								<xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all"/>
							</xsl:apply-templates>
							<xsl:text>&#160;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</div>
			<div id="header-logo" class="logo">
				<a href="http://xims.info/">
					<span>XIMS</span>
				</a>
			</div>
		</div>
		<div id="access-container">
			<ol id="accesslist">
				<li>
					Jump to: <a href="#mainmenu">Main Menu (Home, Logout)</a>
				</li>
				<li>
					<a href="#subheader">Navigate and search</a>
				</li>
				<li>
					<a href="#tab-container">Edit Menu</a>
				</li>
				<li>
					<a href="#table-container">Content area</a>
				</li>
			</ol>
		</div>
		<div id="titlelogo">
			<div id="header-tr">
				<xsl:call-template name="header.arrownavigation"/>
				<xsl:call-template name="menu-widget"/>
				<xsl:call-template name="help-widget"/>
				<div class="empty-div-cell">
					<label for="input-search" class="hidden">
						<xsl:value-of select="$i18n/l/Search_for"/>
					</label>
				</div>
				<div class="header-td-right">
					<xsl:call-template name="header.cttobject.search"/>
				</div>
				<!--<div id="header-logo" class="logo">
					<a href="http://xims.info/">&#xa0;<span>XIMS</span>
					</a>
				</div>-->
			</div>
		</div>
	</xsl:template>
	<xsl:template name="subheader_noncontent">
		<table id="subheader">
			<tr>
				<td>
					<!--<xsl:call-template name="message"/>-->
				</td>
				<xsl:call-template name="header.cttobject.search"/>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="subheader_nonavigation">
		<table id="subheader">
			<tr>
				<td>
					<xsl:call-template name="message"/>
				</td>
			</tr>
		</table>
	</xsl:template>
	<xsl:template name="subheader">
		<!--<xsl:param name="createwidget">false</xsl:param>-->
		<xsl:param name="parent_id"/>
		<xsl:param name="noarrownavigation">false</xsl:param>
		<!--<xsl:param name="nooptions">false</xsl:param>
		<xsl:param name="nostatus">false</xsl:param>-->
		<!--<div id="subheader" class="container">-->
		<div id="subheader">
			<div id="subheader-tr">
				<xsl:call-template name="header.arrownavigation"/>
				<!--<div class="empty-div-cell"><span>&#160;</span></div>-->
				<div class="sh-empty-div-cell">
					<label for="input-search" class="hidden">
						<xsl:value-of select="$i18n/l/Search_for"/>
					</label>
				</div>
				<xsl:call-template name="header.cttobject.search"/>
			</div>
		</div>
	</xsl:template>
	<xsl:template name="header.arrownavigation">
		<div id="navback">
			<a href="javascript:history.go(-1)">
				<!--<img src="{$skimages}navigate-back.png" width="28" height="28" border="0" alt="{$i18n/l/Back}" title="{$i18n/l/Back}" name="back"/>-->
				<img src="{$skimages}navigate-back.png" alt="{$i18n/l/Back}" title="{$i18n/l/Back}" name="back"/>
			</a>
		</div>
		<div id="navup">
			<xsl:choose>
				<xsl:when test="$parent_path != ''">
					<a>
						<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,$parent_path,'?m=',$m)"/><xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:attribute>
						<img src="{$skimages}navigate-up.png" alt="{$i18n/l/Up}" title="{$i18n/l/Up}" name="up"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<!--<img src="{$skimages}navigate-up.png" width="28" height="28" border="0" alt="{$i18n/l/Up}" title="{$i18n/l/Up}" name="up"/>-->
					<img src="{$skimages}navigate-up.png" alt="{$i18n/l/Up}" title="{$i18n/l/Up}" name="up"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<div id="navfwd">
			<a href="javascript:history.go(+1)">
				<img src="{$skimages}navigate-forward.png" alt="{$i18n/l/Forward}" title="{$i18n/l/Forward}" name="forward"/>
			</a>
		</div>
	</xsl:template>
	
	<xsl:template name="header.cttobject.createwidget">
		<xsl:param name="parent_id"/>
		<div class="create-widget">
			<a href="#object-types" class="flyout create-widget fg-button fg-button-icon-right ui-state-default ui-corner-all" tabindex="0" >
				<span class="ui-icon ui-icon-triangle-1-s"/>
				<xsl:value-of select="$i18n/l/Create"/>
			</a>
			<div id="object-types" class="hidden-content">
				<ul>
					<xsl:choose>
						<xsl:when test="/document/context/object/@id = 1">
							<xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]"/>
						</xsl:when>
						<xsl:when test="$parent_id != ''">
							<xsl:apply-templates select="/document/object_types/object_type[can_create and parent_id = $parent_id]">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/document/object_types/object_type[can_create and (@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11')]">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
							<li>
								<a href="#">
									<xsl:value-of select="$i18n/l/More"/>
								</a>
								<ul>
									<!-- Only show basic object types on first page: TODO Select from object type properties and not from OT names or IDs!
                                        Do not display object types that either are not fully implemented or that are not meant to be created directly.
                                        We may consider adding an object type property for the latter types.
                                        jokar, 2006-05-03: parameter parent_id, to prevent the diret creation of e.g. VLibraryItem::Document-s
                                        jerboaa, 2007-07-19: Do not show object types which contain "Item" in their name with the only exception
					                     of "NewsItem"! 
                                    -->
									<xsl:apply-templates select="/document/object_types/object_type[can_create and not(@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11' or name = 'Portal' or name = 'Annotation' or name = 'AnonDiscussionForumContrib' or ( contains(name,'Item') and not(substring-before(name, 'Item')='News') ) or name = 'SiteRoot' or parent_id != $parent_id)]">
										<xsl:sort select="name"/>
									</xsl:apply-templates>
								</ul>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
		</div>
		    <noscript>
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get">
            <!--<td width="126" nowrap="nowrap">-->
                <select name="objtype">
                    <xsl:choose>
                        <xsl:when test="/document/context/object/@id = 1">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]" mode="form"/>
                        </xsl:when>
                        <xsl:otherwise>
			    <!-- Do not show object types which contain "Item" in their name with the only exception of "NewsItem"! -->
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name != 'Portal' and name != 'Annotation' and name != 'AnonDiscussionForumContrib' and not(contains(name,'Item') and not(substring-before(name, 'Item')='News')) and parent_id = $parent_id]" mode="form">
			        <xsl:sort select="name"/>
			    </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </select>
                <xsl:text>&#160;</xsl:text>
                    <input type="submit" class="ui-state-default ui-corner-all fg-button">
											<xsl:attribute name="value"><xsl:value-of select="$i18n/l/create"/></xsl:attribute>
                    </input>
                <input name="page" type="hidden" value="{$page}"/>
                <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                <xsl:if test="$defsorting != 1">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                </xsl:if>
        </form>
    </noscript>
	</xsl:template>
	<xsl:template name="header.cttobject.search">
		<xsl:variable name="Search" select="$i18n/l/Search"/>
		<div id="sh-search" class="qsearch ui-widget-content ui-corner-all">
			<form method="get" name="quicksearch">
				<xsl:attribute name="action"><xsl:choose><xsl:when test="$absolute_path != ''"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($xims_box,$goxims,'/user')"/></xsl:otherwise></xsl:choose></xsl:attribute>
				<label for="start_here">
					<xsl:value-of select="$i18n/l/From_here"/>
				</label>
				<input id="start_here" type="checkbox" class="start_here ui-corner-all" name="start_here" value="1">
					<xsl:if test="$start_here != ''">
						<xsl:attribute name="checked">true</xsl:attribute>
					</xsl:if>
				</input>
				<!--<label for="input-search" class="hidden"><xsl:value-of select="$i18n/l/Search_for" /></label>-->
				<input type="text" class="search ui-corner-all" id="input-search" name="s" size="17" maxlength="200">
					<xsl:choose>
						<xsl:when test="$s != ''">
							<xsl:attribute name="value"><xsl:value-of select="$s"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value">[<xsl:value-of select="$Search"/>]</xsl:attribute>
							<xsl:attribute name="onfocus">document.quicksearch.s.value=&apos;&apos;;</xsl:attribute>
							<xsl:attribute name="aria-label"><xsl:value-of select="$Search"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</input>
				<xsl:text>&#160;</xsl:text>
				<button class="ui-state-default ui-corner-all fg-button fg-button-icon-left" type="submit" name="submit" title="{$Search}">
					<span class="ui-icon ui-icon-search"/>
					<span class="text">
						<xsl:value-of select="$Search"/>
					</span>
				</button>
				<!--<input type="image" src="{$sklangimages}search.png" name="submit" width="65" height="14" alt="{$Search}" title="{$Search}" border="0"/>-->
				<input type="hidden" name="search" value="1"/>
				<!--</div>-->
			</form>
		</div>
	</xsl:template>
	<xsl:template match="object_type">
		<xsl:variable name="parent_id" select="parent_id"/>
		<xsl:variable name="sorting">
			<xsl:if test="$defsorting != 1">
				<xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="fullname">
			<xsl:choose>
				<xsl:when test="$parent_id != ''">
					<xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--
		<xsl:variable name="fullname_i18n"/>
		<xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>
		<fullname_i18n><xsl:value-of select="concat('$i18n/l/',$fullname)"/></fullname_i18n>
			<xsl:value-of select="concat($i18n/l/,$fullname)"/>
		</xsl:variable>-->
		<li>
			<a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1;objtype={$fullname};page={$page};r={/document/context/object/@id}{$sorting}">
				<xsl:value-of select="$fullname"/>
			</a>
		</li>
	</xsl:template>
	<xsl:template match="object_type" mode="form">
		<xsl:variable name="parent_id" select="parent_id"/>
		<xsl:variable name="fullname">
			<xsl:choose>
				<xsl:when test="$parent_id != ''">
					<xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<option value="{$fullname}">
			<xsl:value-of select="$fullname"/>
		</option>
	</xsl:template>
	<xsl:template name="cttobject.options.send_email">
		<xsl:variable name="id" select="@id"/>
		<xsl:if test="marked_deleted != '1' 
                  and (user_privileges/send_as_mail = '1')  
                  and (locked_time = '' 
                       or locked_by_id = /document/context/session/user/@id)
                  and /document/object_types/object_type[
                        @id=/document/context/object/object_type_id
                      ]/is_mailable = '1'
                  and published = '1'">
			<a>
				<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';prepare_mail=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,
                                           ';order=',$order,
                                           ';page=',$page,
                                           ';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
				<img src="{$skimages}option_email.png" border="0" name="email{$id}" width="18" height="19" title="Generate Spam" alt="Generate Spam"/>
			</a>
		</xsl:if>
	</xsl:template>
	<!--Help Widget-->
	<xsl:template name="help-widget">
		<div id="help">
			<div class="help-widget">
				<a href="#help-types" class="flyout help-widget fg-button fg-button-icon-left ui-state-default ui-widget ui-corner-all" tabindex="0">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Help"/></xsl:attribute>
					<span class="ui-icon ui-icon-help"/>
					<xsl:value-of select="$i18n/l/Help"/>
				</a>
				<div id="help-types" class="hidden-content">
					<ul>
						<li>
							<a href="http://xims.info/documentation/" target="_blank" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Systeminfo"/></xsl:attribute>
								<span class="ui-icon ui-icon-info"/>
								<span class="text">
									<xsl:value-of select="$i18n/l/Systeminfo"/>
								</span>
							</a>
						</li>
						<li>
							<a href="http://www.uibk.ac.at/zid/systeme/xims/xims_schritt_fuer_schritt.pdf" target="_blank" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/stepManual"/></xsl:attribute>
								<span class="ui-icon ui-icon-document"/>
								<span class="text">
									<xsl:value-of select="$i18n/l/Manual"/>
								</span>
							</a>
						</li>
						<li>
							<a href="http://www.uibk.ac.at/zid/systeme/xims/xims_benutzer_faq.html" target="_blank" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/FAQ_long"/></xsl:attribute>
								<span class="ui-icon ui-icon-lightbulb"/>
								<span class="text">
									<xsl:value-of select="$i18n/l/FAQ"/>
								</span>
							</a>
						</li>
						<li>
							<a href="mailto:xims-support@uibk.ac.at" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/MailToSupport"/></xsl:attribute>
								<span class="ui-icon ui-icon-mail-closed"/>
								<span class="text">
									<xsl:value-of select="$i18n/l/MailToSupport"/>
								</span>
							</a>
						</li>
					</ul>
				</div>
			</div>
			</div>
			<noscript>
<!--				<ul>
						<li>-->
							<a href="http://xims.info/documentation/" target="_blank"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Systeminfo"/></xsl:attribute>
								<!--<span class="ui-icon ui-icon-info"/>-->
								<span class="text">
									<xsl:value-of select="$i18n/l/Systeminfo"/>
								</span>
							</a>
							&#160;&#160;
<!--						</li>
						<li>-->
							<a href="http://www.uibk.ac.at/zid/systeme/xims/xims_schritt_fuer_schritt.pdf" target="_blank"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/stepManual"/></xsl:attribute>
								<!--<span class="ui-icon ui-icon-document"/>-->
								<span class="text">
									<xsl:value-of select="$i18n/l/Manual"/>
								</span>
							</a>
							&#160;&#160;
<!--						</li>
						<li>-->
							<a href="http://www.uibk.ac.at/zid/systeme/xims/xims_benutzer_faq.html" target="_blank"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/FAQ_long"/></xsl:attribute>
								<!--<span class="ui-icon ui-icon-lightbulb"/>-->
								<span class="text">
									<xsl:value-of select="$i18n/l/FAQ"/>
								</span>
							</a>
							&#160;&#160;
<!--						</li>
						<li>-->
							<a href="mailto:xims-support@uibk.ac.at"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/MailToSupport"/></xsl:attribute>
								<!--<span class="ui-icon ui-icon-mail-closed"/>-->
								<span class="text">
									<xsl:value-of select="$i18n/l/MailToSupport"/>
								</span>
							</a>
							&#160;&#160;
<!--						</li>
					</ul>-->
			</noscript>
		<!--</div>-->
	</xsl:template>
	<!--Menu Widget-->
	<xsl:template name="menu-widget">
		<div id="menu">
			<div class="menu-widget">
				<a href="#menu-types" class="flyout menu-widget fg-button fg-button-icon-left ui-state-default ui-widget ui-corner-all" tabindex="0">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Menu"/></xsl:attribute>
					<span class="ui-icon ui-icon-gear"/>
					<xsl:value-of select="$i18n/l/Menu"/>
				</a>
				<div id="menu-types" class="hidden-content">
					<ul>
						<xsl:choose>
							<xsl:when test="/document/context/session/public_user = '1'">
								<li>
									<a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
										<span class="text">
											<xsl:value-of select="$i18n/l/login"/>
										</span>
									</a>
								</li>
							</xsl:when>
							<xsl:otherwise>
								<li>
									<a href="{$xims_box}{$goxims}/user" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
										<span class="ui-icon ui-icon-home"/>
										<span class="text">
											<xsl:value-of select="/document/context/session/user/name"/>
										</span>
									</a>
								</li>
								<li>
									<a href="{$goxims_content}{$absolute_path}?reason=logout" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
										<span class="ui-icon ui-icon-power"/>
										<span class="text">
											<xsl:value-of select="$i18n/l/logout"/>
										</span>
									</a>
								</li>
							</xsl:otherwise>
						</xsl:choose>
						<!--<li>
							<a href="" class="fg-button fg-button-icon-left ui-state-default ui-corner-all">
							<span class="ui-icon ui-icon-bookmark"/>
							<span class="text">
								<xsl:value-of select="$i18n/l/default_bookmark"/>
							</span>
							</a>
						</li>-->
					</ul>
				</div>
			</div>
</div>			
			<noscript>
					<!--<ul>-->
						<xsl:choose>
							<xsl:when test="/document/context/session/public_user = '1'">
								<!--<li>-->
									<a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
										<span class="text">
											<xsl:value-of select="$i18n/l/login"/>
										</span>
									</a>
									&#160;&#160;
								<!--</li>-->
							</xsl:when>
							<xsl:otherwise>
								<!--<li>-->
									<a href="{$xims_box}{$goxims}/user"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
										<!--<span class="ui-icon ui-icon-home"/>-->
										<span class="text">
											<xsl:value-of select="/document/context/session/user/name"/>
										</span>
									</a>
									&#160;&#160;
								<!--</li>
								<li>-->
									<a href="{$goxims_content}{$absolute_path}?reason=logout"> <!--class="fg-button fg-button-icon-left ui-state-default ui-corner-all">-->
										<!--<span class="ui-icon ui-icon-home"/>-->
										<span class="text">
											<xsl:value-of select="$i18n/l/logout"/>
										</span>
									</a>
									&#160;&#160;&#160;&#160;
								<!--</li>-->
							</xsl:otherwise>
						</xsl:choose>
					<!--</ul>-->
			</noscript>
		<!--</div>-->
	</xsl:template>
</xsl:stylesheet>
