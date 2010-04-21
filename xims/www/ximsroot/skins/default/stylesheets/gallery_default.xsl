<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: gallery_default.xsl 1652 2007-03-24 16:14:37Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="folder_default.xsl"/>

<xsl:template name="header.cttobject.createwidget">
    <xsl:param name="parent_id"/>
    <div id="MDME" style="display:none">
        <ul>
            <li><xsl:value-of select="$i18n/l/Create"/>
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
<!--                            <li><xsl:value-of select="$i18n/l/More"/>
                                <ul>
                                    <xsl:apply-templates select="/document/object_types/object_type[can_create and not(@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11' or name = 'Portal' or name = 'Annotation' or name = 'AnonDiscussionForumContrib' or ( contains(name,'Item') and not(substring-before(name, 'Item')='News') ) or name = 'SiteRoot' or parent_id != $parent_id)]">
                                        <xsl:sort select="name"/>
                                    </xsl:apply-templates>
                                </ul>
                            </li>-->
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and (@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11')]">
                                <xsl:sort select="name"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
            </li>
        </ul>
    </div>
    
    <noscript>
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0;" method="get">
                <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="objtype">
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
                <input type="image"
                    name="create"
                    src="{$sklangimages}create.png"
                    alt="{$i18n/l/Create}"
                    title="{$i18n/l/Create}" />
                <input name="page" type="hidden" value="{$page}"/>
                <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                <xsl:if test="$defsorting != 1">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                </xsl:if>
        </form>
    </noscript>
</xsl:template>

<xsl:template name="message">
<div class="div-right" style="float:right"><a href="{$xims_box}{$goxims_content}{$absolute_path}/?preview=1"><xsl:value-of select="$i18n/l/Preview"/></a></div>
</xsl:template>

	<xsl:template name="create-widget">
	<xsl:param name="mode" select="false()"/>
	<xsl:param name="parent_id"/>
		 
		<!-- Default Create-Widget (Container View) -->

		<div id="create-widget">
			<a href="#object-types" class="flyout create-widget fg-button fg-button-icon-right ui-state-default ui-corner-all" tabindex="0">
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
							<xsl:apply-templates select="/document/object_types/object_type[can_create and parent_id = $parent_id]" mode="fo-menu">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/document/object_types/object_type[can_create and (@id = '1' or @id = '2' or @id = '3' or @id = '4' or @id = '20' or @id = '11')]" mode="fo-menu">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
			&#160;<a href="{$xims_box}{$goxims_content}{$absolute_path}?preview=1" class="button"><xsl:value-of select="$i18n/l/Preview"/></a>
		</div>
		
		</xsl:template>
</xsl:stylesheet>
