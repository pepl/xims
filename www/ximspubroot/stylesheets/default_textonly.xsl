<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/1999/xhtml"
                >
<!--$Id$-->

<xsl:import href="include/common.xsl"/>

<xsl:output method="html" encoding="ISO-8859-1"/>

<xsl:template match="/page">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de">
    <head>
      <xsl:call-template name="meta"/>
      <title><xsl:value-of select="rdf:RDF/rdf:Description/dc:title/text()"/></title>
      <link rel="stylesheet" href="/ximsroot/stylesheets/default.css" type="text/css" />
      <link rel="stylesheet" href="/ximspubroot/stylesheets/default.css" type="text/css" />
    </head>

    <body bgcolor="#ffffff" text="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
        <!--UdmComment-->
        <table border="0" cellpadding="0" cellspacing="0" width="100%">

     <!-- Begin header -->
    <tr>
        <td bgcolor="#123853" width="75%">
            <span style="color:#ffffff; font-size:14pt;">The eXtensible Information Management System</span>
        </td>
            <td bgcolor="#123853" align="right" width="25%">
            <xsl:text>&#160;</xsl:text>
        </td>
        </tr>
        <tr>
            <td class="pathinfo">
                    <xsl:call-template name="pathinfo"/>
            </td>
            <td class="pathinfo" align="right">
                    <a href="{$request.uri}?style=print">[printversion]</a>
                <xsl:text>&#160;&#160;</xsl:text>
                <a href="{$request.uri}">[html-version]</a>
            </td>
         </tr>
     <!-- End header -->
    <tr>
            <td colspan="2" style="padding-left:10px;">
                  Deptlinks navigation:<xsl:text>&#160;</xsl:text>
                  <xsl:call-template name="deptlinks">
                        <xsl:with-param name="mode">print</xsl:with-param>
                  </xsl:call-template>
            </td>
        </tr>
    <tr>
         <td valign="top" colspan="2" class="content">
                <br /><br />
                <!--/UdmComment-->
                <xsl:apply-templates select="body"/>
         </td>
    </tr>
        <tr>
        <td colspan="2">&#160;</td>
        </tr>
       <tr>
                <td valign="baseline" style="padding-left:10px;">
                    <xsl:call-template name="copyfooter"/>
                </td>
                <td valign="top" align="right" style="padding-right:10px;">
                    <xsl:call-template name="powerdbyfooter"/>
                </td>
    </tr>
        </table>
      </body>
    </html>
</xsl:template>


<xsl:template match="link">
    <a href="{@href}/?style=textonly"><xsl:value-of select="text()"/></a><xsl:text>&#160;&#160;&#160;</xsl:text>
</xsl:template>

<xsl:template match="img">
    <xsl:choose>
        <xsl:when test="@alt != ''">
            [Image: <xsl:value-of select="//img/@alt"/>]
        </xsl:when>
        <xsl:otherwise>
            [Image: No description available]
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="a">
    <a>
        <xsl:if test="@href != ''">
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="contains(@href = '?')">
                        <xsl:value-of select="concat(@href,'&amp;style=textonly')"/>
                    </xsl:when>
                    <xsl:when test="contains(@href, '#')">
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@href,'?style=textonly')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="title">
            <xsl:choose>
                <xsl:when test="@title != ''">
                    <xsl:value-of select="@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:if test="@target != ''">
            <xsl:attribute name="target">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@name != ''">
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@id != ''">
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@class != ''">
            <xsl:attribute name="class">
                <xsl:value-of select="@class"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </a>
</xsl:template>
</xsl:stylesheet>
