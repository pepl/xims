<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
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
                <xsl:value-of select="title" /> - XIMS
            </title>
            <xsl:call-template name="css"/>
        </head>
        <body>
        <xsl:call-template name="header">
          <xsl:with-param name="noncontent">true</xsl:with-param>
        </xsl:call-template>

        <form name="recursiveobjectcopy" action="{$xims_box}{$goxims_content}?id={@id}" method="GET" style="margin-top: 0px; margin-left: 5px;">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee" >
          <tr>
            <td align="center">

            <br />
            <!-- begin widget table -->
            <table width="300" cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td class="bluebg">Warning - Child Objects Found!</td>
              </tr>
              <tr>
                <td>&#160;</td>
              </tr>
              <tr>
                <td>
                    <p>
                        <xsl:value-of select="/document/context/session/warning_msg"/>
                        that could also be copied.
                    </p>
                    <p>
                        Include all children in copy:&#160;<input type="checkbox" name="recursivecopy" value="1" checked="true"/>
                    </p>
                    <p>
                        Click 'Confirm' to continue, or 'Cancel' to return to abort this action.
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
                        <input name="submit" type="submit" value="Confirm" class="control"/>
                        <input name="id" type="hidden" value="{$id}"/>
                        <input type="hidden" name="confirmcopy" value="1"/>
                        <input type="hidden" name="copy" value="1"/>
                      </td>
                      <td>
                        <input name="default" type="button" value="Cancel" onClick="javascript:history.go(-1)"  class="control"/>
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
          <xsl:call-template name="script_bottom"/>
        </form>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>

