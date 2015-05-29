<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<!--  <xsl:import href="document_common.xsl"/>
  <xsl:import href="vlibraryitem_common.xsl"/>
-->
<xsl:import href="create_common.xsl"/>
<xsl:import href="newsitem_common.xsl"/>
 <!-- <xsl:param name="selEditor" select="true()"/>-->
  
  <xsl:template name="create-content">
	<xsl:call-template name="form-locationtitle-create"/>
    <xsl:call-template name="form-leadimage-create"/>
    <br class="clear"/>
    <input type="hidden" name="proceed_to_edit" value="1"/>
  </xsl:template>

</xsl:stylesheet>
