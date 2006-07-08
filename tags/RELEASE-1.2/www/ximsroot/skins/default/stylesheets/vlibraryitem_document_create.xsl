<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="document_common.xsl"/>
<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform.body.value=''; document.eform['abstract'].value=''; document.eform.name.focus();">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-subtitle"/>
                    <xsl:call-template name="tr-subject-create"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="tr-body-create"/>
                    <tr>
                        <td colspan="3">
                            <xsl:call-template name="testbodysxml"/>
                            <xsl:call-template name="prettyprint"/>
                        </td>
                    </tr>
                    <xsl:call-template name="trytobalance"/>
                    <xsl:call-template name="tr-abstract-create"/>
                    <xsl:call-template name="markednew"/>
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
