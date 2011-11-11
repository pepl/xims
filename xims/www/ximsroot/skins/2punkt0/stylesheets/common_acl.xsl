<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_acl.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml">
		
	<xsl:template name="grant-form">
		<xsl:param name="multiple" select="false()"/>
		<form action="{$xims_box}{$goxims_content}" method="get">
			<xsl:choose>
			<xsl:when test="$multiple">
				<xsl:apply-templates select="/document/objectlist/object" />
				<p><xsl:value-of select="$i18n/l/Notice"/>: <xsl:value-of select="$i18n/l/ACLNotice"/></p>
				<br class="clear"/><br/>
			</xsl:when>	
			<xsl:otherwise>
				<input type="hidden" name="multiselect" value="{/document/context/object/@id}"/>
			</xsl:otherwise>
			</xsl:choose>
			<h2><xsl:value-of select="$i18n/l/Grant_newprivs"/></h2>
		<xsl:if test="$multiple or (not($multiple) and /document/object_types/object_type[@id=/document/context/object/object_type_id]/is_fs_container)">				
		<p>
			<label for="recacl"><xsl:value-of select="$i18n/l/GrantRecursive"/></label> 
			<input type="checkbox" name="recacl" id="recacl" value="1" class="checkbox"/>
		</p>
		</xsl:if>
		
		<p>
			<label for="grantees" class=""><xsl:value-of select="$i18n/l/Name"/>&#160;<xsl:value-of select="$i18n/l/of"/>&#160;<xsl:value-of select="$i18n/l/User"/>&#160;<xsl:value-of select="$i18n/l/or"/>&#160;<xsl:value-of select="$i18n/l/Role"/>&#160;</label>&#160;
			<input name="grantees" type="text" value="" id="grantees"/>&#160;&#160;
			(<xsl:value-of select="$i18n/l/SeparateUsers"/>)
		</p>
	
		<xsl:call-template name="acl-checkboxes"/>	
		
		<button class="button" type="submit">
			<xsl:attribute name="name">aclgrantmultiple</xsl:attribute>
			<xsl:value-of select="$i18n/l/save"/>
		</button>
		<input name="userid" type="hidden" >
			<xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
		</input>
		<input name="id" type="hidden" value="{/document/context/object/@id}"/>
		<xsl:call-template name="rbacknav"/>
		&#160;
		<button class="button" type="submit">
			<xsl:attribute name="name">aclrevokemultiple</xsl:attribute>
			<xsl:value-of select="$i18n/l/Revoke_grants"/>
		</button>
	
	</form>
	<br/>
					<form action="{$xims_box}{$goxims_content}" method="get">
						<p><button type="submit" name="cancel"><xsl:value-of select="$i18n/l/cancel"/></button></p>
					</form>
	</xsl:template>	
	
	<xsl:template name="acl-checkboxes">
		<div>
			<xsl:attribute name="id">buttonset_<xsl:value-of select="@id"/>_<xsl:value-of select="/document/context/object/@id"/></xsl:attribute>
			
			<input type="checkbox" name="acl_view"><xsl:attribute name="id"><xsl:value-of select="concat('acl_view_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_view_',@id,'_',/document/context/object/@id)"/></xsl:attribute>View</label>
			
			<input type="checkbox" name="acl_write"><xsl:attribute name="id"><xsl:value-of select="concat('acl_write_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_write_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Write</label>
			
			<input type="checkbox" name="acl_create"><xsl:attribute name="id"><xsl:value-of select="concat('acl_create_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_create_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Create</label>
			
			<input type="checkbox" name="acl_delete"><xsl:attribute name="id"><xsl:value-of select="concat('acl_delete_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_delete_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Delete</label>
			
			<input type="checkbox" name="acl_copy"><xsl:attribute name="id"><xsl:value-of select="concat('acl_copy_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_copy_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Copy</label>

			<input type="checkbox" name="acl_move"><xsl:attribute name="id"><xsl:value-of select="concat('acl_move_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_move_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Move</label>
					
			<input type="checkbox" name="acl_publish"><xsl:attribute name="id"><xsl:value-of select="concat('acl_publish_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_publish_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Publish</label>
			
			<input type="checkbox" name="acl_grant"><xsl:attribute name="id"><xsl:value-of select="concat('acl_grant_',@id,'_',/document/context/object/@id)"/></xsl:attribute></input>
			<label><xsl:attribute name="for"><xsl:value-of select="concat('acl_grant_',@id,'_',/document/context/object/@id)"/></xsl:attribute>Grant</label>
		</div>
		<script type="text/javascript">
			$(document).ready(function() {
				$('#buttonset_<xsl:value-of select="@id"/>_<xsl:value-of select="/document/context/object/@id"/>').buttonset();
			});
		</script>
	</xsl:template>	
</xsl:stylesheet>