<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforum_common.xsl 2191 2009-01-07 20:04:18Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
        <xsl:comment>UdmComment</xsl:comment>
        <xsl:call-template name="header"/>
        <div id="leftcontent">
            <xsl:call-template name="stdlinks"/>
            <xsl:call-template name="departmentlinks"/>
            <xsl:call-template name="documentlinks"/>
        </div>
        <div id="centercontent">
            <xsl:comment>/UdmComment</xsl:comment>
            <xsl:call-template name="forum"/>
            <div id="footer">
                <span class="left">
                    <xsl:call-template name="copyfooter"/>
                </span>
                <span class="right">
                    <xsl:call-template name="powerdbyfooter"/>
                </span>
            </div>
        </div>
        <iframe name="hiddenIframe" id="hiddenIframe" style="display: none"/>
    </body>
</html>
</xsl:template>

 
<xsl:template name="pathinfo">
    <xsl:apply-templates select="/document/context/object/parents/object[object_type_id != /document/object_types/object_type[name='AnonDiscussionForumContrib']/@id and @parent_id &gt; 1]"/>
    <xsl:if test="/document/context/object/object_type_id = /document/object_types/object_type[name='AnonDiscussionForum']/@id">
        / <a class="nodeco" href="{$goxims_content}{$absolute_path}"><xsl:value-of select="location"/></a>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
