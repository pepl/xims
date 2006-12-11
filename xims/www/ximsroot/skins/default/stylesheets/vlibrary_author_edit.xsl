<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common">
    <xsl:import href="common.xsl"/>
    <xsl:output method="xml"
                encoding="utf-8"
                media-type="text/html"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                omit-xml-declaration="yes"
                indent="yes"/>
    <xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
    <xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title><xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/author)"/></title>
            </head>
            <body onLoad="setBg('vliteminfo');" onunload="window.close();">
                <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="POST"
                      onSubmit="window.opener.location='{$xims_box}{$goxims_content}?id={@id};authors=1';return true;">
                    <xsl:apply-templates select="/document/context/object/children"/>
                </form>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="children/object">
        <fieldset>
            <legend>
                <xsl:value-of select="concat($i18n/l/edit, ' ', $i18n_vlib/l/author)"/>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>
            </legend>
            <table>
                <tr>
                    <td><label for="vlauthor_firstname"><xsl:value-of select="$i18n_vlib/l/firstname"/></label></td>
                    <td colspan="2">
                        <input tabindex="40" 
                               type="text" 
                               id="vlauthor_firstname" 
                               name="vlauthor_firstname" 
                               size="25" 
                               value="{firstname}" 
                               class="text" 
                               title="{$i18n_vlib/l/firstname}"/>
                    </td>
                </tr>
                <tr>
                    <td><label for="vlauthor_middlename"><xsl:value-of select="$i18n_vlib/l/middlename"/></label></td>
                    <td colspan="2">
                        <input tabindex="40" 
                               type="text" 
                               id="vlauthor_middlename" 
                               name="vlauthor_middlename" 
                               size="25" 
                               value="{middlename}" 
                               class="text" 
                               title="{$i18n_vlib/l/middlename}"/>
                    </td>
                </tr>
                <tr>
                    <td><label for="vlauthor_lastname"><xsl:value-of select="$i18n_vlib/l/lastname"/></label></td>
                    <td colspan="2">
                        <input tabindex="40" 
                               type="text" 
                               id="vlauthor_lastname" 
                               name="vlauthor_lastname"
                               size="50"
                               value="{lastname}" 
                               class="text" 
                               title="{$i18n_vlib/l/lastname}"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="vlauthor_suffix"><xsl:value-of select="$i18n_vlib/l/suffix"/></label>
                    </td>
                    <td colspan="2">
                        <input tabindex="40"
                               type="text" 
                               id="vlauthor_suffix" 
                               name="vlauthor_suffix"
                               size="5"
                               value="{suffix}"
                               class="text"
                               title="{$i18n_vlib/l/suffix}"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="vlauthor_Objecttype"><xsl:value-of select="$i18n_vlib/l/orgauthor"/></label>
                    </td>
                    <td colspan="2">
                        <input tabindex="40" 
                               type="checkbox" 
                               id="vlauthor_object_type" 
                               name="vlauthor_object_type" 
                               class="text" 
                               title="{$i18n_vlib/l/orgauthor}"
                               value="1">
                            <xsl:if test="object_type=1">
                                <xsl:attribute name="checked">checked</xsl:attribute>
                            </xsl:if>
                        </input>
                    </td>
                </tr>
            </table>
        </fieldset>
        <p>
            <input type="hidden" name="vlauthor_id" id="vlauthor_id" value="{@id}"/>
            <input type="submit" name="author_store" value="{$i18n/l/save}" class="control" accesskey="S"></input>
            <input type="submit" name="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C"></input>
        </p>
    </xsl:template>
</xsl:stylesheet>
