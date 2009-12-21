<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:variable name="i18n_reflib" select="document(concat($currentuilanguage,'/i18n_reflibrary.xml'))"/>

<xsl:template match="/document/context/object">
<html>
    <!--<xsl:call-template name="head-edit"/>-->
    <xsl:call-template name="head_default">
			<xsl:with-param name="reflib">true</xsl:with-param>
    </xsl:call-template>
    <body>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        
        <xsl:call-template name="header"/>
        <div class="edit">
        <div id="tab-container" class="ui-corner-top">	
            <xsl:call-template name="table-edit"/>
         </div>
         <div class="cancel-save">
            <xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
						</div>
         <div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" id="create-edit-form">
            
            <xsl:call-template name="reftypes_list"/>
            <br clear="left"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="tr-vlauthors"/>
  
                    
                    <xsl:call-template name="tr-vleditors"/>
                    <xsl:call-template name="tr-vlserials"/>
                    <div id="reference-properties" class="ui-widget-content ui-corner-all">
                    <xsl:apply-templates select="/document/reference_properties/reference_property">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                    .
                    </div>

                    <!-- Add Fulltext (->XIMS::File object as child ?) -->
                    <xsl:call-template name="tr-abstract"/>
                    <xsl:call-template name="tr-notes"/>
    
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <!--<xsl:call-template name="canceledit"/>-->
        <form action="{$xims_box}{$goxims_content}" name="reftypechangeform" method="get" style="display:none">
            <input type="hidden" name="id" value="{@id}"/>
            <input type="hidden" name="change_reference_type" value="1"/>
            <input type="hidden" name="reference_type_id" value=""/>
            <xsl:call-template name="rbacknav"/>
        </form>

        <div class="cancel-save">
            <xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
						</div>
				</div>
        <!--<xsl:call-template name="script_bottom"/>-->
    </body>
</html>
</xsl:template>

<!--    <xsl:template name="reftypes_select">
        <div>
            <xsl:value-of select="$i18n_reflib/l/ChangeRefType"/> &#160;
                <select name="reftypes_select" id="reftypes_select" onchange="return submitReferenceTypeUpdate(this.value);">
                    <xsl:apply-templates select="/document/reference_types/reference_type"/>
                </select>
        </div>
    </xsl:template>-->
    
    <xsl:template name="reftypes_list">
    		<div id="change-reftype">
    		<div><xsl:value-of select="$i18n_reflib/l/ChangeRefType"/> &#160;</div>
		<a class="flyout create-widget fg-button fg-button-icon-right ui-state-default ui-corner-all" tabindex="0" href="#ref-types">
			<span class="ui-icon ui-icon-triangle-1-s"/>
			<xsl:value-of select="/document/reference_types/reference_type[@id=$reftype]/name"/>
		</a> 
		<div id="ref-types" class="hidden-content">
			<ul>
					<xsl:apply-templates select="/document/reference_types/reference_type" mode="getoptions"/>
			</ul>
			</div>
    <!--<xsl:apply-templates select="/document/reference_types/reference_type" mode="descriptions"/>-->
    </div>
    </xsl:template>
    
    <xsl:template match="reference_type" mode="getoptions">
    <li><a href="javascript:return submitReferenceTypeUpdate(this.value);"><xsl:value-of select="name"/></a></li>
</xsl:template>

    <xsl:template match="/document/reference_types/reference_type">
        <option value="{@id}">
            <xsl:if test="@id = /document/context/object/reference_type_id">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="name"/>
        </option>
    </xsl:template>

</xsl:stylesheet>
