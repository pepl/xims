<?xml version="1.0" encoding="utf-8" ?>
<!--
  # Copyright (c) 2002-2008 The XIMS Project.
  # See the file "LICENSE" for information and conditions for use, reproduction,
  # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
  # $Id: vlibraryitem_document_edit.xsl 1902 2008-01-25 12:17:28Z haensel $
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="vlibraryitem_document_edit_htmlarea.xsl"/>

  <xsl:template match="/document/context/object">

    <html>
      <xsl:call-template name="head"/>
      <body onload="initEditor();">
        <script src="{$ximsroot}scripts/vlibrary_default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <div class="edit">
          <xsl:call-template name="table-edit"/>
          <form action="{$xims_box}{$goxims_content}?id={@id}"
            name="eform"
            method="POST">
            <table border="0" width="98%">
              <xsl:call-template name="tr-locationtitle-edit_doc"/>
              <xsl:call-template name="tr-abstract"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'keyword'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'subject'"/>
              </xsl:call-template>
              <xsl:call-template name="tr-chronicle_from"/>
              <xsl:call-template name="tr-chronicle_to"/>
              <xsl:call-template name="markednew"/>
            </table>
            <xsl:call-template name="saveedit"/>
          </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="tr-abstract">
    <tr>
      <td colspan="2">
        <label for="vlsubject_description">
          <xsl:value-of select="$i18n_vlib/l/description"/>
        </label>
        <br />
        <textarea tabindex="40"
          name="abstract"
          rows="20"
          cols="90"
          id="body"
          style="width: 100%"
          class="text"
          title="{$i18n_vlib/l/description}">
          <xsl:value-of select="abstract"/>
        </textarea>
      </td>
    </tr>
  </xsl:template>


</xsl:stylesheet>
