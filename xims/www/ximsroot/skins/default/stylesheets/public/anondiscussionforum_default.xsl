<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2004 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/xhtml1/strict">

<xsl:import href="../anondiscussionforum_default.xsl"/>
<xsl:import href="anondiscussionforum_common.xsl"/>

<xsl:template name="forum">
    <h1><xsl:value-of select="title" /></h1>

    <p class="content">
        <xsl:apply-templates select="abstract"/>
    </p>

    <p>
        <xsl:if test="user_privileges/create">
          <form action="{$xims_box}{$goxims_content}" method="GET" style="margin-bottom: 0;">
            <input type="hidden" name="objtype" value="AnonDiscussionForumContrib"/>
            <input type="hidden" name="id" value="{@id}" />
            <input type="submit" name="create" value="{$i18n/l/Create_topic}" class="control"/><br /><br />
          </form>
        </xsl:if>
    </p>

    <xsl:call-template name="forumtable"/>
</xsl:template>

</xsl:stylesheet>