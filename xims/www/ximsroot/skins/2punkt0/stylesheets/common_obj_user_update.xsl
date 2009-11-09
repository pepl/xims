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
        <!--<head>
            <title>
                <xsl:value-of select="title" /> - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>-->
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>


            <div id="table-container">

                <h1 class="bluebg"><xsl:value-of select="$i18n/l/Privs_updated"/></h1>

                <p><xsl:call-template name="message"/></p>
<br/><br/>
                <div id="button-forms">
                    <form name="userConfirm" action="{$xims_box}{$goxims_content}" method="get">
                        <input class="ui-state-default ui-corner-all fg-button" name="obj_acllist" type="submit" value="{$i18n/l/Choose_another_user}"/>
                        <input name="id" type="hidden" value="{@id}"/>
                        <xsl:call-template name="rbacknav"/>
                    </form>
                    &#160;
                       <xsl:call-template name="exitredirectform"/>
            </div>
</div>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

