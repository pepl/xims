<?xml version="1.0"?>
	<!--
		# Copyright (c) 2002-2011 The XIMS Project. # See the file "LICENSE"
		for information and conditions for use, reproduction, # and
		distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
		$Id: codemirror_css_script.xsl 2249 2009-08-10 11:29:26Z haensel $
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	
    <xsl:import href="codemirror_load.xsl"/>
    
    <xsl:template name="codemirror_scripts">
    	<xsl:call-template name="codemirror_load" />
		<xsl:call-template name="codemirror_css_init" />
	</xsl:template>
    
	<xsl:template name="codemirror_css_init">
    
    	<script language="javascript" type="text/javascript">
			var ximsroot = '<xsl:value-of select="$ximsroot" />'
		</script>
        
		<script language="javascript" type="text/javascript">
			$().ready(function(){
			
			  var textarea = document.getElementById('body');
			  //für FF, bringt nix
			  //textarea.focus();
			  var editor = new CodeMirrorUI(textarea,
			  {
				path : '<xsl:value-of select="$ximsroot" />',
				searchMode : 'popup'
			  },
			  {
				height: "250px",
				//content: textarea.value,
				parserfile: ["parsecss.js"/*, "parsexml.js", "tokenizejavascript.js", "parsejavascript.js", "parsehtmlmixed.js"*/],
				stylesheet: [ /*ximsroot + "scripts/codemirror_ui/lib/CodeMirror/css/xmlcolors.css",
							ximsroot + "scripts/codemirror_ui/lib/CodeMirror/css/jscolors.css",*/
							ximsroot + "scripts/codemirror_ui/lib/CodeMirror/css/csscolors.css",],
				path: ximsroot + "scripts/codemirror_ui/lib/CodeMirror/js/",
				autoMatchParens: true
			  });
					
			});
		</script>
	</xsl:template>
    
</xsl:stylesheet>
