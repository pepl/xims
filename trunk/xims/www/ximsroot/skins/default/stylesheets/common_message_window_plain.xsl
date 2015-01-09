<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_message_window_plain.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template match="/">
    <html>
      <head>
          <title><xsl:value-of select="/document/context/session/error_msg|/document/context/session/warning_msg|/document/context/session/message"/></title>
          <xsl:call-template name="css"/>
      </head>
      <body margintop="0" marginleft="0" marginwidth="0" marginheight="0">
        <p>
            <xsl:call-template name="message"/>
        </p>
        <pre>
            <xsl:value-of select="/document/context/session/verbose_msg" />
        </pre>
        <br/>
        <p>
            <a href="javascript:window.close()"><xsl:value-of select="$i18n/l/close_window"/></a>
        </p>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
</xsl:template>
</xsl:stylesheet>
