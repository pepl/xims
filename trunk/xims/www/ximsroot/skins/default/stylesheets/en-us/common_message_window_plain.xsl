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
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/">
<html>
  <head>
      <title><xsl:value-of select="/document/context/session/error_msg|/document/context/session/warning_msg|/document/context/session/message"/></title>
    <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
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
        <a href="javascript:window.close()">close window</a>
    </p>
  </body>
</html>
</xsl:template>
</xsl:stylesheet>
