<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibraryitem_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default">
			<xsl:with-param name="mode">create</xsl:with-param>
			<xsl:with-param name="reflib">true</xsl:with-param>
    </xsl:call-template>
    <body>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <xsl:call-template name="header">
					<xsl:with-param name="containerpath">true</xsl:with-param>
        </xsl:call-template>
        <div class="edit">
        <div id="tab-container" class="ui-corner-top">
        <xsl:call-template name="table-create"/>
        </div>
        <div class="cancel-save">
					<xsl:call-template name="cancelcreateform">
                    <xsl:with-param name="with_save">yes</xsl:with-param>
                </xsl:call-template>
        </div>
            <div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" enctype="multipart/form-data" id="create-edit-form">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <input type="hidden" name="reftype" value="{$reftype}"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="tr-vlauthors"/>
                    <xsl:call-template name="tr-vleditors"/>
                    <xsl:call-template name="tr-vlserials"/>
                    <div id="reference-properties" class="ui-widget-content ui-corner-all">
                    <xsl:apply-templates select="/document/reference_properties/reference_property">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="tr-abstract"/>
                    <xsl:call-template name="tr-notes"/>
                    </div>
                <xsl:call-template name="saveaction"/>
            </form>
            		</div>
             <div class="cancel-save">
            <xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
						</div>
        </div>
    </body>
</html>
</xsl:template>

</xsl:stylesheet>
