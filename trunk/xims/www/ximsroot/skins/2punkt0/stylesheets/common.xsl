<?xml version="1.0" encoding="utf-8"?>
<!--
		# Copyright (c) 2002-2009 The XIMS Project. # See the file "LICENSE"
		for information and conditions for use, reproduction, # and
		distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. #
		$Id: common.xsl 2248 2009-08-10 10:27:04Z haensel $
	-->
<!DOCTYPE stylesheet [
	<!ENTITY lc "'aäbcdefghijklmnoöpqrstuüvwxyz'">
	<!ENTITY uc "'AÄBCDEFGHIJKLMNOÖPQRSTUÜVWXYZ'">
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dyn="http://exslt.org/dynamic" xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="dyn">
	<xsl:import href="../../../stylesheets/common.xsl"/>
	<!--<xsl:import href="common_footer.xsl"/>-->
	<xsl:import href="common_header.xsl"/>
	<xsl:import href="common_metadata.xsl"/>
	<xsl:import href="common_localized.xsl"/>
	<xsl:import href="common_jscalendar_scripts.xsl"/>
	<xsl:import href="common_tinymce_scripts.xsl"/>
	<xsl:output method="xml" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
	<xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>
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
	<xsl:template name="cancelform">
		<xsl:param name="with_save" select="'no'"/>
		<!--
			method get is needed, because goxims does not handle a PUTed 'id'
		-->
		<form class="cancelsave-form" action="{$xims_box}{$goxims_content}" name="cform" method="get">
			<input type="hidden" name="id" value="{@id}"/>
			<xsl:if test="$with_save = 'yes'">
				<xsl:call-template name="save_jsbutton"/>
			</xsl:if>
			<xsl:call-template name="rbacknav"/>
			<!--<input type="submit" name="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C"/>-->
			<button class="control ui-state-default ui-corner-all fg-button" type="submit" name="cancel_create" accesskey="C">
				<span class="text">
					<xsl:value-of select="$i18n/l/cancel"/>
				</span>
			</button>
		</form>
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
	<xsl:template name="cancelcreateform">
		<xsl:param name="with_save" select="'no'"/>
		<form class="cancelsave-form" action="{$xims_box}{$goxims_content}{$absolute_path}" method="post">
			<xsl:if test="$with_save = 'yes'">
				<xsl:call-template name="save_jsbutton"/>
			</xsl:if>
			<xsl:call-template name="rbacknav"/>
			<button class="ui-state-default ui-corner-all fg-button" type="submit" name="cancel_create" accesskey="C">
				<span class="text">
					<xsl:value-of select="$i18n/l/cancel"/>
				</span>
			</button>
			<!--<input type="submit" name="cancel_create" value="{$i18n/l/cancel}" class="control" accesskey="C"/>-->
		</form>
	</xsl:template>
	<xsl:template name="save_jsbutton">
		<button class="ui-state-default ui-corner-all fg-button" type="submit" name="submit_eform" accesskey="S" onclick="document.eform.store.click(); return false">
			<span class="text">
				<xsl:value-of select="$i18n/l/save"/>
			</span>
		</button>
		<!--		
	<script type="text/javascript">
/*document.write('<input type="submit" name="submit_eform" value="{$i18n/l/save}" onclick="document.eform.store.click(); return false" class="control"/>');*/
document.write('<button class="ui-state-default ui-corner-all fg-button" type="submit" name="submit_eform" accesskey="C" onclick="document.eform.store.click(); return false"><span class="text"><xsl:value-of select="$i18n/l/save"/></span></button>');
		</script>-->
	</xsl:template>
	<xsl:template name="exitredirectform">
		<xsl:variable name="object_type_id" select="object_type_id"/>
		<xsl:variable name="parent_id" select="@parent_id"/>
		<form name="userConfirm" action="{$xims_box}{$goxims_content}" method="get">
			<input class="ui-state-default ui-corner-all fg-button" name="exit" type="submit">
				<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Done"/></xsl:attribute>
			</input>
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
		<input type="submit" name="store" value="{$i18n/l/save}" class="control hidden" accesskey="S"/>
	</xsl:template>
	<xsl:template name="saveedit">
		<input type="hidden" name="id" value="{@id}"/>
		<xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
			<input name="sb" type="hidden" value="date"/>
			<input name="order" type="hidden" value="desc"/>
		</xsl:if>
		<input type="submit" name="store" value="{$i18n/l/save}" class="control hidden" accesskey="S"/>
	</xsl:template>
	<xsl:template name="grantowneronly">
		<div id="tr-grantowneronly">
			<fieldset>
				<legend>
					<div id="label-grantowneronly">
						<xsl:value-of select="$i18n/l/Priv_grant_options"/>
					</div>
				</legend>
				<input name="owneronly" type="radio" value="false" checked="checked" id="radio-cp-par-privs" class="radio-button"/>
				<label for="radio-cp-par-privs">
					<xsl:value-of select="$i18n/l/Copy_parent_privs"/>
				</label>
				<xsl:text>&#160;&#160;</xsl:text>
				<input name="owneronly" type="radio" value="true" onclick="document.eform.defaultroles.disabled = true;" onblur="document.eform.defaultroles.disabled = false;" id="radio-grantmyself" class="radio-button"/>
				<label for="radio-grantmyself">
					<xsl:value-of select="$i18n/l/Grant_myself_only"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('PrivilegeGrantOptions')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Priv_grant_options"/></xsl:attribute>
					(?)</a>
			</fieldset>
			<br/>
			<div id="label-empty">&#160;</div>
			<xsl:text>&#160;</xsl:text>
			<label for="checkb-defaultroles">
				<xsl:value-of select="$i18n/l/Grant_default_roles"/>
			</label>
			<input name="defaultroles" type="checkbox" value="true" id="checkb-defaultroles" class="checkbox"/>
		</div>
	</xsl:template>
	<xsl:template name="markednew">
		<div id="tr-marknew">
			<fieldset>
				<legend>
					<div id="label-marknew">
						<xsl:value-of select="$i18n/l/Mark_new"/>
					</div>
				</legend>
				<input name="markednew" type="radio" value="true" id="radio-marknew-true" class="radio-button">
					<xsl:if test="marked_new = '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="radio-marknew-true">
					<xsl:value-of select="$i18n/l/Yes"/>
				</label>
				<input name="markednew" type="radio" value="false" id="radio-marknew-false" class="radio-button">
					<xsl:if test="marked_new != '1'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</input>
				<label for="radio-marknew-false">
					<xsl:value-of select="$i18n/l/No"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('markednew')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Mark_new"/></xsl:attribute>
					(?)</a>
			</fieldset>
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
	<xsl:template name="table-create">
		<div id="create-title">
			<h1>
				<xsl:value-of select="$i18n/l/create"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/>
			</h1>
		</div>
	</xsl:template>
	<xsl:template name="table-edit">
		<div id="edit-title">
			<h1>
				<xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>' <xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/>
			</h1>
		</div>
	</xsl:template>
	<xsl:template name="table-move">
		<div id="move-title">
			<h1>
				<xsl:value-of select="$i18n/l/Move_object"/> '<xsl:value-of select="title"/>' 
			</h1>
		</div>
	</xsl:template>
	<xsl:template name="tr-locationtitle-create">
		<xsl:call-template name="tr-title-create"/>
		<xsl:call-template name="tr-location-create"/>
	</xsl:template>
	<xsl:template name="tr-locationtitle-edit">
		<xsl:call-template name="tr-title-edit"/>
		<xsl:call-template name="tr-location-edit"/>
	</xsl:template>
	<xsl:template name="tr-location-edit">
		<xsl:param name="testlocation" select="true()"/>
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<xsl:variable name="publish_gopublic">
			<xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
		</xsl:variable>
		<div id="tr-location">
			<!--<img src="{$ximsroot}images/spacer_white.gif" alt="*"/>-->
			<div id="label-location">
				<!--<span class="compulsory">-->
				<label for="input-location">
					<xsl:value-of select="$i18n/l/Location"/>
				</label>
				<!--</span>-->
			</div>
			<input type="text" name="name" size="60" value="{location}" id="input-location">
				<xsl:choose>
					<xsl:when test="$publish_gopublic = '0' and published = '1'">
						<xsl:attribute name="readonly">readonly</xsl:attribute>
						<xsl:attribute name="class">readonlytext</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">text</xsl:attribute>
						<xsl:attribute name="onfocus">this.className='text focused'</xsl:attribute>
						<xsl:if test="$testlocation">
							<!--<xsl:attribute name="onchange">this.className='text'; return testlocation();</xsl:attribute>-->
							<xsl:attribute name="onchange">this.className='text';</xsl:attribute>
						</xsl:if>
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
			<!-- we only test locations for unpublished docs -->
			<xsl:if test="published = '0'">
				<!-- location-testing AJAX code -->
				<xsl:if test="$testlocation">
					<xsl:call-template name="testlocationjs">
						<xsl:with-param name="event" select="'edit'"/>
						<xsl:with-param name="obj_type" select="/document/object_types/object_type[@id=$objecttype]/fullname"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:if>
			<!--<xsl:call-template name="marked_mandatory"/>-->
		</div>
	</xsl:template>
	<xsl:template name="tr-location-create">
		<xsl:param name="testlocation" select="true()"/>
		<div id="tr-location">
			<!--<img src="{$ximsroot}images/spacer_white.gif" alt="*"/>-->
			<div id="label-location">
				<!--<span class="compulsory">-->
				<label for="input-location">
					<xsl:value-of select="$i18n/l/Location"/>
				</label>
				<!--</span>-->
			</div>
			<!--<input type="text" name="name" size="60" class="text" onfocus="this.className='text focused'" onblur="this.className='text';" id="input-location">-->
			<input type="text" name="name" size="60" class="text" id="input-location">
				<xsl:if test="$testlocation">
					<xsl:attribute name="onchange">return testlocation();</xsl:attribute>
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
				<xsl:attribute name="title"><xsl:value-of select="IlpDefaultWinlabel"/></xsl:attribute>
			</div>
			<div id="location-dialog">
				<xsl:attribute name="title"><xsl:value-of select="IlpDefaultWinlabel"/></xsl:attribute>
			</div>
			<!-- location-testing AJAX code -->
			<xsl:if test="$testlocation">
				<xsl:call-template name="testlocationjs">
					<xsl:with-param name="event" select="'create'"/>
				</xsl:call-template>
			</xsl:if>
			<!--<xsl:call-template name="marked_mandatory"/>-->
		</div>
	</xsl:template>
	<xsl:template name="tr-title-create">
		<xsl:call-template name="tr-title"/>
	</xsl:template>
	<xsl:template name="tr-title-edit">
		<xsl:call-template name="tr-title"/>
	</xsl:template>
	<xsl:template name="tr-title">
		<div id="tr-title">
			<div id="label-title">
				<label for="input-title">
					<xsl:value-of select="$i18n/l/Title"/>&#160;*
				</label>
			</div>
			<input type="text" name="title" size="60" class="text" id="input-title" value="{title}">
				<xsl:attribute name="onchange">return testtitle();</xsl:attribute>
			</input>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Title')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Title"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-locationtitle-edit_xml">
		<xsl:variable name="objecttype">
			<xsl:value-of select="object_type_id"/>
		</xsl:variable>
		<div id="tr-location">
			<!--<img src="{$ximsroot}images/spacer_white.gif" alt="*"/>-->
			<div id="label-location">
				<span class="compulsory">
					<label for="input-location">
						<xsl:value-of select="$i18n/l/Location"/>
					</label>
				</span>
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
				<xsl:call-template name="testlocationjs">
					<xsl:with-param name="event" select="'edit'"/>
					<xsl:with-param name="obj_type" select="/document/object_types/object_type[@id=$objecttype]/fullname"/>
				</xsl:call-template>
			</xsl:if>
		</div>
		<xsl:call-template name="tr-title-edit"/>
	</xsl:template>
	<xsl:template name="tr-bodyfromfile-create">
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
	<xsl:template name="tr-bodyfromfile-edit">
		<div id="tr-bodyfromfile">
			<div id="label-bodyfromfile">
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
		<script type="text/javascript">
        var origbody = document.getElementById('body').value;
    </script>
	</xsl:template>
	<xsl:template name="tr-body-create">
		<xsl:param name="with_origbody" select="'no'"/>
		<div>
			<label for="body">
				<xsl:value-of select="$i18n/l/Body"/>
			</label>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Body')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/></xsl:attribute>(?)</a>
			<br/>
			<xsl:call-template name="ui-resizable"/>
			<div id="bodymain">
				<div id="bodycon">
					<textarea name="body" id="body" rows="20" cols="90" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;" class="resizable ui-widget-content">
					&#160;
				</textarea>
				</div>
			</div>
			<xsl:if test="$with_origbody = 'yes'">
				<xsl:call-template name="jsorigbody"/>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="tr-body-edit">
		<xsl:param name="with_origbody" select="'no'"/>
		<div>
			<label for="body">Body</label>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Body')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Body"/></xsl:attribute>(?)</a>
			<br/>
			<xsl:call-template name="ui-resizable"/>
			<div id="bodymain">
				<div id="bodycon">
					<textarea name="body" id="body" rows="20" cols="90" class="resizable ui-widget-content">
						<xsl:choose>
							<xsl:when test="string-length(body) &gt; 0">
								<xsl:apply-templates select="body"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>&#160;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</textarea>
				</div>
			</div>
			<xsl:if test="$with_origbody = 'yes'">
				<xsl:call-template name="jsorigbody"/>
			</xsl:if>
		</div>
	</xsl:template>
	<xsl:template name="ui-resizable">
		<script type="text/javascript">
				$(function() {
					$(".resizable").resizable();
				});
		</script>
	</xsl:template>
	<xsl:template name="tr-keywords-create">
		<xsl:call-template name="tr-keywords"/>
	</xsl:template>
	<xsl:template name="tr-keywords-edit">
		<xsl:call-template name="tr-keywords"/>
	</xsl:template>
	<xsl:template name="tr-keywords">
		<div id="tr-keywords">
			<div id="label-keywords">
				<label for="input-keywords">
					<xsl:value-of select="$i18n/l/Keywords"/>
				</label>
			</div>
			<input type="text" name="keywords" size="60" class="text" id="input-keywords"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Keywords')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Keywords"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<!-- Legacy -->
	<xsl:template name="tr-abstract-create">
		<xsl:call-template name="tr-abstract"/>
	</xsl:template>
	<xsl:template name="tr-abstract-edit">
		<xsl:call-template name="tr-abstract"/>
	</xsl:template>
	<xsl:template name="tr-abstract">
		<div id="tr-abstract">
			<div id="label-abstract">
				<label for="input-abstract">
					<xsl:value-of select="$i18n/l/Abstract"/>
				</label>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Abstract')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Abstract"/></xsl:attribute>(?)</a>
			</div>
			<br/>
			<textarea id="input-abstract" name="abstract" rows="3" cols="71">
				<xsl:apply-templates select="abstract"/>
			</textarea>
		</div>
	</xsl:template>
	<xsl:template name="tr-notes">
		<tr>
			<td valign="top" colspan="3">
				<xsl:value-of select="$i18n/l/Notes"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Notes')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Notes"/></xsl:attribute>(?)</a>
				<br/>
				<textarea name="notes" rows="3" cols="90" id="input-notes">
					<xsl:apply-templates select="notes"/>
				</textarea>
			</td>
		</tr>
	</xsl:template>
	<xsl:template name="tr-stylesheet-create">
		<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
		<div id="tr-stylesheet">
			<div id="label-stylesheet">
				<label for="input-stylesheet">
					<xsl:value-of select="$i18n/l/Stylesheet"/>
				</label>
			</div>
			<input type="text" name="stylesheet" size="60" value="" class="text" id="input-stylesheet"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Stylesheet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Stylesheet"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_stylesheet"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-stylesheet-edit">
		<div id="tr-stylesheet">
			<div id="label-stylesheet">
				<label for="input-stylesheet">
					<xsl:value-of select="$i18n/l/Stylesheet"/>
				</label>
			</div>
			<input type="text" name="stylesheet" size="60" value="{style_id}" class="text" id="input-stylesheet"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Stylesheet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Stylesheet"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_stylesheet"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-css-create">
		<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
		<div id="tr-css">
			<div id="label-css">
				<label for="input-css">
					<xsl:value-of select="$i18n/l/CSS"/>
				</label>
			</div>
			<input type="text" name="css" size="60" value="" class="text" id="input-css"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('CSS')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/CSS"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=CSS;sbfield=eform.css')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_css"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-css-edit">
		<div id="tr-css">
			<div id="label-css">
				<label for="input-css">
					<xsl:value-of select="$i18n/l/CSS"/>
				</label>
			</div>
			<input type="text" name="css" size="60" value="{css_id}" class="text" id="input-css"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('CSS')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/CSS"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=CSS;sbfield=eform.css')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_css"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-script-create">
		<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
		<div id="tr-javascript">
			<div id="label-javascript">
				<label for="input-javascript">
					<xsl:value-of select="$i18n/l/JavaScript"/>
				</label>
			</div>
			<input type="text" name="script" size="60" value="" class="text" id="input-javascript"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('JavaScript')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/JavaScript"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=JavaScript;sbfield=eform.script')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_script"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-script-edit">
		<div id="tr-javascript">
			<div id="label-javascript">
				<label for="input-javascript">
					<xsl:value-of select="$i18n/l/JavaScript"/>
				</label>
			</div>
			<input type="text" name="script" size="60" value="{script_id}" class="text" id="input-javascript"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('JavaScript')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/JavaScript"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=JavaScript;sbfield=eform.script')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_script"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-feed-create">
		<xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
		<div id="tr-rssfeed">
			<div id="label-rssfeed">
				<label for="input-rssfeed">
					<xsl:value-of select="$i18n/l/RSSFeed"/>
				</label>
			</div>
			<input type="text" name="feed" size="60" value="" class="text" id="input-rssfeed"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Portlet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/RSSFeed"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=Portlet;sbfield=eform.feed')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_feed"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-feed-edit">
		<div id="tr-rssfeed">
			<div id="label-rssfeed">
				<label for="input-rssfeed">RSS-Feed</label>
			</div>
			<input type="text" name="feed" size="60" value="{feed_id}" class="text" id="input-rssfeed"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Portlet')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/RSSFeed"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.feed')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_feed"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-image-create">
		<div id="tr-image">
			<div id="label-image">
				<label for="input-image">
					<xsl:value-of select="$i18n/l/Image"/>
				</label>
			</div>
			<input type="text" name="image" size="60" value="" class="text" id="input-image"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Image')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Image"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}?contentbrowse=1;to={$parentid};otfilter=Image;sbfield=eform.image')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_image"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-image-edit">
		<div id="tr-image">
			<div id="label-image">
				<label for="input-image">
					<xsl:value-of select="$i18n/l/Image"/>
				</label>
			</div>
			<input type="text" name="image" size="60" value="{image_id}" class="text" id="input-image"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Image')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Image"/></xsl:attribute>(?)</a>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">
				<xsl:value-of select="$i18n/l/Browse_image"/>
			</a>
		</div>
	</xsl:template>
	<xsl:template name="jscalendar-selector">
		<xsl:param name="timestamp_string"/>
		<xsl:param name="formfield_id"/>
		<xsl:param name="default_value" select="'creation_timestamp'"/>
		<input type="hidden" name="{$formfield_id}" id="{$formfield_id}">
			<xsl:attribute name="value"><xsl:value-of select="$timestamp_string"/></xsl:attribute>
		</input>
		<span id="show_vft{$formfield_id}">
			<xsl:value-of select="$timestamp_string"/>
		</span>
		<xsl:text>&#160;</xsl:text>
		<img src="{$skimages}calendar.gif" id="f_trigger_vft{$formfield_id}" style="cursor: pointer;" alt="{$i18n/l/Date_selector}" title="{$i18n/l/Date_selector}" onmouseover="this.style.background='red';" onmouseout="this.style.background=''"/>
		<script type="text/javascript">
        var current_datestring = "<xsl:value-of select="$timestamp_string"/>";
        var current_date;
        //if ( current_datestring.length > 0 ) {
        if ( current_datestring.length ) {
            current_date = Date.parseDate(current_datestring, "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = current_date;
        }
        else {
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = "<xsl:choose>
				<xsl:when test="default_value='creation_timestamp'">
					<xsl:value-of select="$i18n/l/Valid_from_default_creation_timestamp"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n/l/Valid_from_default"/>
				</xsl:otherwise>
			</xsl:choose>"
        }
        Calendar.setup({
            inputField     :    "<xsl:value-of select="$formfield_id"/>",
            ifFormat       :    "%Y-%m-%d %H:%M",
            displayArea    :    "show_vft<xsl:value-of select="$formfield_id"/>",
            daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
            button         :    "f_trigger_vft<xsl:value-of select="$formfield_id"/>",
            align          :    "Tl",
            singleClick    :    true,
            showsTime      :    true,
            timeFormat     :    "24"
        });
    </script>
	</xsl:template>
	<xsl:template name="ui-datepicker">
		<xsl:param name="timestamp_string"/>
		<xsl:param name="formfield_id"/>
		<xsl:param name="default_value" select="'creation_timestamp'"/>
		<input type="text" id="input-validfrom" readonly="readonly" disabled="disabled">
			<xsl:attribute name="value"><xsl:value-of select="$timestamp_string"/></xsl:attribute>
		</input>
		<input type="hidden" name="{$formfield_id}" id="{$formfield_id}">
			<xsl:attribute name="value"><xsl:value-of select="$timestamp_string"/></xsl:attribute>
		</input>
		<!--<span id="show_vft{$formfield_id}">
			<xsl:value-of select="$timestamp_string"/>
		</span>
		<xsl:text>&#160;</xsl:text>-->
		<!--<img src="{$skimages}calendar.gif" id="f_trigger_vft{$formfield_id}" style="cursor: pointer;" alt="{$i18n/l/Date_selector}" title="{$i18n/l/Date_selector}" onmouseover="this.style.background='red';" onmouseout="this.style.background=''"/>-->
		<script type="text/javascript">
        var current_datestring = "<xsl:value-of select="$timestamp_string"/>";
        var current_date;
        if ( current_datestring.length > 0 ) {
            //current_date = Date.parseDate(current_datestring, "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
            $.datepicker.parseDate('DD, MM d, yy', current_datestring, {
							shortYearCutoff: 20, 
							dayNamesShort: $.datepicker.regional['fr'].dayNamesShort, 
							//dayNamesShort: $.datepicker.regional['de'].dayNamesShort, 
							dayNames: $.datepicker.regional['de'].dayNames, 
							monthNamesShort: $.datepicker.regional['de'].monthNamesShort, 
							monthNames: $.datepicker.regional['de'].monthNames
							});
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = current_date;
        }
        else {
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = "<xsl:choose>
				<xsl:when test="default_value='creation_timestamp'">
					<xsl:value-of select="$i18n/l/Valid_from_default_creation_timestamp"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$i18n/l/Valid_from_default"/>
				</xsl:otherwise>
			</xsl:choose>"
        }
        Calendar.setup({
            inputField     :    "<xsl:value-of select="$formfield_id"/>",
            ifFormat       :    "%Y-%m-%d %H:%M",
            displayArea    :    "show_vft<xsl:value-of select="$formfield_id"/>",
            daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
            button         :    "f_trigger_vft<xsl:value-of select="$formfield_id"/>",
            align          :    "Tl",
            singleClick    :    true,
            showsTime      :    true,
            timeFormat     :    "24"
        });
    </script>
	</xsl:template>
	<xsl:template name="tr-valid_from">
		<xsl:variable name="valid_from_timestamp_tmp">
			<xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>
		</xsl:variable>
		<xsl:variable name="valid_from_timestamp">
			<xsl:if test="$valid_from_timestamp_tmp != '-- :'">
				<xsl:value-of select="$valid_from_timestamp_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div id="tr-validfrom">
			<div id="label-validfrom">
				<!--<label for="input-validfrom">-->
				<xsl:value-of select="$i18n/l/Valid_from"/>
				<!--</label>-->
			</div>
			<xsl:call-template name="jscalendar-selector">
				<xsl:with-param name="timestamp_string" select="$valid_from_timestamp"/>
				<xsl:with-param name="formfield_id" select="'valid_from_timestamp'"/>
			</xsl:call-template>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_from')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_from"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="tr-valid_to">
		<xsl:variable name="valid_to_timestamp_tmp">
			<xsl:apply-templates select="valid_to_timestamp" mode="ISO8601-MinNoT"/>
		</xsl:variable>
		<xsl:variable name="valid_to_timestamp">
			<xsl:if test="$valid_to_timestamp_tmp != '-- :'">
				<xsl:value-of select="$valid_to_timestamp_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div id="tr-validto">
			<div id="label-validto">
				<!--<label for="input-validto">-->
				<xsl:value-of select="$i18n/l/Valid_to"/>
				<!--</label>-->
			</div>
			<xsl:call-template name="jscalendar-selector">
				<xsl:with-param name="timestamp_string" select="$valid_to_timestamp"/>
				<xsl:with-param name="formfield_id" select="'valid_to_timestamp'"/>
			</xsl:call-template>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_to')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_to"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	<xsl:template name="options-menu-bar">
		<xsl:param name="createwidget">true</xsl:param>
		<xsl:param name="parent_id"/>
		<xsl:variable name="dataformat">
			<xsl:value-of select="data_format_id"/>
		</xsl:variable>
		<xsl:variable name="df" select="/document/data_formats/data_format[@id=$dataformat]"/>
		<xsl:variable name="dfname" select="$df/name"/>
		<xsl:variable name="dfmime" select="$df/mime_type"/>
		<!--<div id="tab-container" class="ui-corner-top">-->
		<div id="options-menu-bar" class="ui-corner-top">
			<div id="options">
				<!--<div id="tab-cell1">-->
				<xsl:call-template name="cttobject.dataformat">
					<xsl:with-param name="dfname" select="$dfname"/>
				</xsl:call-template>
				<span id="object-title">
					<xsl:value-of select="title"/>
				</span>
				<!--</div>
			<div id="tab-cell3">-->
				<xsl:call-template name="cttobject.options"/>
				<xsl:call-template name="cttobject.options.send_email"/>
				<!--</div>
			<div id="tab-cell2">-->
				<xsl:call-template name="cttobject.status"/>
				<!--</div>-->
			</div>
			<!--<div id="create">-->
			<xsl:if test="/document/context/object/user_privileges/create
                            and $createwidget = 'true'
                            and /document/object_types/object_type[can_create]">
				<xsl:call-template name="header.cttobject.createwidget">
					<xsl:with-param name="parent_id">
						<xsl:value-of select="$parent_id"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<!--</div>-->
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
				<span class="sprite sprite-new">
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
							<xsl:attribute name="class">sprite sprite-status_pub</xsl:attribute>
							&#xa0;
							<span>
								<xsl:value-of select="$l_Object_last_published"/>&#160;
									<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;
									<xsl:value-of select="$l_by"/>&#160;
									<xsl:call-template name="lastpublisherfullname"/>&#160;
									<xsl:value-of select="$l_at_place"/>&#160;
									<xsl:value-of select="$published_path"/>
							</span>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">sprite sprite-status_pub_async</xsl:attribute>
								&#xa0;
								<span>
								<xsl:value-of select="$l_Object_modified"/>&#160;
									<xsl:call-template name="lastpublisherfullname"/>&#160;
									<xsl:value-of select="$l_at_time"/>&#160;
									<xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>&#160;
									<xsl:value-of select="$l_changed"/>.
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
				<a class="sprite sprite-locked">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',@id,';cancel=1;r=',/document/context/object/@id)"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';page=',$page)"/></xsl:if><xsl:if test="$currobjmime='application/x-container' and $defsorting != 1"><xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/></xsl:if></xsl:attribute>
					<span>
						<xsl:value-of select="$l_Release_lock"/>
					</span>
										&#160;
				</a>
			</xsl:when>
			<xsl:when test="locked_by_id != '' and locked_time != ''">
				<a class="sprite sprite-locked">
					<xsl:attribute name="title"><xsl:value-of select="$l_Object_locked"/><xsl:apply-templates select="locked_time" mode="datetime"/><xsl:value-of select="$l_by"/>&#160;
					<xsl:call-template name="lockerfullname"/>.
				</xsl:attribute>
					<span>
						<xsl:value-of select="$l_Object_locked"/>
						<xsl:apply-templates select="locked_time" mode="datetime"/>
						<xsl:value-of select="$l_by"/>&#160;
					<xsl:call-template name="lockerfullname"/>.
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
				<a class="sprite sprite-option_edit">
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
				<a class="sprite sprite-option_copy">
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
				<a class="sprite sprite-option_move">
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
				<a class="sprite sprite-option_pub">
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
				<a class="sprite sprite-option_acl">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
                &#xa0;<span>
						<xsl:value-of select="$l_Access_control"/>
					</span>
				</a>
			</xsl:when>
			<xsl:when test="user_privileges/delete and marked_deleted = '1'">
				<a class="sprite sprite-option_undelete">
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
				<a class="sprite sprite-option_purge" title="{$l_purge}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
          &#xa0;<span>
						<xsl:value-of select="$l_purge"/>
					</span>
				</a>
			</xsl:when>
			<xsl:when test="user_privileges/delete and published != '1'  
                      and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
				<a class="sprite sprite-option_delete" title="{$l_delete}">
					<xsl:attribute name="href"><xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan_prompt=1')"/><xsl:if test="$currobjmime='application/x-container'"><xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,
                                           ';r=',/document/context/object/@id)"/></xsl:if></xsl:attribute>
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
	<xsl:template name="testbodysxml">
		<xsl:call-template name="wfcheckjs"/>
		<a href="javascript:void()" onclick="return wfcheck();">
			<img src="{$skimages}option_wfcheck.png" border="0" alt="{$i18n/l/Test_body_xml}" title="{$i18n/l/Test_body_xml}" align="left" width="32" height="19"/>
		</a>
	</xsl:template>
	<xsl:template name="prettyprint">
		<xsl:param name="ppmethod" select="'htmltidy'"/>
		<xsl:call-template name="prettyprintjs">
			<xsl:with-param name="ppmethod" select="$ppmethod"/>
		</xsl:call-template>
		<a href="javascript:void()" onclick="return prettyprint();">
			<img src="{$skimages}option_prettyprint.png" border="0" alt="{$i18n/l/Prettyprint}" title="{$i18n/l/Prettyprint}" align="left" width="32" height="19"/>
		</a>
	</xsl:template>
	<xsl:template name="xmlhttpjs">
		<!--    function getXMLHTTPObject() {
        var xmlhttp=false;
        /*@cc_on @*/
        /*@if (@_jscript_version &gt;= 5)
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
    }-->
	</xsl:template>
	<xsl:template name="wfcheckjs">
		<script type="text/javascript">
			<xsl:call-template name="xmlhttpjs"/>
				var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?test_wellformedness=1')"/>";
<!--        function wfcheck() {
            var xmlhttp = getXMLHTTPObject();
            var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?test_wellformedness=1')"/>";
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not check well-formedness.")
                    }
                    else {
                        alert(xmlhttp.responseText + '\n');
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('test_wellformedness=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }-->
		</script>
	</xsl:template>
	<xsl:template name="prettyprintjs">
		<xsl:param name="ppmethod" select="'htmltidy'"/>
		<script type="text/javascript">
			<xsl:call-template name="xmlhttpjs"/>
					var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?', $ppmethod, '=1')"/>";
					var ppmethod = "<xsl:value-of select="$ppmethod"/>";
        <!--function prettyprint() {
            var xmlhttp = getXMLHTTPObject();
            var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?', $ppmethod, '=1')"/>";
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not pretty print.")
                    }
                    else {
                        document.eform.body.value=xmlhttp.responseText;
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('<xsl:value-of select="$ppmethod"/>=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }-->
		</script>
	</xsl:template>
	<xsl:template name="testlocationjs">
		<xsl:param name="event"/>
		<xsl:param name="obj_type"/>
		<script type="text/javascript">
			<!-- returns objtype query param value -->
			<!--    function getObjTypeFromQuery() {
        var str = document.location.search;
        var searchToken = "objtype=";
        var fromPos = str.indexOf(searchToken) + searchToken.length;
        var subStr = str.substring(fromPos, str.length);
        return(subStr.substring(0, subStr.indexOf(";")));
    }-->
			<!-- called for events create and edit -->
			<xsl:choose>
				<xsl:when test="$event='create'">
            var obj = getObjTypeFromQuery();
            </xsl:when>
				<xsl:otherwise>
            var obj = '<xsl:value-of select="$obj_type"/>';
            </xsl:otherwise>
			</xsl:choose>
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
		<script type="text/javascript" language="javascript" src="{$ximsroot}json/json-min.js"/>
		<script type="text/javascript" language="javascript" src="{$ximsroot}scripts/test_location.js"/>
	</xsl:template>
	<xsl:template name="tr-minify">
		<xsl:call-template name="mk-tr-checkbox">
			<xsl:with-param name="title-i18n" select="'minify'"/>
			<xsl:with-param name="xpath" select="'attributes/minify'"/>
		</xsl:call-template>
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
	<xsl:template name="mk-tr-textfield">
		<xsl:param name="title-i18n" select="''"/>
		<xsl:param name="title" select="$title-i18n"/>
		<xsl:param name="name" select="translate($title, &uc;, &lc;)"/>
		<xsl:param name="size" select="'60'"/>
		<xsl:param name="maxlength" select="'127'"/>
		<xsl:param name="xpath" select="'/..'"/>
		<tr>
			<td valign="top">
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
				<input type="text" size="{$size}" name="{$name}" value="{dyn:evaluate($xpath)}" class="text" maxlength="{$maxlength}"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('{$title}')" class="doclink">(?)
        </a>
			</td>
		</tr>
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
	<!--	Templates from stylesheets/common.xsl-->
	<xsl:template name="head_default">
		<xsl:param name="mode"/>
		<xsl:param name="calendar" select="false()"/>
		<xsl:param name="questionnaire" select="false()"/>
		<xsl:param name="ap-pres" select="false()"/>
		<head>
			<title>
				<xsl:choose>
					<xsl:when test="$mode='create'">
						<xsl:call-template name="title-create"/>
					</xsl:when>
					<xsl:when test="$mode='edit'">
						<xsl:call-template name="title-edit"/>
					</xsl:when>
					<xsl:when test="$mode='delete'">
						<xsl:call-template name="title-delete"/>
					</xsl:when>
					<xsl:when test="$mode='move'">
						<xsl:call-template name="title-move"/>
					</xsl:when>
					<xsl:when test="$mode='mg-acl'">
						<xsl:call-template name="title-mg-acl"/>
					</xsl:when>
					<xsl:when test="$mode='user'">
						<xsl:call-template name="title-userpage"/>
						<!-- <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/userpages.css" type="text/css"/> -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="title"/>
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:call-template name="css">
				<xsl:with-param name="jquery-ui-smoothness">true</xsl:with-param>
				<xsl:with-param name="fg-menu">true</xsl:with-param>
				<xsl:with-param name="questionnaire" select="$questionnaire"/>
				<xsl:with-param name="ap-pres" select="$ap-pres"/>
				<xsl:with-param name="calendar">
					<xsl:value-of select="$calendar"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="script_head">
				<xsl:with-param name="jquery">true</xsl:with-param>
				<xsl:with-param name="fg-menu">true</xsl:with-param>
				<xsl:with-param name="calendar">
					<xsl:value-of select="$calendar"/>
				</xsl:with-param>
			</xsl:call-template>
		</head>
	</xsl:template>
	<xsl:template name="title-create">
		<xsl:value-of select="$i18n/l/create"/>&#160;
		<xsl:value-of select="$objtype"/>&#160;
		<xsl:value-of select="$i18n/l/in"/>&#160;
		<xsl:value-of select="$absolute_path"/> - XIMS
	</xsl:template>
	<xsl:template name="title-edit">
		<xsl:value-of select="$i18n/l/edit"/>&#160;
		<xsl:value-of select="$objtype"/>&#160;'
		<xsl:value-of select="title"/>'&#160;
		<xsl:value-of select="$i18n/l/in"/>&#160;
		<xsl:value-of select="$parent_path"/> - XIMS
	</xsl:template>
	<xsl:template name="title-move">
		<xsl:value-of select="$i18n/l/Move_object"/>&#160;<xsl:value-of select="location"/> - XIMS
	</xsl:template>
	<xsl:template name="title-delete">
		<xsl:value-of select="$i18n/l/ConfDeletion1"/>&#160;<xsl:value-of select="$objtype"/>&#160;'<xsl:value-of select="title"/>'&#160;<xsl:value-of select="$i18n/l/ConfDeletion2"/>&#160; - XIMS
	</xsl:template>
	<xsl:template name="title-mg-acl">
		<xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="object/title"/>' - XIMS
	</xsl:template>
	<xsl:template name="title-userpage">
		<xsl:value-of select="name"/> - XIMS
	</xsl:template>
	<xsl:template name="title">
		<xsl:value-of select="title"/> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - <xsl:call-template name="department_title"/> - XIMS
	</xsl:template>
	<xsl:template name="css">
		<xsl:param name="jquery-ui" select="false()"/>
		<xsl:param name="jquery-ui-smoothness" select="false()"/>
		<xsl:param name="fg-menu" select="false()"/>
		<xsl:param name="questionnaire" select="false()"/>
		<xsl:param name="ap-pres" select="false()"/>
		<xsl:param name="calendar" select="false()"/>
		<!--<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/defcontmin.css" type="text/css"/>-->
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/2punkt0.css" type="text/css"/>
		<!-- <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/rest.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/common.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/sprites.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/menu.css" type="text/css"/>
		<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/content.css" type="text/css"/>-->
		<xsl:if test="$jquery-ui-smoothness">
			<!--<link rel="stylesheet" href="{$jquery_dir}themes/smoothness/ui.all.css" type="text/css"/>-->
			<link rel="stylesheet" href="{$jquery_dir}themes/smoothness/ui.theme.css" type="text/css"/>
			<link rel="stylesheet" href="{$jquery_dir}themes/smoothness/ui.dialog.css" type="text/css"/>
			<link rel="stylesheet" href="{$jquery_dir}themes/smoothness/ui.resizable.css" type="text/css"/>
			<link rel="stylesheet" href="{$jquery_dir}themes/smoothness/ui.core.css" type="text/css"/>
			<!--<link rel="stylesheet" href="{$jquery_dir}themes/smoothness/ui.datepicker.css" type="text/css"/>-->
		</xsl:if>
		<xsl:if test="$fg-menu">
			<link rel="stylesheet" href="{$jquery_dir}fg-menu/fg.menu.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$questionnaire">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/questionnaire.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$ap-pres">
			<link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/axpointpresentation.css" type="text/css"/>
		</xsl:if>
		<xsl:if test="$calendar">
			<link rel="stylesheet" type="text/css" media="all" href="{$ximsroot}jscalendar-1.0/calendar-blue.css" title="winter"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="script_head">
		<xsl:param name="jquery" select="false()"/>
		<xsl:param name="fg-menu" select="false()"/>
		<!--<xsl:param name="data-tables" select="false()"/>-->
		<xsl:param name="calendar" select="false()"/>
		<xsl:if test="$jquery">
			<script src="{$jquery_dir}jquery" type="text/javascript"/>
			<script src="{$jquery_dir}jquery-ui" type="text/javascript"/>
			<script src="{$jquery_dir}jquery-ui-i18n.js" type="text/javascript"/>
		</xsl:if>
		<xsl:if test="$fg-menu">
			<script language="javascript" src="{$jquery_dir}fg-menu/fg.menu-min.js" type="text/javascript"/>
		</xsl:if>
		<xsl:if test="$calendar">
			<script type="text/javascript">
				var calendarSelector = '<xsl:value-of select="$i18n/l/Date_selector"/>';
				var imageFolder = '<xsl:value-of select="$skimages"/>';
			</script>
			<xsl:call-template name="jscalendar_scripts"/>
		</xsl:if>
		<script src="{$ximsroot}skins/{$currentskin}/scripts/2punkt0.js" type="text/javascript">
			<xsl:text>&#160;</xsl:text>
		</script>
		<script src="{$ximsroot}scripts/default.js" type="text/javascript">
			<xsl:text>&#160;</xsl:text>
		</script>
		<!--<script src="{$ximsroot}skins/{$currentskin}/scripts/2punkt0-all-min.js" type="text/javascript"/>-->
	</xsl:template>
	<xsl:template name="script_bottom">
		<!-- defmin.js generated by xims_minimize_jscss.pl
    <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    -->
		<script src="{$ximsroot}skins/{$currentskin}/scripts/defmin.js" type="text/javascript">
			<xsl:text>&#160;</xsl:text>
		</script>
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
		<p>
			<form action="{$xims_box}{$goxims}/bookmark" name="eform">
				<p>
					<label for="input-path">
						<xsl:value-of select="$i18n/l/Path"/>
					</label>: 
            <input type="text" name="path" size="40" class="text" id="input-path"/>
					<xsl:text>&#160;</xsl:text>
					<a href="javascript:openDocWindow('Bookmark')" class="doclink">(?)</a>
					<xsl:text>&#160;</xsl:text>
					<a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$stdhome}?contentbrowse=1;sbfield=eform.path')" class="doclink">
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
				<input type="submit" class="ui-state-default ui-corner-all fg-button" name="create" value="{$i18n/l/create}"/>
			</form>
		</p>
	</xsl:template>
</xsl:stylesheet>
