<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="document_common.xsl"/>
<xsl:import href="newsitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
			<xsl:call-template name="head_default">
			<xsl:with-param name="calendar">true</xsl:with-param>
			<xsl:with-param name="mode">edit</xsl:with-param>
			</xsl:call-template>
			<body>
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
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST" id="create-edit-form">
              
                    <xsl:call-template name="tr-title-edit"/>
                    <xsl:call-template name="tr-leadimage-edit"/>
                    <xsl:call-template name="tr-body-edit">
                        <xsl:with-param name="with_origbody" select="'yes'"/>
                    </xsl:call-template>

                            <xsl:call-template name="testbodysxml"/>
                            <xsl:call-template name="prettyprint"/>

                    <xsl:call-template name="trytobalance"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-valid_from"/>
                    <xsl:call-template name="tr-valid_to"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="expandrefs"/>
        
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
					<div class="cancel-save">
						<xsl:call-template name="cancelform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
				</div>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

<!--<xsl:template name="head-edit">
    <head>
        <title><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
        <xsl:call-template name="css"/>
        <xsl:call-template name="jscalendar_scripts"/>
    </head>
</xsl:template>-->

</xsl:stylesheet>
