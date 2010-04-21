<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">


<xsl:template name="form-obj-specific">
			<!--<xsl:call-template name="autoindex"/>-->
			<xsl:call-template name="defaultsorting"/>
			<xsl:call-template name="image-size"/>
			<xsl:call-template name="thumbnail-pos"/>
			<xsl:call-template name="show-caption"/>
			<xsl:call-template name="show-nav"/>
			
	</xsl:template>

<xsl:template name="form-keywords"/>

<!--Position of thrumbnails-->
<xsl:template name="image-size">
<tr>
	<td valign="top">Größe der Bilder:</td>
	<td colspan="2">
	<input type="radio" id="imgwidth-800" name="imgwidth" class="radio-button" value="800">
		<xsl:if test="/document/context/object/attributes/imgwidth = 800"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input>
	<label for="imgwidth-800">800 x 600</label><br/>
	<input type="radio" id="imgwidth-600" name="imgwidth" class="radio-button" value="600">
		<xsl:if test="/document/context/object/attributes/imgwidth = 600"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-600">600 x 450</label><br/>
	<input type="radio" id="imgwidth-400" name="imgwidth" class="radio-button" value="400">
		<xsl:if test="/document/context/object/attributes/imgwidth = 400"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-400">400 x 200</label><br/>
	<!--<input type="radio" id="imgwidth-200" name="imgwidth" class="radio-button" value="200">
		<xsl:if test="/document/context/object/attributes/imgwidth = 200"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-200">200 x 150</label>-->
	</td>
</tr>
</xsl:template>

<!--Position of thrumbnails-->
<xsl:template name="thumbnail-pos">
<tr>
	<td valign="top">Position der Thumbnails:</td>
	<td colspan="2">
	<input type="radio" id="thumbpos-top" name="thumbpos" class="radio-button" value="top">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'top'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-top">oben</label><br/>
	<input type="radio" id="thumbpos-bottom" name="thumbpos" class="radio-button" value="bottom">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'bottom'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-bottom">unten</label><br/>
	<input type="radio" id="thumbpos-left" name="thumbpos" class="radio-button" value="left">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'left'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-left">links</label><br/>
	<input type="radio" id="thumbpos-no" name="thumbpos" class="radio-button" value="no">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'no'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-no">keine Thumbnails</label>
	</td>
</tr>
</xsl:template>

<xsl:template name="show-caption">
<tr>
<td colspan="3">
<label for="showcaption">Zeige Bildbeschreibung an</label> 
<input type="checkbox" id="showcaption" name="showcaption" class="checkbox">
	<xsl:if test="/document/context/object/attributes/showcaption = 1"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input><br/>
</td>
</tr>
</xsl:template>

<xsl:template name="show-nav">
<tr>
<td colspan="3">
<label for="shownav">Zeige Navigation an</label>
<input type="checkbox" id="shownav" name="shownavigation" class="checkbox">
	<xsl:if test="/document/context/object/attributes/shownavigation = 1"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input>
</td>
</tr>
</xsl:template>

</xsl:stylesheet>
