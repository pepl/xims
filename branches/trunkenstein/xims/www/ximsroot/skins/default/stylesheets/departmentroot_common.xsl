<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: departmentroot_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:template match="objectlist/object">
    <div class="tr-deptportlets-item">
      <div class="deptportlets-item">
        <a href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
      </div>
      <a href="{$goxims_content}{$absolute_path}?portlet_id={id};rem_portlet=1">
	      <img src="{$skimages}option_delete.png"
	            border="0"
	            width="37"
	            height="19"
	            alt="{$i18n/l/delete}"
	            title="{$i18n/l/delete}"
	      />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
