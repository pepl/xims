<?xml version="1.0" encoding="utf-8"?>
<!--
  # Copyright (c) 2002-2006 The XIMS Project.
  # See the file "LICENSE" for information and conditions for use, reproduction,
  # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
  # $Id$
  -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="common.xsl"/>
  <xsl:import href="../text_edit.xsl"/>
  <xsl:output method="html" 
              encoding="utf-8" 
              media-type="text/html" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              indent="no"/>

  <!-- not used for XIMS::Text -->
  <xsl:template name="tr-minify"/>

</xsl:stylesheet>
