<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<!--  <xsl:import href="document_common.xsl"/>
  <xsl:import href="vlibraryitem_common.xsl"/>
-->
<xsl:import href="create_common.xsl"/>
<xsl:import href="newsitem_common.xsl"/>

 <!-- <xsl:param name="selEditor" select="true()"/>-->
  
  <xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
    <xsl:call-template name="form-leadimage-create"/>
    <br class="clear"/>
    <input type="hidden" name="proceed_to_edit" value="1"/>
  </xsl:template>
  
  <xsl:template name="form-location-create">
	<xsl:param name="testlocation" select="true()"/>
	<div>
	  <div class="label-std">
		<label for="input-location">
		  <!-- Location is now 'Pfad' in german translation - 
			   <xsl:value-of select="$i18n/l/Location"/>
		  -->
		  <xsl:value-of select="$i18n/l/LocationURL"/>
		  </label>&#160;*
	  </div>
	  <input type="text" name="name" size="60" class="text" id="input-location" onchange="checkLangSuffix()"></input>
	  <xsl:text>&#160;</xsl:text>
	  <a class="button" id="buttonBrTarget">
		<xsl:attribute name="href">
		  javascript:createDialog('<xsl:value-of select="$xims_box"/><xsl:value-of select="$goxims_content"/>?id=<xsl:value-of select="/document/context/object/parents/object[position() = (last() - 1)]/@id"/>&amp;contentbrowse=1&amp;sbfield=eform.name&amp;urllink=1','default-dialog','<xsl:value-of select="$i18n/l/browse_target"/>')
		</xsl:attribute>
		<xsl:value-of select="$i18n/l/browse_target"/>
	  </a>
	  <!-- end uibk special -->
	  <xsl:text>&#160;</xsl:text>
	  <a class="button warn" id="content-lang-notice" style="display:none;" href="javascript:openLangDialog()">Hinweis</a>
	  <div id="dialog-lang" title="{$i18n/l/Notice}">
		<p><xsl:value-of select="$i18n/l/WarnLangSuffix"/></p>
	  </div>
	  <script type="text/javascript">
			function openLangDialog(){
				$( '#dialog-lang' ).dialog('open');
			}
			function checkLangSuffix(){
				var arr = $('#input-location').val().split('.');
				if($.inArray(arr[arr.length -1], ['de','en','fr','ru','es','it']) != -1){
					$('#content-lang-notice').show();
					}
				else {
					$('#content-lang-notice').hide();
				}
			}
			$(document).ready(function(){
				$( "#dialog-lang" ).dialog({ autoOpen: false });
				checkLangSuffix();
			});
	  </script>	
	</div>	
  </xsl:template>

  
</xsl:stylesheet>
