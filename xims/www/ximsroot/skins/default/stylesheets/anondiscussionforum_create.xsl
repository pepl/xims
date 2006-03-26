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

<xsl:import href="../../../stylesheets/anondiscussionforum_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body onLoad="document.eform['abstract'].value=''; document.eform.name.focus()">
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" style="margin-top:0px;">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-create"/>
                    <xsl:call-template name="tr-description-create"/>
                    <xsl:call-template name="tr-keywords-create"/>
                    <xsl:call-template name="markednew"/>
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

<xsl:template name="tr-description-create">
    <tr>
        <td colspan="3">
            <xsl:value-of select="$i18n/l/Description"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('adf_description')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="abstract" rows="5" cols="100" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333 solid 1px;">&#160;</textarea>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
