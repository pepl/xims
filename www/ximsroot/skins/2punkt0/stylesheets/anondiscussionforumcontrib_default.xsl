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

    <xsl:import href="common.xsl"/>
    <xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head_default"/>
      <body>
        <xsl:call-template name="header">
          <xsl:with-param name="nooptions">true</xsl:with-param>
          <xsl:with-param name="nostatus">true</xsl:with-param>
        </xsl:call-template>

        <div id="content-container">
        <xsl:call-template name="forum"/>
        </div>
      </body>
    </html>
</xsl:template>

<xsl:template name="forum">
	<h1 id="create-title" class="small-headings">
		<xsl:value-of select="$i18n/l/Topic"/>&#160;'<xsl:value-of select="title"/>'&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$i18n/l/Discussionforum"/>&#160;'<xsl:value-of select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/title"/>'
		</h1>
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
            <!--<table>-->
                <xsl:apply-templates select="/document/objectlist/object"/>
            <!--</table>-->
        </p>
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
                  <span><xsl:value-of select="$i18n/l/delete"/></span>
                  </a>
          </xsl:if>
          <br/>
          
          </p>
</xsl:template>

<!--<xsl:template name="replyform">
    <a name="reply"/>
    <form name="eform"
          action="{$xims_box}{$goxims_content}{$absolute_path}?objtype=AnonDiscussionForumContrib"
          method="post"
          onsubmit="return checkFields()">
      <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
      <table class="forumbox">
        <tr>
          <td class="forumhead" colspan="2"><xsl:value-of select="$i18n/l/reply"/></td>
        </tr>
        <tr>
          <td class="forumcontent"><xsl:value-of select="$i18n/l/Title"/> *</td>
          <td><input class="foruminput" type="text" name="title" size="60" value="Re: {title}"/></td>
        </tr>
        <tr>
          <td class="forumcontent"><xsl:value-of select="$i18n/l/Author"/> *</td>
          <td><input class="foruminput" type="text" name="author" size="60"/></td>
        </tr>
        <tr>
          <td class="forumcontent"><xsl:value-of select="$i18n/l/Email"/>:</td>
          <td><input class="foruminput" type="text" name="email" size="60"/></td>
        </tr>
        <tr>
          <td class="forumcontent"><xsl:value-of select="$i18n/l/Text"/> *</td>
          <td>
            <textarea class="foruminput" name="body" rows="10" cols="60"></textarea>
          </td>
        </tr>
      </table>
      <br />
      <p>
        <xsl:call-template name="saveaction"/>
      </p>
    </form>
    <div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
</xsl:template>-->

<xsl:template match="body">
    <xsl:call-template name="br-replace">
        <xsl:with-param name="word" select="."/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
