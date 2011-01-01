<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: document_edit.xsl 1902 2008-01-25 12:17:28Z haensel $
-->


<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
                
  <xsl:import href="common.xsl"/>

  <!-- XXX c&p :-( -->

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


  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="common-head">
        <xsl:with-param name="mode" select="'prepare-mail'"/>
      </xsl:call-template>
      <body>
        <div class="edit">
          <form action="{$xims_box}{$goxims_content}?id={@id}"
                name="eform" 
                method="post">
            <div style="position: absolute; right: 11px;">
              <input type="submit" name="send_as_mail" value="{$i18n/l/Send}" class="control"/>  
              <input type="submit" name="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C"/>
            </div>
            <table border="0" 
                   width="98%">
              <xsl:call-template name="mk-tr-textfield">
                <xsl:with-param name="title" select="'To'"/>
              </xsl:call-template>
              <xsl:call-template name="mk-tr-textfield">
                <xsl:with-param name="title" select="'Reply-To'"/>
              </xsl:call-template>
              <xsl:call-template name="mk-tr-textfield">
                <xsl:with-param name="title" select="'Subject'"/>
              </xsl:call-template>
              <xsl:call-template name="mk-tr-checkbox">
                <xsl:with-param name="title-i18n" select="'Include_images'"/>
                <xsl:with-param name="title" select="'mailer_include_images'"/>
              </xsl:call-template>
            </table>
          </form>
        </div>
        <br />
        <div style="margin: auto; text-align: center;">
          <p><xsl:value-of select="$i18n/l/Preview"/>:</p>
          <iframe name="Mail Preview" 
                  src="{$published_path}"
                  width="750px" 
                  height="500px" 
                  scrolling="yes" 
                  marginheight="2" 
                  marginwidth="2" 
                  frameborder="1">
            <p>No iframes?</p>
          </iframe>
        </div>      
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
