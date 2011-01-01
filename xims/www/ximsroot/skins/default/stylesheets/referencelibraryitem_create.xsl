<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="post" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <input type="hidden" name="reftype" value="{$reftype}"/>
                <table border="0" width="98%">
                    <xsl:call-template name="markednew"/>
                    <xsl:call-template name="tr-vlauthors"/>
                    <xsl:call-template name="tr-vleditors"/>
                    <xsl:call-template name="tr-vlserials"/>
                    <xsl:apply-templates select="/document/reference_properties/reference_property">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="tr-abstract"/>
                    <xsl:call-template name="tr-notes"/>
                </table>
                <xsl:call-template name="saveaction"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

</xsl:stylesheet>
