<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: gallery_edit.xsl 2239 2009-08-03 09:35:54Z haensel $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="gallery_common.xsl"/>
<xsl:import href="common.xsl"/>
<xsl:import href="container_common.xsl"/>

<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit"/>
                    <xsl:call-template name="markednew"/>
											<xsl:call-template name="tr-abstract-edit"/>
											<xsl:call-template name="form-obj-specific"/>
											<xsl:call-template name="grantowneronly"/>
                </table>
                <xsl:call-template name="saveedit"/>
            </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
    </body>
</html>
</xsl:template>

</xsl:stylesheet>
