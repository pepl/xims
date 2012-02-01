<?xml version="1.0" encoding="utf-8"?>
<!--
		# Copyright (c) 2002-2011 The XIMS Project. # See the file "LICENSE"
		for information and conditions for use, reproduction, # and
		distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
		$Id: common.xsl 2248 2009-08-10 10:27:04Z haensel $
	-->
<!DOCTYPE stylesheet [
	<!ENTITY lc "'aäbcdefghijklmnoöpqrstuüvwxyz'">
	<!ENTITY uc "'AÄBCDEFGHIJKLMNOÖPQRSTUÜVWXYZ'">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" xmlns:aaa="http://www.w3.org/2005/07/aaa" extension-element-prefixes="dyn">
	<xsl:import href="../../../stylesheets/common.xsl"/>
	<xsl:import href="common_header.xsl"/>
	<xsl:import href="common_head.xsl"/>
	<xsl:import href="common_metadata.xsl"/>
	<xsl:import href="common_footer.xsl"/>
	<xsl:import href="common_localized.xsl"/>
	<xsl:import href="common_tinymce_scripts.xsl"/>
	<xsl:output method="xml" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
	<xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>
	
	<xsl:variable name="objtypeid" select="/document/context/object/object_type_id"/>
	<xsl:variable name="objtypename" select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/>
	<!--<xsl:param name="objtype_name">
		<xsl:value-of select="$i18n/l/ots/ot[@id=$objtypeid]"/>
	</xsl:param>-->
	
	<xsl:variable name="currobjmime" select="/document/data_formats/data_format[@id=/document/context/object/data_format_id]/mime_type"/>
	<!--
		save those strings in variables as they are called per object in
		object/children
	-->
	<!-- cttobject.options -->
	<xsl:variable name="l_Edit" select="$i18n/l/Edit"/>
	<xsl:variable name="l_Move" select="$i18n/l/Move"/>
	<xsl:variable name="l_Copy" select="$i18n/l/Copy"/>
	<xsl:variable name="l_Publishing_options" select="$i18n/l/Publishing_options"/>
	<xsl:variable name="l_Access_control" select="$i18n/l/Access_control"/>
	<xsl:variable name="l_Undelete" select="$i18n/l/Undelete"/>
	<xsl:variable name="l_purge" select="$i18n/l/purge"/>
	<xsl:variable name="l_delete" select="$i18n/l/delete"/>
	<!-- cttobject.status -->
	<xsl:variable name="l_Object_marked_new" select="$i18n/l/Object_marked_new"/>
	<xsl:variable name="l_New" select="$i18n/l/New"/>
	<xsl:variable name="l_Published" select="$i18n/l/Published"/>
	<xsl:variable name="l_Object_last_published" select="$i18n/l/Object_last_published"/>
	<xsl:variable name="l_by" select="$i18n/l/by"/>
	<xsl:variable name="l_at_place" select="$i18n/l/at_place"/>
	<xsl:variable name="l_Object_modified" select="$i18n/l/Object_modified"/>
	<xsl:variable name="l_at_time" select="$i18n/l/at_time"/>
	<xsl:variable name="l_changed" select="$i18n/l/changed"/>
	<xsl:variable name="l_Unlock" select="$i18n/l/Unlock"/>
	<xsl:variable name="l_Release_lock" select="$i18n/l/Release_lock"/>
	<xsl:variable name="l_Locked" select="$i18n/l/Locked"/>
	<xsl:variable name="l_Object_locked" select="$i18n/l/Object_locked"/>
	
	<xsl:template name="objtype_name">
		<xsl:param name="ot_id"/>
		<xsl:param name="ot_name"/>
		<xsl:choose>
			<xsl:when test="$ot_id != ''">
		<xsl:value-of select="$i18n/l/ots/ot[@id=$ot_id]"/>
		</xsl:when>
		<xsl:when test="$ot_name != ''">
		<xsl:value-of select="$i18n/l/*[name()=$ot_name]"/>
		</xsl:when>
		</xsl:choose>
		<!--<xsl:value-of select="concat($i18n, concat('/l/',$objtypename))"/>-->
		<!--<xsl:value-of select="document(concat($currentuilanguage,'/i18n.xml/l/')),$objtypename"/>-->
	</xsl:template>
	
	<xsl:template name="cancelform">
		<xsl:param name="with_save" select="'yes'"/>
		<!-- method get is needed, because goxims does not handle a PUTed 'id' -->
		<div class="cancel-save">
			<form class="cancelsave-form" action="{$xims_box}{$goxims_content}" name="cform" method="get">
				<input type="hidden" name="id" value="{@id}"/>
				<xsl:if test="$with_save = 'yes'">
					<xsl:call-template name="save_jsbutton"/>
				</xsl:if>
				<xsl:call-template name="rbacknav"/>
				<button type="submit" name="cancel" accesskey="C">
					<xsl:value-of select="$i18n/l/cancel"/>
				</button>
			</form>
			&#160;<br/>
		</div>
	</xsl:template>
	
	<xsl:template name="cancelform-copy">
		<div class="cancel-save cancelsave-form">
			<button type="submit" name="submit_eform" accesskey="S" onclick="document.eform.store.click(); return false">
			<!--<button type="submit" name="submit_eform" accesskey="S" onclick="$('#store').click();return false">-->
				<xsl:value-of select="$i18n/l/save"/>
			</button>
			<button class="save-button-js" type="submit" name="submit_eform" accesskey="C" onclick="document.cform.cancel.click(); return false">
				<xsl:value-of select="$i18n/l/cancel"/>
			</button>
		</div>
		&#160;
		<br/>
		<br/>
		&#160;
	</xsl:template>
	
	<xsl:template name="cancelcreateform">
		<xsl:param name="with_save" select="'yes'"/>
		<div class="cancel-save">
			<form class="cancelsave-form" action="{$xims_box}{$goxims_content}{$absolute_path}" method="post">
				<xsl:if test="$with_save = 'yes'">
					<xsl:call-template name="save_jsbutton"/>
				</xsl:if>
				<xsl:call-template name="rbacknav"/>
				<button type="submit" name="cancel_create" accesskey="C">
					<xsl:value-of select="$i18n/l/cancel"/>
				</button>
			</form>
			&#160;<br/>
		</div>
	</xsl:template>
	
	<!--	legacy-->
	<xsl:template name="cancelaction">
		<xsl:call-template name="cancelcreateform">
			<xsl:with-param name="with_save">yes</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="canceledit">
		<xsl:call-template name="cancelform">
			<xsl:with-param name="with_save">yes</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="head-create">
		<xsl:call-template name="head_default">
			<xsl:with-param name="mode">create</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="head-edit">
		<xsl:call-template name="head_default">
			<xsl:with-param name="mode">edit</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!--	end legacy-->
	
	<xsl:template name="save_jsbutton">
		<button class="save-button-js" type="submit" name="submit_eform" accesskey="S" onclick="$('#store').click(); return false">
			<xsl:value-of select="$i18n/l/save"/>
		</button>
	</xsl:template>
	
	<xsl:template name="exitredirectform">
		<xsl:variable name="object_type_id" select="object_type_id"/>
		<xsl:variable name="parent_id" select="@parent_id"/>
		<form name="userConfirm" action="{$xims_box}{$goxims_content}" method="get">
			<button name="exit" type="submit">
				<xsl:value-of select="$i18n/l/Done"/>
			</button>
			<xsl:choose>
				<xsl:when test="$r != ''">
					<input name="id" type="hidden" value="{$r}"/>
					<input name="page" type="hidden" value="{$page}"/>
					<input name="sb" type="hidden" value="{$sb}"/>
					<input name="order" type="hidden" value="{$order}"/>
				</xsl:when>
				<xsl:otherwise>
					<input name="id" type="hidden">
						<xsl:choose>
							<xsl:when test="/document/object_types/object_type[@id=$object_type_id]/redir_to_self='0'">
								<xsl:attribute name="value"><xsl:value-of select="parents/object[@document_id=$parent_id]/@id"/></xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</input>
				</xsl:otherwise>
			</xsl:choose>
		</form>
	</xsl:template>
	<xsl:template name="saveaction">
		<input type="hidden" name="id" value="{/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}"/>
		<xsl:if test="/document/object_types/object_type[name=$objtype]/redir_to_self='0'">
			<input name="sb" type="hidden" value="date"/>
			<input name="order" type="hidden" value="desc"/>
		</xsl:if>
		<input type="submit" name="store" value="{$i18n/l/save}" class="control save-button" accesskey="S" id="store"/>
	</xsl:template>
	
	<xsl:template name="saveedit">
		<input type="hidden" name="id" value="{@id}"/>
		<xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
			<input name="sb" type="hidden" value="date"/>
			<input name="order" type="hidden" value="desc"/>
		</xsl:if>
		<input type="submit" name="store" value="{$i18n/l/save}" class="save-button hidden" accesskey="S" id="store"/>
	</xsl:template>
	
	<xsl:template name="form-grant">
		<div id="tr-grantowneronly" class="form-div block">
			<h2>
				<xsl:value-of select="$i18n/l/Priv_grant_options"/>
			</h2>
			<input name="owneronly" type="radio" value="false" checked="checked" id="radio-cp-par-privs" class="radio-button"/>
			<label for="radio-cp-par-privs">
				<xsl:value-of select="$i18n/l/Copy_parent_privs"/>
			</label>
			<br/>
			<input name="owneronly" type="radio" value="true" onclick="document.eform.defaultroles.disabled = true;" onblur="document.eform.defaultroles.disabled = false;" id="radio-grantmyself" class="radio-button"/>
			<label for="radio-grantmyself">
				<xsl:value-of select="$i18n/l/Grant_myself_only"/>
			</label>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('PrivilegeGrantOptions')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Priv_grant_options"/></xsl:attribute>
					(?)</a>
			<br/>
			<xsl:text>&#160;</xsl:text>
			<label for="checkb-defaultroles">
				<xsl:value-of select="$i18n/l/Grant_default_roles"/>
			</label>
			<input name="defaultroles" type="checkbox" value="true" id="checkb-defaultroles" class="checkbox"/>
		</div>
	</xsl:template>
	<xsl:template name="markednew">
		<div>
			<div class="label">
				<label for="input-marknew">
					<xsl:value-of select="$i18n/l/Mark_new"/>
				</label>
			</div>
			<input name="markednew" type="checkbox" id="input-marknew" class="checkbox">
				<xsl:if test="marked_new = '1'">
					<xsl:attribute name="checked">checked</xsl:attribute>
				</xsl:if>
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('markednew')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Mark_new"/></xsl:attribute>
					(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="publish-on-save">
		<div class="block">
			<xsl:if test="$usertype = 'expert' or $usertype = 'webadmin'">
				<div class="label">
					<label for="input-pubonsave">
						<xsl:value-of select="$i18n/l/Pub_on_save"/>
					</label>
				</div>
				<input name="pubonsave" type="checkbox" id="input-pubonsave" class="checkbox">
					<xsl:if test="$pubonsave = '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('pubonsave')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Pub_on_save"/></xsl:attribute>
					(?)</a>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="form-marknew-pubonsave">
		<div class="form-div ui-corner-all div-right">
			<xsl:call-template name="markednew"/>
			<xsl:call-template name="publish-on-save"/>
		</div>
	</xsl:template>
	<xsl:template name="expandrefs">
		<!-- Temporarily disabled until implemented by the application class
    <tr>
        <td colspan="3">
        <xsl:value-of select="$i18n/l/Publish_ref_objects"/>:
        <input name="expandrefs" type="radio" value="true">
          <xsl:if test="attributes/expandrefs = '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/Yes"/>
        <input name="expandrefs" type="radio" value="false">
          <xsl:if test="attributes/expandrefs != '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/No"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('expandrefs')" class="doclink">(?)</a>
        </td>
    </tr>
-->
	</xsl:template>
	
	<xsl:template name="heading">
		<xsl:param name="mode"/>
		<xsl:param name="selEditor" select="false()"/>
		<div id="tab-container" class="ui-corner-top">
			<h1>
				<xsl:choose>
					<xsl:when test="$mode='create'">
						<xsl:value-of select="$i18n/l/create"/>&#160;<!--<xsl:value-of select="$objtype"/>&#160;-->
						<xsl:call-template name="objtype_name">
							<xsl:with-param name="ot_name">
								<xsl:value-of select="$objtype"/>
							</xsl:with-param>
						</xsl:call-template>&#160;
						<xsl:if test="$selEditor">
							<xsl:value-of select="$i18n/l/using"/>
							<xsl:text>&#160;</xsl:text>
							<label for="xims_wysiwygeditor">
								<xsl:value-of select="$i18n/l/Editor"/>
							</label>
							<xsl:text>&#160;</xsl:text>
							<xsl:call-template name="setdefaulteditor"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$mode='edit'">
						<xsl:value-of select="$i18n/l/edit"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
						<xsl:call-template name="objtype_name">
							<xsl:with-param name="ot_name">
								<xsl:value-of select="$objtype"/>
							</xsl:with-param>
						</xsl:call-template>
						&#160;'<xsl:value-of select="title"/>'&#160;
						<xsl:if test="$selEditor">
							<xsl:value-of select="$i18n/l/using"/>
							<xsl:text>&#160;</xsl:text>
							<label for="xims_wysiwygeditor">
								<xsl:value-of select="$i18n/l/Editor"/>
							</label>
							<xsl:text>&#160;</xsl:text>
							<xsl:call-template name="setdefaulteditor"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$mode='move'">
						<xsl:value-of select="$i18n/l/Move_object"/> '<xsl:value-of select="title"/>' 
					</xsl:when>
					<xsl:when test="$mode='movemultiple'">
						<xsl:value-of select="$i18n/l/Move_objects"/> 
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="title"/>
					</xsl:otherwise>
				</xsl:choose>
			</h1>
		</div>
	</xsl:template>
	
	<xsl:template name="form-keywordabstract">
		<div class="form-div ui-corner-all block">
			<h2>Meta Data</h2>
			<xsl:call-template name="form-keywords"/>
			<xsl:call-template name="form-abstract"/>
		</div>
	</xsl:template>
	<xsl:template name="form-abstractnotes">
		<div class="form-div ui-corner-all block">
			<h2>Meta Data</h2>			
			<xsl:call-template name="form-abstract"/>
			<xsl:call-template name="form-notes"/>
		</div>
	</xsl:template>
	<xsl:template name="form-locationtitle-create">
		<div class="form-div ui-corner-all div-left">
			<xsl:call-template name="form-title"/>
			<xsl:call-template name="form-location-create"/>
		</div>
	</xsl:template>
	<xsl:template name="form-locationtitle-edit">
		<div class="form-div ui-corner-all div-left">
			<xsl:call-template name="form-title"/>
			<xsl:call-template name="form-location-edit"/>
		</div>
	</xsl:template>
	<xsl:template name="form-location-edit">
		<xsl:param name="testlocation" select="true()"/>
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<xsl:variable name="publish_gopublic">
			<xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
		</xsl:variable>
		<div>
			<div class="label-std">
				<label for="input-location">
					<xsl:value-of select="$i18n/l/Location"/>
				</label>
			</div>
			<input type="text" name="name" size="60" value="{location}" id="input-location">
				<xsl:choose>
					<!--make location-field readonly if object published or object is a newsletter-->
					<xsl:when test="($publish_gopublic = '0' and published = '1') or ($objecttype = '15')">
						<xsl:attribute name="readonly">readonly</xsl:attribute>
						<xsl:attribute name="class">readonlytext</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Location')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Location"/></xsl:attribute>(?)</a>
			<a href="#" id="dialog_link" class="ui-state-default ui-corner-all" style="display: none;">
				<span class="ui-icon ui-icon-newwin"/>
				<xsl:value-of select="IlpDefaultWinlabel"/>
				<span class="ui-icon ui-icon-alert"/>
			</a>
			<!-- ui-dialog -->
			<div id="dialog">
				<xsl:attribute name="title"><xsl:value-of select="IlpDefaultWinlabel"/></xsl:attribute>
			</div>
			<div id="location-dialog">
				<xsl:attribute name="title"><xsl:value-of select="IlpDefaultWinlabel"/></xsl:attribute>
			</div>
			<!-- we only test locations for unpublished docs -->
			<xsl:if test="published = '0'">
				<!-- location-testing AJAX code -->
				<xsl:if test="$testlocation">
					<xsl:call-template name="testlocationjs"/>
				</xsl:if>
			</xsl:if>
			<!--<xsl:call-template name="marked_mandatory"/>-->
		</div>
	</xsl:template>
	<xsl:template name="form-location-create">
		<!--<xsl:param name="testlocation" select="true()"/>-->
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<div>
			<div class="label-std">
				<label for="input-location">
					<xsl:value-of select="$i18n/l/Location"/>
				</label>
			</div>
			<input type="text" name="name" size="60" class="text" id="input-location">
				<xsl:if test="$testlocation">
					<xsl:attribute name="onchange">return testlocation();</xsl:attribute>
				</xsl:if>
				<!--make location-field readonly if object is a newsitem-->
				<xsl:if test="$objecttype = '15'">
					<xsl:attribute name="readonly">readonly</xsl:attribute>
					<xsl:attribute name="class">readonlytext</xsl:attribute>
				</xsl:if>
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Location')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Location"/></xsl:attribute>(?)</a>
			<a href="#" id="dialog_link" class="ui-state-default ui-corner-all" style="display: none;">
				<span class="ui-icon ui-icon-newwin"/>
				<xsl:value-of select="IlpDefaultWinlabel"/>
				<span class="ui-icon ui-icon-alert"/>
			</a>
			<!-- ui-dialog -->
			<div id="dialog">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/IlpDefaultWinlabel"/></xsl:attribute>
			</div>
			<div id="location-dialog">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/IlpDefaultWinlabel"/></xsl:attribute>
			</div>
			<!-- location-testing AJAX code -->
			<xsl:if test="$testlocation">
				<xsl:call-template name="testlocationjs" />
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="form-title">
		<xsl:param name="testlocation" select="true()"/>
		<div id="tr-title">
			<div class="label-std">
				<label for="input-title">
					<xsl:value-of select="$i18n/l/Title"/>&#160;*
				</label>
			</div>
			<input type="text" name="title" size="60" class="text" id="input-title" value="{title}">
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Title')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Title"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="form-locationtitle-edit_xml">
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<div class="form-div ui-corner-all div-left">
			<xsl:call-template name="form-title"/>
			<div>
				<div class="label-std">
					<label for="input-location">
						<xsl:value-of select="$i18n/l/Location"/>
					</label>
				</div>
				<!-- strip suffix; leave it, if it's a sdbk with lang-extension -->
				<input type="text" name="name" size="60" id="input-location">
					<xsl:choose>
						<xsl:when test="published = '1'">
							<xsl:attribute name="readonly">readonly</xsl:attribute>
							<xsl:attribute name="class">readonlytext</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">text</xsl:attribute>
							<xsl:attribute name="onfocus">this.className='text focused'</xsl:attribute>
							<xsl:attribute name="onblur">this.className='text'; return testlocation();</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="substring-after(location, '.sdbk') = '.de' or
                                        substring-after(location, '.sdbk') = '.en' or
                                        substring-after(location, '.sdbk') = '.es' or
                                        substring-after(location, '.sdbk') = '.fr' or
                                        substring-after(location, '.sdbk') = '.it' or
                                        substring-after(location, '.sdbk') = '.sdbk'">
							<xsl:attribute name="value"><xsl:value-of select="location"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="value"><xsl:value-of select="substring-before(location, concat('.', /document/data_formats/data_format
                       [@id=/document/context/object/data_format_id]/suffix))"/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</input>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Location')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Location"/></xsl:attribute>(?)</a>
				<a href="#" id="dialog_link" class="ui-state-default ui-corner-all" style="display: none;">
					<span class="ui-icon ui-icon-newwin"/>
					<xsl:value-of select="IlpDefaultWinlabel"/>
					<span class="ui-icon ui-icon-alert"/>
				</a>
				<!-- ui-dialog -->
				<div id="dialog">
					<xsl:attribute name="title"><xsl:value-of select="IlpDefaultWinlabel"/></xsl:attribute>
				</div>
				<div id="location-dialog">
					<xsl:attribute name="title"><xsl:value-of select="IlpDefaultWinlabel"/></xsl:attribute>
				</div>
				<xsl:if test="not(published = 1)">
					<!-- location-testing AJAX code -->
					<xsl:call-template name="testlocationjs"/>
				</xsl:if>
			</div>
		</div>
	</xsl:template>
	<xsl:template name="form-bodyfromfile-create">
		<div id="tr-bodyfromfile">
			<div id="label-bodyfromfile">
				<label for="input-bodyfromfile">
					<xsl:value-of select="$i18n/l/bodyfromfile_create"/>
				</label>
			</div>
			<input type="file" name="file" size="50" class="text" id="input-bodyfromfile"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('BodyFile')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/bodyfromfile_create"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="form-bodyfromfile-edit">
		<div id="tr-bodyfromfile">
			<div class="label-large">
				<label for="input-bodyfromfile">
					<xsl:value-of select="$i18n/l/bodyfromfile_edit"/>
				</label>
			</div>
			<input type="file" name="file" size="50" class="text" id="input-bodyfromfile"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('BodyFile')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/bodyfromfile_edit"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="jsorigbody">
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
         var origbody = document.getElementById('body').value; 
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="form-body-create">
		<xsl:param name="with_origbody" select="'no'"/>
		<xsl:param name="mode" select="html"/>
		<xsl:param name="ppmethod">
			<xsl:choose>
				<xsl:when test="$mode = 'xml'">
					<xsl:value-of select="prettyprintxml"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="htmltidy"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<div class="block form-div">
			<h2>
				<label for="body">
					<xsl:value-of select="$i18n/l/Body"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Body')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/></xsl:attribute>(?)</a>
			</h2>
			<xsl:call-template name="ui-resizable"/>
			<!--<div id="bodymain">
				<div id="bodycon">-->
					<textarea name="body" id="body" rows="20" cols="90" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;" >
						<xsl:if test="$mode = 'html'">
							<xsl:text>&lt;p&gt;&#160;&lt;/p&gt;</xsl:text>
						</xsl:if>
					</textarea>
				<!--</div>
			</div>-->
			<xsl:call-template name="form-bodyfromfile-create"/>
			<xsl:call-template name="form-minify"/>
			<xsl:call-template name="testbodysxml"/>
			<xsl:call-template name="prettyprint">
				<xsl:with-param name="ppmethod" select="$ppmethod"/>
			</xsl:call-template>
			<xsl:call-template name="trytobalance"/>
		</div>
	</xsl:template>
	<xsl:template name="testbodysxml">
		<xsl:call-template name="wfcheckjs"/>
		<a href="javascript:void()" onclick="return wfcheck();">
			<img src="{$skimages}option_wfcheck.png" alt="{$i18n/l/Test_body_xml}" title="{$i18n/l/Test_body_xml}" width="32" height="19"/>
		</a>
	</xsl:template>
	<xsl:template name="prettyprint">
		<xsl:param name="ppmethod" select="'htmltidy'"/>
		<xsl:call-template name="prettyprintjs">
			<xsl:with-param name="ppmethod" select="$ppmethod"/>
		</xsl:call-template>
		<a href="javascript:prettyprint('#body')">
			<img src="{$skimages}option_prettyprint.png" alt="{$i18n/l/Prettyprint}" title="{$i18n/l/Prettyprint}" width="32" height="19"/>
		</a>
	</xsl:template>
	
	<xsl:template name="form-body-edit">
		<xsl:param name="with_origbody" select="'no'"/>
		<xsl:param name="mode" select="html"/>
		<xsl:param name="ppmethod">
			<xsl:choose>
				<xsl:when test="$mode = 'xml'">
					<xsl:value-of select="prettyprintxml"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="htmltidy"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<div class="block form-div">
			<h2>
				<label for="body">Body</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Body')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/></xsl:attribute>(?)</a>
			</h2>
			<xsl:call-template name="ui-resizable"/>
			<!--<div id="bodymain">-->
				<!--<div id="bodycon" class="resizable">-->
					<!--<textarea name="body" id="body" rows="20" cols="90" class="resizable ui-widget-content">-->
					<textarea name="body" id="body" rows="20" cols="90">
						<xsl:choose>
							<xsl:when test="string-length(body) &gt; 0">
								<xsl:apply-templates select="body"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>&#160;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</textarea>
				<!--</div>-->
			<!--</div>-->
			<xsl:call-template name="form-bodyfromfile-create"/>
			<xsl:call-template name="form-minify"/>
			<xsl:call-template name="testbodysxml"/>
			<xsl:call-template name="prettyprint">
				<xsl:with-param name="ppmethod" select="$ppmethod"/>
			</xsl:call-template>
			<xsl:call-template name="trytobalance"/>
		</div>
	</xsl:template>
	
	<xsl:template name="trytobalance"/>
	
	<xsl:template name="ui-resizable">
		<script type="text/javascript">
				$(function() {
					$(".resizable").resizable();
					$(".CodeMirror-wrapping").resizable();
				});
		</script>
	</xsl:template>
	
	<xsl:template name="form-keywords">
		<div id="tr-keywords">
			<div class="label-std">
				<label for="input-keywords">
					<xsl:value-of select="$i18n/l/Keywords"/>
				</label>
				<!--<br/>-->
			</div>
			<input type="text" name="keywords" size="60" class="text" value="{keywords}" id="input-keywords"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Keywords')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Keywords"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="form-abstract">
		<div id="tr-abstract">
			<div class="label-std">
				<label for="input-abstract">
					<xsl:value-of select="$i18n/l/Abstract"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Abstract')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Abstract"/></xsl:attribute>(?)</a>
			</div>
			<br/>
			<textarea id="input-abstract" name="abstract" rows="3" cols="74">
				<xsl:apply-templates select="abstract"/>
			</textarea>
		</div>
	</xsl:template>
	<xsl:template name="form-notes">
		<div id="tr-notes">
			<div id="label-notes">
				<label for="input-notes">
					<xsl:value-of select="$i18n/l/Notes"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Notes')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Notes"/></xsl:attribute>(?)</a>
			</div>
			<br/>
			<textarea name="notes" rows="3" cols="74" id="input-notes">
				<xsl:apply-templates select="notes"/>
			</textarea>
		</div>
	</xsl:template>

	<xsl:template name="form-stylesheet">
		<xsl:variable name="curr_id">
			<xsl:choose>
				<xsl:when test="@id != ''">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>-->
		<div id="tr-stylesheet">
			<div class="label-std">
				<label for="input-stylesheet">
					<xsl:value-of select="$i18n/l/Stylesheet"/>
				</label>
			</div>
			<input type="text" name="stylesheet" size="60" value="{style_id}" class="text" id="input-stylesheet"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Stylesheet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Stylesheet"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet','default-dialog','{$i18n/l/Browse_stylesheet}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_stylesheet"/>
			</a>
		</div>
	</xsl:template>
	
	<xsl:template name="form-css">
		<xsl:variable name="curr_id">
			<xsl:choose>
				<xsl:when test="@id != ''">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="tr-css">
			<div class="label-std">
				<label for="input-css">
					<xsl:value-of select="$i18n/l/CSS"/>
				</label>
			</div>
			<input type="text" name="css" size="60" value="{css_id}" class="text" id="input-css"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('CSS')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/CSS"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=CSS,Folder;sbfield=eform.css','default-dialog','{$i18n/l/Browse_stylesheet}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_css"/>
			</a>
		</div>
	</xsl:template>

	<xsl:template name="form-script">
		<xsl:variable name="curr_id">
			<xsl:choose>
				<xsl:when test="@id != ''">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="tr-javascript">
			<div class="label-std">
				<label for="input-javascript">
					<xsl:value-of select="$i18n/l/JavaScript"/>
				</label>
			</div>
			<input type="text" name="script" size="60" value="{script_id}" class="text" id="input-javascript"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('JavaScript')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/JavaScript"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=JavaScript,Folder;sbfield=eform.script','default-dialog','{$i18n/l/Browse_stylesheet}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_script"/>
			</a>
		</div>
	</xsl:template>
	
	<xsl:template name="form-feed">
		<xsl:variable name="curr_id">
			<xsl:choose>
				<xsl:when test="@id != ''">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="tr-rssfeed">
			<div class="label-std">
				<label for="input-rssfeed">
					<xsl:value-of select="$i18n/l/RSSFeed"/>
				</label>
			</div>
			<input type="text" name="feed" size="60" value="{feed_id}" class="text" id="input-rssfeed"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Portlet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/RSSFeed"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet,Folder;sbfield=eform.feed','default-dialog','{$i18n/l/Browse_stylesheet}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_feed"/>
			</a>
		</div>
	</xsl:template>
	
	<xsl:template name="form-image">
		<xsl:variable name="curr_id">
			<xsl:choose>
				<xsl:when test="@id != ''">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="tr-image">
			<div class="label-std">
				<label for="input-image">
					<xsl:value-of select="$i18n/l/Image"/>
				</label>
			</div>
			<input type="text" name="image" size="60" value="{image_id}" class="text" id="input-image"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Image')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Image"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={$curr_id};contentbrowse=1;to={$curr_id};otfilter=Image;sbfield=eform.image','default-dialog','{$i18n/l/Browse_image}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_image"/>
			</a>
		</div>
	</xsl:template>

<!--
	<xsl:template name="ui-datepicker">
		<xsl:param name="formfield_id"/>
		<xsl:param name="input_id"/>
		<xsl:param name="xml_node"/>
		<xsl:param name="buttontext"/>
		<xsl:param name="mode"/>
		<xsl:param name="range">true</xsl:param>
		<xsl:param name="date_lang">
			<xsl:choose>
				<xsl:when test="$currentuilanguage = 'de-at'">de</xsl:when>
				<xsl:otherwise>en</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
			$(function() {
				var id = '<xsl:value-of select="$input_id"/>';
				$.datepicker.setDefaults($.datepicker.regional['<xsl:value-of select="$date_lang"/>']);
				$("#"+id).datepicker({
					showOn: 'button',
					buttonImage: '<xsl:value-of select="$skimages"/>calendar.gif',
					buttonImageOnly: true,
					buttonText:'<xsl:value-of select="$buttontext"/>',					
					onSelect: function(date){
						date = $(this).datepicker('getDate');				
						<xsl:choose>
					<xsl:when test="$mode = 'datetime'">$("#<xsl:value-of select="$formfield_id"/>").val(date.print("%Y-%m-%d %H:%M"));</xsl:when>
					<xsl:when test="$mode = 'date'">$("#<xsl:value-of select="$formfield_id"/>").val(date.print("%Y-%m-%d"));</xsl:when>
					<xsl:otherwise>$("#<xsl:value-of select="$formfield_id"/>").val(date.print("%Y-%m-%d %H:%M"));</xsl:otherwise>
				</xsl:choose>						
						$(this).datepicker("hide");
						},
					<xsl:if test="$range = 'true'">beforeShow: customRange</xsl:if>
				});
				/* surprisingly date is set to "today" although is should be null */
			
				<xsl:choose>
					<xsl:when test="$xml_node = '' or not($xml_node)">
						$("#"+id).datepicker('setDate', null);
						$("#"+id).val('<xsl:value-of select="$i18n/l/Valid_from_default"/>');
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
						<xsl:when test="not(name(node()[1]))">
						$("#"+id).datepicker('setDate', new Date(<xsl:value-of select="$xml_node/year"/>, <xsl:value-of select="$xml_node/month"/>-1, <xsl:value-of select="$xml_node/day"/>));
						//$("#"+id).val('<xsl:value-of select="$i18n/l/Valid_from_default"/>');
						</xsl:when>
						<xsl:otherwise>
							alert("xmlnode: "+'<xsl:value-of select="$xml_node"/>');
							$("#"+id).datepicker('setDate', '<xsl:value-of select="$xml_node"/>');
						</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				});
			</xsl:with-param>
		</xsl:call-template>
		<input type="hidden" name="{$formfield_id}" id="{$formfield_id}">
		</input>
	</xsl:template>
	-->
<!--
	<xsl:template name="ui-datepicker">
		<xsl:param name="formfield_id"/>
		<xsl:param name="input_id"/>
		<xsl:param name="xml_node"/>
		<xsl:param name="buttontext"/>
		<xsl:param name="mode"/>
		<xsl:param name="range">true</xsl:param>
		<xsl:param name="date_lang">
			<xsl:choose>
				<xsl:when test="$currentuilanguage = 'de-at'">de</xsl:when>
				<xsl:otherwise>en</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
				var id = '<xsl:value-of select="$input_id"/>';
				var date_lang = '<xsl:value-of select="$date_lang"/>';
				var button_image = '<xsl:value-of select="$skimages"/>calendar.gif';
				var button_text = '<xsl:value-of select="$buttontext"/>';
				var formfield_id = '<xsl:value-of select="$formfield_id"/>';
				var value, year, month, day;
				<xsl:choose>
					<xsl:when test="not(name(node()[1]))">
						year = <xsl:value-of select="$xml_node/year"/>;
						month = <xsl:value-of select="$xml_node/month"/>;
						day = <xsl:value-of select="$xml_node/day"/>;
					</xsl:when>
					<xsl:otherwise>
						value = '<xsl:value-of select="$xml_node"/>';
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<input type="hidden" name="{$formfield_id}" id="{$formfield_id}"></input>
	</xsl:template>
	-->
	<!--
	<xsl:template name="form-valid_from">
		<div id="tr-validfrom">
			<div class="label-std">
				<label for="input-validfrom">
					<xsl:value-of select="$i18n/l/Valid_from"/>
				</label>
			</div>
			<input type="text" id="input-validfrom" readonly="readonly" class="input">
				<xsl:choose>
					<xsl:when test="valid_from_timestamp != ''">
						<xsl:attribute name="value"><xsl:apply-templates select="valid_from_timestamp" mode="date"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<xsl:call-template name="ui-datepicker">
				<xsl:with-param name="input_id" select="'input-validfrom'"/>
				<xsl:with-param name="formfield_id" select="'valid_from_timestamp'"/>
				<xsl:with-param name="xml_node" select="valid_from_timestamp"/>
				<xsl:with-param name="buttontext">
					<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/Valid_from"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_from')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_from"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	-->
	<xsl:template name="ui-datepicker">
		<xsl:param name="date_lang">
			<xsl:choose>
				<xsl:when test="$currentuilanguage = 'de-at'">de</xsl:when>
				<xsl:otherwise>en</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
				var date_lang = '<xsl:value-of select="$date_lang"/>';
				var button_image = '<xsl:value-of select="$skimages"/>calendar.gif';
				$(document).ready(function(){
					initDatepicker();
				});
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	<xsl:template name="ui-datetimepicker">
		<xsl:param name="date_lang">
			<xsl:choose>
				<xsl:when test="$currentuilanguage = 'de-at'">de</xsl:when>
				<xsl:otherwise>en</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
				var date_lang = '<xsl:value-of select="$date_lang"/>';
				var button_image = '<xsl:value-of select="$skimages"/>calendar.gif';
				$(document).ready(function(){
					initDateTimepicker();
				});
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	<xsl:template name="form-valid_from">
		<div id="tr-validfrom">
			<div class="label-std">
				<label for="input-validfrom">
					<xsl:value-of select="$i18n/l/Valid_from"/>
				</label>
			</div>
			<input type="text" id="input-validfrom" name="valid_from_timestamp" readonly="readonly" class="input" size="12">
				<xsl:choose>
					<xsl:when test="valid_from_timestamp != ''">
						<xsl:attribute name="value"><xsl:apply-templates select="valid_from_timestamp" mode="datetime-ISO-8601"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<xsl:call-template name="ui-datetimepicker">
			</xsl:call-template>
			<script type="text/javascript">
				$(document).ready(function(){					
					$('#input-validfrom').datetimepicker({buttonText: '<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/Valid_from"/>'});
				});
				
			</script>
			
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_from')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_from"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>

	<xsl:template name="form-valid_to">
		<div>
			<div class="label-std">
				<label for="input-validto">
					<xsl:value-of select="$i18n/l/Valid_to"/>
				</label>
			</div>
			<input type="text" id="input-validto" readonly="readonly" class="input" name="valid_to_timestamp" size="12">
				<xsl:choose>
					<xsl:when test="valid_to_timestamp != ''">
						<xsl:attribute name="value"><xsl:apply-templates select="valid_to_timestamp" mode="datetime-ISO-8601"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<script type="text/javascript">
				$(document).ready(function(){
					$('#input-validto').datetimepicker({buttonText: '<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/Valid_to"/>'});
				});
				
			</script>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_to')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_to"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<!--	
	<xsl:template name="form-valid_to">
		<div>
			<div class="label-std">
				<label for="input-validto">
					<xsl:value-of select="$i18n/l/Valid_to"/>
				</label>
			</div>
			<input type="text" id="input-validto" readonly="readonly" class="input">
				<xsl:choose>
					<xsl:when test="valid_from_timestamp != ''">
						<xsl:attribute name="value"><xsl:apply-templates select="valid_to_timestamp" mode="date"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<xsl:call-template name="ui-datepicker">
				<xsl:with-param name="input_id" select="'input-validto'"/>
				<xsl:with-param name="formfield_id" select="'valid_to_timestamp'"/>
				<xsl:with-param name="xml_node" select="valid_to_timestamp"/>
				<xsl:with-param name="buttontext">
					<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n/l/Valid_to"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_to')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_to"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>-->
	<xsl:template name="form-pagerowlimit-edit">
		<div id="tr-pagerowlimit">
			<div class="label-large">
				<label for="input-pagerowlimit">
					<xsl:value-of select="$i18n/l/PageRowLimit"/>
				</label>
			</div>
			<input type="text" name="pagerowlimit" size="2" maxlength="2" value="{attributes/pagerowlimit}" class="text input" id="input-pagerowlimit"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('PageRowLimit')" class="doclink">(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="options-menu-bar">
		<xsl:param name="createwidget" select="$createwidget"/>
		<xsl:param name="parent_id" select="$parent_id"/>
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
		<xsl:variable name="dfname" select="$df/name"/>
		<xsl:variable name="dfmime" select="$df/mime_type"/>
		<xsl:variable name="showtrashcan" select="$showtrashcan"/>
		<div id="options-menu-bar" class="ui-corner-top">
			<div id="objtype-title">
				<xsl:call-template name="cttobject.dataformat">
					<xsl:with-param name="dfname" select="$dfname"/>
				</xsl:call-template>
				<h1>
					<xsl:value-of select="title"/>
					<xsl:if test="$showtrashcan">
						&#160;-&#160;<xsl:value-of select="$i18n/l/Trashcan"/>
					</xsl:if>
				</h1>
			</div>
			<div id="options">
				<xsl:if test="not ($showtrashcan) and not (marked_deleted = 1)">
					<xsl:call-template name="state-toolbar"/>
					<xsl:call-template name="options-toolbar">
						<xsl:with-param name="email-disabled" select="false()"/>
					</xsl:call-template>
				</xsl:if>
			</div>
			<xsl:if test="/document/context/object/user_privileges/create and $createwidget != 'false'">
				<xsl:call-template name="create-widget">
					<xsl:with-param name="mode" select="$createwidget"/>
					<xsl:with-param name="parent_id" select="$parent_id"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="$currobjmime='application/x-container' and not(object_type_id = 39 or object_type_id = 37 or object_type_id = 24)">
				<div id="trash">
					<xsl:choose>
						<xsl:when test="$showtrashcan">
							<a href="{$xims_box}{$goxims_content}{$absolute_path}" class="button"><xsl:value-of select="$i18n/l/Container_View"/></a>
						</xsl:when>
						<xsl:otherwise>
				<a class="button option-trashcan">
					<xsl:attribute name="href">
						<xsl:value-of select="concat($goxims_content,'?id=',@id,';showtrashcan=1;r=',/document/context/object/@id)"/>
						<xsl:value-of select="concat(';page=',$page)"/>
						<xsl:if test="$defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if>
					</xsl:attribute>
					<span>
						<xsl:value-of select="$i18n/l/Trashcan"/>
					</span>
				</a>
				</xsl:otherwise>
				</xsl:choose>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="cttobject.status">
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<xsl:variable name="publish_gopublic">
			<xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
		</xsl:variable>
		<xsl:variable name="published_path_base">
			<xsl:choose>
				<xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
					<xsl:value-of select="$absolute_path_nosite"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$absolute_path"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="object_path">
			<xsl:choose>
				<xsl:when test="local-name(..) = 'children'">
					<xsl:value-of select="concat($published_path_base,'/',location)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$published_path_base"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="published_path">
			<xsl:choose>
				<xsl:when test="$publish_gopublic = 0">
					<xsl:value-of select="concat($publishingroot,$object_path)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($gopublic_content,$object_path)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="marked_new= '1'">
				<span class="xims-sprite sprite-new">
					<span>
						<xsl:value-of select="$l_Object_marked_new"/>
					</span>
				&#160;
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.status.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="published = '1'">
				<a href="{$published_path}" target="_blank">
					<xsl:choose>
						<xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
							<xsl:attribute name="class">xims-sprite sprite-status_pub</xsl:attribute>
							&#xa0;
							<span>
								<xsl:value-of select="$l_Object_last_published"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$l_at_place"/>&#160;<xsl:value-of select="$published_path"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">xims-sprite sprite-status_pub_async</xsl:attribute>
								&#xa0;
								<span>
								<xsl:value-of select="$l_Object_modified"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$l_at_time"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$l_changed"/>.
								</span>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.status.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="locked_by_id != '' and locked_time != '' and locked_by_id = /document/context/session/user/@id">
				<a class="xims-sprite sprite-locked">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',@id,';cancel=1;r=',/document/context/object/@id)"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';page=',$page)"/></xsl:if><xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:attribute>
					<span>
						<xsl:value-of select="$l_Release_lock"/>
					</span>
										&#160;
				</a>
			</xsl:when>
			<xsl:when test="locked_by_id != '' and locked_time != ''">
				<a class="xims-sprite sprite-locked">
					<xsl:attribute name="title"><xsl:value-of select="$l_Object_locked"/>&#160;<xsl:apply-templates select="locked_time" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;
					<xsl:call-template name="lockerfullname"/>.
				</xsl:attribute>
					<span>
						<xsl:value-of select="$l_Object_locked"/>&#160;<xsl:apply-templates select="locked_time" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;<xsl:call-template name="lockerfullname"/>.
				</span>
				&#160;
			</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.status.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
		<!--</div>-->
	</xsl:template>
	<xsl:template name="options-toolbar">
		<xsl:param name="copy-disabled" select="false()"/>
		<xsl:param name="move-disabled" select="false()"/>
		<xsl:param name="email-disabled" select="true()"/>
		<!-- some objecttypes like simpledb_item have no trashcan option -->
		<xsl:param name="forcepurge" select="false()"/>
		<!--<xsl:param name="showtrashcan" select="false()"/>-->
		
		<div class="toolbar">
			<xsl:choose>
				<xsl:when test="$showtrashcan or (marked_deleted = 1)">
					<xsl:call-template name="button.options.undelete"/>
					<xsl:call-template name="button.options.purge"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="button.options.edit"/>
					<xsl:if test="not($copy-disabled)">
						<xsl:call-template name="button.options.copy"/>
					</xsl:if>
					<xsl:if test="not($move-disabled)">
						<xsl:call-template name="button.options.move"/>
					</xsl:if>
					<xsl:call-template name="button.options.publish"/>
					<xsl:call-template name="button.options.acl"/>
					<xsl:choose>
						<xsl:when test="$forcepurge">
							<xsl:call-template name="button.options.purge"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="button.options.delete"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not($email-disabled)">
						<xsl:call-template name="button.options.send_email"/>
					</xsl:if>
				</xsl:otherwise>
				</xsl:choose>

			
		</div>
	</xsl:template>
	
	<xsl:template name="button.options.edit">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and user_privileges/write and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="button option-edit">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';edit=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Edit"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="button.options.copy">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and user_privileges/copy and /document/context/object/user_privileges/create">
				<a class="button option-copy">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';copy=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Copy"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="button.options.move">
		<xsl:variable name="parentid" select="@parent_id"/>
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="to">
			<xsl:choose>
				<xsl:when test="$currobjmime='application/x-container'">
					<xsl:value-of select="/document/context/object/@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/document/context/object/parents/object[@document_id=$parentid]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and user_privileges/move and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="button option-move">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';move_browse=1;to=',$to)"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Move"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="button.options.publish">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and (user_privileges/publish|user_privileges/publish_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id) ">
				<a class="button option-publish">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';publish_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Publishing_options"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--<xsl:template name="button.options.acl_or_undelete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and (user_privileges/grant|user_privileges/grant_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="button option-acl">
					<xsl:attribute name="id">option-acl_<xsl:value-of select="$id"/></xsl:attribute>
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Access_control"/>
				</a>
				<script type="text/javascript">
				$(document).ready(function() {

					$( "#option-acl_<xsl:value-of select="$id"/>" ).tooltip(
						{ 
						content: function(response) {				
						$.get('<xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1;tooltip=1')"/>', response);
						return "Loading...";
						}
						},
						{position: {my: "center top", at: "center bottom"}},
						{width: "530"}
					);
				});

	</script>
			</xsl:when>
			<xsl:when test="user_privileges/delete and marked_deleted = '1'">
				<a class="button option-undelete">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';undelete=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Undelete"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->
	
	<xsl:template name="button.options.acl">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="(user_privileges/grant|user_privileges/grant_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="button option-acl">
					<xsl:attribute name="id">option-acl_<xsl:value-of select="$id"/></xsl:attribute>
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Access_control"/>
				</a>
				<script type="text/javascript">
				$(document).ready(function() {
					$( "#option-acl_<xsl:value-of select="$id"/>" ).tooltip(
						{ 
						content: function(response) {				
						$.get('<xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1;tooltip=1')"/>', response);
						return "Loading...";
						}
						},
						{width: "530"},
						{position: {offset: "-300 10", my: "right top", at: "left bottom",collision: "fit", of: '#option-acl_<xsl:value-of select="$id"/>'}}
					);
				});

	</script>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
			</xsl:choose>
	</xsl:template>
	
	<xsl:template name="button.options.undelete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="user_privileges/delete">
				<a class="button option-undelete">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';undelete=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Undelete"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="button.options.purge_or_delete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="user_privileges/delete and marked_deleted = '1'">
				<a class="button option-purge" title="{$l_purge}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_purge"/>
				</a>
			</xsl:when>
			<xsl:when test="user_privileges/delete and published != '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="button option-delete" title="{$l_delete}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan_prompt=1')"/><!--trashcan_prompt does not check wether the object has any children--><!--		<xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan=1')"/>--><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_delete"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="button.options.purge">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="user_privileges/delete">
				<a class="button option-purge" title="{$l_purge}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_purge"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="button.options.delete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="user_privileges/delete and published != '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="button option-delete" title="{$l_delete}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan_prompt=1')"/><!--trashcan_prompt does not check wether the object has any children--><!--		<xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan=1')"/>--><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_delete"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="button.options.send_email">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' 
                  and (user_privileges/send_as_mail = '1')  
                  and (locked_time = '' 
                       or locked_by_id = /document/context/session/user/@id)
                  and /document/object_types/object_type[
                        @id=/document/context/object/object_type_id
                      ]/is_mailable = '1'
                  and published = '1'">
				<a class="button option-send_mail">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';prepare_mail=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$i18n/l/Send"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button option-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="state-toolbar">
		<div class="toolbar">
			<xsl:call-template name="button.state.new"/>
			<xsl:call-template name="button.state.publish"/>
			<xsl:call-template name="button.state.locked"/>
		</div>
	</xsl:template>
	<xsl:template name="button.state.publish">
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<xsl:variable name="publish_gopublic">
			<xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
		</xsl:variable>
		<xsl:variable name="published_path_base">
			<xsl:choose>
				<xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
					<xsl:value-of select="$absolute_path_nosite"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$absolute_path"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="object_path">
			<xsl:choose>
				<xsl:when test="local-name(..) = 'children'">
					<xsl:value-of select="concat($published_path_base,'/',location)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$published_path_base"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="published_path">
			<xsl:choose>
				<xsl:when test="$publish_gopublic = 0">
					<xsl:value-of select="concat($publishingroot,$object_path)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($gopublic_content,$object_path)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="published = '1'">
				<a href="{$published_path}" target="_blank">
					<xsl:choose>
						<xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
							<xsl:attribute name="class">button status-pub</xsl:attribute>
							<span>
								<xsl:value-of select="$l_Object_last_published"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$l_at_place"/>&#160;<xsl:value-of select="$published_path"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">button status-pub_async</xsl:attribute>
							<span>
								<xsl:value-of select="$l_Object_modified"/>&#160;<xsl:call-template name="lastpublisherfullname"/>&#160;<xsl:value-of select="$l_at_time"/>&#160;<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;<xsl:value-of select="$l_changed"/>.
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button status-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="button.state.new">
		<xsl:choose>
			<xsl:when test="marked_new= '1'">
				<span class="xims-sprite sprite-new">
					<span>
						<xsl:value-of select="$l_Object_marked_new"/>
					</span>
				&#160;
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.status.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="button.state.locked">
		<xsl:choose>
			<xsl:when test="locked_by_id != '' and locked_time != '' and locked_by_id = /document/context/session/user/@id">
				<a class="button status-locked">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',@id,';cancel=1;r=',/document/context/object/@id)"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';page=',$page)"/></xsl:if><xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:attribute>
					<xsl:value-of select="$l_Release_lock"/>
				</a>
			</xsl:when>
			<xsl:when test="locked_by_id != '' and locked_time != ''">
				<a class="button status-locked">
					<xsl:attribute name="title"><xsl:value-of select="$l_Object_locked"/>&#160;<xsl:apply-templates select="locked_time" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;<xsl:call-template name="lockerfullname"/>.
				</xsl:attribute>
					<xsl:value-of select="$l_Object_locked"/>&#160;<xsl:apply-templates select="locked_time" mode="datetime"/>&#160;<xsl:value-of select="$l_by"/>&#160;<xsl:call-template name="lockerfullname"/>.
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="button status-disabled">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options">
		<xsl:call-template name="cttobject.options.edit"/>
		<xsl:call-template name="cttobject.options.copy"/>
		<xsl:call-template name="cttobject.options.move"/>
		<xsl:call-template name="cttobject.options.publish"/>
		<xsl:call-template name="cttobject.options.acl_or_undelete"/>
		<xsl:call-template name="cttobject.options.purge_or_delete"/>
	</xsl:template>
	<xsl:template name="cttobject.options.edit">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and user_privileges/write and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="xims-sprite sprite-option_edit">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';edit=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
          &#xa0;
          <span>
						<xsl:value-of select="$l_Edit"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.options.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options.copy">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and user_privileges/copy and /document/context/object/user_privileges/create">
				<a class="xims-sprite sprite-option_copy">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';copy=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
          &#xa0;
          <span>
						<xsl:value-of select="$l_Copy"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.options.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options.move">
		<xsl:variable name="parentid" select="@parent_id"/>
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="to">
			<xsl:choose>
				<xsl:when test="$currobjmime='application/x-container'">
					<xsl:value-of select="/document/context/object/@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/document/context/object/parents/object[@document_id=$parentid]/@id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and user_privileges/move and published != '1'  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="xims-sprite sprite-option_move">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';move_browse=1;to=',$to)"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
                &#xa0;<span>
						<xsl:value-of select="$l_Move"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.options.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options.publish">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and (user_privileges/publish|user_privileges/publish_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id) ">
				<a class="xims-sprite sprite-option_pub">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';publish_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
                &#xa0;
                <span>
						<xsl:value-of select="$l_Publishing_options"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.options.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options.acl_or_undelete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="marked_deleted != '1' and (user_privileges/grant|user_privileges/grant_all)  and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="xims-sprite sprite-option_acl">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
                &#xa0;<span>
						<xsl:value-of select="$l_Access_control"/>
					</span>
				</a>
			</xsl:when>
			<xsl:when test="user_privileges/delete and marked_deleted = '1'">
				<a class="xims-sprite sprite-option_undelete">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';undelete=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
                &#xa0;<span>
						<xsl:value-of select="$l_Undelete"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.options.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options.purge_or_delete">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="user_privileges/delete and marked_deleted = '1'">
				<a class="xims-sprite sprite-option_purge" title="{$l_purge}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
          &#xa0;<span>
						<xsl:value-of select="$l_purge"/>
					</span>
				</a>
			</xsl:when>
			<xsl:when test="user_privileges/delete and published != '1' and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="xims-sprite sprite-option_delete" title="{$l_delete}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan_prompt=1')"/><!--trashcan_prompt does not check wether the object has any children--><!--		<xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan=1')"/>--><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
          &#xa0;<span>
						<xsl:value-of select="$l_delete"/>
					</span>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cttobject.options.spacer"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="cttobject.options.spacer">
		<span class="sprite-spacer">&#xa0;</span>
	</xsl:template>
	<xsl:template name="cttobject.options.send_email">
		<xsl:variable name="id" select="@id"/>
		<xsl:if test="marked_deleted != '1' 
                  and (user_privileges/send_as_mail = '1')  
                  and (locked_time = '' 
                       or locked_by_id = /document/context/session/user/@id)
                  and /document/object_types/object_type[
                        @id=/document/context/object/object_type_id
                      ]/is_mailable = '1'
                  and published = '1'">
			<a>
				<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';prepare_mail=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,
                                           ';order=',$order,
                                           ';page=',$page,
                                           ';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
				<img src="{$skimages}option_email.png" border="0" name="email{$id}" width="18" height="19" title="Generate Spam" alt="Generate Spam"/>
			</a>
		</xsl:if>
	</xsl:template>
	<xsl:template name="ui-icon.spacer">
		<span class="sprite-ui-icon-spacer">&#xa0;</span>
	</xsl:template>
	<xsl:template name="cttobject.status.spacer">
		<span class="sprite-status-spacer">&#xa0;</span>
	</xsl:template>
	<xsl:template name="cttobject.del.spacer">
		<span class="sprite-del-spacer">&#xa0;</span>
	</xsl:template>
	<xsl:template name="cttobject.dataformat">
		<xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>
		<span class="sprite-list sprite-list_{$dfname}">
			<span>
				<xsl:value-of select="$dfname"/>
			</span>&#xa0;</span>
	</xsl:template>
	<xsl:template name="toggle_hls">
		<xsl:if test="$hls != ''">
			<div id="toggle_highlight">
				<form>
					<xsl:value-of select="$i18n/l/you_searched_for"/> '<xsl:value-of select="$hls"/>'.
                <input type="button" value="{$i18n/l/toggle_hls}" onclick="toggleHighlight(getParamValue('hls'))"/>
				</form>
			</div>
		</xsl:if>
	</xsl:template>
	<xsl:template name="xmlhttpjs">
		<xsl:call-template name="mk-inline-js">
			<xsl:with-param name="code">
    function getXMLHTTPObject() {
        var xmlhttp=false;
        /*@cc_on @*/
        /*@if (@_jscript_version >= 5)
        // JScript gives us Conditional compilation, we can cope with old IE versions.
        // and security blocked creation of the objects.
        try {
            xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
            try {
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch (E) {
                xmlhttp = false;
            }
        }
        @end @*/
        if (!xmlhttp &amp;&amp; typeof XMLHttpRequest!='undefined') {
            xmlhttp = new XMLHttpRequest();
        }
        return xmlhttp;
    }
    </xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="wfcheckjs">
		<xsl:call-template name="xmlhttpjs"/>
		<script type="text/javascript">
				var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?test_wellformedness=1')"/>";
		</script>
	</xsl:template>
	<xsl:template name="prettyprintjs">
		<xsl:param name="ppmethod" select="'htmltidy'"/>
		<xsl:call-template name="xmlhttpjs"/>
		<script type="text/javascript">
					var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/>";
					var ppmethod = "<xsl:value-of select="$ppmethod"/>";
		</script>
	</xsl:template>
	<xsl:template name="testlocationjs">
		<script type="text/javascript" src="{$ximsroot}scripts/json-min.js"/>
		<script type="text/javascript" src="{$ximsroot}scripts/test_location.js"/>
		<script type="text/javascript">
		var obj    = '<xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/fullname"/>';
		var suffix = '<xsl:value-of select="/document/data_formats/data_format[@id=/document/context/object/data_format_id]/suffix"/>';
		var locWarnText1 = "<xsl:value-of select="$i18n/l/LocationWarning1"/>";
		var locWarnText2 = "<xsl:value-of select="$i18n/l/LocationWarning2"/>";
		var locWarnButton = "<xsl:value-of select="$i18n/l/Yes"/>";
		var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/>';
		
		var notice = "";
		var btnOK = "<xsl:value-of select="$i18n/l/IlpButtonOK"/>";
		var btnIgnore = "<xsl:value-of select="$i18n/l/IlpButtonAcceptSuggestion"/>";
		var btnChange = "<xsl:value-of select="$i18n/l/IlpButtonChange"/>";
		var textChange = "<xsl:value-of select="$i18n/l/IlpLocationWouldChange"/>";
		var textExists = "<xsl:value-of select="$i18n/l/IlpLocationExists"/>";
		var textDirtyLoc = "<xsl:value-of select="$i18n/l/IlpDirtyLocation"/>";
		var textNoLoc = "<xsl:value-of select="$i18n/l/IlpNoLocationProvided"/>";
		var textLocFirst = "<xsl:value-of select="$i18n/l/IlpProvideLocationFirst"/>";
			</script>
	</xsl:template>
	<xsl:template name="form-minify">
		<div>
			<div class="label">
				<label for="input-minify">
					<xsl:value-of select="$i18n/l/minify"/>
				</label>
			</div>
			<input type="checkbox" class="checkbox" name="minify" id="input-minify">
				<xsl:if test="attributes/minify = '1'">
					<xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
				</xsl:if>
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('minify')" class="doclink">(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="jquery-listitems-bg">
		<xsl:param name="pick"/>
		<xsl:if test="$pick">
			<script type="text/javascript">
        $(function() {
          $("<xsl:value-of select="$pick"/>:odd").addClass("listitem_odd");
          $("<xsl:value-of select="$pick"/>:even").addClass("listitem_even");
        });
      </script>
		</xsl:if>
	</xsl:template>
	<xsl:template name="mk-textfield">
		<xsl:param name="title-i18n" select="''"/>
		<xsl:param name="title" select="$title-i18n"/>
		<xsl:param name="name" select="translate($title, &uc;, &lc;)"/>
		<xsl:param name="size" select="'60'"/>
		<xsl:param name="maxlength" select="'127'"/>
		<xsl:param name="xpath" select="'/..'"/>
		<div>
			<div id="label-{$name}" class="label-std">
				<label for="input-{$name}">
					<xsl:choose>
						<xsl:when test="string-length($title-i18n)&gt;0">
							<xsl:value-of select="dyn:evaluate( concat('$i18n/l/', $title-i18n) )"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$title"/>
						</xsl:otherwise>
					</xsl:choose>
				</label>
			</div>
			<input type="text" size="{$size}" name="{$name}" value="{dyn:evaluate($xpath)}" class="text" maxlength="{$maxlength}" id="input-{$name}"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('{$title}')" class="doclink">(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="mk-textarea">
		<xsl:param name="title-i18n" select="''"/>
		<xsl:param name="title" select="$title-i18n"/>
		<xsl:param name="name" select="translate($title, &uc;, &lc;)"/>
		<xsl:param name="length" select="'60'"/>
		<xsl:param name="maxlength" select="'127'"/>
		<xsl:param name="xpath" select="'/..'"/>
		<xsl:param name="cols" select="'60'"/>
		<xsl:param name="rows" select="'60'"/>
		<div>
			<div id="label-{$name}">
				<label for="input-{$name}">
					<xsl:choose>
						<xsl:when test="string-length($title-i18n)&gt;0">
							<xsl:value-of select="dyn:evaluate( concat('$i18n/l/', $title-i18n) )"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$title"/>
						</xsl:otherwise>
					</xsl:choose>
				</label>
			</div>
			<textarea name="{$name}" cols="{$cols}" rows="{$rows}" class="text">
				<xsl:value-of select="dyn:evaluate($xpath)"/>
			</textarea>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('{$title}')" class="doclink">(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="mk-tr-checkbox">
		<xsl:param name="title-i18n" select="''"/>
		<xsl:param name="title" select="$title-i18n"/>
		<xsl:param name="name" select="translate($title, &uc;, &lc;)"/>
		<xsl:param name="xpath" select="'/..'"/>
		<tr>
			<td>
				<xsl:choose>
					<xsl:when test="string-length($title-i18n)&gt;0">
						<xsl:value-of select="dyn:evaluate( concat('$i18n/l/', $title-i18n) )"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$title"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td colspan="2">
				<input name="{$name}" type="checkbox" value="true">
					<xsl:if test="dyn:evaluate($xpath) = '1'">
						<xsl:attribute name="checked"><xsl:value-of select="checked"/></xsl:attribute>
					</xsl:if>
				</input>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('{$title}')" class="doclink">(?)</a>
			</td>
		</tr>
	</xsl:template>

	<xsl:template name="mk-inline-js">
		<xsl:param name="code"/>
		<script type="text/javascript">
			<xsl:text disable-output-escaping="yes">//&lt;![CDATA[</xsl:text>
			<xsl:value-of disable-output-escaping="yes" select="$code"/>
			<xsl:text disable-output-escaping="yes">//]]&gt;</xsl:text>
		</script>
	</xsl:template>
	
	<!--	Templates from stylesheets/common.xsl-->
<xsl:template name="script_bottom">
	<xsl:param name="tinymce" select="false()"/>
    <xsl:param name="codemirror" select="false()"/>
	<xsl:param name="simpledb" select="false()"/>
	<xsl:param name="vlib" select="false()"/>
	<xsl:param name="reflib" select="false()"/>
	<xsl:param name="questionnaire" select="false()"/>
	
	<!-- container for dialog, i.e. browse for object-->
	<div id="default-dialog" style="max-height:400px;max-width:800px"></div>
	
	<!--<script src="{$ximsroot}skins/{$currentskin}/scripts/min.js" type="text/javascript"/>-->
	<script src="{$ximsroot}scripts/jquery/jquery-ui-i18n.js" type="text/javascript"/>
	<script src="{$ximsroot}scripts/default.js" type="text/javascript"/>
	<script src="{$ximsroot}skins/{$currentskin}/scripts/2punkt0.js" type="text/javascript"/>
	
	<xsl:if test="$tinymce">
		<xsl:call-template name="tinymce_scripts"/>
	</xsl:if>
	
	<xsl:if test="$codemirror">
		<xsl:call-template name="codemirror_scripts"/>
	</xsl:if>
	
	<xsl:if test="$simpledb">
		<script src="{$ximsroot}scripts/simpledb.js" type="text/javascript"/>
		<script type="text/javascript">
			var button_image = '<xsl:value-of select="$skimages"/>calendar.gif';
			$(document).ready(function(){
				initDatepicker();
			});
		</script>
	</xsl:if>
	<xsl:if test="$vlib">
		<script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"/>
		<script type="text/javascript" language="javascript">
			<xsl:choose>
				<xsl:when test="(/document/context/object/object_type_id = '45') or (/document/context/object/object_type_id = '11')">
			var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,'?id=',/document/context/object/@id)"/>';
			</xsl:when>
				<xsl:otherwise>
			var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,/document/context/object/location_path)"/>';
			</xsl:otherwise>
			</xsl:choose>      
			var parentpath = '<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path)"/>';
	</script>
	</xsl:if>
	<xsl:if test="$reflib">
		<script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"/>
		<script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"/>
	</xsl:if>
	<xsl:if test="$questionnaire">
		<script src="{$ximsroot}scripts/questionnaire.js" type="text/javascript"/>
	</xsl:if>
</xsl:template>	
	<xsl:template match="/document/context/object/parents/object">
		<xsl:param name="no_navigation_at_all">false</xsl:param>
		<xsl:variable name="thispath">
			<xsl:call-template name="parentpath"/>
		</xsl:variable>
		<xsl:if test="$no_navigation_at_all = 'false'">
        / <a href="{$goxims_content}{$thispath}/{location}">
				<xsl:value-of select="location"/>
			</a>
		</xsl:if>
	</xsl:template>
	<!-- used in urllink-contentbrowse, returns the absolute path of target
	  only working as long as the title of the siteroot is named something like "http://www.uibk.ac.at"-->
	<xsl:template name="targetpath_abs">
		<xsl:for-each select="/document/context/object/targetparents/object[@document_id != 1]">
			<xsl:choose>
				<xsl:when test="@document_id = 2">
					<xsl:value-of select="title"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="location"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>/<xsl:value-of select="/document/context/object/target/object/location"/>
	</xsl:template>
	<xsl:template name="bookmark_link">
		<xsl:choose>
			<xsl:when test="content_id != ''">
				<a href="{$xims_box}{$goxims_content}{content_id}">
					<xsl:value-of select="content_id"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a href="{$xims_box}{$goxims_content}/">/root</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="create_bookmark">
		<xsl:param name="admin" select="false()"/>
		<h2>
			<xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$i18n/l/Bookmark"/>
		</h2>
		<form action="{$xims_box}{$goxims}/bookmark" name="eform">
			<p>
				<label for="input-path">
					<xsl:value-of select="$i18n/l/Path"/>
				</label>: 
			<input type="text" name="path" size="40" class="text" id="input-path"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Bookmark')" class="doclink">(?)</a>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:createDialog('{$xims_box}{$goxims_content}{$stdhome}?contentbrowse=1;sbfield=eform.path','default-dialog','{$i18n/l/Browse_for} {$i18n/l/Object}')" class="button">
				<xsl:value-of select="$i18n/l/Browse_for"/>&#160;<xsl:value-of select="$i18n/l/Object"/>
			</a>
			</p>
			<p>
				<label for="cb-stdbm">
					<xsl:value-of select="$i18n/l/Set_as"/>&#160;
							<xsl:value-of select="$i18n/l/default_bookmark"/>
				</label>: 
				<input type="checkbox" class="checkbox" name="stdhome" value="1" id="cb-stdbm"/>
				<a href="javascript:openDocWindow('DefaultBookmark')" class="doclink">(?)</a>
				<xsl:text>&#160;</xsl:text>
			</p>
			<xsl:if test="$admin">
				<input type="hidden" name="name" value="{$name}"/>
				<input name="userquery" type="hidden" value="{$userquery}"/>
			</xsl:if>
			<button type="submit" name="create" value="1">
				<xsl:value-of select="$i18n/l/Create"/>
			</button>
		</form>
	</xsl:template>
	
	<xsl:template name="back-to-home">
		<!--<p class="back">
			<span class="ui-icon ui-icon-home"></span><a href="{$xims_box}{$goxims}/user"><xsl:value-of select="$i18n/l/BackToHome"/></a>
		</p>-->
		<a class="button" href="{$xims_box}{$goxims}/user"><xsl:value-of select="$i18n/l/cancel"/></a>
	</xsl:template>
</xsl:stylesheet>
