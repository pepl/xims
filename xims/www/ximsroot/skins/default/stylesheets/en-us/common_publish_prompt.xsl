<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
    <!-- $Id$ -->
    <xsl:import href="common.xsl"/>
    <xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>
    <xsl:param name="id"/>

    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>
                    Confirm Publishing - XIMS
                </title> 
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
                <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
                <script type="text/javascript">
                    <xsl:comment>
                        <![CDATA[
                            function disableIt(obj) {
                                var autoexport = window.document.forms[1].elements['autoexport'];
                                if (!autoexport) {
                                    return;
                                }
                                var i;
                                for (i = 0; i < autoexport.length; i++) {
                                    if ( !(autoexport[i].disabled) ) {
                                        obj.disabled = false;
                                        return true;
                                    }
                                }
                            }
                        ]]>
                    </xsl:comment>
                </script>
            </head>
            <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$ximsroot}skins/{$currentskin}/images/body_bg.png" onLoad="disableIt(document.forms[1].autopublishlinks);">
                <xsl:call-template name="header">
                    <xsl:with-param name="noncontent">true</xsl:with-param>
                </xsl:call-template>

                <form name="objPublish" action="{$xims_box}{$goxims_content}" method="GET" style="margin-top: 0px; margin-left: 5px;">
                    <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
                        <tr>
                            <td align="center">
                                
                                <br />
                                <!-- begin widget table -->
                                <table width="350" cellpadding="2" cellspacing="2" border="0">
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
                                                <xsl:if test="published/text()!='1'">
                                                    <xsl:text> NOT </xsl:text>
                                                </xsl:if>
                                                currently published
                                            </strong>
                                            <xsl:if test="published/text()='1'">
                                                at <br/><a href="{$publishingroot}{$absolute_path}" target="_new">
                                                    <xsl:value-of select="concat($publishingroot,$absolute_path)"/></a>
                                            </xsl:if>
                                        </td>
                                    </tr>

                                    <!-- warn about ungranded children -->
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
                                                    <xsl:when test="published/text()='1'">
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
                                                <xsl:when test="published/text()='1'">
                                                    'Republish'
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    'Publish'
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            to export the current object,
                                            <xsl:if test="published/text()='1'">
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
                                                            The following references were found in the object
                                                        </td>
                                                    </tr>
                                                    <xsl:apply-templates select="/document/objectlist/object"/>
                                                    <tr>
                                                        <td colspan="3">
                                                            <xsl:text> </xsl:text>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="3">
                                                            <table>
                                                                <tr>
                                                                    <xsl:choose>
                                                                        <xsl:when test="/document/objectlist/object[location != '']">
                                                                            <td>
                                                                                Auto(re)publish selected links besides the current object?
                                                                            </td>
                                                                            <td>
                                                                                <input type="checkbox" name="autopublishlinks" value="1" disabled="true"/>
                                                                            </td>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                                <td colspan="2">No references to objects that could be auto(re)published found.</td>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                    <!--
                                                                    <td>
                                                                        remove unpublished links
                                                                    </td>
                                                                    <td>
                                                                        <input type="checkbox" name="removelinks" value="1"/>
                                                                    </td>
                                                                    -->
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </xsl:if>
                                            <!-- end link table -->
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
                                                                <xsl:when test="published/text()='1'">
                                                                    <xsl:attribute name="value">Republish</xsl:attribute>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="value">Publish</xsl:attribute>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </input>
                                                        <input name="id" type="hidden" value="{$id}"/>
                                                    </td>
                                                    <xsl:if test="published/text()='1'">
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

    <xsl:template name="csv2ul">
        <xsl:param name="list"/>
        <ul>
            <xsl:call-template name="csv2li">
                <xsl:with-param name="list" select="$list"/>
            </xsl:call-template>
        </ul>
    </xsl:template>

    <xsl:template name="csv2li">
        <xsl:param name="list"/>
        <xsl:variable name="item" select="substring-before($list, ',')"/>
        <xsl:variable name="rest" select="substring-after($list, ',')"/>
        <xsl:choose>
            <xsl:when test="$item">
                <li>
                    <xsl:value-of select="$item"/>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:value-of select="$list"/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$rest">
            <xsl:call-template name="csv2li">
                <xsl:with-param name="list" select="$rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/document/objectlist/object">
        <tr>
            <td>
                <input type="checkbox" name="autoexport" value="{@id}">
                    <xsl:choose>
                        <xsl:when test="string-length(location) &lt;= 0">
                            <xsl:attribute name="disabled">true</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &gt; concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                            <xsl:attribute name="checked">true</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="published != 1">
                        </xsl:when>
                        <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                            <xsl:attribute name="disabled">true</xsl:attribute>
                        </xsl:when>
                   </xsl:choose>
                </input>
            </td>
            <td>
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
                <br/>

                This 
                <xsl:choose>
                    <xsl:when test="string-length(location) &lt;= 0">
                        <xsl:text> is not a XIMS object</xsl:text>
                    </xsl:when>
                    <xsl:when test="published != 1">
                        <xsl:text> object has not been published yet</xsl:text>
                    </xsl:when>
                    <xsl:when test="concat(last_modification_timestamp/year,last_modification_timestamp/month,last_modification_timestamp/day,last_modification_timestamp/hour,last_modification_timestamp/minute,last_modification_timestamp/second) &lt;= concat(last_publication_timestamp/year,last_publication_timestamp/month,last_publication_timestamp/day,last_publication_timestamp/hour,last_publication_timestamp/minute,last_publication_timestamp/second)">
                       <xsl:text> object has last been published at </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/><xsl:text> and not modified since then.</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:text> object has been modified since the last publication at </xsl:text><xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>

