<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforum_edit.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default">
			<xsl:with-param name="mode">mode</xsl:with-param>
    </xsl:call-template>
    <body onload="document.eform['abstract'].value=''; document.eform.name.focus()">
        
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

                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="tr-description-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="markednew"/>

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

<xsl:template name="tr-description-edit">
    <div id="tr-description">
        <div id="label-description">
        <label for="input-description">
            <xsl:value-of select="$i18n/l/Description"/>
            </label></div>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('adf_description')" class="doclink">(?)</a>
            <br/>
            <textarea name="abstract" rows="3" cols="71" id="input-description">
							<xsl:choose>
                    <xsl:when test="string-length(abstract) &gt; 0">
                        <xsl:apply-templates select="abstract"/>
                     </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>            
            </textarea>
       </div>
</xsl:template>

</xsl:stylesheet>
