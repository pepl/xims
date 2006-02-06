<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
<!-- $Id$ -->
<xsl:import href="common.xsl"/>
<xsl:import href="../common_publish_prompt.xsl"/>
<xsl:output method="html" encoding="utf-8" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:template match="/document/context/object">
    <html>
        <xsl:call-template name="head"/>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png" onLoad="disableIt(document.forms[1].autopublish,'objids');">
            <xsl:call-template name="header">
                <xsl:with-param name="noncontent">true</xsl:with-param>
            </xsl:call-template>

            <form name="objPublish" action="{$xims_box}{$goxims_content}" method="GET" style="margin-top: 0px; margin-left: 5px;">
                <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
                    <tr>
                        <td align="center">

                            <br />
                            <!-- begin widget table -->
                            <table width="400" cellpadding="2" cellspacing="2" border="0">
                                <tr>
                                    <td class="bluebg">Publishing Options for Object '<xsl:value-of select="title"/>'</td>
                                </tr>
                                <tr>
                                    <td>&#160;</td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>
                                            Status: This object is
                                            <xsl:if test="published!='1'">
                                                <xsl:text> NOT </xsl:text>
                                            </xsl:if>
                                            currently published
                                        </strong>
                                        <xsl:if test="published='1'">
                                            at <br/><a href="{$published_path}" target="_new">
                                                <xsl:value-of select="$published_path"/></a>
                                        </xsl:if>
                                    </td>
                                </tr>

                                <!-- warn about ungraned children -->
                                <xsl:if test="message">
                                    <tr>
                                        <td>
                                            Warning: The object '<xsl:value-of select="title"/>' has the following dependencies that
                                            you do not have the correct permissions to publish:
                                            <xsl:call-template name="csv2ul">
                                                <xsl:with-param name="list" select="message"/>
                                            </xsl:call-template>
                                            These objects will be skipped during publishing.
                                        </td>
                                    </tr>
                                </xsl:if>
                                <!-- end warning -->

                                <!-- autoindex -->
                                <xsl:if test="contains( attributes/text(), 'autoindex=1' )">
                                    <tr>
                                        <td>
                                            <strong>Note: The autoindex-option is set for this container.</strong>
                                            <xsl:choose>
                                                <xsl:when test="published='1'">
                                                    An index file will be regenerated if you choose 'Republish'.
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    An index file will be generated if you choose 'Publish'.
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <!-- end autoindex -->

                                <tr>
                                    <td>
                                        Click
                                        <xsl:choose>
                                            <xsl:when test="published='1'">
                                                'Republish'
                                            </xsl:when>
                                            <xsl:otherwise>
                                                'Publish'
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        to export the current object,
                                        <xsl:if test="published='1'">
                                            'Unpublish' to remove the object from the live server,
                                        </xsl:if>
                                        or 'Cancel' to return to the previous screen.
                                    </td>
                                </tr>
                                <!-- references -->
                                <tr>
                                    <td align="center">
                                        <!-- begin link table -->
                                        &#160;
                                        <xsl:if test="/document/objectlist/object">
                                            <table cellpadding="2" cellspacing="0" border="0">
                                                <tr>
                                                    <td colspan="3">
                                                        <div style="margin-bottom: 3px;">The following <strong>related objects</strong> (children or links) were found:</div>
                                                    </td>
                                                </tr>
                                                <xsl:apply-templates select="/document/objectlist/object"/>
                                                <tr>
                                                    <td colspan="3">
                                                        <table style="margin-top: 15px;">
                                                            <xsl:choose>
                                                                <xsl:when test="/document/objectlist/object[location != '']">
                                                                    <tr>
                                                                        <td>
                                                                            (De)Select all
                                                                        </td>
                                                                        <td>
                                                                            <input type="checkbox" name="selector" value="1" onClick="switcher(this,'objids') ? document.forms[1].autopublish.checked = 1 : document.forms[1].autopublish.checked = 0;"/>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            Auto(re)publish selected objects besides the current object?
                                                                        </td>
                                                                        <td>
                                                                            <input type="checkbox" name="autopublish" value="1" disabled="true"/>
                                                                        </td>
                                                                    </tr>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <tr>
                                                                        <td colspan="2"><br/>No related objects (children, links) to be auto(re)published found.</td>
                                                                    </tr>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </xsl:if>
                                        <!-- end link table -->
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Update dependencies (related Portlets, Auto-Indices, ...)
                                    </td>
                                    <td>
                                        <input type="checkbox" name="update_dependencies" value="1" checked="checked" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center">

                                        <!-- begin buttons table -->
                                        <table cellpadding="2" cellspacing="0" border="0">
                                            <tr align="center">
                                                <td>
                                                    <input name="publish" type="submit" class="control">
                                                        <xsl:choose>
                                                            <xsl:when test="published='1'">
                                                                <xsl:attribute name="value">Republish</xsl:attribute>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:attribute name="value">Publish</xsl:attribute>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </input>
                                                    <input name="id" type="hidden" value="{$id}"/>
                                                    <xsl:call-template name="rbacknav"/>
                                                </td>
                                                <xsl:if test="published='1'">
                                                    <td>
                                                        <input name="unpublish" type="submit" value="Unpublish" class="control"/>
                                                    </td>
                                                </xsl:if>
                                                <td>
                                                    <input name="default" type="button" value="Cancel" onClick="javascript:history.go(-1)" class="control"/>
                                                </td>
                                            </tr>
                                        </table>
                                        <!-- end buttons table -->

                                    </td>
                                </tr>
                            </table>
                            <!-- end widget table -->
                            <br />

                        </td>
                    </tr>
                </table>
            </form>
        </body>
    </html>
</xsl:template>

<xsl:template match="/document/objectlist/object">
    <tr>
        <td valign="top">
            <input type="checkbox" name="objids" value="{@id}">
                <xsl:choose>
                    <xsl:when test="string-length(location) &lt;= 0">
                        <xsl:attribute name="disabled">true</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &gt; concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                        <xsl:attribute name="checked">true</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published = '1' and
concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                        <xsl:attribute name="disabled">true</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="published != '1'">
                        <xsl:attribute name="onClick">isChecked('objids') ? document.forms[1].autopublish.checked = 1 : document.forms[1].autopublish.checked = 0</xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </input>
        </td>
        <td valign="top">
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="not(starts-with(location_path,'/')) and not(starts-with(location_path,$goxims_content))">
                            <xsl:value-of select="concat($goxims_content,$parent_path,'/',location_path)"/>
                        </xsl:when>
                        <xsl:when test="starts-with(location_path,'/') and not(starts-with(location_path,$goxims_content))">
                            <xsl:value-of select="concat($goxims_content,location_path)"/>
                        </xsl:when>
                            <xsl:otherwise>
                            <xsl:value-of select="location_path"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="location_path"/>
            </a>

            <div style="margin-top: 3px; margin-bottom: 8px;">
            This
            <xsl:choose>
                <xsl:when test="string-length(location) &lt;= 0">
                    <xsl:text> is not a XIMS object or could not be resolved.</xsl:text>
                </xsl:when>
                <xsl:when test="published != '1'">
                    <xsl:text> object is not currently published.</xsl:text>
                </xsl:when>
                <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                    <xsl:text> object was last published at </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/><xsl:text> and has not been modified since then.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> object has been modified since the last publication at </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                </xsl:otherwise>
            </xsl:choose>
            </div>
        </td>
    </tr>
</xsl:template>
</xsl:stylesheet>

