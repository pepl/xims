<?xml version="1.0" encoding="utf-8" ?>

<!--
# Copyright (c) 2002-2009 The XIMS Project.
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
            
            
           <form name="userEdit" action="{$xims_box}{$goxims}/user" method="post" id="create-edit-form" style="margin: 10px;">
           	<h1>
            	<!--<xsl:value-of select="$i18n/l/GenerateWebsite"/>!-->
				Webseite generieren
            </h1>
           	<table cellspacing="2" cellpadding="2">
           <tr >
           	<td>
           <label for="input-path">Pfad  :</label>
           </td>
		   <td>
           <input id="input-path" type="text" size="40" name="path"/>
		   </td>
           </tr>
                     
           <tr>
           <td>
           <label for="input-title">Titel  :</label>
           </td>
		   <td>
           <input id="input-title" type="text" size="40" name="title"/>
		   </td>
           </tr>
           
           <tr>
           <td>
           <label for="input-shortname">Kurzname  :</label>
           </td>
		   <td>
           <input id="input-shortname" type="text" size="40" name="shortname"/>
		   </td>
           </tr>
           
           <tr>
           <td>
           <label for="input-owner">Webbeauftragter </label>
           </td>
		   <td>
           <input id="input-owner" type="text" size="40" name="owner"/>
		   </td>
           </tr>
           
           <tr>
           <td>
           <label for="input-role">Rolle  :</label>
           </td>
		   <td>
           <input id="input-role" type="text" size="40" name="role"/>
		   </td>
           </tr>
          
		   
           <tr>
           <td>
           <label for="input-grantees">Weitere Bevollmächtigte :</label>
           </td>
		   <td>
           <input id="input-grantees" type="text" size="40" name="grantees"/>
		   </td>
           </tr>
           
            </table>
           
           
            <div>
           <!--<div>-->
           <label for="input-nobm">Kein Standardlesezeichen anlegen</label>
           <!--</div>-->
           <input id="input-nobm" type="checkbox" size="40" name="nobm" class="checkbox"/>
           </div>
           
           <br/><br/>
                        <button name="gen_website" type="submit">
												Speichern		<!--<xsl:value-of select="$i18n/l/save"/>   -->                  
                        </button>
													&#160;
                        <button name="cancel" type="button" onclick="javascript:history.go(-1)">
										Abbrechen			<!--<xsl:value-of select="$i18n/l/cancel"/>-->
										</button>           
            </form>
            
            </div>
            <xsl:call-template name="script_bottom"/>
            </body>
            </html>
            </xsl:template>
            
</xsl:stylesheet>
