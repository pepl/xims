<?xml version="1.0" encoding="utf-8"?>
<!--
 # Copyright (c) 2002-2013 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id: libraryitem_common.xsl 2188 2009-01-03 18:24:00Z pepl $
 -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--<xsl:import href="common.xsl"/>-->
	
	<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
	
	<xsl:variable name="popupsizes">
		<subject     x="910" y="500"/>
		<author      x="620" y="320"/>
		<keyword     x="550" y="200"/>
		<publication x="600" y="260"/>
		<delete      x="550" y="340"/>
		<editor      x="550" y="340"/>
		<journal      x="550" y="340"/>
	</xsl:variable>
	
	<xsl:template name="form-vlproperties">
		<xsl:param name="mo"/>
		<xsl:param name="mode"/>
		<xsl:param name="property"><xsl:value-of select="$i18n_vlib/l/*[name()=$mo]"/></xsl:param>
		<div class="form-div block">
		<div class="block">
			<div class="label-large">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>:
			</div>
			<div id="mapped_{$mo}s">
				<xsl:choose>
					<xsl:when test="$mo='author'">
						<xsl:apply-templates select="authorgroup/author"/>
					</xsl:when>
					<xsl:when test="$mo='editor'">
						<xsl:apply-templates select="editorgroup/author"/>
					</xsl:when>
					<xsl:when test="$mo='serial'">
						<xsl:apply-templates select="serial" mode="edit"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[name()=concat($mo, 'set')]/*[name()=$mo]"/>
					</xsl:otherwise>
				</xsl:choose>
				<span id="message_{$mo}"><xsl:comment/></span>
				<xsl:text>&#160;</xsl:text>
			</div>
		</div>
		<xsl:if test="$mo!='serial' or ($mo='serial' and not(/document/context/object/serial) )">
		<div>
			<div class="label-large">
				<!--<label for="svl{$mo}">-->
				<!-- <label for="vl{$mo}">-->
					<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>
				<!-- </label> -->
			</div>
			<xsl:if test="/document/context/*[name()=concat('vl', $mo,'s')] or $mo = 'editor'">
				<span id="svl{$mo}container">
					<xsl:choose>
						<xsl:when test="$mo='editor'">
							<xsl:apply-templates select="/document/context/*[name()=concat('vl', 'author','s')]" mode="editor"/>
						</xsl:when>
						<xsl:otherwise>
						<xsl:choose>
            <xsl:when test="/document/context/*[name()=concat('vl', $mo,'s')]">
							<xsl:apply-templates select="/document/context/*[name()=concat('vl', $mo,'s')]"/>
							</xsl:when>
							<xsl:otherwise></xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<xsl:text>&#160;</xsl:text>
				<xsl:choose>
					<xsl:when test="$mode='rl'">
						<button type="submit" name="create_{$mo}_mapping" class="button"><xsl:value-of select="$i18n_vlib/l/Create_mapping" /></button>
					</xsl:when>
					<xsl:otherwise>
						<button type="button" name="create_mapping" class="button" onclick="createMapping('{$mo}', $('#svl{$mo}').val(), '{$i18n_vlib/l/select_name}')"><xsl:value-of select="$i18n_vlib/l/Create_mapping" /></button>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<xsl:if test="$mode != 'rl'">
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo}','{$popupsizes[name()=$mo]/@x}','{$popupsizes[name()=$mo]/@y}')">
				<!--  <a onclick="$('#{$mo}_box').load('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo} fieldset')"> -->
				<xsl:value-of select="concat($i18n/l/create, ' ', $i18n_vlib/l/*[name()=$mo])"/>
			</a>
			</xsl:if>
			<xsl:text>&#160;</xsl:text>
		</div>
		</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template name="form-vlkeywords-edit">
		<div class="form-div block">
		<div class="block">
			<div class="label-med">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/Keywords"/>
			</div>
			<div class="div-left" style="width:600px">
				<xsl:apply-templates select="keywordset/keyword">
					<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				</xsl:apply-templates>
				</div>
			<br class="clear"/>
		</div>
		
		<div class="block">
			<div class="label-med">
				<label for="vlkeyword"><xsl:value-of select="$i18n_vlib/l/Assign_new"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/Keywords"/></label>
			</div>				
				<!--<a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>-->				
				<xsl:apply-templates select="/document/context/vlkeywords"/>
				<xsl:text>&#160;</xsl:text>
				<button type="submit" name="create_mapping" class="button"><xsl:value-of select="$i18n_vlib/l/Create_mapping"/></button>
		</div>
		</div>
	</xsl:template>
	
	<xsl:template name="form-vlsubjects-edit">
	<div class="form-div block">
		<div class="block">
			<div class="label-med">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>				
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_vlib/l/subjects"/>
			</div>
			<div class="div-left" style="width:600px">
				<xsl:apply-templates select="subjectset/subject">
					<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				</xsl:apply-templates>
				
			</div>
			<br class="clear"/>
		</div>
		
		<div class="block">
			<div class="label-med">
							<label for="vlsubject"><xsl:value-of select="$i18n_vlib/l/Assign_new"/>				
							<xsl:text>&#160;</xsl:text>
							<xsl:value-of select="$i18n_vlib/l/subjects"/></label>
			</div>
				<!--
				<a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
				-->
				<xsl:apply-templates select="/document/context/vlsubjects"/>
				<xsl:text>&#160;</xsl:text>
				<button type="submit" name="create_mapping" class="button"><xsl:value-of select="$i18n_vlib/l/Create_mapping"/></button>
		</div>
	</div>
	</xsl:template>
	
	<xsl:template match="keywordset/keyword|subjectset/subject|publicationset/publication">
		<a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1&amp;{concat(name(),'_id')}={id}" target="_blank" title="Browse in a new window">
			<xsl:value-of select="name"/>
			<xsl:if test="volume != ''">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="volume"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</a>
		<xsl:text>&#160;</xsl:text>
		<!--<button type="button" name="remove_mapping" onclick="removeMapping('{name()}','{id}')"><xsl:value-of select="$i18n_vlib/l/Delete_mapping" /></button>-->
		<a href="javascript:removeMapping('{name()}', '{id}')">
			<xsl:attribute name="title"><xsl:value-of select="$i18n_vlib/l/Delete_mapping"/>: <xsl:value-of select="name"/></xsl:attribute>
			<span class="xdelete"> x </span>
		</a>
		<xsl:if test="position()!=last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="authorgroup/author">
		<a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1&amp;{concat(name(),'_id')}={id}" target="_blank" title="Browse in a new window">
			<xsl:value-of select="firstname"/>&#160;<xsl:value-of select="lastname"/>
		</a>
		<xsl:text>&#160;</xsl:text>
		<a href="javascript:removeMapping('{name()}', '{id}')" title="$i18n/l/Delete_mapping: {name}">
			<span class="xdelete"> x </span>
		</a>
		<xsl:if test="position()!=last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="editorgroup/author">
		<a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1&amp;{concat(name(),'_id')}={id}" target="_blank" title="Browse in a new window">
			<xsl:value-of select="firstname"/>&#160;<xsl:value-of select="lastname"/>
		</a>
		<xsl:text>&#160;</xsl:text>
		<a href="javascript:removeMapping('{name()}', '{id}')" title="$i18n/l/Delete_mapping: {name}">
			<span class="xdelete"> x </span>
		</a>
		<xsl:if test="position()!=last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="vlserials">
		<select name="svlserial" id="svlserial">
			<xsl:apply-templates select="/document/context/vlserials/serial">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlsubjects">
		<select name="svlsubject" id="svlsubject">
			<xsl:apply-templates select="/document/context/vlsubjects/subject">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlkeywords">
		<select name="svlkeyword" id="svlkeyword">		
			<xsl:apply-templates select="/document/context/vlkeywords/keyword">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlpublications">
		<select name="svlpublication" id="svlpublication">
			<xsl:apply-templates select="/document/context/vlpublications/publication">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlauthors">
		<select name="svlauthor" id="svlauthor">
			<xsl:apply-templates select="/document/context/vlauthors/author">
				<xsl:sort select="translate(lastname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				<xsl:sort select="translate(firstname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				<xsl:sort select="translate(middlename,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlauthors" mode="editor">
		<select name="svleditor" id="svleditor">
			<xsl:apply-templates select="/document/context/vlauthors/author">
				<xsl:sort select="translate(lastname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				<xsl:sort select="translate(firstname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				<xsl:sort select="translate(middlename,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlpublications/publication">
		<option value="{id}">
			<xsl:value-of select="normalize-space(concat(name, ' (', volume, ')'))"/>
		</option>
	</xsl:template>
	
	<xsl:template match="vlsubjects/subject|vlkeywords/keyword">
		<option value="{id}">
			<xsl:value-of select="normalize-space(name)"/>
		</option>
	</xsl:template>
	
	<xsl:template match="vlauthors/author">
		<option value="{id}">
			<xsl:value-of select="normalize-space(concat(firstname, ' ', middlename, ' ', lastname, ' ', suffix))"/>
		</option>
	</xsl:template>
	
	<xsl:template match="vlserials/serial">
		<option value="{@id}">
			<xsl:value-of select="title"/>
		</option>
	</xsl:template>


</xsl:stylesheet>
