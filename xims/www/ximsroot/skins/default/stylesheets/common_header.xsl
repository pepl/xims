<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_header.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml" 
                xmlns:str="http://exslt.org/strings"
                xmlns:exslt="http://exslt.org/common"
                extension-element-prefixes="str exslt">
	
	<xsl:variable name="supportmail_body">
		<xsl:text>
			%0D%0A%0D%0A
			-----%0D%0A
		</xsl:text>
		<xsl:value-of select="$i18n/l/NoticeSupport"/>:%0D%0A
		<xsl:value-of select="$i18n/l/Name"/>: <xsl:value-of select="/document/context/session/user/name"/>%0D%0A
		<xsl:value-of select="$i18n/l/Context"/>:
		<xsl:choose>
			<xsl:when test="/document/context/object/location_path != ''"><xsl:value-of select="/document/context/object/location_path"/></xsl:when>
			<xsl:when test="/document/context/object/parents/object[last()]/location_path !=''"><xsl:value-of select="/document/context/object/parents/object[last()]/location_path"/></xsl:when>
			<xsl:otherwise>?</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
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
		
		<!--
			Warnung - Testsystem - UIBK
		-->
		<!--
		<div style="color: red; font-weight: bold; text-align: center;">
			<p>Achtung Testsystem! Es kann zu unangekündigten Änderungen und Ausfällen kommen.<br/>
				Dieses System arbeitet gegen die Produktiv-Daten. Alle Änderungen werden für die Webseiten der Uni übernommen.
			</p>
		</div>
		-->
		<!-- End Warnung Testsystem - UIBK -->
		<div id="path-logo">
			<div id="locbar">
              <xsl:choose>
				<xsl:when test="$nopath='false' and $noncontent ='false'">
					<xsl:value-of select="$i18n/l/YouAreIn"/>
					<xsl:choose>
						<xsl:when test="$containerpath='false'">
							<xsl:apply-templates select="/document/context/object/parents/object[@document_id != 1]">
								<xsl:with-param name="no_navigation_at_all" select="$no_navigation_at_all"/>
							</xsl:apply-templates>
							<xsl:if test="$create!='true'">
                            / <a href="{$goxims_content}{$absolute_path}">
									<xsl:value-of select="location"/>
                                    <xsl:comment/>
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
				</xsl:when>
                <xsl:otherwise><xsl:comment/></xsl:otherwise>
              </xsl:choose>
			</div>
			<div id="header-logo">
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
					<a href="#options-menu-bar">Edit Menu</a>
				</li>
				<li>
					<a href="#options-menu-bar">Content area</a>
				</li>
			</ol>
		</div>
		<div id="menu-bar">
			<xsl:call-template name="header.arrownavigation"/>
			<xsl:call-template name="menu-widget"/>
			<xsl:call-template name="help-widget"/>
            <xsl:call-template name="motd"/>
			<xsl:call-template name="header.search"/>
		</div>
		<!--
		<div class="xims-content">
			<p>&#160;
				<xsl:if test="/document/context/session/message">
					<xsl:value-of select="/document/context/session/message"/>
				</xsl:if>	
				<xsl:if test="/document/context/session/warning_msg">
					<xsl:value-of select="/document/context/session/warning_msg"/>
				</xsl:if>
				<xsl:if test="/document/context/session/error_msg">
					<xsl:value-of select="/document/context/session/error_msg"/>
				</xsl:if>
			</p>
		</div>-->
	</xsl:template>

	<xsl:template name="header.arrownavigation">
		<div id="navback">
			<a href="javascript:history.go(-1)">
				<img src="{$skimages}navigate-back.png" alt="{$i18n/l/Back}" title="{$i18n/l/Back}" />
			</a>
		</div>
		<div id="navup">
			<xsl:choose>
				<xsl:when test="$parent_path != ''">
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="concat($goxims_content,$parent_path)"/>
							<xsl:if test="$currobjmime='application/x-container' and $defsorting != 1">
								<xsl:value-of select="concat('?sb=',$sb,'&amp;order=',$order)"/>
							</xsl:if>
						</xsl:attribute>
						<img src="{$skimages}navigate-up.png" alt="{$i18n/l/Up}" title="{$i18n/l/Up}"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<img src="{$skimages}navigate-up.png" alt="{$i18n/l/Up}" title="{$i18n/l/Up}"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<div id="navfwd">
			<a href="javascript:history.go(+1)">
				<img src="{$skimages}navigate-forward.png" alt="{$i18n/l/Forward}" title="{$i18n/l/Forward}"/>
			</a>
		</div>
	</xsl:template>
	
	<xsl:template name="create-widget">
	<xsl:param name="mode" select="false()"/>
	<xsl:param name="parent_id"/>
	<xsl:choose>
		 
		<!-- Default Create-Widget (Container View) -->
		<xsl:when test="$mode='default'">
		<div id="create-widget">
			<button>				
				<xsl:value-of select="$i18n/l/Create"/>
			</button>
					<xsl:choose>
						<xsl:when test="/document/context/object/@id = 1">
							<ul style="z-index:100;">
								<xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]"  mode="fo-menu"/>
							</ul>
						</xsl:when>
						
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$parent_id != ''">
									<ul style="position:absolute !important; z-index: 100; width: 160px">
										<xsl:apply-templates select="/document/object_types/object_type[can_create and parent_id = $parent_id]" mode="fo-menu">
											<xsl:sort select="name"/>
										</xsl:apply-templates>
									</ul>						
								</xsl:when>						
								<xsl:otherwise>
									<ul
                                                                            style="width:180px; z-index: 100;">
										<!--<xsl:apply-templates select="/document/object_types/object_type[can_create and (@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11')]" mode="fo-menu">-->
										<xsl:apply-templates select="/document/object_types/object_type[can_create and menu_level = '1']" mode="fo-menu">
											<xsl:sort select="name"/>
										</xsl:apply-templates>
										<li>
											<a href="#" class="more">
												<xsl:value-of select="$i18n/l/More"/>
											</a>
										<!--</li>
									</ul>-->
									<ul class="more">
										<!-- Only show basic object types on first page: TODO Select from object type properties and not from OT names or IDs!
					                        Do not display object types that either are not fully implemented or that are not meant to be created directly.
					                        We may consider adding an object type property for the latter types.
					                        jokar, 2006-05-03: parameter parent_id, to prevent the diret creation of e.g. VLibraryItem::Document-s
					                        jerboaa, 2007-07-19: Do not show object types which contain "Item" in their name with the only exception
						                     of "NewsItem"! 
											susanne, 2012-03-29: Done! Finally :)
					                    -->
										<!--<xsl:apply-templates select="/document/object_types/object_type[can_create and not(@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11' or name = 'Portal' or name = 'Annotation' or name = 'BidokEntry' or name = 'BidokIndex' or ( contains(fullname,'Item') and not(substring-before(name, 'Item')='News') ) or name = 'SiteRoot' or parent_id != $parent_id)]" mode="fo-menu">-->
										<xsl:apply-templates select="/document/object_types/object_type[can_create and menu_level = '2']" mode="fo-menu">	
											<xsl:sort select="name"/>
										</xsl:apply-templates>
									</ul>
									</li>
								</ul>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
		</div>
		<!--<noscript>
			<form action="{$xims_box}{$goxims_content}{$absolute_path}?" method="get">
				<select name="objtype">
					<xsl:choose>
						<xsl:when test="/document/context/object/@id = 1">
							<xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]" mode="form"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/document/object_types/object_type[can_create and name != 'Portal' and name != 'Annotation' and not(contains(name,'Item') and not(substring-before(name, 'Item')='News')) and parent_id = $parent_id]" mode="form">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</select>
				<xsl:text>&#160;</xsl:text>
				<button type="submit" class="button">
						<xsl:value-of select="$i18n/l/create"/>
				</button>
				<input name="create" type="hidden" value="1"/>
				<input name="page" type="hidden" value="{$page}"/>
				<input name="r" type="hidden" value="{/document/context/object/@id}"/>
				<xsl:if test="$defsorting != 1">
					<input name="sb" type="hidden" value="{$sb}"/>
					<input name="order" type="hidden" value="{$order}"/>
				</xsl:if>
			</form>
		</noscript>-->
		</xsl:when>
	</xsl:choose>	
	</xsl:template>
	
	<xsl:template name="header.search">
		<xsl:variable name="Search" select="$i18n/l/Search"/>
		<div id="menu-search" class="ui-widget-content ui-corner-all">
			<form method="get" name="quicksearch">
				<xsl:attribute name="action">
					<xsl:choose>
						<xsl:when test="$absolute_path != ''">
							<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($xims_box,$goxims,'/user')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<label for="start_here">
					<xsl:value-of select="$i18n/l/From_here"/>
				</label>
				<input id="start_here" type="checkbox" class="checkbox" name="start_here" value="1">
					<xsl:if test="$start_here != ''">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<input type="text" id="input-search" name="s" size="17" maxlength="200">
					<xsl:choose>
						<xsl:when test="$s != ''">
							<xsl:attribute name="value">
								<xsl:value-of select="$s"/>
							</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value">[<xsl:value-of select="$Search"/>]</xsl:attribute>
							<xsl:attribute name="onfocus">document.quicksearch.s.value=&apos;&apos;;</xsl:attribute>
							<!--<xsl:attribute name="aria-labelledby"><xsl:value-of select="$Search"/></xsl:attribute>-->
						</xsl:otherwise>
					</xsl:choose>
				</input>
				<xsl:text>&#160;</xsl:text>
				<button class="button-search" type="submit"><xsl:value-of select="$Search"/></button>
				<input type="hidden" name="search" value="1"/>
			</form>
		</div>
	</xsl:template>
	
	<xsl:template match="object_type" mode="fo-menu">
		<xsl:variable name="parent_id" select="parent_id"/>
		<xsl:variable name="sorting">
			<xsl:if test="$defsorting != 1">
				<xsl:value-of select="concat('&amp;sb=',$sb,'&amp;order=',$order)"/>
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
		<li>
			<a href="{$xims_box}{$goxims_content}{$absolute_path}?create=1&amp;objtype={$fullname}&amp;page={$page}&amp;r={/document/context/object/@id}{$sorting}">
				<!--<xsl:value-of select="$fullname"/>-->
				<xsl:call-template name="objtype_name">
					<xsl:with-param name="ot_name">
						<xsl:value-of select="name"/>
					</xsl:with-param>
				</xsl:call-template>
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
			<!--<xsl:value-of select="$fullname"/>-->
			<xsl:call-template name="objtype_name">
				<xsl:with-param name="ot_name">
					<xsl:value-of select="/document/object_types/object_type[@id=$parent_id]/name"/>::<xsl:value-of select="name"/>
				</xsl:with-param>
			</xsl:call-template>
		</option>
	</xsl:template>
	
	<!--<xsl:template name="cttobject.options.send_email">
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
				<xsl:attribute name="href">
					<xsl:value-of select="concat($goxims_content,'?id=',$id,';prepare_mail=1')"/>
					<xsl:if test="$currobjmime='application/x-container'">
						<xsl:value-of select="concat(';sb=',$sb,
                                           ';order=',$order,
                                           ';page=',$page,
                                           ';r=',/document/context/object/@id)"/>
					</xsl:if>
				</xsl:attribute>
				<img src="{$skimages}option_email.png" border="0" name="email{$id}" width="18" height="19" title="Generate Spam" alt="Generate Spam"/>
			</a>
		</xsl:if>
	</xsl:template>
	-->

	
	<!--Menu Widget-->
	<xsl:template name="menu-widget">			
	<div id="menu-widget">
		<button><xsl:value-of select="$i18n/l/Menu"/></button>
			<ul style="position:absolute !important; width: 150px">
				<xsl:choose>
					<xsl:when test="/document/context/session/public_user = '1'">
						<li>
							<a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}">
								<xsl:value-of select="$i18n/l/login"/>
							</a>
						</li>
					</xsl:when>
					<xsl:otherwise>
						<li>
							<a href="{$xims_box}{$goxims}/user">
								<xsl:value-of select="/document/context/session/user/name"/>
							</a>
						</li>
						<li>
							<a href="#" class="more" id="get-bm">
								<xsl:value-of select="$i18n/l/Bookmarks"/>
							</a>
							<ul class="more" id="bm-links">
								<xsl:if test="/document/context/object">
									<li id="new-bm">
										<a href="#">
											<xsl:attribute name="onclick">$.post('<xsl:value-of select="$xims_box"/><xsl:value-of select="$goxims"/>/bookmark', {create: 1, token: '<xsl:value-of select="/document/context/session/token"/>', path: '<xsl:value-of select="/document/context/object/location_path"/>', no_redir: 1} )</xsl:attribute>
											<span class="ui-icon ui-icon-star"><xsl:comment/></span><xsl:value-of select="$i18n/l/SetBMforCurrentObj"/>
										</a>
									</li>
								</xsl:if>
								<li><xsl:comment/></li>
							</ul>
						</li>
						<li>
                          <form name="logout" 
                              method="post"
                              action="{$goxims}/logout">
                            <xsl:call-template name="input-token"/>
                            <input type="hidden" name="reason" value="logout"/>
                            <input type="hidden" name="redirect" value="{$goxims}{$contentinterface}{$absolute_path}"/>
                            <!-- <input type="submit" name="logout"
                                 value="{$i18n/l/logout}"/> -->
                            <a href="javascript:document.logout.submit()">
									<xsl:value-of select="$i18n/l/logout"/>
							</a>
                          </form>
							<!-- <a href="{$goxims_content}{$absolute_path}?reason=logout"> -->
							<!-- 		<xsl:value-of select="$i18n/l/logout"/> -->
							<!-- </a> -->
						</li>
					</xsl:otherwise>
				</xsl:choose>					
			</ul>
			<!--<ul class="more" id="bm-links"><li></li></ul>-->
		</div>
		<noscript>
			<xsl:choose>
				<xsl:when test="/document/context/session/public_user = '1'">
					<a href="{$xims_box}{$goxims}{$contentinterface}{$absolute_path}">
						<span class="text">
							<xsl:value-of select="$i18n/l/login"/>
						</span>
					</a>&#160;&#160;
							</xsl:when>
				<xsl:otherwise>
					<a href="{$xims_box}{$goxims}/user">
						<span class="text">
							<xsl:value-of select="/document/context/session/user/name"/>
						</span>
					</a>
									&#160;&#160;
									<a href="{$goxims}/logout?reason=logout&amp;redirect={$goxims}{$contentinterface}{$absolute_path}">
						<span class="text">
							<xsl:value-of select="$i18n/l/logout"/>
						</span>
					</a>
									&#160;&#160;&#160;&#160;
							</xsl:otherwise>
			</xsl:choose>
		</noscript>
	</xsl:template>

	<!--Help Widget-->	
	<!-- customize the items in this widget in the config file -->
	<xsl:template name="help-widget">
	  <div id="help-widget">
		<button><xsl:value-of select="$i18n/l/Help"/></button>
		<ul style="position:absolute !important; width: 150px">
		  <xsl:copy-of select="$helplinks"/>
		</ul>
      </div>
	</xsl:template>


    <xsl:template name="motd">
      <xsl:if test="exslt:node-set($motd)/*[local-name()='MOTD']/*
                    and not(contains(/document/context/session/attributes, 'motd=read')
                            or /document/context/session/attributes/motd='read' )">
        <div id="motd" title="{exslt:node-set($motd)//@title}" style="display:none">
          <xsl:copy-of select="exslt:node-set($motd)/*[local-name()='MOTD']/*"/>
        </div>
        <div style="float: left; margin-right: 20px; margin-top: 13.5px; position: relative; z-index: 30;">
          <a class="warning_msg"
             id="motd-link"
             href="#"
             style="border-radius: 5px; padding: 5px; text-decoration:none;">
            <xsl:value-of select="exslt:node-set($motd)//@title"/>
          </a>
        </div>
      </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
