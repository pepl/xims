<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: docbookxml_edit_codemirror.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

	<xsl:import href="docbookxml_edit.xsl"/>
	<xsl:import href="codemirror_scripts.xsl"/>

	<xsl:param name="codemirror" select="true()"/>	
	<xsl:param name="cm_mode">xml</xsl:param>
	 <xsl:param name="selEditor" >code</xsl:param>
	
</xsl:stylesheet>
