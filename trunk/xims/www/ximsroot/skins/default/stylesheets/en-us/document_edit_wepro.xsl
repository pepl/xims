<?xml version="1.0" encoding="iso-8859-1"?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.w3.org/TR/xhtml1/strict">
    <xsl:import href="common.xsl"/>
    <xsl:variable name="bodycontent">
        <xsl:call-template name="body"/>
        </xsl:variable>
        <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
      <xsl:call-template name="head-edit_wepro"/>
    <body>
        <p class="edit">
                       <xsl:call-template name="table-edit_wepro"/>
                    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST" name="eform">
                            <table border="0" width="98%">
                                <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:call-template name="tr-body-edit_wepro"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                                <tr>
                                        <td colspan="3">
                                            <xsl:call-template name="markednew"/>
                                        </td>
                                </tr>
                                <tr>
                                        <td colspan="3">
                                            <xsl:call-template name="expandrefs"/>
                                        </td>
                                </tr>
                </table>
                            <xsl:call-template name="saveedit"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

<xsl:template name="body">
    <xsl:apply-templates select="/document/context/object/body"/>
</xsl:template>

</xsl:stylesheet>