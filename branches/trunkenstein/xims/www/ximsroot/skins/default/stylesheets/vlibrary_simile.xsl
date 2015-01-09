<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
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
                doctype-system="about:legacy-compat"
                omit-xml-declaration="yes"
                indent="no"/>

    <xsl:param name="chronicle_from"/>
    <xsl:param name="chronicle_to"/>
    <xsl:param name="submit.x"/>
    <xsl:param name="submit"/>

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
                </div>
                <div id="tl1" style="height: 300px; border: 1px solid #aaa">
                </div>
                <div class="controls" id="controls">
                </div>
                <xsl:call-template name="script_bottom"/>
                <!--<xsl:call-template name="create_menu_js"/>-->
            </body>
        </html>
    </xsl:template>

<xsl:template name="cttobject.options.copy"/>

    <xsl:template name="head_default">
        <head>
            <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
            <xsl:call-template name="css"/>
            <xsl:call-template name="script_head"/>
            <!--<xsl:call-template name="create_menu_css"/>-->
            <script src="http://simile.mit.edu/timeline/api/timeline-api.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="http://simile.mit.edu/timeline/examples/examples.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script>
                var tl;
                function onLoad() {
                    var eventSource = new Timeline.DefaultEventSource();
                    var theme = Timeline.ClassicTheme.create();

                    var startdate = "<xsl:apply-templates select="/document/context/object/children/object/meta/date_from_timestamp" mode="RFC822" />";

                    // TODO: get rid of hardcoded demo timespan
                    var bandInfos = [
                        Timeline.createBandInfo({
                            eventSource:    eventSource,
                            date:           startdate,
                            width:          "60%",
                            intervalUnit:   Timeline.DateTime.MONTH,
                            intervalPixels: 100
                        }),
                        Timeline.createBandInfo({
                            showEventText:  false,
                            trackHeight:    0.5,
                            trackGap:       0.2,
                            eventSource:    eventSource,
                            date:           startdate,
                            width:          "20%",
                            intervalUnit:   Timeline.DateTime.YEAR,
                            intervalPixels: 200
                        }),
                        Timeline.createBandInfo({
                            showEventText:  false,
                            trackHeight:    0.5,
                            trackGap:       0.2,
                            eventSource:    eventSource,
                            date:           startdate,
                            width:          "20%",
                            intervalUnit:   Timeline.DateTime.DECADE,
                            intervalPixels: 200
                        })
                    ];

                    bandInfos[1].syncWith = 0;
                    bandInfos[1].highlight = true;
                    bandInfos[2].syncWith = 0;
                    bandInfos[2].highlight = true;

                    <xsl:if test="$submit.x != '' or $submit != ''">
                    tl = Timeline.create(document.getElementById("tl1"), bandInfos);
                    // TODO: get rid of hardcoded demo timespan
                    Timeline.loadXML("?vlchronicle=1&amp;onepage=1&amp;style=simile_timeline_src&amp;chronicle_from=<xsl:value-of select="$chronicle_from"/>;chronicle_to=<xsl:value-of select="$chronicle_to"/>", function(xml, url) { eventSource.loadXML(xml, url); });

                    setupFilterHighlightControls(document.getElementById("controls"), tl, [0,1], theme);
                    </xsl:if>
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

    <xsl:template name="chronicle_switch">
        <table width="100%" border="0" style="margin: 0px;" id="vlsearchswitch">
            <tr>
                <td valign="top" width="50%" align="center" class="vlsearchswitchcell">
                    <form style="margin-bottom: 0px;" action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" name="vlib_search">
                        Chronik von
                        <input style="background: #eeeeee; font-family: helvetica; font-size: 10pt" type="text" name="chronicle_from" size="10" maxlength="200" value="{$chronicle_from}" />
                        bis
                        <input style="background: #eeeeee; font-family: helvetica; font-size: 10pt" type="text" name="chronicle_to" size="10" maxlength="200" value="{$chronicle_to}" />
                        <xsl:text>&#160;</xsl:text>
                        <input type="image"
                            src="{$skimages}go.png"
                            name="submit"
                            width="25"
                            height="14"
                            alt=""
                            title=""
                            border="0"
                            style="vertical-align: text-bottom;"
                        />
                        <input type="hidden" name="simile" value="1"/>
                    </form>
                </td>
            </tr>
        </table>

    </xsl:template>

</xsl:stylesheet>
