<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_edit.xsl 1902 2008-01-25 12:17:28Z haensel $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
                
  <xsl:import href="create_common.xsl"/>

  <xsl:variable name="objecttype">
    <xsl:value-of select="/document/context/object/object_type_id"/>
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


<xsl:template name="create-content">
<div class="form-div block">
	<xsl:call-template name="form-nl-to"/>
	<xsl:call-template name="form-nl-replyto"/>
<xsl:call-template name="form-nl-subject"/>
<xsl:call-template name="form-includeimages"/>
</div>              
              <div style="margin: auto; text-align: center;">
          <p><xsl:value-of select="$i18n/l/Preview"/>:</p>
          <iframe name="MailPreview" id="mailpreview" src="{$published_path}">
                  <!--width="850px" 
                  height="500px" 
                  scrolling="yes" 
                  marginheight="2" 
                  marginwidth="2" 
                  frameborder="1">-->
            <p>No iframes?</p>
          </iframe>
        </div>      
</xsl:template>

<xsl:template name="title-create">
	<xsl:value-of select="$i18n/l/Email_Send"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
	<xsl:call-template name="objtype_name">
		<xsl:with-param name="ot_name">
			<xsl:value-of select="$objtype"/>
		</xsl:with-param>
	</xsl:call-template>
	&#160;'<xsl:value-of select="title"/>'&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
</xsl:template>

	<xsl:template name="heading">
		<div id="tab-container" class="ui-corner-top">
			<h1>
				<xsl:value-of select="$i18n/l/Email_Send"/>&#160;<!--<xsl:value-of select="$objtype"/>-->
				<xsl:call-template name="objtype_name">
					<xsl:with-param name="ot_name">
						<xsl:value-of select="$objtype"/>
					</xsl:with-param>
				</xsl:call-template>
				&#160;'<xsl:value-of select="title"/>'&#160;
			</h1>
		</div>
	</xsl:template>

<xsl:template name="cancelcreateform">
		<div class="cancel-save">
			<form class="cancelsave-form" action="{$xims_box}{$goxims_content}{$absolute_path}" method="post">
			<xsl:call-template name="save_jsbutton"/>			
			<!--<button type="submit" name="send_as_mail" value="{$i18n/l/Send}" accesskey="S">
				<xsl:value-of select="$i18n/l/Send"/>
			</button> -->
				<xsl:call-template name="rbacknav"/>
				<button type="submit" name="cancel_create" accesskey="C">
					<span class="text">
						<xsl:value-of select="$i18n/l/cancel"/>
					</span>
				</button>
			</form>
			&#160;<br/>
		</div>
	</xsl:template>
	
	<xsl:template name="save_jsbutton">
		<button class="save-button-js hidden" type="submit" name="submit_eform" accesskey="S" onclick="document.eform.send_as_mail.click(); return false">
			<span class="text">
				<xsl:value-of select="$i18n/l/Email_Send"/>
			</span>
		</button>
	</xsl:template>
	
	<xsl:template name="saveedit">
		<!--<input type="hidden" name="id" value="{@id}"/>
		<xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
			<input name="sb" type="hidden" value="date"/>
			<input name="order" type="hidden" value="desc"/>
		</xsl:if>
		<input type="submit" name="store" value="{$i18n/l/save}" class="save-button" accesskey="S"/>-->
		<button type="submit" name="send_as_mail" class="save-button" accesskey="S">
				<xsl:value-of select="$i18n/l/Send"/>
			</button> 
	</xsl:template>

<xsl:template name="form-nl-to">
  <div>
    <div class="label-std"><label for="input-nl-to"><xsl:value-of select="$i18n/l/Email_To"/></label></div>
    <input id="input-nl-to" name="to" size="60" type="text" class="text"/>
    <!--<xsl:text>&#160;</xsl:text>
    <a href="javascript:openDocWindow('To')" class="doclink">
    <xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/To"/></xsl:attribute>(?)</a>-->
  </div>
</xsl:template>

<xsl:template name="form-nl-replyto">
<div>
	<div class="label-std"><label for="input-nl-replyto"><xsl:value-of select="$i18n/l/Email_Reply-To"/></label></div>
	<input id="input-nl-replyto" name="reply-to" size="60" type="text" class="text"/>
	<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Reply-To')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Reply-To"/></xsl:attribute>(?)</a>-->
				</div>
</xsl:template>

<xsl:template name="form-nl-subject">
<div>
	<div class="label-std"><label for="input-nl-subject"><xsl:value-of select="$i18n/l/Email_Subject"/></label></div>
	<input id="input-nl-subject" name="subject" size="60" type="text" class="text"/>
	<!--<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Subject')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Subject"/></xsl:attribute>(?)</a>-->
				</div>
</xsl:template>

<xsl:template name="form-includeimages">
		<div>
				<div class="label">
					<label for="input-include_images"><xsl:value-of select="$i18n/l/Include_images"/></label>
				</div>
				<input name="mailer_include_images" type="checkbox" id="input-include_images" class="checkbox">
						<xsl:attribute name="checked">checked</xsl:attribute>
				</input>
				<!--<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('Include_images')" class="doclink">
					<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Include_images"/></xsl:attribute>
					(?)</a>-->
		</div>
	</xsl:template>
  
</xsl:stylesheet>
