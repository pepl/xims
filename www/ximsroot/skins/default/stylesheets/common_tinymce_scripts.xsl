<?xml version="1.0"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:template name="tinymce_scripts">
    <script language="javascript" type="text/javascript" src="{$ximsroot}tinymce/jscripts/tiny_mce/tiny_mce.js"></script>
    <script language="javascript" type="text/javascript">
    tinyMCE.init({
        mode : 'exact',
        elements : 'body',
        language : '<xsl:value-of select="substring(/document/context/session/uilanguage,1,2)"/>',
        document_base_url : '<xsl:choose><xsl:when test="$edit = '1'"><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/></xsl:otherwise></xsl:choose>',
        auto_cleanup_word : true,
        entity_encoding : 'raw',
        plugins : 'table,contextmenu,advhr,searchreplace',
        theme_advanced_buttons1_add_before: 'cut,copy,paste,separator,search,replace,separator',
        theme_advanced_buttons3_add_before : 'tablecontrols,separator',
        theme_advanced_toolbar_location : 'top',
        theme_advanced_toolbar_align : 'left',
        theme_advanced_path_location : 'bottom',

        <!-- Does not work with TinyMCE 1.44RC1 unfortunately
        content_css :  &apos;<xsl:choose>
            <xsl:when test="css_id != ''"><xsl:value-of select="concat($xims_box,$goxims_content,css_id,'?plain=1')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="concat($ximsroot,$defaultcss)"/></xsl:otherwise>
          </xsl:choose>&apos;,
        -->

    });
    // auto_focus : 'body'

    var origbody = null;
    </script>
</xsl:template>
</xsl:stylesheet>
