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
<xsl:import href="common.xsl"/>
<xsl:output method="html" encoding="utf-8"/>
<xsl:param name="id"/>

<xsl:template match="/document/context/object">
    <html>
        <head>
            <title>
                Confirm Object Deletion - XIMS
            </title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript">0</script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
        <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <form name="objectdeletion" action="{$xims_box}{$goxims_content}" method="GET" style="margin-top: 0px; margin-left: 5px;">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table width="300" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg">Confirm Object Deletion</td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td>
                  <p>
                      You are about to delete the object '<xsl:value-of select="title"/>' from the system.
                  </p>
                  <p>
                      <strong>This is a <em>permanent</em> action that cannot be undone!</strong>
                  </p>
                  <p>
                      Click 'Confirm' to continue, or 'Cancel' to return to the previous screen.
                  </p>
                </td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td align="center">

                  <!-- begin buttons table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr align="center">
                      <td>
                        <input class="control" name="delete" type="submit" value="Confirm"/>
                        <input name="id" type="hidden" value="{$id}"/>
                        <xsl:call-template name="rbacknav"/>
                      </td>
                      <td>
                        <input class="control"
                               name="default"
                               type="button"
                               value="Cancel"
                               onClick="javascript:history.go(-1)"
                        />
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

</xsl:stylesheet>

