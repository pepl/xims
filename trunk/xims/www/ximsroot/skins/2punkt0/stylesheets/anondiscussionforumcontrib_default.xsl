<?xml version="1.0" encoding="utf-8" ?>
<!--
 # Copyright (c) 2002-2009 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id: anondiscussionforumcontrib_default.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="view_common.xsl"/>
    <xsl:import href="anondiscussionforum_common.xsl"/>
    
    <xsl:template name="view-content">
			<xsl:call-template name="forum"/>
    </xsl:template>

<xsl:template name="forum">
    <p>
        <xsl:if test="parents/object[@document_id=/document/context/object/@parent_id]/object_type_id = object_type_id">
            <xsl:value-of select="$i18n/l/In_reply_to"/>
            '<a href="{concat($xims_box,$goxims_content,$parent_path)}">
                <xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/title"/>
            </a>'
            &#160;&#160;
            |
            &#160;&#160;
        </xsl:if>
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat($xims_box,$goxims_content)"/>
                <xsl:call-template name="path2topics"/>
            </xsl:attribute><xsl:value-of select="$i18n/l/Topic_overview"/>
        </a>
        &#160;&#160;
        |
        &#160;&#160;
        <a href="#reply"><xsl:value-of select="$i18n/l/reply"/></a>
    </p>

    <div class="forumbox">
            <div class="forumhead">
                <xsl:value-of select="title"/>
                (
                <xsl:choose>
                    <xsl:when test="attributes/email">
                        <a href="mailto:{attributes/email}"><xsl:value-of select="attributes/author"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="attributes/author"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="attributes/coemail">, <a href="mailto:{attributes/coemail}"><xsl:value-of select="attributes/coauthor"/></a>
                    </xsl:when>
                    <xsl:when test="attributes/coauthor">, <xsl:value-of select="attributes/coauthor"/>
                    </xsl:when>
                </xsl:choose>
                )
								&#160;
                <xsl:apply-templates select="creation_time" mode="datetime"/>
            </div>
        <div>
                <xsl:apply-templates select="body"/>
        </div>
    </div>

    <br />


    <br/>
    <xsl:if test="../../objectlist/object">
        <p>
            <xsl:value-of select="$i18n/l/Previous_replies"/>:<br/>
            </p>
                <xsl:apply-templates select="/document/objectlist/object"/>
    
    </xsl:if>

    <!--<xsl:call-template name="replyform"/>-->
    <xsl:call-template name="write-topic">
			<xsl:with-param name="reply">true</xsl:with-param>
		</xsl:call-template>
		<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>

</xsl:template>

<xsl:template match="/document/objectlist/object">
    <xsl:variable name="dataformat">
      <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
               <p>
               <xsl:call-template name="level-spacer">
									<xsl:with-param name="level" select="@level"/>
								</xsl:call-template>
          <a href="{$goxims_content}?id={@id}">
						<xsl:attribute name="class">
							sprite <xsl:value-of select="concat('sprite-list_',/document/data_formats/data_format[@id=$dataformat]/name)"/>
						</xsl:attribute>
          <xsl:value-of select="title"/></a>
          (<xsl:choose>
            <xsl:when test="attributes/email">
              <a href="mailto:{attributes/email}"><xsl:value-of select="attributes/author"/></a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="attributes/author"/>
            </xsl:otherwise>
          </xsl:choose>
          ,
          <xsl:apply-templates select="creation_timestamp" mode="datetime"/>)
              <xsl:if test="/document/context/object/user_privileges/delete">
                  &#160;<a href="{$goxims_content}?id={@id};delete_prompt=1;" class="sprite sprite-option_delete" title="{$i18n/l/delete}">
                  <span><xsl:value-of select="$i18n/l/delete"/></span>&#160;
                  </a>
          </xsl:if>
          <br/>
          
          </p>
</xsl:template>

<xsl:template name="level-spacer">
<xsl:param name="level" select="@level"/>
<xsl:call-template name="cttobject.status.spacer"/>
<xsl:if test="$level > 1">
	<xsl:call-template name="level-spacer">
		<xsl:with-param name="level" select="($level) -1"/>
	</xsl:call-template>
</xsl:if>
</xsl:template>

<xsl:template match="body">
    <xsl:call-template name="br-replace">
        <xsl:with-param name="word" select="."/>
    </xsl:call-template>
</xsl:template>

<!-- this objecttype can not be published, edited, etc. -> so we have to overwrite the options-menu -->
	<xsl:template name="options-menu-bar">
		<xsl:param name="createwidget" select="$createwidget"/>
		<!--<xsl:param name="mode"/>-->
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
				<xsl:call-template name="cttobject.dataformat">
					<xsl:with-param name="dfname" select="$dfname"/>
				</xsl:call-template>
				<h1>
					<xsl:value-of select="$i18n/l/Topic"/>&#160;'<xsl:value-of select="title"/>'&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$i18n/l/Discussionforum"/>&#160;'<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/title"/>'
				</h1>
				<xsl:call-template name="button.state.publish"/>
				&#160;&#160;&#160;
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
