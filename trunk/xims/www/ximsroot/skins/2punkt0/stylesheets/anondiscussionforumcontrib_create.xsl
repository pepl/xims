<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforumcontrib_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="common.xsl"/>
  <xsl:import href="../../../stylesheets/anondiscussionforum_common.xsl"/>

  <xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head-create_discussionforum"/>
      <body onload="document.eform.body.value='';document.eform.title.focus()"
            margintop="0"
            marginleft="0"
            marginwidth="0"
            marginheight="0"
            background="{$skimages}body_bg.png">

        <xsl:call-template name="forum"/>

        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>


<xsl:template name="head-create_discussionforum">
    <head>
        <title><xsl:value-of select="$i18n/l/Create_topic"/> - XIMS</title>
        <xsl:call-template name="css"/>
    </head>
</xsl:template>

<xsl:template name="forum">
    <form action="{$xims_box}{$goxims_content}{$parent_path}?objtype={$objtype}" name="eform" method="post" onsubmit="return checkFields();" style="margin-top:0px;" >
      <input type="hidden" name="objtype" value="{$objtype}"/>
      <table border="0" width="620" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
        <tr>
          <td valign="top" class="forumhead" colspan="2"><xsl:value-of select="$i18n/l/Create_topic"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent" width="80"><span class="compulsory"><xsl:value-of select="$i18n/l/Topic"/></span>:</td>
          <td><input type="text" name="title" size="60"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><span class="compulsory"><xsl:value-of select="$i18n/l/Author"/></span>:</td>
          <td><input type="text" name="author" size="30"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Email"/>:</td>
          <td><input type="text" name="email" size="30"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Coauthor"/>:</td>
          <td><input type="text" name="coauthor" size="30"/></td>
        </tr>
        <tr>
          <td valign="middle" class="forumcontent"><xsl:value-of select="$i18n/l/Coauthor"/>&#160;<xsl:value-of select="$i18n/l/Email"/>:</td>
          <td><input type="text" name="coemail" size="30"/></td>
        </tr>
        <tr>
          <td valign="top" class="forumcontent" style="padding-top:3px;"><span class="compulsory"><xsl:value-of select="$i18n/l/Text"/></span>:</td>
          <td>
            <textarea name="body" rows="20" cols="50"><xsl:text>&#160;</xsl:text></textarea>
          </td>
        </tr>
      </table>
      <br />
      <p>
        <xsl:call-template name="saveaction"/>
      </p>
    </form>
<!--    <xsl:call-template name="cancelaction"/>
 					</div>-->
					<div class="cancel-save">
						<xsl:call-template name="cancelcreateform">
							<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
					</div>
<!--				</div>-->
</xsl:template>

</xsl:stylesheet>
