<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_publications.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exslt="http://exslt.org/common">
  <xsl:import href="common.xsl"/>
  <xsl:import href="vlibraryitem_common.xsl"/>
  <xsl:output method="xml"
              encoding="utf-8"
              media-type="text/html"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              omit-xml-declaration="yes"
              indent="yes"/>

  <xsl:template match="/document/context/object">
    <html>
      <head>
        <title><xsl:value-of select="$i18n_vlib/l/filter_create"/></title>
        <xsl:call-template name="css"/>
        <script src="{$ximsroot}scripts/filter_create.js" type="text/javascript" />
        <xsl:call-template name="jscalendar_scripts" />
      </head>
      <body>
        <div style="margin:0.66em;padding:0.33em;background-color:#eeeeee;">
        <form action="{$xims_box}{$goxims_content}"
              name="eform"
              method="get"
              onsubmit="window.opener.document.location.reload();self.close();">
          <input type="hidden" name="id" id="id" value="{@id}"/>
          <xsl:apply-templates select="/document/context/vlsubjectinfo"/>
          <xsl:apply-templates select="/document/context/vlkeywordinfo"/>
          <div style="position:relative; width:250px; float:left">
            <xsl:apply-templates select="/document/object_types"/>
            <xsl:apply-templates select="/document/context/vlmediatypeinfo"/>
            <xsl:call-template name="vlib_filter_search" />
          </div>
          <xsl:call-template name="vlib_filter_buttons" />
          <xsl:call-template name="vlib_filter_chronicle" />
          <div style="clear:both" />
        </form>
        </div>
        <xsl:call-template name="script_bottom"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="vlsubjectinfo">
    <fieldset>
      <legend>
        <xsl:value-of select="$i18n_vlib/l/subject_list"/>
      </legend>
      <table>
        <tr>
          <td>
            <label for="vlsubjects_available"><xsl:value-of select="$i18n_vlib/l/available"/></label><br />
            <select id="subject1" name="vlsubjects_available" size="10" ondblclick="add_item('subject');" style="width:280px">
                <xsl:apply-templates select="subject" >
                  <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    order="ascending"/>
                </xsl:apply-templates>
            </select>
          </td>
          <td style="vertical-align:top; padding-top:20px;">
            <button type="button" onclick="add_item('subject');"><xsl:text>&#160;&gt;&#160;</xsl:text></button><br />
            <button type="button" onclick="remove_item('subject');"><xsl:text>&#160;&lt;&#160;</xsl:text></button>
          </td>
          <td>
            <label for="vlsubjects_selected"><xsl:value-of select="$i18n_vlib/l/selected"/></label><br />
            <select id="subject2" name="vlsubjects_selected" size="10" ondblclick="remove_item('subject');" style="width:280px" />
          </td>
        </tr>
      </table>
    </fieldset>
  </xsl:template>

  <xsl:template match="subject">
    <option value="{id}"><xsl:value-of select="concat(name,' (',object_count,')')" /></option>
  </xsl:template>

  <xsl:template match="vlkeywordinfo">
    <fieldset>
      <legend>
        <xsl:value-of select="$i18n_vlib/l/keywords"/>
      </legend>
      <table>
        <tr>
          <td>
            <label for="vlkeywords_available"><xsl:value-of select="$i18n_vlib/l/available"/></label><br />
            <select id="keyword1" name="vlkeywords_available" size="10" ondblclick="add_item('keyword');" style="width:280px">
                <xsl:apply-templates select="keyword" >
                  <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                    order="ascending"/>
                </xsl:apply-templates>
            </select>
          </td>
          <td style="vertical-align:top; padding-top:20px;">
            <button type="button" onclick="add_item('keyword');"><xsl:text>&#160;&gt;&#160;</xsl:text></button><br />
            <button type="button" onclick="remove_item('keyword');"><xsl:text>&#160;&lt;&#160;</xsl:text></button>
          </td>
          <td>
            <label for="vlkeywords_selected"><xsl:value-of select="$i18n_vlib/l/selected"/></label><br />
            <select id="keyword2" name="vlkeywords_selected" size="10" ondblclick="remove_item('keyword');" style="width:280px" />
          </td>
        </tr>
      </table>
    </fieldset>
  </xsl:template>

  <xsl:template match="keyword">
    <option value="{id}"><xsl:value-of select="concat(name,' (',object_count,')')" /></option>
  </xsl:template>

  <xsl:template match="vlmediatypeinfo">
    <fieldset style="position:relative;width:250px; display:block">
      <legend>
        <xsl:value-of select="$i18n_vlib/l/mediatype"/>
      </legend>
      <select name="vlmediatype_selected" size="1" >
        <option />
        <xsl:apply-templates select="mediatype" />
      </select>
    </fieldset>
  </xsl:template>

  <xsl:template match="mediatype">
    <option value="{mediatype}"><xsl:value-of select="concat(mediatype,' (',object_count,')')" /></option>
  </xsl:template>

  <xsl:template match="/document/object_types">
    <fieldset style="position:relative;width:250px; display:block">
      <legend>
        <xsl:value-of select="$i18n_vlib/l/subject"/>
      </legend>
      <select name="vlobjecttype_selected" size="1" >
        <option />
        <xsl:apply-templates select="object_type[parent_id=/document/object_types/object_type[name='VLibraryItem']/@id]" >
          <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
            order="ascending"/>
        </xsl:apply-templates>
      </select>
    </fieldset>
  </xsl:template>

  <xsl:template match="object_type">
    <option value="{@id}"><xsl:value-of select="name" /></option>
  </xsl:template>

  <xsl:template name="vlib_filter_search">
    <fieldset style="width:250px; position:relative; display:block;">
      <legend>
        <xsl:value-of select="$i18n_vlib/l/Fulltext_search"/>
      </legend>
      <input name="vls" />
    </fieldset>
  </xsl:template>

  <xsl:template name="vlib_filter_chronicle">
    <fieldset style="position:relative; float:right; width:200px;">
      <legend>
        <xsl:value-of select="$i18n_vlib/l/chronicle_filter"/>
      </legend>
      <table>
        <xsl:call-template name="vlib_filter_tr-chronicle_from" />
        <xsl:call-template name="vlib_filter_tr-chronicle_to" />
      </table>
    </fieldset>
  </xsl:template>

  <xsl:template name="vlib_filter_tr-chronicle_from">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/chronicle_from"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="chronicle_from_date" id="chronicle_from_date" size="10"  />
            <xsl:text>&#160;</xsl:text>
            <img
              src="{$skimages}calendar.gif"
              id="f_trigger_vft"
              style="cursor: pointer;"
              alt="{$i18n/l/Date_selector}"
              title="{$i18n/l/Date_selector}"
              onmouseover="this.style.background='red';"
              onmouseout="this.style.background=''"
            />
            <script type="text/javascript">
                var current_date;
                Calendar.setup({
                    inputField     :    "chronicle_from_date",
                    ifFormat       :    "%Y-%m-%d",
                    displayArea    :    "show_vft",
                    daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
                    button         :    "f_trigger_vft",
                    align          :    "Tl",
                    singleClick    :    true,
                    showsTime      :    true,
                    timeFormat     :    "24"
                });
            </script>
        </td>
    </tr>
  </xsl:template>

  <xsl:template name="vlib_filter_tr-chronicle_to">
    <tr>
        <td valign="top"><xsl:value-of select="$i18n_vlib/l/chronicle_to"/></td>
        <td colspan="2">
            <input tabindex="40" type="text" name="chronicle_to_date" id="chronicle_to_date" size="10" value="" />
            <xsl:text>&#160;</xsl:text>
            <img
              src="{$skimages}calendar.gif"
              id="t_trigger_vft"
              style="cursor: pointer;"
              alt="{$i18n/l/Date_selector}"
              title="{$i18n/l/Date_selector}"
              onmouseover="this.style.background='red';"
              onmouseout="this.style.background=''"
            />
            <script type="text/javascript">
                var current_date;
                Calendar.setup({
                    inputField     :    "chronicle_to_date",
                    ifFormat       :    "%Y-%m-%d",
                    displayArea    :    "show_vft",
                    daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
                    button         :    "t_trigger_vft",
                    align          :    "Tl",
                    singleClick    :    true,
                    showsTime      :    true,
                    timeFormat     :    "24"
                });
            </script>
        </td>
    </tr>
  </xsl:template>

  <xsl:template name="vlib_filter_buttons">
    <div style="position:relative; float: right; width:110px; text-align:center; padding-top:10px;">
      <input type="button" name="filter_store" value="{$i18n/l/save}" class="control" accesskey="S" onclick="alert(createFilterParams());" /><br />
      <input type="button" name="filter_activate" value="{$i18n_vlib/l/activate}" class="control" accesskey="A" onclick="opener.location = '{$xims_box}{$goxims_content}{$absolute_path}?filter=1;' + createFilterParams() ; //window.close();" /><br />
      <input type="button" name="cancel" value="{$i18n/l/cancel}" class="control" accesskey="C" onclick="window.close();" />
    </div>
  </xsl:template>

</xsl:stylesheet>
