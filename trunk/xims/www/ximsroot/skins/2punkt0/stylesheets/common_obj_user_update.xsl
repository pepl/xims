<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_obj_user_update.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<!--<xsl:import href="common_header.xsl"/>-->

<xsl:variable name="object_type_id">
    <xsl:value-of select="/document/context/object/object_type_id"/>
</xsl:variable>
<xsl:variable name="parent_id">
    <xsl:value-of select="/document/context/object/@parent_id"/>
</xsl:variable>

<xsl:template match="/document/context/object">
    <html>
    <xsl:call-template name="head_default"/>
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

            <div id="content-container">

                <h1 class="bluebg"><xsl:value-of select="$i18n/l/Privs_updated"/></h1>

                <p><xsl:call-template name="message"/></p>
<br/><br/>
                <div id="button-forms">
                    <form name="userConfirm" action="{$xims_box}{$goxims_content}" method="get">
                        <button class="button" name="obj_acllist" type="submit"><xsl:value-of select="$i18n/l/Choose_another_user"/></button>
                        <input name="id" type="hidden" value="{@id}"/>
                        <xsl:call-template name="rbacknav"/>
                    </form>
                    &#160;
                       <xsl:call-template name="exitredirectform"/>
            </div>
</div>
<xsl:call-template name="script_bottom"/>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

