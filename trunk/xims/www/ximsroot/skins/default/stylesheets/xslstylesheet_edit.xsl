<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_xml"/>
                    <xsl:call-template name="tr-body-edit"/>
                    <xsl:call-template name="tr-keywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="markednew"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
    </body>
</html>
</xsl:template>

</xsl:stylesheet>
