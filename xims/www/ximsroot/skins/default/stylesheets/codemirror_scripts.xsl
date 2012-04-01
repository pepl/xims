<?xml version="1.0"?>
	<!--
		# Copyright (c) 2002-2011 The XIMS Project. # See the file "LICENSE"
		for information and conditions for use, reproduction, # and
		distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
		$Id: common_xml_script.xsl 2249 2009-08-10 11:29:26Z haensel $
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:template name="codemirror_scripts">
		<xsl:call-template name="codemirror_load" />
		<xsl:call-template name="codemirror_init" />
	</xsl:template>
	
	<xsl:template name="codemirror_load">
			<script language="javascript" type="text/javascript" src="{$ximsroot}scripts/codemirror_ui/lib/CodeMirror-2.0/lib/codemirror.js"></script>
            <link rel="stylesheet" href="{$ximsroot}scripts/codemirror_ui/lib/CodeMirror-2.0/lib/codemirror.css" />
            <script src="{$ximsroot}scripts/codemirror_ui/lib/CodeMirror-2.0/mode/{$cm_mode}/{$cm_mode}.js"></script>
            <link rel="stylesheet" href="{$ximsroot}scripts/codemirror_ui/lib/CodeMirror-2.0/mode/{$cm_mode}/{$cm_mode}.css" />
			<script language="javascript" type="text/javascript" src="{$ximsroot}scripts/codemirror_ui/js/codemirror-ui.js"></script>
			<link rel="stylesheet" type="text/css" href="{$ximsroot}scripts/codemirror_ui/css/codemirror-ui.css" />
	</xsl:template>

	<xsl:template name="codemirror_init">
		<xsl:param name="cm_mode"><xsl:value-of select="$cm_mode"/></xsl:param>
		<script language="javascript" type="text/javascript">
			$().ready(function(){
				var ximsroot = '<xsl:value-of select="$ximsroot" />';
				var textarea = document.getElementById('body');
				var editor = new CodeMirrorUI(textarea,
				{
					path : '<xsl:value-of select="$ximsroot" />scripts/codemirror_ui//',
					searchMode : 'popup'
				},
				{
					height: '250px',
                    mode: '<xsl:value-of select="$cm_mode"/>',
                    lineNumbers: true,
					autoMatchParens: true
				});
			});
		</script>
	</xsl:template>

</xsl:stylesheet>
