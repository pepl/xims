<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="simpledb_common.xsl"/>
<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
 doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-create"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-create"/>
            <xsl:call-template name="error_msg"/>
            <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}" name="eform" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="objtype" value="{$objtype}"/>
                <table border="0" width="98%">
                    <xsl:apply-templates select="/document/member_properties/member_property">
                        <xsl:sort select="position" order="ascending" data-type="number"/>
                    </xsl:apply-templates>
                    <xsl:call-template name="tr-abstract-edit"/>
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
