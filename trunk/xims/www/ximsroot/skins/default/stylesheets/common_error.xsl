<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_error.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

    <xsl:template match="/">
    <html>
        <xsl:call-template name="head_default"/>
            <body>
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>
            
            <div id="content-container">
            <h1 class="redbg">
                <xsl:value-of select="$i18n/l/Error"/></h1>
                <p>
                <xsl:value-of select="/document/context/session/error_msg"/>
            </p>
              <xsl:if test="/document/context/session/verbose_msg != ''">
                <div class="error_details">
                    <p><strong><xsl:value-of select="$i18n/l/Error_details"/>:</strong></p>
                    <pre>
                        <xsl:value-of select="/document/context/session/verbose_msg" />
                    </pre>
                </div>
              </xsl:if>
              <br/>
            <p>
            <button type="button" class="button" onclick="javascript:history.go(-1)"><xsl:value-of select="$i18n/l/Back"/></button>
            </p>
            </div>
            <xsl:call-template name="script_bottom"/>
      </body>
    </html>
    </xsl:template>
    
    <xsl:template name="title">
        <xsl:value-of select="$i18n/l/Error"/>: <xsl:value-of select="/document/context/session/error_msg"/>
    </xsl:template>
</xsl:stylesheet>
