<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibraryitem_document_create.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:import href="document_common.xsl"/>
  <xsl:import href="vlibraryitem_common.xsl"/>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="common-head">
        <xsl:with-param name="mode">create</xsl:with-param>
      </xsl:call-template>
      <body onLoad="document.eform.name.focus();">
        <div class="edit">
          <xsl:call-template name="table-create"/>
          <form action="{$xims_box}{$goxims_content}{$absolute_path}?objtype={$objtype}"
                name="eform" 
                method="POST" 
                enctype="multipart/form-data">
            <input type="hidden" 
                   name="objtype" 
                   value="{$objtype}"/>
            <table border="0"
                   width="98%">
              <xsl:call-template name="tr-locationtitle-create"/>
            </table>
            <input type="hidden"
                   name="proceed_to_edit"
                   value="1"/>
            <xsl:call-template name="saveaction"/>
          </form>
        </div>
        <br />
        <xsl:call-template name="cancelaction"/>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
