<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: image_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="file_create.xsl"/>

<xsl:template name="tr-file-create">
<div id="tr-file">
	<div id="label-file"><label for="input-file">
			<span class="compulsory"><xsl:value-of select="$i18n/l/Image"/></span>
	</label></div>
            <input type="file" name="file" size="49" class="text input" id="input-file" />
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
  </div>
</xsl:template>

</xsl:stylesheet>
