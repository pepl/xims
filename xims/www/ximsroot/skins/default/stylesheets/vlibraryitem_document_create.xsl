<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_document_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<!--  <xsl:import href="document_common.xsl"/>
  <xsl:import href="vlibraryitem_common.xsl"/>
-->  <xsl:import href="create_common.xsl"/>
  
 <!-- <xsl:param name="selEditor" select="true()"/>-->
  
  <xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
    <br class="clear"/>
    <input type="hidden" name="proceed_to_edit" value="1"/>
  </xsl:template>

</xsl:stylesheet>
