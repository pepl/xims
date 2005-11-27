<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2005 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">


<xsl:import href="referencelibraryitem_common.xsl"/>
<xsl:param name="css" select="concat($ximsroot,'skins/',$currentskin,'/stylesheets/reference_library_cv_defaultstyle.css')"/>

<xsl:variable name="volumerefpropid" select="/document/reference_properties/reference_property[name='volume']/@id"/>
<xsl:variable name="issuerefpropid" select="/document/reference_properties/reference_property[name='issue']/@id"/>
<xsl:variable name="pagesrefpropid" select="/document/reference_properties/reference_property[name='pages']/@id"/>
<xsl:variable name="spagerefpropid" select="/document/reference_properties/reference_property[name='spage']/@id"/>
<xsl:variable name="epagerefpropid" select="/document/reference_properties/reference_property[name='epage']/@id"/>
<xsl:variable name="identifierrefpropid" select="/document/reference_properties/reference_property[name='identifier']/@id"/>
<xsl:variable name="urlrefpropid" select="/document/reference_properties/reference_property[name='url']/@id"/>
<xsl:variable name="url2refpropid" select="/document/reference_properties/reference_property[name='url2']/@id"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head_default"/>
        <body>
            <div id="reflib_citebody">
                <ul id="reflib_citelist">
                    <xsl:apply-templates select="children/object" mode="divlist">
                        <xsl:sort select="title" order="ascending"/>
                    </xsl:apply-templates>
                </ul>
            </div>
        </body>
    </html>
</xsl:template>


<xsl:template match="children/object" mode="divlist">
    <xsl:variable name="date" select="reference_values/reference_value[property_id=$daterefpropid]/value"/>
    <xsl:variable name="btitle" select="reference_values/reference_value[property_id=$btitlerefpropid]/value"/>
    <xsl:variable name="volume" select="reference_values/reference_value[property_id=$volumerefpropid]/value"/>
    <xsl:variable name="issue" select="reference_values/reference_value[property_id=$issuerefpropid]/value"/>
    <xsl:variable name="pages" select="reference_values/reference_value[property_id=$pagesrefpropid]/value"/>
    <xsl:variable name="spage" select="reference_values/reference_value[property_id=$spagerefpropid]/value"/>
    <xsl:variable name="epage" select="reference_values/reference_value[property_id=$epagerefpropid]/value"/>
    <xsl:variable name="identifier" select="reference_values/reference_value[property_id=$identifierrefpropid]/value"/>
    <xsl:variable name="url" select="reference_values/reference_value[property_id=$urlrefpropid]/value"/>
    <xsl:variable name="url2" select="reference_values/reference_value[property_id=$url2refpropid]/value"/>
    <xsl:variable name="serial_id" select="serial_id"/>
    <li class="reflib_citation" name="reflib_citation">
        <span class="reflib_authors">
            <xsl:choose>
                <xsl:when test="authorgroup/author">
                    <xsl:apply-templates select="authorgroup/author">
                        <xsl:sort select="position" order="ascending"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    Anonymous</xsl:otherwise>
            </xsl:choose>
        </span>,
        <span class="reflib_title">
              <xsl:value-of select="reference_values/reference_value[property_id=$titlerefpropid]/value"/>
        </span>
        <xsl:if test="$serial_id != '' or $btitle != ''">,
            <span class="reflib_serial">
                <xsl:choose>
                    <xsl:when test="$serial_id != ''">
                        <xsl:value-of select="/document/context/vlserials/serial[id=$serial_id]/title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$btitle"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </xsl:if><xsl:if test="$volume != ''">&#xa0;<xsl:value-of select="$volume"/></xsl:if><xsl:if test="$issue != ''">&#xa0;<xsl:value-of select="$issue"/></xsl:if><xsl:if test="$spage != '' or $pages != ''">, </xsl:if>
        <xsl:choose>
            <xsl:when test="$spage != ''">
                <xsl:value-of select="$spage"/><xsl:if test="$epage != ''">-<xsl:value-of select="$epage"/></xsl:if>
            </xsl:when>
            <xsl:when test="$pages != ''">
                <xsl:value-of select="$pages"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$date != ''"> (<xsl:value-of select="$date"/>)</xsl:if>
        <xsl:if test="$url != ''">&#xa0;<a href="{$url}">URL</a></xsl:if>
        <xsl:if test="$url2 != ''">&#xa0;<a href="{$url2}">Alternative URL (local copy)</a></xsl:if>
        <xsl:if test="$identifier != ''">;
            <xsl:choose>
                <xsl:when test="starts-with($identifier, 'oai:arXiv.org:')">
                    <a href="http://arXiv.org/abs/{substring-after($identifier,'oai:arXiv.org:')}"><xsl:value-of select="$identifier"/></a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$identifier"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="abstract != ''">
            &#xa0;<a href="#" onClick="blocking('abstract{position()}'); return false;">Toggle Abstract</a>
            <div id="abstract{position()}" class="reflib_abstract" style="display: none"><xsl:apply-templates select="abstract"/></div>
        </xsl:if>
<!--
        <xsl:if test="editorgroup/author">
            <div class="reflib_editors">
                <strong>Editors</strong>: <xsl:apply-templates select="editorgroup"/>
            </div>
        </xsl:if>
-->
    </li>
</xsl:template>

<xsl:template match="authorgroup/author|editorgroup/author">
    <span class="reflib_author">
        <xsl:if test="firstname != ''"><xsl:value-of select="substring(firstname, 1,1)"/>. </xsl:if><xsl:value-of select="lastname"/>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </span>
</xsl:template>


<xsl:template name="head_default">
    <head>
        <title>Publications - <xsl:value-of select="title" /></title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
        <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/reference_library.css" type="text/css"/>
        <link rel="stylesheet" href="{$css}" type="text/css"/>
        <script src="{$ximsroot}scripts/vlibrary_default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/reflibrary.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script type="text/javascript">
function blocking(nr) {
    if (document.layers) {
        current = (document.layers[nr].display == 'none') ? 'block' : 'none';
        document.layers[nr].display = current;
    }
    else if (document.all) {
        current = (document.all[nr].style.display == 'none') ? 'block' : 'none';
        document.all[nr].style.display = current;
    }
    else if (document.getElementById) {
        vista = (document.getElementById(nr).style.display == 'none') ? 'block' : 'none';
        document.getElementById(nr).style.display = vista;
    }
}
        </script>
    </head>
</xsl:template>

</xsl:stylesheet>
