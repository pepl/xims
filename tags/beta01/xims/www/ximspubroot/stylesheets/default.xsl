<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcq="http://purl.org/dc/qualifiers/1.0/"
                xmlns="http://www.w3.org/TR/xhtml1/strict"
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
                 <!-- there is no textonly version needed at the moment, but it exists one -->
                <!--<xsl:text>&#160;&#160;</xsl:text>
                <a href="{$request.uri}?style=textonly">[textonly]</a>-->
            </td>
         </tr>
    <!-- End header -->
    </table>
    
    <table width="100%" border="0" style="margin-top: 20px; margin-left: 0px; padding-left: 0px">
       <tr>
            <td valign="top" class="links">
                <xsl:call-template name="stdlinks"/>
                <xsl:call-template name="deptlinks"/>
                <xsl:call-template name="documentlinks"/>
            </td>
            <td valign="top" align="left" class="content">
                <!--/UdmComment-->
                <xsl:apply-templates select="body"/>
            </td>
        </tr>
        <tr>
            <td valign="baseline" align="left">
                <xsl:call-template name="copyfooter"/>
            </td>
            <td valign="top" align="right">
                <xsl:call-template name="powerdbyfooter"/>
            </td>
        </tr>
        </table>
      </body>
    </html>
</xsl:template>

</xsl:stylesheet>
