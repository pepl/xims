<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_delete_confirm.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="common.xsl"/>
  <xsl:import href="../vlibrary_common.xsl"/>
  <xsl:output method="html" encoding="utf-8"/>
  <xsl:param name="author_id"/>
  <xsl:param name="author_firstname"/>
  <xsl:param name="author_middlename"/>
  <xsl:param name="author_lastname"/>
  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title>
          Löschen des Objekts bestätigen - XIMS
        </title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
      </head>
      <body margintop="0" marginleft="0" marginwidth="0" marginheight="0" background="{$skimages}body_bg.png">
        <form name="objectdeletion"
              action="{$xims_box}{$goxims_content}"
              method="GET"
              style="margin-top: 0px; margin-left: 5px;"
              onSubmit="window.opener.document.location.reload(); self.close();">

          <input name="id" id="id" type="hidden" value="{@id}"/>

          <table width="99%"
                 cellpadding="0"
                 cellspacing="0"
                 border="0"
                 bgcolor="#eeeeee">
            <tr>
              <td align="center">

                <br />
                <!-- begin widget table -->
                <table width="300"
                       cellpadding="2"
                       cellspacing="0"
                       border="0">
                  <tr>
                    <td class="bluebg">Löschen des Objekts bestätigen</td>
                  </tr>
                  <tr>
                    <td>&#160;</td>
                  </tr>
                  <tr>
                    <td>
                      <p>
                        Sie sind dabei den folgenden Eintrag zu löschen:
                      </p>
                      <p>
                        <em>
                          <xsl:value-of select="$author_firstname"/>&#160;
                          <xsl:value-of select="$author_middlename"/>&#160;
                          <xsl:value-of select="$author_lastname"/>
                        </em>
                      </p>
                      <p>
                        <strong>Dies ist eine <em>endgültige</em> Aktion und kann nicht rückgängig gemacht werden!</strong>
                      </p>
                      <p>
                        Klicken Sie auf 'Bestätigen' um fortzufahren, oder 'Abbrechen' um zurück zur vorigen Seite zu gelangen.
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
                            
                            <input type="submit" name="author_delete" id="author_delete" value="Bestätigen" class="control" accesskey="S"></input>
                            <input name="vlauthor_id" id="vlauthor_id" type="hidden" value="{$author_id}"/>
                            <!--<xsl:call-template name="rbacknav"/>-->
                          </td>
                          <td>
                            <input type="submit" name="cancel" id="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C"></input>
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

