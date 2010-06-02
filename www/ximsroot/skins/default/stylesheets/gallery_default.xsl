<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: gallery_default.xsl 1652 2007-03-24 16:14:37Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="folder_default.xsl"/>
<xsl:import href="gallery_common.xsl"/>

<xsl:template name="message">
<div class="div-right" style="float:right"><a href="{$xims_box}{$goxims_content}{$absolute_path}/?preview=1"><xsl:value-of select="$i18n/l/Preview"/></a></div>
</xsl:template>

</xsl:stylesheet>
