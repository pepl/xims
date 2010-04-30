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
	<input type="radio" id="imgwidth-640" name="imgwidth" class="radio-button" value="640">
		<xsl:if test="/document/context/object/attributes/imgwidth = 640 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-640">640 x 480</label><br/>
	<input type="radio" id="imgwidth-400" name="imgwidth" class="radio-button" value="400">
		<xsl:if test="/document/context/object/attributes/imgwidth = 400"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
	</input><label for="imgwidth-400">400 x 300</label><br/>
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
		<xsl:if test="/document/context/object/attributes/thumbpos = 'top' or /document/context/object/attributes =''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
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
	<xsl:if test="/document/context/object/attributes/showcaption = 1 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input><br/>
</td>
</tr>
</xsl:template>

<xsl:template name="show-nav">
<tr>
<td colspan="3">
<label for="shownav">Zeige Navigation an</label>
<input type="checkbox" id="shownav" name="shownavigation" class="checkbox">
	<xsl:if test="/document/context/object/attributes/shownavigation = 1 or /document/context/object/attributes = ''"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
</input>
</td>
</tr>
</xsl:template>

<xsl:template name="header.cttobject.createwidget">
    <xsl:param name="parent_id"/>
    <div id="MDME" style="display:none">
        <ul>
            <li><xsl:value-of select="$i18n/l/Create"/>
                <ul>
                    <xsl:choose>
                        <xsl:when test="/document/context/object/@id = 1">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]"/>
                        </xsl:when>
                        <xsl:when test="$parent_id != ''">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and parent_id = $parent_id]">
                                <xsl:sort select="name"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and @id = '3']">
                                <xsl:sort select="name"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
            </li>
        </ul>
    </div>
    
    <noscript>
        <form action="{$xims_box}{$goxims_content}{$absolute_path}" style="margin-bottom: 0;" method="get">
                <select style="background: #eeeeee; font-family: helvetica; font-size: 10pt" name="objtype">
                    <xsl:choose>
                        <xsl:when test="/document/context/object/@id = 1">
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name = 'SiteRoot' ]" mode="form"/>
                        </xsl:when>
                        <xsl:otherwise>
			    <!-- Do not show object types which contain "Item" in their name with the only exception of "NewsItem"! -->
                            <xsl:apply-templates select="/document/object_types/object_type[can_create and name != 'Portal' and name != 'Annotation' and name != 'AnonDiscussionForumContrib' and not(contains(name,'Item') and not(substring-before(name, 'Item')='News')) and parent_id = $parent_id]" mode="form">
			        <xsl:sort select="name"/>
			    </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </select>
                <xsl:text>&#160;</xsl:text>
                <input type="image"
                    name="create"
                    src="{$sklangimages}create.png"
                    alt="{$i18n/l/Create}"
                    title="{$i18n/l/Create}" />
                <input name="page" type="hidden" value="{$page}"/>
                <input name="r" type="hidden" value="{/document/context/object/@id}"/>
                <xsl:if test="$defsorting != 1">
                    <input name="sb" type="hidden" value="{$sb}"/>
                    <input name="order" type="hidden" value="{$order}"/>
                </xsl:if>
        </form>
    </noscript>
</xsl:template>

</xsl:stylesheet>
