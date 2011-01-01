<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="common_edit_bxe.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit_bxe"/>
    <body onload="bxe_start('{$goxims_content}?id={@id};bxeconfig=1');">
        <div id="main" bxe_xpath="/slideshow" />
    </body>
</html>
</xsl:template>

</xsl:stylesheet>
