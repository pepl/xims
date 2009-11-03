<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_footer.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://exslt.org/strings" extension-element-prefixes="str" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:template name="footer">
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<div class="container border narrow space-top">
			<div class="left width-third">
				<xsl:choose>
					<xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type='application/x-container'">
						<xsl:call-template name="please_read"/>&#160;
                        <a href="{$xims_box}{$goxims_content}{$absolute_path}?sitemap=1">
							<xsl:value-of select="$i18n/l/Treeview"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="please_read"/>&#160;
                        <xsl:choose>
							<xsl:when test="$printview != '0'">
								<a href="{$goxims_content}{$absolute_path}?m={$m}">
									<xsl:value-of select="$i18n/l/Defaultview"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a href="{$goxims_content}{$absolute_path}?m={$m};printview=1">
									<xsl:value-of select="$i18n/l/Printview"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="center width-third">
				<span id="department_title">
					<xsl:call-template name="department_title"/>
				</span>
			</div>
			<div class="right width-third">
				<a class="popuplink" href="http://xims.info/documentation/" target="_blank">Systeminfo</a>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template name="please_read">
		<xsl:variable name="encoded_title" select="str:encode-uri(title,false())"/>
		<a href="mailto:?subject=[XIMS]%20{$encoded_title}&amp;body={str:encode-uri($i18n/l/Please_read_object,false())}:%0A%0A%22{$encoded_title}%22%0A{$xims_box}{$goxims_content}?id={@id}%0A">
			<xsl:value-of select="$i18n/l/Email"/>
		</a>
	</xsl:template>
</xsl:stylesheet>
