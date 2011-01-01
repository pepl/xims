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

  <xsl:import href="vlibraryitem_common.xsl"/>
  <xsl:import href="document_common.xsl"/>

  <xsl:template name="tr_set-body-edit">
    <xsl:call-template name="tr-body-edit">
      <xsl:with-param name="with_origbody" select="'yes'"/>
    </xsl:call-template>
   
    <tr>
      <td colspan="3">
        <xsl:call-template name="testbodysxml"/>
        <xsl:call-template name="prettyprint"/>
      </td>
    </tr>
    <xsl:call-template name="trytobalance"/>
  </xsl:template>
  

  <xsl:template name="head">
    <xsl:call-template name="common-head">
      <xsl:with-param name="mode">edit</xsl:with-param>
      <xsl:with-param name="calendar" select="true()" />
      <xsl:with-param name="jquery" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="/document/context/object">
    <html>
      <xsl:call-template name="head"/>
      <body>
        <div class="edit">
          <xsl:call-template name="table-edit"/>
          <form action="{$xims_box}{$goxims_content}?id={@id}" 
                name="eform" 
                method="post">
            <table border="0" width="98%">
              <xsl:call-template name="tr-locationtitle-edit_doc"/>
              <xsl:call-template name="tr-subtitle"/>
              <xsl:call-template name="tr-abstract-edit"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'keyword'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'subject'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'author'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-vlproperties">
                <xsl:with-param name="mo" select="'publication'"/>
              </xsl:call-template>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-dc_date"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr_set-body-edit"/>    
              <xsl:call-template name="markednew"/>
              <xsl:call-template name="expandrefs"/>
              <tr><td colspan="3"> </td></tr>
              <xsl:call-template name="tr-publisher"/>
              <xsl:call-template name="tr-mediatype"/>
              <xsl:call-template name="tr-coverage"/>
              <xsl:call-template name="tr-audience"/>
              <xsl:call-template name="tr-legalnotice"/>
              <xsl:call-template name="tr-bibliosource"/>
            </table>
            <xsl:call-template name="saveedit"/>
          </form>
        </div>
        <br />
        <xsl:call-template name="canceledit"/>
        <script type="text/javascript" language="javascript">
          <xsl:text disable-output-escaping="yes">//&lt;![CDATA[</xsl:text>
          <xsl:call-template name="xmlhttpjs"/>          
function mkHandleMapResponse(xmlhttp, property) {
    var mapped_properties = 'mapped_' +  property + 's';
    var message_property  = 'message_' + property ;

    return function() {
       if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
            document.getElementById(mapped_properties).innerHTML = xmlhttp.responseText;
        }
        else {
            document.getElementById(message_property ).innerHTML
                = '<strong>' + xmlhttp.responseText + '</strong>';
        }
      }
    };
}


function post_async(poststr, extra) {
    var xmlhttp = getXMLHTTPObject(); 
    xmlhttp.onreadystatechange = mkHandleMapResponse(xmlhttp, extra);
    xmlhttp.open('post'
                 , '<xsl:value-of select="concat($xims_box
                                                ,$goxims_content
                                                ,/document/context/object/location_path)"/>'
                 , true);
    xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlhttp.setRequestHeader("Content-length", poststr.length);
    xmlhttp.setRequestHeader("Connection", "close");
    xmlhttp.send(poststr);
}

function refresh( property ) {
    $("#svl" + property + "container").load('<xsl:value-of select="concat($xims_box
                                                                         ,$goxims_content
                                                                         ,$parent_path)"/>?list_properties_items=1;property=' + property);

} 

<xsl:text disable-output-escaping="yes">
  //]]&gt;
</xsl:text>
        </script>
        <script src="{$ximsroot}scripts/vlibrary_edit.js" 
                type="text/javascript">
          <xsl:text>&#160;</xsl:text>
        </script>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
