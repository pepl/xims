<?xml version="1.0" encoding="iso-8859-1" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<!-- $Id$ -->
<xsl:import href="config.xsl"/>
<xsl:import href="common.xsl"/>
<xsl:output method="xml" encoding="iso-8859-1" media-type="text/html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no"/>

<xsl:variable name="object_type_id">
    <xsl:value-of select="/document/context/object/object_type_id"/>
</xsl:variable>
<xsl:variable name="parent_id">
    <xsl:value-of select="/document/context/object/@parent_id"/>
</xsl:variable>

<xsl:param name="publish"/>

<xsl:template match="/document">
    <xsl:apply-templates select="context/object"/>
</xsl:template>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                <xsl:value-of select="title" /> - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script><script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr>
            <td align="center">
            <br />
            <!-- begin widget table -->
            <table width="200" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg">Publishing Event Successful</td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td><xsl:call-template name="message"/></td>
              </tr>
              <xsl:if test="$publish='Publish'">
                  <tr>
                    <td>This forum is now publicly available at <a href="{$xims_box}{$gopublic_content}{$absolute_path}" target="_new">
                        <xsl:value-of select="concat($xims_box,$gopublic_content,$absolute_path)"/></a><br/>
                    </td>
                  </tr>
              </xsl:if>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td align="center">
                    <xsl:call-template name="exitredirectform"/>
                </td>
              </tr>
            </table>
            <!-- end widget table -->
            <br />
            </td>
          </tr>
        </table>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

