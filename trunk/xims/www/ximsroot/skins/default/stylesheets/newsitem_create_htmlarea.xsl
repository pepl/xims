<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="document_create_htmlarea.xsl"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create_htmlarea"/>
    <body onLoad="document.eform['abstract'].value=''; document.eform.name.focus()">
        <p class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-leadimage-create"/>
                    <xsl:call-template name="tr-body-create_htmlarea"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <tr>
                        <td colspan="3">
                            <xsl:call-template name="markednew"/>
                        </td>
                    </tr>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </p>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="without-wysiwyg"/>
    </body>
</html>
</xsl:template>
</xsl:stylesheet>
