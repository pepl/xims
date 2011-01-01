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

<xsl:import href="link_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head-edit"/>
    <body>
        <div class="edit">
            <xsl:call-template name="table-edit"/>
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post">
                <table border="0" width="95%">
                    <xsl:call-template name="tr-location-edit"/>
                    <xsl:call-template name="tr-target-edit"/>
                    <tr>
                        <td colspan="2">
                            <xsl:value-of select="$i18n/l/Title"/>: <xsl:value-of select="title"/>
                        </td>
                    </tr>
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

<xsl:template name="tr-target-edit">
    <tr>
        <td valign="top"><span class="compulsory"><xsl:value-of select="$i18n/l/Target"/></span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" value="{symname_to_doc_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={parents/object[@document_id=/document/context/object/@parent_id]/@id};contentbrowse=1;sbfield=eform.target')" class="doclink"><xsl:value-of select="$i18n/l/browse_target"/></a>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>
