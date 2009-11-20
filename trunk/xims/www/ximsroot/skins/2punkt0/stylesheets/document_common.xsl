<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="container_common.xsl"/>
	<!--	<xsl:import href="common_header.xsl"/>-->
	<xsl:param name="printview" select="'0'"/>
	<xsl:template name="table-create">
		<div id="create-title">
			<h1>
				<xsl:value-of select="$i18n/l/create"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$objtype"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/in"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$absolute_path"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/using"/>
				<xsl:text>&#160;</xsl:text>
				<label for="xims_wysiwygeditor">
					<xsl:value-of select="$i18n/l/Editor"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<xsl:call-template name="setdefaulteditor"/>
			</h1>
		</div>
	</xsl:template>
	<xsl:template name="table-edit">
		<div id="edit-title">
			<h1>
				<xsl:value-of select="$i18n/l/edit"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$objtype"/>
				<xsl:text>&#160;'</xsl:text>
				<xsl:value-of select="title"/>
				<xsl:text>'&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/in"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$parent_path"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/using"/>
				<xsl:text>&#160;</xsl:text>
				<label for="xims_wysiwygeditor">
					<xsl:value-of select="$i18n/l/Editor"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<xsl:call-template name="setdefaulteditor"/>
			</h1>
		</div>
	</xsl:template>
	<xsl:template name="trytobalance">
		<div id="tr-trytobal">
			<fieldset>
				<!--<div id="label-trytobal">-->
					<legend>
						<xsl:value-of select="$i18n/l/Try_to_well-balance"/>
					</legend>
				<!--</div>-->
				<input name="trytobalance" type="radio" value="true" checked="checked" onchange="javascript:createCookie('xims_trytobalancewell','true',90);" id="radio-trytobal-true" class="radio-button"/>
				<label for="radio-trytobal-true">
					<xsl:value-of select="$i18n/l/Yes"/>
				</label>
				<input name="trytobalance" type="radio" value="false" onchange="javascript:createCookie('xims_trytobalancewell','false',90);" id="radio-trytobal-false" class="radio-button"/>
				<label for="radio-trytobal-false">
					<xsl:value-of select="$i18n/l/No"/>
				</label>
			</fieldset>
		</div>
		<!-- set checked attribute for trytobalance-input-element according to cookie -->
		<script type="text/javascript">
			<xsl:text>selTryToBalance(document.eform.trytobalance, readCookie('xims_trytobalancewell'));</xsl:text>
		</script>
	</xsl:template>
	
	<xsl:template name="setdefaulteditor">
		<script type="text/javascript" language="Javascript" src="{$ximsroot}scripts/setdefaulteditor.js"/>
		<script type="text/javascript" language="Javascript">
			
			var bodyContentChanged = "<xsl:value-of select="$i18n/l/Body_content_changed"/>";

    </script>
		<form name="editor_selector" id="editor_selector" action="">
			<select name="xims_wysiwygeditor" id="xims_wysiwygeditor" onchange="javascript:return checkBodyFromSel(this.value);">
				<xsl:copy-of select="$editoroptions"/>
			</select>
		</form>
		<script type="text/javascript">
      setSel(document.getElementById('xims_wysiwygeditor'), readCookie('xims_wysiwygeditor'));
    </script>
	</xsl:template>
	
	<xsl:template name="document-options">
				<a href="javascript:previewWindow('{$xims_box}{$goxims_content}{$absolute_path}?pub_preview=1')">
					<xsl:value-of select="$i18n/l/Publishingpreview"/>
				</a>
				<img src="{$ximsroot}images/icons/opens_new_window.gif" alt="{$i18n/l/Opens_in_new_window}" title="{$i18n/l/Opens_in_new_window}"/>
				<xsl:if test="children/object[location='.diff_to_second_last']">
          &#xa0;
          <a href="javascript:diffWindow('{$xims_box}{$goxims_content}{$absolute_path}/.diff_to_second_last?bodyonly=1;pre=1')">
						<xsl:value-of select="$i18n/l/See_changes_latest_edit"/>
					</a>
					<img src="{$ximsroot}images/icons/opens_new_window.gif" alt="{$i18n/l/Opens_in_new_window}" title="{$i18n/l/Opens_in_new_window}"/>
				</xsl:if>
	</xsl:template>
	
	<xsl:template match="children/object" mode="link">
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<xsl:variable name="id" select="@id"/>
		<xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name='URL' 
               or /document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">
			<tr>
				<td width="30">
					<xsl:call-template name="cttobject.status"/>
				</td>
				<td align="center">
					<xsl:call-template name="cttobject.position"/>
				</td>
				<td>
					<a>
						<xsl:attribute name="href"><xsl:choose><xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'"><xsl:value-of select="location"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($goxims_content,symname_to_doc_id,'?sb=',$sb,';order=',$order)"/></xsl:otherwise></xsl:choose></xsl:attribute>
						<xsl:value-of select="title"/>
					</a>
				</td>

					<td align="right">
						<xsl:choose>
							<xsl:when test="marked_deleted != '1' 
                          and user_privileges/write 
                          and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
								<a href="{$goxims_content}?id={@id};edit=1" class="sprite sprite-option_edit">
								<span>
									<xsl:value-of select="$l_Edit"/>
								</span>
								&#160;
							</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="cttobject.options.spacer"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="marked_deleted != '1' 
                          and (user_privileges/publish|user_privileges/publish_all) 
                          and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
								<a href="{$goxims_content}?id={@id};publish_prompt=1" class="sprite sprite-option_pub">
								<span>
									<xsl:value-of select="$i18n/l/Publishing_options"/>
								</span>
								&#160;
							</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="cttobject.options.spacer"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="user_privileges/grant|user_privileges/grant_all">
								<a href="{$goxims_content}?id={@id};obj_acllist=1" class="sprite sprite-option_acl">
								<span>
									<xsl:value-of select="$i18n/l/Access_control"/>
								</span>
								&#160;
							</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="cttobject.options.spacer"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="user_privileges/delete and published != '1' 
                              and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
							<a class="sprite sprite-option_purge">
								<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/></xsl:attribute>
								<span><xsl:value-of select="$i18n/l/purge"/></span>
								&#160;
							</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="cttobject.del.spacer"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>

			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="children/object" mode="comment">
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<!-- <xsl:if test="/document/object_types/object_type[@id=$objecttype]/name='Annotation'"> -->
		<!--
        pepl: This hardcoded OT would not be neccessary if the Annotations would be loaded via -getchildren!!!
        (I guess its time to change the "definition" regarding Annotations and their granted privs)
    -->
		<xsl:if test="$objecttype=16">
			<tr>
				<td colspan="3">
					<img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level}" height="10"/>
					<img src="{$ximsroot}images/icons/list_HTML.gif" alt="" width="20" height="18"/>
					<a href="{$goxims_content}{$absolute_path}?id={@document_id};view=1;m={$m}">
						<xsl:value-of select="title"/>
					</a>
          by <xsl:call-template name="creatorfullname"/>
				</td>
			</tr>
			<tr>
				<td width="96%">
					<img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level+20}" height="10"/>
					<xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
				</td>
				<xsl:if test="$m='e'">
					<td width="2%">
						<xsl:choose>
							<xsl:when test="/document/context/object/user_privileges/write 
                          and locked_time = '' 
                          or locked_by = /document/session/user/@id">
								<a href="{$goxims_content}?id={@id};edit=1">
									<img src="{$skimages}option_edit.png" border="0" alt="Bearbeiten" title="Dieses Objekt bearbeiten" width="32" height="19" align="left" onmouseover="pass('edit{@document_id}','edit','h'); return true;" onmouseout="pass('edit{@document_id}','edit','c'); return true;" onmousedown="pass('edit{@document_id}','edit','s'); return true;" onmouseup="pass('edit{@document_id}','edit','c'); return true;" name="edit{@document_id}"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<img src="{$ximsroot}images/spacer_white.gif" width="32" height="19" border="0" alt="" align="left"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td width="2%">
						<xsl:choose>
							<xsl:when test="user_privileges/delete 
                          and published != '1' 
                          and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
								<form style="margin:0px;" name="delete" method="get" action="{$xims_box}{$goxims_content}">
									<input type="hidden" name="delete_prompt" value="1"/>
									<input type="hidden" name="id" value="{@id}"/>
									<input type="image" name="del{@id}" src="{$skimages}option_purge.png" border="0" width="37" height="19" alt="{$i18n/l/purge}" title="{$i18n/l/purge}"/>
								</form>
							</xsl:when>
							<xsl:otherwise>
								<img src="{$ximsroot}images/spacer_white.gif" width="37" height="19" border="0" alt="" align="left"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
	</xsl:template>
		
</xsl:stylesheet>