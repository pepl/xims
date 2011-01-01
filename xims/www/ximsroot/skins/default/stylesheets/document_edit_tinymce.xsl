<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <xsl:import href="document_common.xsl"/>
    <xsl:import href="common_tinymce_scripts.xsl"/>

    <xsl:variable name="bodycontent">
        <xsl:call-template name="body"/>
    </xsl:variable>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body onload="timeoutWYSIWYGChange(2);">
                <div class="edit">
                    <xsl:call-template name="table-edit"/>
                    <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                        <table border="0" width="98%">
                            <xsl:call-template name="tr-locationtitle-edit_doc"/>
                            <xsl:call-template name="tr-body-edit_tinymce"/>
                            <xsl:call-template name="tr-keywords-edit"/>
                            <xsl:call-template name="tr-abstract-edit"/>
                            <xsl:call-template name="markednew"/>
                            <xsl:call-template name="expandrefs"/>
                        </table>
                        <xsl:call-template name="saveedit"/>
                    </form>
                </div>
                <br />
                <xsl:call-template name="canceledit"/>
                <xsl:call-template name="script_bottom"/>
                <xsl:call-template name="tinymce_scripts"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="title">
        <xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$absolute_path"/> - XIMS
    </xsl:template>

    <xsl:template name="tr-body-edit_tinymce">
        <tr>
            <td colspan="3">
                Body
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
                <br/>
                <!--<textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32" onchange="document.getElementById('xims_wysiwygeditor').disabled = true;">-->
                <textarea tabindex="30" name="body" id="body" style="width: 100%" rows="24" cols="32">
                    <xsl:value-of select="$bodycontent"/>
                </textarea>
                <xsl:call-template name="jsorigbody"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
