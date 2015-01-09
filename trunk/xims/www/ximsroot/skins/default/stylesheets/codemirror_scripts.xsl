<?xml version="1.0"?>
	<!--
		# Copyright (c) 2002-2015 The XIMS Project. # See the file "LICENSE"
		for information and conditions for use, reproduction, # and
		distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
		$Id: common_xml_script.xsl 2249 2009-08-10 11:29:26Z haensel $
	-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns="http://www.w3.org/1999/xhtml">

	<xsl:template name="codemirror_scripts">
		<xsl:call-template name="codemirror_load" />
		<xsl:call-template name="codemirror_init" />
	</xsl:template>
	
	<xsl:template name="codemirror_load">		
		<script  type="text/javascript" src="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/lib/codemirror.js"><xsl:comment/></script>
		<script  type="text/javascript" src="{$ximsroot}vendor/codemirror-ui/js/codemirror-ui.js"><xsl:comment/></script>
		<script  type="text/javascript" src="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/lib/util/search.js"><xsl:comment/></script>
		<script  type="text/javascript" src="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/lib/util/searchcursor.js"><xsl:comment/></script>
                <!-- markdown needs xml preloaded -->
		<xsl:if test="$cm_mode='markdown'">
		  <script  type="text/javascript" src="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/mode/xml/xml.js"><xsl:comment/></script>
		</xsl:if>
		<script  type="text/javascript" src="{$ximsroot}vendor/codemirror-ui/lib/CodeMirror-2.3/mode/{$cm_mode}/{$cm_mode}.js"><xsl:comment/></script>
	</xsl:template>

	<xsl:template name="codemirror_init">
		<xsl:param name="cm_mode"><xsl:value-of select="$cm_mode"/></xsl:param>
		<script  type="text/javascript">
			$().ready(function(){
				var textarea = document.getElementById('body');
				var editor = new CodeMirrorUI(textarea,
				{
					path : ximsconfig.ximsroot + 'vendor/codemirror-ui/js/',
					searchMode : 'popup'
				},
				{
					mode: '<xsl:value-of select="$cm_mode"/>',
					lineNumbers: true,
                    lineWrapping: true,
					matchBrackets: true
				});
				$(".CodeMirror").resizable({ handles: 's' });					
			});
		</script>
	</xsl:template>

</xsl:stylesheet>
