<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="document_create_htmlarea.xsl"/>
<xsl:import href="document_common.xsl"/>
<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <head>
    <xsl:call-template name="common-head">
        <xsl:with-param name="mode">create</xsl:with-param>
        <xsl:with-param name="calendar" select="true()" />
        <xsl:with-param name="htmlarea" select="true()" />
    </xsl:call-template>
    </head>
    <body onLoad=" document.eform['abstract'].value=''; initEditor(); document.eform.name.focus()">
                <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-subtitle"/>
                    <xsl:call-template name="tr-vlsubjects-create"/>
                    <xsl:call-template name="tr-vlauthors-create"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="tr-vlkeywords-create"/>
                    <xsl:call-template name="tr-body-create_htmlarea"/>
                    <tr>
                        <td colspan="3">
                            <xsl:call-template name="testbodysxml"/>
                            <xsl:call-template name="prettyprint"/>
                        </td>
                    </tr>
                    <xsl:call-template name="trytobalance"/>
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="expandrefs"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>
                    <xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
    </body>
</html>
</xsl:template>

</xsl:stylesheet>
