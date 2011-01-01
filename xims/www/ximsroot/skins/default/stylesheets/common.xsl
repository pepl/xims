<?xml version="1.0" encoding="utf-8" ?>

<!-- 
Copyright (c) 2002-2011 The XIMS Project. 
See the file "LICENSE" for information and conditions for use, reproduction,
and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES. 

$Id$
-->

<!DOCTYPE stylesheet [
<!ENTITY  lc "'aäbcdefghijklmnoöpqrstuüvwxyz'">
<!ENTITY  uc "'AÄBCDEFGHIJKLMNOÖPQRSTUÜVWXYZ'">
]>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:dyn="http://exslt.org/dynamic"
                xmlns="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="dyn">

  <xsl:import href="../../../stylesheets/common.xsl" />
  <xsl:import href="common_footer.xsl" />
  <xsl:import href="common_header.xsl" />
  <xsl:import href="common_metadata.xsl" />
  <xsl:import href="common_localized.xsl" />
  <xsl:import href="common_jscalendar_scripts.xsl" />
  <xsl:import href="common_tinymce_scripts.xsl" />

  <xsl:output method="xml"
              omit-xml-declaration="yes"
              encoding="utf-8"
              media-type="text/html"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              indent="no"/>

  <xsl:variable name="i18n" select="document(concat($currentuilanguage,'/i18n.xml'))"/>
  <xsl:variable name="currobjmime" select="/document/data_formats/data_format[@id=/document/context/object/data_format_id]/mime_type"/>
  <!--
      save those strings in variables as they are called per
      object in object/children
  -->
  <!-- cttobject.options -->
  <xsl:variable name="l_Edit" select="$i18n/l/Edit" />
  <xsl:variable name="l_Move" select="$i18n/l/Move" />
  <xsl:variable name="l_Copy" select="$i18n/l/Copy" />
  <xsl:variable name="l_Publishing_options" select="$i18n/l/Publishing_options" />
  <xsl:variable name="l_Access_control" select="$i18n/l/Access_control" />
  <xsl:variable name="l_Undelete" select="$i18n/l/Undelete" />
  <xsl:variable name="l_purge" select="$i18n/l/purge" />
  <xsl:variable name="l_delete" select="$i18n/l/delete" />
  <!-- cttobject.status -->
  <xsl:variable name="l_Object_marked_new" select="$i18n/l/Object_marked_new" />
  <xsl:variable name="l_New" select="$i18n/l/New" />
  <xsl:variable name="l_Published" select="$i18n/l/Published" />
  <xsl:variable name="l_Object_last_published" select="$i18n/l/Object_last_published" />
  <xsl:variable name="l_by" select="$i18n/l/by" />
  <xsl:variable name="l_at_place" select="$i18n/l/at_place" />
  <xsl:variable name="l_Object_modified" select="$i18n/l/Object_modified" />
  <xsl:variable name="l_at_time" select="$i18n/l/at_time" />
  <xsl:variable name="l_changed" select="$i18n/l/changed" />
  <xsl:variable name="l_Unlock" select="$i18n/l/Unlock" />
  <xsl:variable name="l_Release_lock" select="$i18n/l/Release_lock" />
  <xsl:variable name="l_Locked" select="$i18n/l/Locked" />
  <xsl:variable name="l_Object_locked" select="$i18n/l/Object_locked" />


  <xsl:template name="cancelaction">
    <table border="0" align="center" width="98%">
      <tr>
        <td>
          <xsl:call-template name="cancelcreateform" />
        </td>
      </tr>
    </table>
    <!-- inline popup hidden HTML code -->
    <xsl:call-template name="inlinepopup">
      <xsl:with-param name="winlabel" select="$i18n/l/IlpDefaultWinlabel" />
      <!--
          optional parameter to show a close button <xsl:with-param
          name="showclosebutton" select="true()"/>
      -->
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="canceledit">
    <table border="0" align="center" width="98%">
      <tr>
        <td>
          <xsl:call-template name="cancelform" />
        </td>
      </tr>
    </table>
    <!-- inline popup hidden HTML code -->
    <xsl:call-template name="inlinepopup">
      <xsl:with-param name="winlabel" select="$i18n/l/IlpDefaultWinlabel" />
      <!--
          optional parameter to show a close button <xsl:with-param
          name="showclosebutton" select="true()"/>
      -->
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="cancelform">
    <xsl:param name="with_save" select="'no'" />
    <!--
        method get is needed, because goxims does not handle a PUTed 'id'
    -->
    <form action="{$xims_box}{$goxims_content}" name="cform" method="get" id='cform-{$with_save}'
          style="margin-top:0px; margin-bottom:0px; margin-left:-5px; margin-right:0px;">
      <input type="hidden" name="id" value="{@id}" />
      <xsl:if test="$with_save = 'yes'">
        <xsl:call-template name="save_jsbutton" />
      </xsl:if>
      <xsl:call-template name="rbacknav" />
      <input type="submit" name="cancel" value="{$i18n/l/cancel}"
             class="control" accesskey="C" />
    </form>
  </xsl:template>


  <xsl:template name="cancelcreateform">
    <xsl:param name="with_save" select="'no'" />
    <form action="{$xims_box}{$goxims_content}{$absolute_path}"
          method="post">
      <xsl:if test="$with_save = 'yes'">
        <xsl:call-template name="save_jsbutton" />
      </xsl:if>
      <xsl:call-template name="rbacknav" />
      <input type="submit" name="cancel_create" value="{$i18n/l/cancel}"
             class="control" accesskey="C" />
    </form>
  </xsl:template>


  <xsl:template name="save_jsbutton">
    <script type="text/javascript">
      <xsl:text disable-output-escaping="yes">//&lt;![CDATA[</xsl:text>
      document.write(
        '<input type="submit" name="submit_eform" value="{$i18n/l/save}" onclick="document.eform.store.click(); return false" class="control" />'
      );
      <xsl:text disable-output-escaping="yes">//]]&gt;</xsl:text>
    </script>
  </xsl:template>


  <xsl:template name="exitredirectform">
    <xsl:variable name="object_type_id" select="object_type_id" />
    <xsl:variable name="parent_id" select="@parent_id" />
    <form name="userConfirm" action="{$xims_box}{$goxims_content}"
          method="get">
      <input class="control" name="exit" type="submit" value="Done" />
      <xsl:choose>
        <xsl:when test="$r != ''">
          <input name="id" type="hidden" value="{$r}" />
          <input name="page" type="hidden" value="{$page}" />
          <input name="sb" type="hidden" value="{$sb}" />
          <input name="order" type="hidden" value="{$order}" />
        </xsl:when>
        <xsl:otherwise>
          <input name="id" type="hidden">
            <xsl:choose>
              <xsl:when
                  test="/document/object_types/object_type[@id=$object_type_id]/redir_to_self='0'">
                <xsl:attribute name="value">
                  <xsl:value-of select="parents/object[@document_id=$parent_id]/@id" />
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="value">
                  <xsl:value-of select="@id" />
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </input>
        </xsl:otherwise>
      </xsl:choose>
    </form>
  </xsl:template>


  <xsl:template name="saveaction">
    <input type="hidden" name="id"
           value="{/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id}" />
    <xsl:if
        test="/document/object_types/object_type[name=$objtype]/redir_to_self='0'">
      <input name="sb" type="hidden" value="date" />
      <input name="order" type="hidden" value="desc" />
    </xsl:if>
    <input type="submit" name="store" value="{$i18n/l/save}" class="control"
           accesskey="S" />
  </xsl:template>


  <xsl:template name="saveedit">
    <input type="hidden" name="id" value="{@id}" />
    <xsl:if
        test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
      <input name="sb" type="hidden" value="date" />
      <input name="order" type="hidden" value="desc" />
    </xsl:if>
    <input type="submit" name="store" value="{$i18n/l/save}" class="control"
           accesskey="S" />
  </xsl:template>


  <xsl:template name="grantowneronly">
    <tr>
      <td valign="top" width="135">
        <xsl:value-of select="$i18n/l/Priv_grant_options" />
      </td>
      <td valign="top">
        <input name="owneronly" type="radio" value="false" checked="checked" />
        <xsl:value-of select="$i18n/l/Copy_parent_privs" />
        <input name="owneronly"
               type="radio" 
               value="true"
               onclick="document.eform.defaultroles.disabled = true;" 
               onblur="document.eform.defaultroles.disabled = false;" />
        <xsl:value-of select="$i18n/l/Grant_myself_only" />
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('PrivilegeGrantOptions')" class="doclink">
        (?)</a>
        <div>
          <xsl:text>&#160;&#160;</xsl:text>
          <xsl:value-of select="$i18n/l/Grant_default_roles"/>
          <xsl:text>: </xsl:text>
          <input name="defaultroles" type="checkbox" value="true"/>
        </div>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="markednew">
    <tr>
      <td colspan="3">
        <xsl:value-of select="$i18n/l/Mark_new"/>
        <input name="markednew" type="radio" value="true">
          <xsl:if test="marked_new = '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
          </input><xsl:value-of select="$i18n/l/Yes"/>
          <input name="markednew" type="radio" value="false">
            <xsl:if test="marked_new != '1'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
            </input><xsl:value-of select="$i18n/l/No"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('markednew')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="expandrefs">
    <!-- Temporarily disabled until implemented by the application class
    <tr>
        <td colspan="3">
        <xsl:value-of select="$i18n/l/Publish_ref_objects"/>:
        <input name="expandrefs" type="radio" value="true">
          <xsl:if test="attributes/expandrefs = '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/Yes"/>
        <input name="expandrefs" type="radio" value="false">
          <xsl:if test="attributes/expandrefs != '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input><xsl:value-of select="$i18n/l/No"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('expandrefs')" class="doclink">(?)</a>
        </td>
    </tr>
    -->
  </xsl:template>


  <xsl:template name="common-head">
    <!-- param mode to set the HTML title -->
    <xsl:param name="mode">create</xsl:param>
    <!-- with the following parameters different options can be integratetd into the HTML HEAD
         currently available:
         calendar: Integration of jscalendar (not included in xims, install seperately)
         tinymce
         jquery
    -->
    <xsl:param name="calendar" select="false()" />
    <xsl:param name="tinymce" select="false()" />
    <xsl:param name="jquery" select="false()" />
    <head>
      <title>
        <xsl:if test="$mode='create'">
          <xsl:value-of select="$i18n/l/create"/>
        </xsl:if>
        <xsl:if test="$mode='edit'">
          <xsl:value-of select="$i18n/l/edit"/>
        </xsl:if>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$objtype"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$i18n/l/in"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$absolute_path"/>
        <xsl:text> - XIMS</xsl:text>
      </title>
      <xsl:call-template name="css"/>
      <xsl:if test="$calendar">
        <xsl:call-template name="jscalendar_scripts" />
      </xsl:if>
      <xsl:if test="$tinymce">
        <xsl:call-template name="tinymce_scripts"/>
      </xsl:if>
      <xsl:if test="$jquery">
        <script src="{$jquery}" type="text/javascript"/>
      </xsl:if>
    </head>
  </xsl:template>


  <xsl:template name="head-create">
    <head>
      <title>
      <xsl:value-of select="$i18n/l/create"/>
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="$objtype"/>
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="$i18n/l/in"/>
      <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="$absolute_path"/>
      <xsl:text> - XIMS</xsl:text> 
      </title>
      <xsl:call-template name="css"/>
      <xsl:call-template name="script_head"/>
    </head>
  </xsl:template>


  <xsl:template name="head-edit">
    <head>
      <title>
        <xsl:value-of select="$i18n/l/edit"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$objtype"/>
        <xsl:text>&#160;'</xsl:text>
        <xsl:value-of select="title"/>
        <xsl:text>' </xsl:text>
        <xsl:value-of select="$i18n/l/in"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$parent_path"/>
        <xsl:text> - XIMS</xsl:text>
      </title>
      <xsl:call-template name="css"/>
      <xsl:call-template name="script_head"/>
    </head>
  </xsl:template>


  <xsl:template name="table-create">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
      <tr>
        <td valign="top">
          <xsl:value-of select="$i18n/l/create"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$objtype"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$i18n/l/in"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$absolute_path"/>
        </td>
        <td align="right" valign="top">
          <xsl:call-template name="cancelcreateform">
            <xsl:with-param name="with_save">yes</xsl:with-param>
          </xsl:call-template>
        </td>
      </tr>
    </table>
  </xsl:template>


  <xsl:template name="table-edit">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
      <tr>
        <td valign="top">
          <xsl:value-of select="$i18n/l/edit"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$objtype"/>
          <xsl:text>&#160;'</xsl:text>
          <xsl:value-of select="title"/>
          <xsl:text>' </xsl:text>
          <xsl:value-of select="$i18n/l/in"/>
          <xsl:text>&#160;</xsl:text>
          <xsl:value-of select="$parent_path"/>
        </td>
        <td align="right" valign="top">
          <xsl:call-template name="cancelform">
            <xsl:with-param name="with_save">yes</xsl:with-param>
          </xsl:call-template>
        </td>
      </tr>
    </table>
  </xsl:template>


  <xsl:template name="tr-locationtitle-create">
    <xsl:call-template name="tr-location-create"/>
    <xsl:call-template name="tr-title-create"/>
  </xsl:template>


  <xsl:template name="tr-locationtitle-edit">
    <xsl:call-template name="tr-location-edit"/>
    <xsl:call-template name="tr-title-edit"/>
  </xsl:template>


  <xsl:template name="tr-location-create">
    <xsl:param name="testlocation" select="true()"/>
    <tr>
      <td valign="top">
        <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
        <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
      </td>
      <td>
        <input tabindex="10" 
               type="text" 
               name="name" 
               size="40" 
               class="text"
               onfocus="this.className='text focused'"
               onblur="this.className='text';">
          <xsl:if test="$testlocation">
            <xsl:attribute name="onchange">return testlocation();</xsl:attribute>
          </xsl:if>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        <!-- location-testing AJAX code -->
        <xsl:if test="$testlocation">
          <xsl:call-template name="testlocationjs">
            <xsl:with-param name="event" select="'create'"/>
          </xsl:call-template>
        </xsl:if>
      </td>
      <td align="right" valign="top">
        <xsl:call-template name="marked_mandatory"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-location-edit">
    <xsl:param name="testlocation" select="true()"/>
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:variable name="publish_gopublic">
      <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
    </xsl:variable>
    <tr>
      <td valign="top">
        <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
        <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
      </td>
      <td>
        <input tabindex="10" type="text" name="name" size="40" value="{location}">
          <xsl:choose>
            <xsl:when test="$publish_gopublic = '0' and published = '1'">
              <xsl:attribute name="readonly">readonly</xsl:attribute>
              <xsl:attribute name="class">readonlytext</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">text</xsl:attribute>
              <xsl:attribute name="onfocus">this.className='text focused'</xsl:attribute>
              <xsl:if test="$testlocation">
                <xsl:attribute name="onchange">this.className='text'; return testlocation();</xsl:attribute>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        <!-- we only test locations for unpublished docs -->
        <xsl:if test="published = '0'">
          <!-- location-testing AJAX code -->
          <xsl:if test="$testlocation">
            <xsl:call-template name="testlocationjs">
              <xsl:with-param name="event" 
                              select="'edit'"/>
              <xsl:with-param name="obj_type"
                              select="/document/object_types/object_type[@id=$objecttype]/fullname"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>
      </td>
      <td align="right" valign="top">
        <xsl:call-template name="marked_mandatory"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-title-create">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Title"/></td>
      <td colspan="2">
        <input tabindex="20" type="text" name="title" size="60" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-title-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Title"/></td>
      <td colspan="2">
        <input tabindex="20" type="text" name="title" size="60" value="{title}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-locationtitle-edit_xml">
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <tr>
      <td valign="top">
        <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
        <span class="compulsory"><xsl:value-of select="$i18n/l/Location"/></span>
      </td>
      <td>
        <!-- strip suffix; leave it, if it's a sdbk with lang-extension -->
        <input tabindex="10" type="text" name="name" size="40" value="{location}">
          <xsl:choose>
            <xsl:when test="published = '1'">
              <xsl:attribute name="readonly">readonly</xsl:attribute>
              <xsl:attribute name="class">readonlytext</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">text</xsl:attribute>
              <xsl:attribute name="onfocus">this.className='text focused'</xsl:attribute>
              <xsl:attribute name="onblur">this.className='text'; return testlocation();</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        <xsl:if test="not(published = 1)">
          <!-- location-testing AJAX code -->
          <xsl:call-template name="testlocationjs">
            <xsl:with-param name="event" select="'edit'"/>
            <xsl:with-param name="obj_type" select="/document/object_types/object_type[@id=$objecttype]/fullname"/>
          </xsl:call-template>
        </xsl:if>
      </td>
      <td align="right" valign="top">
        <xsl:call-template name="marked_mandatory"/>
      </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
  </xsl:template>


  <xsl:template name="tr-bodyfromfile-create">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/bodyfromfile_create"/></td>
      <td colspan="2">
        <input tabindex="30" type="file" name="file" size="49" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BodyFile')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-bodyfromfile-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/bodyfromfile_edit"/></td>
      <td colspan="2">
        <input tabindex="30" type="file" name="file" size="49" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('BodyFile')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="jsorigbody">
    <xsl:call-template name="mk-inline-js"> 
      <xsl:with-param name="code">  
      var origbody = document.getElementById('body').value;
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="tr-body-create">
    <xsl:param name="with_origbody" select="'no'"/>
    <tr>
      <td colspan="3">
        Body
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
        <br/>

        <xsl:call-template name="textarearesize_js_css"/>
        <div id="bodymain">
          <div id="bodycon">
            <textarea tabindex="30" name="body" id="body" rows="15" cols="90">&#160;</textarea>
            <!-- TOP DRAG BAR -->
            <div id="T" class="brd"></div>
            <!-- LEFT DRAG BAR -->
            <div id="L" class="brd"></div>
            <!-- BOTTOM DRAG BAR -->
            <div id="B" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
            <div id="BR" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
            <!-- RIGHT DRAG BAR -->
            <!-- When ID "R" is used here, MSIE won't scale the right drag bar correctly, using "U" therefore -->
            <div id="U" class="brd edg v" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
            <div id="UB" class="brd edg nw" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
          </div>
        </div>

        <xsl:if test="$with_origbody = 'yes'">
          <xsl:call-template name="jsorigbody"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-body-edit">
    <xsl:param name="with_origbody" select="'no'"/>
    <tr>
      <td colspan="3">
        Body
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
        <br/>

        <xsl:call-template name="textarearesize_js_css"/>
        <div id="bodymain">
          <div id="bodycon">
            <textarea tabindex="30" name="body" id="body" rows="15" cols="90" >
              <xsl:choose>
                <xsl:when test="string-length(body) &gt; 0">
                  <xsl:apply-templates select="body"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>&#160;</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </textarea>
            <!-- TOP DRAG BAR -->
            <div id="T" class="brd"></div>
            <!-- LEFT DRAG BAR -->
            <div id="L" class="brd"></div>
            <!-- BOTTOM DRAG BAR -->
            <div id="B" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
            <div id="BR" class="brd edg h" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
            <!-- RIGHT DRAG BAR -->
            <!-- When ID "R" is used here, MSIE won't scale the right drag bar correctly, using "U" therefore -->
            <div id="U" class="brd edg v" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
            <div id="UB" class="brd edg nw" onmousedown="MD(event, this)" onmouseup="MU(event, this)"></div>
          </div>
        </div>

        <xsl:if test="$with_origbody = 'yes'">
          <xsl:call-template name="jsorigbody"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-keywords-create">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Keywords"/></td>
      <td colspan="2">
        <input tabindex="40" type="text" name="keywords" size="60" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-keywords-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Keywords"/></td>
      <td colspan="2">
        <input tabindex="40" type="text" name="keywords" size="60" value="{keywords}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <!-- Legacy -->
  <xsl:template name="tr-abstract-create">
    <xsl:call-template name="tr-abstract-edit"/>
  </xsl:template>


  <xsl:template name="tr-abstract-edit">
    <tr>
      <td valign="top" colspan="3">
        <xsl:value-of select="$i18n/l/Abstract"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
        <br />
        <textarea tabindex="50" name="abstract" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
          <xsl:apply-templates select="abstract"/>
        </textarea>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-notes">
    <tr>
      <td valign="top" colspan="3">
        <xsl:value-of select="$i18n/l/Notes"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Notes')" class="doclink">(?)</a>
        <br />
        <textarea tabindex="50" name="notes" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
          <xsl:apply-templates select="notes"/>
        </textarea>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-stylesheet-create">
    <xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Stylesheet"/></td>
      <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet')" class="doclink"><xsl:value-of select="$i18n/l/Browse_stylesheet"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-stylesheet-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Stylesheet"/></td>
      <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="{style_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet,Folder;sbfield=eform.stylesheet')" class="doclink"><xsl:value-of select="$i18n/l/Browse_stylesheet"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-css-create">
    <xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/CSS"/></td>
      <td colspan="2">
        <input tabindex="30" type="text" name="css" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('CSS')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=CSS;sbfield=eform.css')" class="doclink"><xsl:value-of select="$i18n/l/Browse_css"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-css-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/CSS"/></td>
      <td colspan="2">
        <input tabindex="30" type="text" name="css" size="40" value="{css_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('CSS')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=CSS;sbfield=eform.css')" class="doclink"><xsl:value-of select="$i18n/l/Browse_css"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-script-create">
    <xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/JavaScript"/></td>
      <td colspan="2">
        <input tabindex="30" type="text" name="script" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('JavaScript')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=JavaScript;sbfield=eform.script')" class="doclink"><xsl:value-of select="$i18n/l/Browse_script"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-script-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/JavaScript"/></td>
      <td colspan="2">
        <input tabindex="30" type="text" name="script" size="40" value="{script_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('JavaScript')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=JavaScript;sbfield=eform.script')" class="doclink"><xsl:value-of select="$i18n/l/Browse_script"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-feed-create">
    <xsl:variable name="parentid" select="parents/object[@document_id=/document/context/object/@parent_id]/@id"/>
    <tr>
      <td valign="top">RSS-Feed</td>
      <td colspan="2">
        <input tabindex="30" type="text" name="feed" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Portlet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};contentbrowse=1;to={$parentid};otfilter=Portlet;sbfield=eform.feed')" class="doclink"><xsl:value-of select="$i18n/l/Browse_feed"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-feed-edit">
    <tr>
      <td valign="top">RSS-Feed</td>
      <td colspan="2">
        <input tabindex="30" type="text" name="feed" size="40" value="{feed_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Portlet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.feed')" class="doclink"><xsl:value-of select="$i18n/l/Browse_feed"/></a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="jscalendar-selector">
    <xsl:param name="timestamp_string"/>
    <xsl:param name="formfield_id"/>
    <xsl:param name="default_value" select="'creation_timestamp'"/>

    <input tabindex="40" type="hidden" name="{$formfield_id}" id="{$formfield_id}">
        <xsl:attribute name="value">
            <xsl:value-of select="$timestamp_string"/>
        </xsl:attribute>
    </input>
    <span id="show_vft{$formfield_id}"><xsl:value-of select="$timestamp_string"/></span>
    <xsl:text>&#160;</xsl:text>
    <img src="{$skimages}calendar.gif"
         id="f_trigger_vft{$formfield_id}"
         style="cursor: pointer;"
         alt="{$i18n/l/Date_selector}"
         title="{$i18n/l/Date_selector}"
         onmouseover="this.style.background='red';"
         onmouseout="this.style.background=''"/>

    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">  
        var current_datestring = "<xsl:value-of select="$timestamp_string"/>";
        var current_date;
        if ( current_datestring.length > 0 ) {
            current_date = Date.parseDate(current_datestring, "%Y-%m-%d %H:%M").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = current_date;
        }
        else {
            document.getElementById("show_vft<xsl:value-of select="$formfield_id"/>").innerHTML = "<xsl:choose><xsl:when test="default_value='creation_timestamp'"><xsl:value-of select="$i18n/l/Valid_from_default_creation_timestamp"/></xsl:when><xsl:otherwise><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:otherwise></xsl:choose>"
        }
        Calendar.setup({
            inputField     :    "<xsl:value-of select="$formfield_id"/>",
            ifFormat       :    "%Y-%m-%d %H:%M",
            displayArea    :    "show_vft<xsl:value-of select="$formfield_id"/>",
            daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
            button         :    "f_trigger_vft<xsl:value-of select="$formfield_id"/>",
            align          :    "Tl",
            singleClick    :    true,
            showsTime      :    true,
            timeFormat     :    "24"
        });
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="tr-valid_from">
    <xsl:variable name="valid_from_timestamp_tmp">
      <xsl:apply-templates select="valid_from_timestamp" mode="ISO8601-MinNoT"/>
    </xsl:variable>
    <xsl:variable name="valid_from_timestamp">
      <xsl:if test="$valid_from_timestamp_tmp != '-- :'">
        <xsl:value-of select="$valid_from_timestamp_tmp"/>
      </xsl:if>
    </xsl:variable>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Valid_from"/></td>
      <td colspan="2">
        <xsl:call-template name="jscalendar-selector">
          <xsl:with-param name="timestamp_string" select="$valid_from_timestamp"/>
          <xsl:with-param name="formfield_id" select="'valid_from_timestamp'"/>
        </xsl:call-template>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Valid_from')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-valid_to">
    <xsl:variable name="valid_to_timestamp_tmp">
      <xsl:apply-templates select="valid_to_timestamp" mode="ISO8601-MinNoT"/>
    </xsl:variable>
    <xsl:variable name="valid_to_timestamp">
      <xsl:if test="$valid_to_timestamp_tmp != '-- :'">
        <xsl:value-of select="$valid_to_timestamp_tmp"/>
      </xsl:if>
    </xsl:variable>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n/l/Valid_to"/></td>
      <td colspan="2">
        <xsl:call-template name="jscalendar-selector">
          <xsl:with-param name="timestamp_string" select="$valid_to_timestamp"/>
          <xsl:with-param name="formfield_id" select="'valid_to_timestamp'"/>
        </xsl:call-template>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Valid_to')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="cttobject.status">
    <xsl:variable name="objecttype">
      <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:variable name="publish_gopublic">
      <xsl:value-of select="/document/object_types/object_type[@id=$objecttype]/publish_gopublic"/>
    </xsl:variable>
    <xsl:variable name="published_path_base">
      <xsl:choose>
        <xsl:when test="$resolvereltositeroots = 1 and $publish_gopublic = 0">
          <xsl:value-of select="$absolute_path_nosite"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$absolute_path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="object_path">
      <xsl:choose>
        <xsl:when test="local-name(..) = 'children'">
          <xsl:value-of select="concat($published_path_base,'/',location)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$published_path_base"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="published_path">
      <xsl:choose>
        <xsl:when test="$publish_gopublic = 0">
          <xsl:value-of select="concat($publishingroot,$object_path)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($xims_box,$gopublic_content,$object_path)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="cttobject_status">
      <xsl:choose>
        <xsl:when test="marked_new= '1'">
          <span class="xims-sprite sprite-status_new" title="{$l_Object_marked_new}">
            <span>
              <xsl:value-of select="$l_Object_marked_new"/>
            </span>
            &#160;
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="cttobject.status.spacer"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="published = '1'">          
          <a href="{$published_path}" target="_blank">
            <xsl:choose>
              <xsl:when test="concat(last_modification_timestamp/year,
                                     last_modification_timestamp/month,
                                     last_modification_timestamp/day,
                                     last_modification_timestamp/hour,
                                     last_modification_timestamp/minute,
                                     last_modification_timestamp/second)
                        &lt;= concat(last_publication_timestamp/year,
                                     last_publication_timestamp/month,
                                     last_publication_timestamp/day,
                                     last_publication_timestamp/hour,
                                     last_publication_timestamp/minute,
                                     last_publication_timestamp/second)">
                <xsl:attribute name="class">xims-sprite sprite-status_pub</xsl:attribute>                           
                <xsl:attribute name="title">
                  <xsl:value-of select="$l_Object_last_published"/>
                  <xsl:text> </xsl:text>
                  <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_by"/>
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="lastpublisherfullname"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_at_place"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$published_path"/>
                </xsl:attribute>
                &#xa0;
                <span>
                  <xsl:value-of select="$l_Object_last_published"/>
                  <xsl:text> </xsl:text>
                  <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_by"/>
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="lastpublisherfullname"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_at_place"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$published_path"/>
                </span>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class">xims-sprite sprite-status_pub_async</xsl:attribute>
                <xsl:attribute name="title">
                  <xsl:value-of select="$l_Object_modified"/>
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="lastpublisherfullname"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_at_time"/>
                  <xsl:text> </xsl:text>
                  <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_changed"/>
                </xsl:attribute>			
                &#xa0;
                <span> 
                  <xsl:value-of select="$l_Object_modified"/>
                  <xsl:text> </xsl:text>
                  <xsl:call-template name="lastpublisherfullname"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_at_time"/>
                  <xsl:text> </xsl:text>
                  <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$l_changed"/>
                </span>
              </xsl:otherwise>
            </xsl:choose>
          </a>   
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="cttobject.status.spacer"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="locked_by_id != '' and locked_time != '' and locked_by_id = /document/context/session/user/@id">
          <a class="xims-sprite sprite-status_locked"
             title="{$l_Release_lock}">
            <xsl:attribute name="href">
              <xsl:value-of select="concat($goxims_content,'?id=',@id,';cancel=1;r=',/document/context/object/@id)"/>
              <xsl:if test="$currobjmime='application/x-container'">
                <xsl:value-of select="concat(';page=',$page)"/>
              </xsl:if>
              <xsl:if test="$currobjmime='application/x-container' and $defsorting != 1">
                <xsl:value-of select="concat(';sb=',$sb,';order=',$order)"/>
              </xsl:if>
            </xsl:attribute>
            <span>
              <xsl:value-of select="$l_Release_lock"/>
            </span>
            &#160;
          </a>
        </xsl:when>
        <xsl:when test="locked_by_id != '' and locked_time != ''">
          <a class="xims-sprite sprite-status_locked">
            <xsl:attribute name="title">
              <xsl:value-of select="$l_Object_locked"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="locked_time" mode="datetime"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="$l_by"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="lockerfullname"/>.
            </xsl:attribute>
            <span>
              <xsl:value-of select="$l_Object_locked"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="locked_time" mode="datetime"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="$l_by"/>
              <xsl:text> </xsl:text>
              <xsl:call-template name="lockerfullname"/>.
            </span>
            &#160;
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="cttobject.status.spacer"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>


  <xsl:template name="cttobject.options">
    <span class="cttobject_options">
      <xsl:call-template name="cttobject.options.edit"/>
      <xsl:call-template name="cttobject.options.copy"/>
      <xsl:call-template name="cttobject.options.move"/>
      <xsl:call-template name="cttobject.options.publish"/>
      <xsl:call-template name="cttobject.options.acl_or_undelete"/>
      <xsl:call-template name="cttobject.options.purge_or_delete"/>
    </span>
  </xsl:template>


  <xsl:template name="cttobject.options.edit">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="marked_deleted != '1' 
                      and user_privileges/write 
                      and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
        <a class="xims-sprite sprite-option_edit"
           title="{$l_Edit}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';edit=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;
          <span><xsl:value-of select="$l_Edit"/></span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="cttobject.options.spacer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="cttobject.options.copy">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="marked_deleted != '1' 
                  and user_privileges/copy 
                  and /document/context/object/user_privileges/create">
        <a class="xims-sprite sprite-option_copy"
           title="{$l_Copy}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';copy=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;<span>
          <xsl:value-of select="$l_Copy"/></span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="cttobject.options.spacer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="cttobject.options.move">
    <xsl:variable name="parentid" select="@parent_id"/>
    <xsl:variable name="id" select="@id"/>
    <xsl:variable name="to">
      <xsl:choose>
        <xsl:when test="$currobjmime='application/x-container'">
          <xsl:value-of select="/document/context/object/@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/document/context/object/parents/object[@document_id=$parentid]/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="marked_deleted != '1' 
                      and user_privileges/move and published != '1'  
                      and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
        <a class="xims-sprite sprite-option_move"
           title="{$l_Move}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';move_browse=1;to=',$to)"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;
          <span><xsl:value-of select="$l_Move"/></span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="cttobject.options.spacer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="cttobject.options.publish">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="marked_deleted != '1'
                      and (user_privileges/publish|user_privileges/publish_all)  
                      and (locked_time = '' or locked_by_id = /document/context/session/user/@id) ">
        <a class="xims-sprite sprite-option_pub"
           title="{$l_Publishing_options}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';publish_prompt=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;
          <span><xsl:value-of select="$l_Publishing_options"/></span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="cttobject.options.spacer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="cttobject.options.acl_or_undelete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="marked_deleted != '1' 
                      and (user_privileges/grant|user_privileges/grant_all) 
                      and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
        <a class="xims-sprite sprite-option_acl"
           title="{$l_Access_control}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';obj_acllist=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
            <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,
                                         ';r=',/document/context/object/@id)"/></xsl:if>
          </xsl:attribute>
          &#xa0;<span><xsl:value-of select="$l_Access_control"/></span>
        </a>
      </xsl:when>
      <xsl:when test="user_privileges/delete and marked_deleted = '1'">
        <a class="xims-sprite sprite-option_undelete"
           title="{$l_Undelete}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';undelete=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;<span><xsl:value-of select="$l_Undelete"/></span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="cttobject.options.spacer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="cttobject.options.purge_or_delete">
    <xsl:variable name="id" select="@id"/>
    <xsl:choose>
      <xsl:when test="user_privileges/delete and marked_deleted = '1'">
        <a class="xims-sprite sprite-option_purge"
           title="{$l_purge}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';delete_prompt=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;<span><xsl:value-of select="$l_purge"/></span>
        </a>
      </xsl:when>
      <xsl:when test="user_privileges/delete and published != '1'  
                      and (locked_time = '' or locked_by_id = /document/context/session/user/@id)">
        <a class="xims-sprite sprite-option_delete"
           title="{$l_delete}">
          <xsl:attribute name="href">
            <xsl:value-of select="concat($goxims_content,'?id=',$id,';trashcan_prompt=1')"/>
            <xsl:if test="$currobjmime='application/x-container'">
              <xsl:value-of select="concat(';sb=',$sb,';order=',$order,';page=',$page,';hd=',$hd,
                                           ';r=',/document/context/object/@id)"/>
            </xsl:if>
          </xsl:attribute>
          &#xa0;<span><xsl:value-of select="$l_delete"/></span>
        </a>
      </xsl:when>     
      <xsl:otherwise>
        <xsl:call-template name="cttobject.options.spacer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="cttobject.options.spacer">
    <span class="xims-sprite sprite-spacer">&#xa0;</span>
  </xsl:template>


  <xsl:template name="cttobject.status.spacer">
    <span class="xims-sprite sprite-status-spacer">&#xa0;</span>
  </xsl:template>


  <xsl:template name="cttobject.del.spacer">
    <span class="xims-sprite-del-spacer">&#xa0;</span>
  </xsl:template>

  <xsl:template name="cttobject.dataformat">
    <xsl:param name="dfname" select="/document/data_formats/data_format[@id=current()/data_format_id]/name"/>
    <xsl:choose>
      <xsl:when test="marked_deleted=1">
        <xsl:attribute name="bgcolor">#c6c6c6</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <span class="sprite-list sprite-list_{$dfname}">
      <span>
        <xsl:value-of select="$dfname"/>
    </span>&#xa0;</span>
  </xsl:template>

  <xsl:template name="toggle_hls">
    <xsl:if test="$hls != ''">
      <div id="toggle_highlight">
        <form>
          <xsl:value-of select="$i18n/l/you_searched_for"/> '<xsl:value-of select="$hls"/>'.
          <input type="button" value="{$i18n/l/toggle_hls}" onclick="toggleHighlight(getParamValue('hls'))"/>
        </form>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template name="textarearesize_js_css">
    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code"><![CDATA[

    /*
     * The following code is based on the discussion thread available at
     * http://www.webdeveloper.com/forum/showthread.php?t=64005
     *
    */

    var l=0;
    var t=0;
    var w=748;
    var h=260;
    var minw=w;
    var minh=h;

    var dragon=false;
    var dragsrc=null;
    var ox=0;
    var oy=0;
    var dx=0;
    var dy=0;

    var nw=0;
    var nh=0;
    var nt=0;
    var nl=0;

    function repositionAll() {
      nl=l;
      nt=t;
      nw=w;
      nh=h;
      if(dragsrc.id.indexOf("U")>=0) {
        //move the right
        if((nw+dx)>minw) nw+=dx;
        else nw=minw;
      }
      if(dragsrc.id.indexOf("B")>=0) {
        //move the bottom
        if((nh+dy)>minh) nh+=dy;
        else nh=minh;
      }
      if(nw<minw) { nl=l+w-minw; nw=minw; }
      if(nh<minh) { nt=t+h-minh; nh=minh; }
      window.status="("+(nl)+", "+(nt)+") ["+(nw)+"X"+(nh)+"]";
      document.getElementById("bodycon").style.width=nw+"px";
      document.getElementById("bodycon").style.height=nh+"px";

      document.getElementById("L").style.height=(nh-40)+"px";
      document.getElementById("T").style.width=(nw-40)+"px";
      document.getElementById("U").style.height=(nh-40)+"px";
      document.getElementById("B").style.width=(nw-40)+"px";


      document.getElementById("body").style.width=(nw-8)+"px";
      document.getElementById("body").style.height=(nh-8)+"px";
    }

    function MD(event, src) {
      if(event==null) event=window.event;
      dragon=true;
      dragsrc=src;
      ox=parseInt(event.clientX);
      oy=parseInt(event.clientY);
    }

    function MM(event) {
      if(!dragon) return;
      if(event==null) event=window.event;
      dx=parseInt(event.clientX)-ox;
      dy=parseInt(event.clientY)-oy;
      repositionAll();
      return false;
    }

    function MU(event, src) {
      w=nw;
      h=nh;
      t=nt;
      l=nl;
      if(event==null) event=window.event;
      dragon=false;
      dragsrc=null;
      window.status="";
    }

    document.onmousemove=MM;
    document.onmouseup=MU;
    document.ondrag=function() { return false; } ]]>
       </xsl:with-param>
    </xsl:call-template>
    <style type="text/css">
    #bodymain {
      position:relative;
      display:block;
    }

    #bodycon {
      position:relative;
      top:0px;
      left:0px;
      width:748px;
      height:260px;
    }
    /* *** TOP DRAG BAR *** */
    #T {
      top:0px;
      left:20px;
      width:728px;
      height:4px;
    }
    /* *** LEFT DRAG BAR *** */
    #L {
      top:20px;
      left:0px;
      width:4px;
      height:240px;
    }
    /* *** BOTTOM DRAG BAR *** */
    #B {
      bottom:0px;
      left:20px;
      width:728px;
      height:4px;
    }
    #BR {
      bottom:0px;
      right:0px;
      width:20px;
      height:4px;
    }
    /* *** RIGHT DRAG BAR *** */
    #U {
      top:20px;
      right:0px;
      width:4px;
      height:240px;
    }
    #UB {
      bottom:0px;
      right:0px;
      width:4px;
      height:20px;
    }

    .brd {
      position:absolute;
      font-size: 1px; /* for MSIE */
    }

    .edg {
      background-color:#aaaaaa;
    }

    .v {
      cursor:w-resize;
    }

    .h {
      cursor:n-resize;
    }

    .nw {
      cursor:nw-resize;
    }

    #body {
      position:relative;
      top:0px;
      left:0px;
      margin:4px;
      width:740px;
      height:252px;
      border: 1px solid black;
      background-color:#ffffff;
      overflow:auto;
      font-family: 'Courier New','Verdana';
      font-size: 10pt;
    }
    </style>
  </xsl:template>


  <xsl:template name="testbodysxml">
    <xsl:call-template name="wfcheckjs"/>
    <a href="javascript:void()" onclick="return wfcheck();">
      <img src="{$skimages}option_wfcheck.png"
           border="0"
           alt="{$i18n/l/Test_body_xml}"
           title="{$i18n/l/Test_body_xml}"
           align="left"
           width="32"
           height="19"
           />
    </a>
  </xsl:template>


  <xsl:template name="prettyprint">
    <xsl:param name="ppmethod" select="'htmltidy'"/>

    <xsl:call-template name="prettyprintjs">
      <xsl:with-param name="ppmethod" select="$ppmethod"/>
    </xsl:call-template>

    <a href="javascript:void()" onclick="return prettyprint();">
      <img src="{$skimages}option_prettyprint.png"
           border="0"
           alt="{$i18n/l/Prettyprint}"
           title="{$i18n/l/Prettyprint}"
           align="left"
           width="32"
           height="19"
           />
    </a>
  </xsl:template>


  <xsl:template name="xmlhttpjs">
    <![CDATA[
    function getXMLHTTPObject() {
        var xmlhttp=false;
        /*@cc_on @*/
        /*@if (@_jscript_version >= 5)
        // JScript gives us Conditional compilation, we can cope with old IE versions.
        // and security blocked creation of the objects.
        try {
            xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (e) {
            try {
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch (E) {
                xmlhttp = false;
            }
        }
        @end @*/
        if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
            xmlhttp = new XMLHttpRequest();
        }
        return xmlhttp;
    }]]>
  </xsl:template>


  <xsl:template name="wfcheckjs">
    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">
        <xsl:call-template name="xmlhttpjs"/>

        function wfcheck() {
            var xmlhttp = getXMLHTTPObject();
            var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?test_wellformedness=1')"/>";
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not check well-formedness.")
                    }
                    else {
                        alert(xmlhttp.responseText + '\n');
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('test_wellformedness=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="prettyprintjs">
    <xsl:param name="ppmethod" select="'htmltidy'"/>
    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">
      
       <xsl:call-template name="xmlhttpjs"/>

        function prettyprint() {
            var xmlhttp = getXMLHTTPObject();
            var url = "<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?', $ppmethod, '=1')"/>";
            xmlhttp.open("post",url,true);
            xmlhttp.onreadystatechange=function() {
                if (xmlhttp.readyState==4) {
                    if (xmlhttp.status!=200) {
                        alert("Parse Failure. Could not pretty print.")
                    }
                    else {
                        document.eform.body.value=xmlhttp.responseText;
                    }
                }
            }
            xmlhttp.setRequestHeader
            (
                'Content-Type',
                'application/x-www-form-urlencoded; charset=UTF-8'
            );
            xmlhttp.send('<xsl:value-of select="$ppmethod"/>=1&amp;body='+encodeURIComponent(document.eform.body.value));
            return false;
        }
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="testlocationjs">
    <xsl:param name="event"/>
    <xsl:param name="obj_type"/>

    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">

         <xsl:call-template name="xmlhttpjs"/>

    <!-- give notice that location needs to be set first -->
    function enterCheckLoc() {
        var notice = "<xsl:value-of select="$i18n/l/IlpProvideLocationFirst"/>";
        var btnOK = "<xsl:value-of select="$i18n/l/IlpButtonOK"/>";
        notice += <![CDATA[ '<br/><br/>\
                  <input type="button" id="xims_ilp_btn_select" value="'+ btnOK +'" class="control" \
                  onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');document.eform.name.focus();return false;"/>';
                  ]]>      
        var loc = document.eform.name.value;
        <!-- open il-popup when location has not been entered yet -->
        <![CDATA[if ( loc.length < 1 ) {]]>
            document.getElementById('xims_ilp_content').innerHTML=notice;
            openCloseInlinePopup('open', 'xims_ilp_fadebg', 'xims_ilp');
        }
    }

    <!-- main function for testlocation event handling -->
    function testlocation() {
        // get XML-Http-Request-Object
        var xmlhttp = getXMLHTTPObject();
        var location = document.eform.name.value;
        var obj    = '<xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/fullname"/>'; 
        var suffix = '<xsl:value-of select="/document/data_formats/data_format[@id=/document/context/object/data_format_id]/suffix"/>';

        <!-- append suffixes with no lang-extension;
             lang-extensions in the pattern should be taken from 
             /document/languages in the future -->
        <![CDATA[
 	//var pattern = new RegExp( '.*\\.' + suffix + '(\\.(de|en|it|es|fr))?$');
	//if (location.length != 0 &&  ! location.match(pattern)) {
        //    //alert( pattern + ' ' + location + '+' + suffix );
        //    location += suffix;
	//}
        ]]>

        var abspath = '<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path)"/>';
        var query = '?test_location=1;objtype='+ obj +';name='+ encodeURIComponent(location);
        var url = abspath + query;
        <![CDATA[

        <!-- begin AJAX-stuff here -->
        xmlhttp.onreadystatechange=function() {
            // show that something is loading in background
            if (xmlhttp.readyState < 4) {
                document.body.className = 'loading';
            }
            if (xmlhttp.readyState==4) {
                if (xmlhttp.status!=200) {
                    alert("AJAX-request 'test_location' failed!")
                }
                else {
                    // loading is done ;-)
                    document.body.className = '';
                    responseString = xmlhttp.responseText;
                }
                // evaluate response
                var myPattern = /s=##([^##]+)##;l=##([^##]*)##;reason=##([^##]+)##/; //location might be empty in response
                myPattern.exec(responseString);
                var statusCode = RegExp.$1;
                var processedLocation = RegExp.$2;
                var defaultReason = RegExp.$3;

                var notice;
                var controlHtml;
            
                /* choose response according to statusCode. remember: 
                    0 => Location (is) OK
                    1 => Location already exists (in container)
                    2 => No location provided (or location is not convertible)
                    3 => Dirty (no sane) location (location contains hilarious characters)
                 */   
                switch (statusCode) {
                    case "0":
                        // OK (see if location has been mangled and we don't have an URLLink Object)
                        var objType = ']]><xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/fullname"/><![CDATA[';
                        if ( objType.toUpperCase() != 'URLLINK' && location != processedLocation ) {
                            //we would change location on save so report this to user ]]>
                            var text = "<xsl:value-of select="$i18n/l/IlpLocationWouldChange"/>";
                            var btnIgnore = "<xsl:value-of select="$i18n/l/IlpButtonIgnore"/>";
                            var btnChange = "<xsl:value-of select="$i18n/l/IlpButtonChange"/>";
                   <![CDATA[ notice = '<pre style="color: Silver">'+ location +"</pre>";
                            notice += '<pre style="color: Maroon;">'+ processedLocation +"</pre>";
                            notice += "<br/>"+ text;
                            controlHtml = '<br/><br/>\
                            <input type="button" id="xims_ilp_btn_select" class="control" value="'+ btnChange +'" onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');document.eform.name.focus();return false;"/>&#160;\
                            <input type="button" class="control" value="'+ btnIgnore +'" onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');return false;"/>&#160;';
                            notice += controlHtml;
                            // reset notice if ILP would not work properly
                        }
                        break;
                    case "1":
                        // loc exists ]]>
                        var text = "<xsl:value-of select="$i18n/l/IlpLocationExists"/>";
                        var btnOK = "<xsl:value-of select="$i18n/l/IlpButtonOK"/>";
                        <![CDATA[
                        controlHtml = '<br/><br/>\
                        <input type="button" id="xims_ilp_btn_select" class="control" value="'+ btnOK +'" onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');document.eform.name.focus();return false;"/>';
                        ]]>
                        notice = text+controlHtml;
                        break;
                    case "2":
                        // no loc
                        var text = "<xsl:value-of select="$i18n/l/IlpNoLocationProvided"/>";
                        var btnOK = "<xsl:value-of select="$i18n/l/IlpButtonOK"/>";
                        <![CDATA[
                        controlHtml = '<br/><br/>\
                        <input type="button" id="xims_ilp_btn_select" class="control" value="'+ btnOK +'" onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');document.eform.name.focus();return false;"/>';
                        ]]>
                        notice = text+controlHtml;
                        break;
                    case "3":
                        // dirty loc
                        var text = "<xsl:value-of select="$i18n/l/IlpDirtyLocation"/>";
                        var btnOK = "<xsl:value-of select="$i18n/l/IlpButtonOK"/>";
                        <![CDATA[
                        controlHtml = '<br/><br/>\
                        <input type="button" id="xims_ilp_btn_select" class="control" value="'+ btnOK +'" onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');document.eform.name.focus();return false;"/>';
                        ]]>
                        notice = text+controlHtml;
                        break;
                    default:
                        // debug message
                        var text = "Unknown response code of event 'test_location'!";
                        var btnOK = "<xsl:value-of select="$i18n/l/IlpButtonOK"/>";
                        <![CDATA[
                        controlHtml = '<br/><br/>\
                        <input type="button" id="xims_ilp_btn_select" class="control" value="'+ btnOK +'" onclick="openCloseInlinePopup(\'close\', \'xims_ilp_fadebg\', \'xims_ilp\');document.eform.name.focus();return false;"/>';
                        ]]>
                        notice = text+controlHtml;
                        // reset notice if ILP would not work properly
                    break;
                }
                // set content for ILP
                document.getElementById('xims_ilp_content').innerHTML=notice;
                <!-- debug -->
                //alert("reason = "+defaultReason+"\nstatuscode = "+statusCode+"\nlocation = "+processedLocation);
                
                // report notice/error if set
                if (notice) {
                   openCloseInlinePopup('open', 'xims_ilp_fadebg', 'xims_ilp');
                }
            }
        }
        xmlhttp.open("get",url,true);
        xmlhttp.setRequestHeader
        (
            'Content-Type',
            'application/x-www-form-urlencoded; charset=UTF-8'
        );
        xmlhttp.send(null);
    }
      </xsl:with-param>  
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="create_menu_js">
    <script src="{$ximsroot}skins/{$currentskin}/scripts/create_menu_expander.js" 
            type="text/javascript">
      <xsl:text>&#160;</xsl:text>
    </script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/create_menu_setup.js" 
            type="text/javascript">
      <xsl:text>&#160;</xsl:text>
    </script>
  </xsl:template>


  <xsl:template name="create_menu_css">
    <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/create_menu_style.css" type="text/css" />        
  </xsl:template>


  <!-- This template provides HTML code for an inline-popup;
       Usually one does not need more HTML. Simply reset
       content by setting document.getElementbyId("xims_ilp_content").innerHTML
       property (see templates cancelaction/canceledit) -->
  <xsl:template name="inlinepopup">
    <xsl:param name="winlabel"/>
    <xsl:param name="showclosebutton" select="false()"/>

    <!-- dummy-div (including IE 6 hack) for disabling background -->
    <div id="xims_ilp_fadebg">
      &#160;
      <!-- IE conditional comment (do not add additional spaces)-->
      <xsl:comment>[if lte IE 10.0]&gt;&lt;iframe src="index.html"&gt;&lt;/iframe&gt;&lt;![endif]</xsl:comment>
    </div>

    <!-- here is our inline-popup code -->
    <div id="xims_ilp">
      <div id="xims_ilp_windowbg">
        <div id="xims_ilp_winlabel">
          <xsl:if test="$showclosebutton">
            <div id="xims_ilp_close" onclick="openCloseInlinePopup('close', 'xims_ilp_fadebg', 'xims_ilp');return false;">X</div>
          </xsl:if>
          <xsl:value-of select="$winlabel"/>
        </div>
      </div>
      <div id="xims_ilp_content">
        <!-- here comes AJAX response text see testlocationjs template -->
      </div>
    </div>
  </xsl:template>


  <xsl:template name="tr-minify">
    <xsl:call-template name="mk-tr-checkbox">
      <xsl:with-param name="title-i18n" select="'minify'"/>
      <xsl:with-param name="xpath" select="'attributes/minify'"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="jquery-listitems-bg">
    <xsl:param name="pick"/>
    <xsl:if test="$pick">
      <xsl:call-template name="mk-inline-js">
        <xsl:with-param name="code">
          $(function() {
              $("<xsl:value-of select="$pick"/>:odd").addClass("listitem_odd");
              $("<xsl:value-of select="$pick"/>:even").addClass("listitem_even");
          });
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="mk-tr-textfield">
    <xsl:param name="title-i18n" select="''"/>
    <xsl:param name="title" select="$title-i18n"/>    
    <xsl:param name="name" select="translate($title, &uc;, &lc;)"/>
    <xsl:param name="size" select="'60'"/>
    <xsl:param name="maxlength" select="'127'"/>
    <xsl:param name="xpath" select="'/..'"/>
    <tr>  
      <td valign="top">
        <xsl:choose>
          <xsl:when test="string-length($title-i18n)&gt;0">
            <xsl:value-of select="dyn:evaluate( concat('$i18n/l/', $title-i18n) )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>        
      </td>
      <td colspan="2">
        <input type="text" 
               size="{$size}" 
               name="{$name}"
               value="{dyn:evaluate($xpath)}"
               class="text"
               maxlength="{$maxlength}"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('{$title}')" 
           class="doclink">(?)
        </a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="mk-tr-checkbox">
    <xsl:param name="title-i18n" select="''"/>
    <xsl:param name="title" select="$title-i18n"/>   
    <xsl:param name="name" select="translate($title, &uc;, &lc;)"/>
    <xsl:param name="xpath" select="'/..'"/>
    <tr>
      <td >
        <xsl:choose>
          <xsl:when test="string-length($title-i18n)&gt;0">
            <xsl:value-of select="dyn:evaluate( concat('$i18n/l/', $title-i18n) )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>     
      </td>
      <td colspan="2">
        <input name="{$name}" 
               type="checkbox" 
               value="true">
          <xsl:if test="dyn:evaluate($xpath) = '1'">
            <xsl:attribute name="checked">
              <xsl:value-of select="checked"/>
            </xsl:attribute>
          </xsl:if>
        </input>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('{$title}')"
           class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="mk-inline-js">
    <xsl:param name="code"/>

    <script type="text/javascript">
      <xsl:text disable-output-escaping="yes">//&lt;![CDATA[</xsl:text>
      <xsl:value-of disable-output-escaping="yes" select="$code"/> 
      <xsl:text disable-output-escaping="yes">//]]&gt;</xsl:text>
    </script>
  </xsl:template>

</xsl:stylesheet>

