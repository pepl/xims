<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:include href="portlet_common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head-edit"/>
      <body>
        <div class="edit">
          <xsl:call-template name="table-edit"/>
          <form action="{$xims_box}{$goxims_content}?id={@id}" 
                name="eform" 
                method="post">
            <table border="0" 
                   width="98%">
              <xsl:call-template name="tr-locationtitletarget-edit"/>
              <xsl:call-template name="tr-abstract-edit"/>
              <xsl:call-template name="markednew"/>
              <tr>
                <td colspan="3">
                  <xsl:call-template name="extra_properties"/>
                  <xsl:call-template name="contentoptions"/>
                  <xsl:call-template name="contentfilters"/>
                </td>
              </tr>
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

</xsl:stylesheet>

