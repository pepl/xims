<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/ExtraOptions"/></h2>
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
	<xsl:value-of select="$i18n/l/ImageSize"/>:<br/>
	<input type="radio" id="imgwidth-large" name="imgwidth" class="radio-button" value="large">
		<xsl:if test="/document/context/object/attributes/imgwidth = 'large' or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input>
	<label for="imgwidth-large"><xsl:value-of select="$i18n/l/large"/> (<xsl:value-of select="$i18n/l/Width"/> ca. 600px)</label><br/>
	
	<input type="radio" id="imgwidth-medium" name="imgwidth" class="radio-button" value="medium">
		<xsl:if test="/document/context/object/attributes/imgwidth = 'medium'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input>
	<label for="imgwidth-medium"><xsl:value-of select="$i18n/l/medium"/> (<xsl:value-of select="$i18n/l/Width"/> ca. 400px)</label><br/>
	
	<input type="radio" id="imgwidth-small" name="imgwidth" class="radio-button" value="small">
		<xsl:if test="/document/context/object/attributes/imgwidth = 'small'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-small"><xsl:value-of select="$i18n/l/small"/> (<xsl:value-of select="$i18n/l/Width"/> ca. 200px)</label>
</div>
</xsl:template>

<!--Position of thumbnails-->
<xsl:template name="thumbnail-pos">
<div>
<xsl:value-of select="$i18n/l/ThumbPosition"/>:<br/>
<input type="radio" id="thumbpos-top" name="thumbpos" class="radio-button" value="top">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'top' or /document/context/object/attributes =''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-top"><xsl:value-of select="$i18n/l/top"/></label><br/>
	<input type="radio" id="thumbpos-bottom" name="thumbpos" class="radio-button" value="bottom">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'bottom'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-bottom"><xsl:value-of select="$i18n/l/bottom"/></label><br/>
	<input type="radio" id="thumbpos-left" name="thumbpos" class="radio-button" value="left">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'left'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-left"><xsl:value-of select="$i18n/l/left"/></label><br/>
	<input type="radio" id="thumbpos-no" name="thumbpos" class="radio-button" value="no">
		<xsl:if test="/document/context/object/attributes/thumbpos = 'no'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="thumbpos-no"><xsl:value-of select="$i18n/l/noThumbs"/></label>
</div>
</xsl:template>

<xsl:template name="show-caption">
<div>
<label for="showcaption"><xsl:value-of select="$i18n/l/ShowCaption"/></label> <input type="checkbox" id="showcaption" name="showcaption" class="checkbox">
	<xsl:if test="/document/context/object/attributes/showcaption = 1 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input><br/>
<!--(Wird aus der Zusammenfassung / Abstract des BildObjekts generiert)-->
</div>
</xsl:template>

<xsl:template name="show-nav">
<div>
<label for="shownavigation"><xsl:value-of select="$i18n/l/ShowNavigation"/></label> <input type="checkbox" id="shownavigation" name="shownavigation" class="checkbox">
	<xsl:if test="/document/context/object/attributes/shownavigation = 1 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input><br/>
</div>
</xsl:template>

	<xsl:template name="create-widget">
	<xsl:param name="mode" select="false()"/>
	<xsl:param name="parent_id"/>		 
		<!-- Default Create-Widget (Container View) -->
		<div id="create-widget">
		<button >
				<xsl:value-of select="$i18n/l/Create"/>
			</button>
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
		<div style="display: inline-block; float:left; margin-top:10px; margin-right: 12px;">
			<xsl:choose>
				<xsl:when test="$view = 'preview'">
					&#160;<a href="{$xims_box}{$goxims_content}{$absolute_path}" class="button"><xsl:value-of select="$i18n/l/Container_View"/></a>
				</xsl:when>
				<xsl:when test="$view = 'container'">
					&#160;<a href="{$xims_box}{$goxims_content}{$absolute_path}?preview=1" class="button"><xsl:value-of select="$i18n/l/Preview"/></a>
				</xsl:when>
			</xsl:choose>
			</div>
		</xsl:template>
</xsl:stylesheet>
