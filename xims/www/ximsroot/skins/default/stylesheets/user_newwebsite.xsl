<?xml version="1.0" encoding="utf-8" ?>

<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_newwebsite.xsl 2216 2009-06-17 12:16:25Z haensel $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>

  <xsl:template match="/document">
    <xsl:apply-templates select="context/session/user"/>
  </xsl:template>

  <xsl:template match="/document/context/session/user">
    <html>
      <xsl:call-template name="head_default">
		<xsl:with-param name="mode">user</xsl:with-param>
      </xsl:call-template>
      <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
        <div id="content-container">
          <xsl:value-of select="/document/context/session/message" disable-output-escaping="yes"/>
          <h1 class="bluebg">
            <xsl:value-of select="$i18n/l/GenerateWebsite"/>!
          </h1>
          
          <form name="userEdit" action="{$xims_box}{$goxims}/user" method="post" id="create-edit-form">
            <xsl:call-template name="input-token"/>
            <div  class="form-div block">
              <div>
                <div class="label-med">
                  <label for="input-path"><xsl:value-of select="$i18n/l/Path"/> :</label>
                </div>
                <input id="input-path" type="text" size="40" value="/uniweb/" name="path"/>
              </div>
              
              <div>
                <div class="label-med">
                  <label for="input-title"><xsl:value-of select="$i18n/l/Title"/> :</label>
                </div>
                <input id="input-title" type="text" size="40" name="title"/>
              </div>
              
              <div>
                <div class="label-med">
                  <label for="input-shortname"><xsl:value-of select="$i18n/l/Shortname"/> :</label>
                </div>
                <input id="input-shortname" type="text" size="40" name="shortname"/>
              </div>
              
              <div>
                <div class="label-med">
                  <label for="input-owner"><xsl:value-of select="$i18n/l/SiteAdmin"/> :</label>
                </div>
                <input id="input-owner" type="text" size="40" name="owner"/>
              </div>
              
              <div>
                <div class="label-med">
                  <label for="input-role"><xsl:value-of select="$i18n/l/Role"/>  :</label>
                </div>
                <input id="input-role" type="text" size="40" name="role"/>
              </div>
              
              <div>
                <div class="label-med">
                  <label for="input-grantees"><xsl:value-of select="$i18n/l/FurtherGrantees"/> :</label>
                </div>
                <input id="input-grantees" type="text" size="40" name="grantees"/>
                <br class="clear"/>
              </div>

              <div>
                <div class="label">
                  <label for="input-nobm"><xsl:value-of select="$i18n/l/NoStdBookmark"/></label>
                </div>
                <input id="input-nobm" type="checkbox" size="40" name="nobm" class="checkbox"/>
              </div>
              
            </div>
            <br/><br/>
            <button name="gen_website" type="submit" class="button">
			  <xsl:value-of select="$i18n/l/save"/>                     
            </button>
			&#160;
            <button name="cancel" type="button" class="button" onclick="javascript:history.go(-1)">
			<xsl:value-of select="$i18n/l/cancel"/></button>
            
          </form>
          
        </div>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
