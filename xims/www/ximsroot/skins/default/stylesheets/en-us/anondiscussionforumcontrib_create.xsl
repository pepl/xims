<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
        xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:import href="../anondiscussionforum_common.xsl"/>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create_discussionforum"/>
    <body onLoad="document.eform.body.value='';document.eform.name.focus()" margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png">
        <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" method="POST">
            <table border="0" width="770" style="border: 1px solid #888888; margin-left: 10px; margin-top: 10px; padding: 0px" cellpadding="3" cellspacing="0">
                <tr>
                    <td valign="top" class="forumhead" colspan="2">Create new topic</td>
                </tr>
                <tr>
                    <td valign="middle" class="forumcontent" width="80">Topic:</td>
                    <td><input type="text" name="title" size="60"/></td>
                </tr>
                <tr>
                    <td valign="middle" class="forumcontent">Author:</td>
                    <td><input type="text" name="author" size="40"/></td>
                </tr>
                <tr>
                    <td valign="middle" class="forumcontent">Email:</td>
                    <td><input type="text" name="email" size="40"/></td>
                </tr>
                <tr>
                    <td valign="middle" class="forumcontent">Co-Author:</td>
                    <td><input type="text" name="coauthor" size="40"/></td>
                </tr>
                <tr>
                    <td valign="middle" class="forumcontent">Co-Author-Email:</td>
                    <td><input type="text" name="coemail" size="40"/></td>
                </tr>
                <tr>
                    <td valign="top" class="forumcontent" style="padding-top:3px;">Text:</td>
                    <td>
                        <textarea name="body" rows="20" cols="70"><xsl:text>&#160;</xsl:text></textarea>
                        <input type="hidden" name="parid" value="{@document_id}"/>
                        <input type="hidden" name="store" value="1"/><br/>
                    </td>
                </tr>
            </table>
            <br />
            <p style="margin-left:380px;">
                <input type="submit" name="submit" value=" Save " class="control"/>
            </p>   
          </form>
          <xsl:call-template name="cancelaction"/>
    </body>
</html>
</xsl:template>
</xsl:stylesheet>
