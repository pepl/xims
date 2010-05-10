<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<!--<xsl:param name="view" select="container"/>-->

<xsl:template name="form-stylemedia">
<div class="block form-div">
<h2>Style &amp; Media / Multimedia</h2>
	<!--<xsl:call-template name="form-stylesheet"/>
	<xsl:call-template name="form-css"/>
	<xsl:call-template name="form-script"/>-->
	<!--<xsl:call-template name="tr-imagedepartmentroot-create"/>-->
	<!--<xsl:call-template name="form-image"/>
	<xsl:call-template name="form-feed"/>-->
</div>
</xsl:template>

<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2>Objekt-spezifische Optionen</h2>
			<!--<xsl:call-template name="autoindex"/>-->
			<xsl:call-template name="defaultsorting"/>
			<xsl:call-template name="image-size"/>
			<xsl:call-template name="thumbnail-pos"/>
			<xsl:call-template name="show-caption"/>
			<xsl:call-template name="show-nav"/>
		</div>
	</xsl:template>

<xsl:template name="form-keywords"/>

<!--Position of thrumbnails-->
<xsl:template name="image-size">
<div>
	Größe der Bilder:<br/>
	<input type="radio" id="imgwidth-800" name="imgwidth" class="radio-button" value="800">
		<xsl:if test="/document/context/object/attributes/imgwidth = 800"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input>
	<label for="imgwidth-800">800 x 600</label><br/>
	
	<input type="radio" id="imgwidth-640" name="imgwidth" class="radio-button" value="640">
		<xsl:if test="/document/context/object/attributes/imgwidth = 640 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input>
	<label for="imgwidth-640">640 x 480</label><br/>
	
	<input type="radio" id="imgwidth-400" name="imgwidth" class="radio-button" value="400">
		<xsl:if test="/document/context/object/attributes/imgwidth = 400"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input>
	<label for="imgwidth-400">400 x 300</label><br/>
	<!--<input type="radio" id="imgwidth-200" name="imgwidth" class="radio-button" value="200">
		<xsl:if test="/document/context/object/attributes/imgwidth = 200"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-200">200 x 150</label>-->
</div>
</xsl:template>

<!--Position of thrumbnails-->
<xsl:template name="thumbnail-pos">
<div>
	Position der Thumnails:<br/>
	<input type="radio" id="thumbpos-top" name="thumbpos" class="radio-button" value="top">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'top' or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
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
</div>
</xsl:template>

<xsl:template name="show-caption">
<div>
<label for="showcaption">Zeige Bildbeschreibung an</label> <input type="checkbox" id="showcaption" name="showcaption" class="checkbox">
	<xsl:if test="/document/context/object/attributes/showcaption = 1 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input><br/>
(Wird aus der Zusammenfassung / Abstract des BildObjekts generiert)
</div>
</xsl:template>

<xsl:template name="show-nav">
<div>
<label for="shownavigation">Zeige Navigation an</label> <input type="checkbox" id="shownavigation" name="shownavigation" class="checkbox">
	<xsl:if test="/document/context/object/attributes/shownavigation = 1 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input><br/>
</div>
</xsl:template>

	<xsl:template name="create-widget">
	<xsl:param name="mode" select="false()"/>
	<xsl:param name="parent_id"/>		 
		<!-- Default Create-Widget (Container View) -->
		<div id="create-widget">
			<a href="#object-types" class="flyout create-widget fg-button fg-button-icon-right ui-state-default ui-corner-all" tabindex="0">
				<span class="ui-icon ui-icon-triangle-1-s"/>
				<xsl:value-of select="$i18n/l/Create"/>
			</a>
			<div id="object-types" class="hidden-content">
				<ul>
					<xsl:choose>
						<xsl:when test="/document/context/object/@id = 1">
							<xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]"/>
						</xsl:when>
						<xsl:when test="$parent_id != ''">
							<xsl:apply-templates select="/document/object_types/object_type[can_create and parent_id = $parent_id]" mode="fo-menu">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="/document/object_types/object_type[can_create and @id = '3']" mode="fo-menu">
								<xsl:sort select="name"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
			<xsl:choose>
				<xsl:when test="$view = 'preview'">
					&#160;<a href="{$xims_box}{$goxims_content}{$absolute_path}" class="button"><xsl:value-of select="$i18n/l/Container_View"/></a>
				</xsl:when>
				<xsl:when test="$view = 'container'">
					&#160;<a href="{$xims_box}{$goxims_content}{$absolute_path}?preview=1" class="button"><xsl:value-of select="$i18n/l/Preview"/></a>
				</xsl:when>
				<xsl:otherwise>
					nix
				</xsl:otherwise>
			</xsl:choose>
			
		</div>
		
		</xsl:template>
</xsl:stylesheet>
