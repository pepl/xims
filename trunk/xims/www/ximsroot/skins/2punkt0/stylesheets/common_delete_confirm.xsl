<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_delete_confirm.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="common.xsl"/>
	<xsl:import href="common_header.xsl"/>
	<!--<xsl:output method="html" encoding="utf-8"/>-->
	<xsl:param name="id"/>
	<xsl:template match="/document/context/object">
		<html>
			<xsl:call-template name="head_default">
				<xsl:with-param name="mode">delete</xsl:with-param>
			</xsl:call-template>
			<!--<head>
				<title>
                Löschen von <xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' bestätigen - XIMS
            </title>
				<xsl:call-template name="css">
					<xsl:with-param name="jquery-ui-smoothness">true</xsl:with-param>
					<xsl:with-param name="fg-menu">true</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="script_head">
					<xsl:with-param name="jquery">true</xsl:with-param>
					<xsl:with-param name="fg-menu">true</xsl:with-param>
				</xsl:call-template>
			</head>-->
			<body>
				<xsl:call-template name="header">
					<!--<xsl:with-param name="noncontent">true</xsl:with-param>
					<xsl:with-param name="nopath">true</xsl:with-param>-->
				</xsl:call-template>
				<div id="table-container">
					<form name="objectdeletion" action="{$xims_box}{$goxims_content}" method="GET">
						<h1 class="bluebg">Löschen des Objekts bestätigen</h1>
						<p>
                      Sie sind dabei das Objekt '<xsl:value-of select="title"/>' zu löschen.
                  </p>
						<p>
							<strong>Dies ist eine <em>endgültige</em> Aktion und kann nicht rückgängig gemacht werden!</strong>
						</p>
						<p>
                      Klicken Sie auf 'Bestätigen' um fortzufahren, oder auf 'Abbrechen' um zurück zur vorigen Seite zu gelangen.
                  </p>
						<div id="confirm-buttons">
							<input class="ui-state-default ui-corner-all fg-button" name="delete" type="submit" value="Bestätigen"/>
							<input name="id" type="hidden" value="{$id}"/>
                        &#160;
                        <input type="button" value="Abbrechen" class="ui-state-default ui-corner-all fg-button" name="default" onclick="javascript:history.go(-1)"/>
						</div>
					</form>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
