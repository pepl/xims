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

<xsl:import href="vlibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="common-head">
        <xsl:with-param name="mode">edit</xsl:with-param>
        <xsl:with-param name="calendar" select="true()" />
    </xsl:call-template>
    <body>
        <!-- TODO: 
            * post_async is currently not loaded
            * should be moved to a script-bottom template together with vlibrary_edit.js
            * post_async should post with OBJECT_ID and not LOCATION_PATH
            * JQuery API should be used
            * when adding or deleting a property the iframed (thickbox) page should be reloaded
        -->
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" enctype="multipart/form-data">
                <table border="0" width="98%">
                    <xsl:call-template name="tr-locationtitle-edit_urllink"/>
                    <xsl:call-template name="tr-vlsubjects-edit"/>
                    <xsl:call-template name="tr-publisher"/>
                    <xsl:call-template name="tr-chronicle_from"/>
                    <xsl:call-template name="tr-chronicle_to"/>
                    <xsl:call-template name="tr-vlkeywords-edit"/>
                    <xsl:call-template name="tr-abstract-edit"/>
                    <xsl:call-template name="tr-mediatype"/>
                    <xsl:call-template name="tr-coverage"/>
                    <xsl:call-template name="tr-audience"/>
                    <xsl:call-template name="tr-legalnotice"/>
                    <xsl:call-template name="tr-bibliosource"/>
                    <xsl:call-template name="markednew"/>
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

<xsl:template name="tr-locationtitle-edit_urllink">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
        </td>
        <td>
            <input tabindex="10" type="text" class="text" name="name" size="40">
                <xsl:choose>
                    <xsl:when test="string-length(symname_to_doc_id) > 0 ">
                        <xsl:attribute name="value"><xsl:value-of select="symname_to_doc_id"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="value"><xsl:value-of select="location"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            <xsl:call-template name="marked_mandatory"/>
        </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>
    
    
<xsl:template name="saveedit">
    <input type="hidden" name="id" value="{@id}"/>
    <input type="hidden" name="close_thickbox" value="1"/>
    <input type="submit" name="store" value="{$i18n/l/save}" class="control" accesskey="S"/>
</xsl:template>

<xsl:template name="cancelform">
    <xsl:param name="with_save" select="'no'"/>
    <!-- method get is needed, because goxims does not handle a PUTed 'id' -->
    <form action="{$xims_box}{$goxims_content}" name="cform" method="get" style="margin-top:0px; margin-bottom:0px; margin-left:-5px; margin-right:0px;">
        <input type="hidden" name="id" value="{@id}"/>
        <input type="hidden" name="close_thickbox" value="1"/>
        <xsl:if test="$with_save = 'yes'">
            <xsl:call-template name="save_jsbutton"/>
        </xsl:if>
        <input type="submit" name="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C"/>
    </form>
</xsl:template>

</xsl:stylesheet>
