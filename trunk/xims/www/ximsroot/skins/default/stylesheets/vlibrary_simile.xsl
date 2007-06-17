<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_default.xsl 1652 2007-03-24 16:14:37Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common">

    <xsl:import href="common.xsl"/>
    <xsl:import href="vlibrary_common.xsl"/>
    <xsl:import href="vlibrary_default.xsl"/>

    <xsl:output method="html"
                encoding="utf-8"
                media-type="text/html"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                indent="no"/>

    <xsl:template match="/document/context/object">
        <html>
            <xsl:call-template name="head_default"/>
            <body onload="onLoad();" onresize="onResize();">
                <xsl:call-template name="header">
                    <xsl:with-param name="createwidget">true</xsl:with-param>
                    <xsl:with-param name="parent_id"><xsl:value-of select="/document/object_types/object_type[name='VLibraryItem']/@id" /></xsl:with-param>
                </xsl:call-template>
                <div id="vlbody">
                    <h1><xsl:value-of select="title"/></h1>
                    <div>
                        <xsl:apply-templates select="abstract"/>
                    </div>
                    <xsl:call-template name="search_switch">
                        <xsl:with-param name="mo" select="'subject'"/>
                    </xsl:call-template>
                    <xsl:call-template name="chronicle_switch" />
                    <xsl:apply-templates select="/document/context/vlsubjectinfo"/>
                </div>
                <div id="tl1" style="height: 300px; border: 1px solid #aaa">
                </div>
                <div class="controls" id="controls">
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="vlsubjectinfo">
        <xsl:variable name="sortedsubjects">
            <xsl:for-each select="/document/context/vlsubjectinfo/subject">
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                          order="ascending"/>
                <xsl:copy>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>

        <table width="600" border="0" align="center" id="vlpropertyinfo">
            <tr><th colspan="{$subjectcolumns}"><xsl:value-of select="$i18n_vlib/l/subjects"/></th></tr>
            <xsl:apply-templates select="exslt:node-set($sortedsubjects)/subject[(position()-1) mod $subjectcolumns = 0]">
                <!-- do not ask me why the second sorting is neccessary here ... 8-{ -->
                <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>

    <xsl:template match="subject">
        <xsl:call-template name="item">
            <xsl:with-param name="mo" select="'subject'"/>
            <xsl:with-param name="colms" select="$subjectcolumns"/>
        </xsl:call-template>
    </xsl:template>

<xsl:template name="cttobject.options.copy"/>

    <xsl:template name="head_default">
        <head>
            <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
            <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}scripts/vlibrary_default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <xsl:call-template name="create_menu_jscss"/>
            <script src="http://simile.mit.edu/timeline/api/timeline-api.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="http://simile.mit.edu/timeline/examples/examples.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script>
                var tl;
                function onLoad() {
                    var eventSource = new Timeline.DefaultEventSource();
                    var theme = Timeline.ClassicTheme.create();

                    // TODO: get rid of hardcoded demo timespan
                    var bandInfos = [
                        Timeline.createBandInfo({
                            eventSource:    eventSource,
                            date:           "Jan 1 1914 00:00:00 GMT",
                            width:          "60%",
                            intervalUnit:   Timeline.DateTime.MONTH,
                            intervalPixels: 100
                        }),
                        Timeline.createBandInfo({
                            showEventText:  false,
                            trackHeight:    0.5,
                            trackGap:       0.2,
                            eventSource:    eventSource,
                            date:           "Jan 1 1914 00:00:00 GMT",
                            width:          "20%",
                            intervalUnit:   Timeline.DateTime.YEAR,
                            intervalPixels: 200
                        }),
                        Timeline.createBandInfo({
                            showEventText:  false,
                            trackHeight:    0.5,
                            trackGap:       0.2,
                            eventSource:    eventSource,
                            date:           "Jan 1 1914 00:00:00 GMT",
                            width:          "20%",
                            intervalUnit:   Timeline.DateTime.DECADE,
                            intervalPixels: 200
                        })
                    ];

                    bandInfos[1].syncWith = 0;
                    bandInfos[1].highlight = true;
                    bandInfos[2].syncWith = 0;
                    bandInfos[2].highlight = true;

                    tl = Timeline.create(document.getElementById("tl1"), bandInfos);
                    // TODO: get rid of hardcoded demo timespan
                    Timeline.loadXML("?vlchronicle=1;chronicle_from=1914-01-01;chronicle_to=1921-12-31;style=simile_timeline_src", function(xml, url) { eventSource.loadXML(xml, url); });

                    setupFilterHighlightControls(document.getElementById("controls"), tl, [0,1], theme);
                }

                var resizeTimerID = null;
                function onResize() {
                    if (resizeTimerID == null) {
                        resizeTimerID = window.setTimeout(function() {
                            resizeTimerID = null;
                            tl.layout();
                        }, 500);
                    }
                }
            </script>
        </head>
    </xsl:template>

</xsl:stylesheet>
