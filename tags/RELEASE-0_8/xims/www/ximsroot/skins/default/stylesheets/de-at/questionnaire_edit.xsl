<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:import href="../questionnaire_edit.xsl"/>
    <xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
    
<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="questionnaire-head-edit"/>
    <body>
        <p class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST" name="eform">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-location-edit"/>
                    <xsl:call-template name="tr-questionnaire-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>
</xsl:stylesheet>
