<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: link_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template name="form-browse_target">
  <div id="tr-target">
    <div class="label-std">
      <label for="input-target">
      <xsl:value-of select="$i18n/l/target"/> *
      </label>
    </div>
    <input type="text" name="target" size="60" value="{symname_to_doc_id}" class="text" id="input-target"/>
    <!--<xsl:text>&#160;</xsl:text>
    <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>-->
    <xsl:text>&#160;</xsl:text>
    <a href="javascript:createDialog('{$xims_box}{$goxims_content}?id={/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}&amp;contentbrowse=1&amp;otfilter=Folder,DepartmentRoot,SiteRoot&amp;sbfield=eform.target','default-dialog','{$i18n/l/browse_target}')" class="button" id="buttonBrTarget">
        <xsl:value-of select="$i18n/l/browse_target"/>
    </a>
  </div>
</xsl:template>

<xsl:template name="form-locationtitletarget-create">
  <div class="form-div div-left">
    <xsl:call-template name="form-title"/>
    <xsl:call-template name="form-location-create"/>
    <xsl:call-template name="form-browse_target"/>
  </div>
</xsl:template>

<xsl:template name="form-locationtitletarget-edit">
<div class="form-div div-left">
  <xsl:call-template name="form-title"/>
     <xsl:call-template name="form-location-edit"/>
    <xsl:call-template name="form-browse_target"/>
    </div>
</xsl:template>

</xsl:stylesheet>
