<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: user_update.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<xsl:import href="common.xsl"/>

<xsl:template match="/document">
    <html>
    <xsl:call-template name="head_default"><xsl:with-param name="mode">user</xsl:with-param></xsl:call-template>

        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>
        
				<div id="content-container">
            <!--<xsl:value-of select="/document/context/session/message" disable-output-escaping="yes"/>-->
            <h1 class="bluebg">
            <xsl:value-of select="$i18n/l/GenerateWebsite"/>!
            </h1>
        <form name="userConfirm" action="{$xims_box}{$goxims}/user" method="get">
        <xsl:value-of select="/document/context/session/message" disable-output-escaping="yes"/>
<br/><br/>
                        <button name="exit" type="submit">
														<xsl:value-of select="$i18n/l/Done"/>                     
                        </button>
        </form>
        </div>
        <xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

