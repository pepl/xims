<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: newsitem_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exslt="http://exslt.org/common"
                xmlns="http://www.w3.org/1999/xhtml" 
                extension-element-prefixes="exslt date">

	<xsl:import href="document_common.xsl"/>
	
	<xsl:variable name="i18n_news" select="document(concat($currentuilanguage,'/i18n_newsitem.xml'))"/>
	<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
	
	<xsl:template name="tr-minify"/>
	<xsl:template name="tr-bodyfromfile-create"/>
	
	<xsl:template name="form-leadimage-create">
		<xsl:call-template name="form-leadimage">
			<xsl:with-param name="mode">create</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="form-leadimage-edit">
		<xsl:call-template name="form-leadimage">
			<xsl:with-param name="mode">edit</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="form-leadimage">
		<xsl:param name="mode"/>
		<div class="form-div block" id="form-leadimage">
		<div id="tr-lead">
			<div class="label-std">
				<label for="input-lead">
					<xsl:value-of select="$i18n/l/Lead"/>
				</label>
			</div>
			<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>-->
			<br/>
			<textarea id="input-lead" name="abstract" rows="3" cols="74" onkeyup="keyup(this)">
				<xsl:apply-templates select="abstract"/>
                <xsl:comment/>
			</textarea>
			<xsl:text>&#160;</xsl:text>
			<span id="charcount">
				<xsl:text>&#160;</xsl:text>
			</span>
			<xsl:call-template name="charcountcheck"/>
		</div>
		<xsl:if test="$mode='edit'">
			<xsl:call-template name="form-image"><xsl:with-param name="mode">edit</xsl:with-param></xsl:call-template>
		</xsl:if>
		<xsl:if test="$mode='create'">
			<xsl:call-template name="form-image"><xsl:with-param name="mode">create</xsl:with-param></xsl:call-template>
			<div>
				<div class="label-std">
					<label for="input-image-title">
						<xsl:value-of select="$i18n/l/Image"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="$i18n/l/Title"/>
					</label>
				</div>
				<input type="text" name="imagetitle" size="60" class="text" id="input-image-title"/>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('ImageTitle')" class="doclink">(?)</a>-->
			</div>
			<div id="tr-image-description">
				<div id="label-image-description">
					<label for="input-image-description">
						<xsl:value-of select="$i18n/l/Image"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="$i18n/l/Description"/>
					</label>
				</div>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('ImageDescription')" class="doclink">(?)</a>-->
				<br/>
				<textarea name="imagedescription" rows="3" cols="74" class="text" id="input-image-description">
					<xsl:text>&#160;</xsl:text>
				</textarea>
				<script type="text/javascript">document.getElementsByName("imagedescription")[0].value = '';</script>
			</div>
            <div id="tr-image-rights">
			  <div id="label-image-rights">
				<label for="input-image-rights">
				  <xsl:value-of select="$i18n/l/Image"/>
				  <xsl:text>&#160;</xsl:text>
				  <xsl:value-of select="$i18n/l/Rights"/>
				</label>
			  </div>
			  <!--<xsl:text>&#160;</xsl:text>
				  <a href="javascript:openDocWindow('ImageRights')" class="doclink">(?)</a>-->
			  <br/>
			  <textarea name="imagerights" rows="3" cols="74" class="text" id="input-image-rights">
				<xsl:text>&#160;</xsl:text>
			  </textarea>
			  <script type="text/javascript">document.getElementsByName("imagerights")[0].value = '';</script>
			</div>
			<div id="tr-image-target">
				<div class="label-std">
					<label for="input-image-target">
						<xsl:value-of select="$i18n/l/Image"/>
						<xsl:text>&#160;</xsl:text>
						<xsl:value-of select="$i18n/l/target"/>
					</label>
				</div>
				<input type="text" name="imagefolder" size="60" class="text" id="input-image-target">
					<!--  Provide an "educated-guess" default value -->
					<xsl:attribute name="value">
                        <!-- filter out root and document when this template is
                             used for URLLinks representing Image Tiles -->
						<xsl:for-each select="/document/context/object/parents/object[@document_id != 1 and object_type_id != 2]">
							<xsl:text>/</xsl:text>
							<xsl:value-of select="location"/>
						</xsl:for-each>
						<xsl:text>/images</xsl:text>
					</xsl:attribute>
				</input>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('NewsItemImage')" class="doclink">(?)</a>-->
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$parentid}&amp;to={$parentid}&amp;otfilter=Folder,DepartmentRoot,SiteRoot&amp;contentbrowse=1;sbfield=eform.imagefolder','default-dialog','{$i18n/l/browse_target}')" class="button">
					<xsl:value-of select="$i18n/l/browse_target"/>
				</a>
			</div>
		</xsl:if>
		</div>
	</xsl:template>

  <xsl:template name="form-image">
    <xsl:param name="mode">edit</xsl:param>
    <div id="tr-image">
      <!-- Load image from XIMS -->
      <xsl:if test="$mode='edit'">
        <xsl:variable name="curr_id">
          <xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
        </xsl:variable>
        <div class="label-std">
          <label for="input-image">
            <xsl:value-of select="$i18n/l/Image"/>
          </label>
        </div>
        <input type="text" name="image" size="60" value="{image_id}" class="text" id="input-image"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$curr_id}&amp;contentbrowse=1&amp;to={$curr_id}&amp;otfilter=Image&amp;sbfield=eform.image','default-dialog','{$i18n/l/Browse_image}')" class="button"><xsl:value-of select="$i18n/l/Browse_image"/></a>
      </xsl:if>
      <!-- Upload image -->
      <xsl:if test="$mode='create'">
        <div class="label-std"><label for="imagefile"><xsl:value-of select="$i18n/l/Image"/></label></div>
        <input type="file" name="imagefile" id="imagefile" class="text"/>
        <xsl:text>&#160;</xsl:text>
      </xsl:if>
    </div>
  </xsl:template>
	
  <xsl:template name="charcountcheck">
	<script type="text/javascript">
      var str_of  = '<xsl:value-of select="$i18n_news/l/of"/>';
      var str_entered = '<xsl:value-of select="$i18n_news/l/Characters_entered"/>';
      var str_charlimit  = '<xsl:value-of select="$i18n_news/l/Charlimit_reached"/>';
      var maxKeys = 390; // Should this be a config.xsl value?
    </script>
  </xsl:template>
	
  <xsl:template name="form-metadata">
    <div class="form-div block">
	  <h2><xsl:value-of select="$i18n/l/Metadata"/></h2>
	  <xsl:call-template name="form-keywords"/>
	  <xsl:call-template name="form-valid_from"/>
	  <xsl:call-template name="form-valid_to"/>
    </div>
  </xsl:template>

  <xsl:template name="form-link">
    <div class="form-div-block">
      <h2>NewsLink</h2>
      <div class="form-div ui-corner-all div-left" id="tr-link">
		<div class="label-std">
		  <label for="input-link">
			<!-- Location is now 'Pfad' in german translation - 
				 <xsl:value-of select="$i18n/l/Location"/>
			-->
			<xsl:value-of select="$i18n/l/LocationURL"/>
		  </label>
		</div>
        <!-- link stored in body field -->
		<input type="text" name="body" size="60" class="text" id="input-link" onchange="checkLangSuffix()" value="{body}"></input>
		
		<xsl:text>&#160;</xsl:text>
        <!-- when adding a navigation link or a document link show
             parent container instead of the departmentlinks folder
		-->
		<a class="button" id="buttonBrTarget">
		  <xsl:attribute name="href">
			javascript:createDialog('<xsl:value-of select="$xims_box"/>
                                     <xsl:value-of select="$goxims_content"/>
                                     <xsl:text>?id=</xsl:text>
                                     <xsl:value-of select="/document/context/object/parents/object[last() - 1]/@id"/>
                                     <xml:text>&amp;contentbrowse=1&amp;sbfield=eform.body&amp;urllink=1'</xml:text>,
                                    'default-dialog',
                                    '<xsl:value-of select="$i18n/l/browse_target"/>');
		  </xsl:attribute>
		  <xsl:value-of select="$i18n/l/browse_target"/>
		</a>
		<xsl:text>&#160;</xsl:text>
		<a class="button warn" id="content-lang-notice" style="display:none;" href="javascript:openLangDialog()">Hinweis</a>
		<div id="dialog-lang" title="{$i18n/l/Notice}">
		  <p><xsl:value-of select="$i18n/l/WarnLangSuffix"/></p>
		</div>
      </div>
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

$( "#dialog-lang" ).dialog({ autoOpen: false });

checkLangSuffix();               
    </script>    
  </xsl:template>


    
</xsl:stylesheet>
