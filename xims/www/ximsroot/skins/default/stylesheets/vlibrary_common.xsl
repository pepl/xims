<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2007 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exslt="http://exslt.org/common"
                extension-element-prefixes="exslt date">
  
  <xsl:variable name="i18n" 
                select="document(concat($currentuilanguage,'/i18n.xml'))"/>
  <xsl:variable name="i18n_vlib" 
                select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
  <xsl:variable name="user_privileges" 
                select="/document/context/object/user_privileges" />
  
  <xsl:param name="colms" select="3"/>
  <xsl:param name="vls"/>
  <xsl:param name="date_from" />
  <xsl:param name="date_to" />
  <xsl:param name="publications"/>
  <xsl:param name="authors"/>
  <xsl:param name="page" select="1" />
  <xsl:param name="subject"/>
  <xsl:param name="subject_id"/>
  <xsl:param name="subject_name"/>
  <xsl:param name="author"/>
  <xsl:param name="author_id"/>
  <xsl:param name="author_firstname"/>
  <xsl:param name="author_middlename"/>
  <xsl:param name="author_lastname"/>
  <xsl:param name="publication"/>
  <xsl:param name="publication_id"/>
  <xsl:param name="publication_name"/>
  <xsl:param name="publication_volume"/>
  <xsl:param name="keyword"/>
  <xsl:param name="keyword_id"/>
  <xsl:param name="most_recent"/>
  <xsl:param name="chronicle_from" />
  <xsl:param name="chronicle_to" />

  <xsl:template name="head_default">
    <head>
      <title><xsl:value-of select="title" /> - <xsl:value-of select="/document/object_types/object_type[@id=/document/context/object/object_type_id]/name"/> - XIMS</title>
      <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
      <link rel="stylesheet" href="{$ximsroot}skins/{$currentskin}/stylesheets/vlibrary.css" type="text/css"/>
      <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
      <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
      <script src="{$ximsroot}scripts/vlibrary_default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
      <xsl:call-template name="create_menu_jscss"/>
    </head>
  </xsl:template>

  <xsl:template name="item">
    <xsl:param name="mo" />
    <tr>
      <td>
        <xsl:call-template name="item_div">
          <xsl:with-param name="mo" select="$mo"/>
        </xsl:call-template>
      </td>
      <xsl:for-each select="following-sibling::node()[position() &lt; $colms]">
        <td>
          <xsl:call-template name="item_div">
            <xsl:with-param name="mo" select="$mo"/>
          </xsl:call-template>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <xsl:template name="item_div">
    <xsl:param name="mo" />
    <div class="vliteminfo" name="vliteminfo" align="center">
      <div> 
        <xsl:call-template name="property_link">
          <xsl:with-param name="mo" select="$mo"/>
        </xsl:call-template>
      </div>
      <div>
        <xsl:call-template name="item_count"/>
      </div>
      <xsl:if test="last_modification_timestamp/day">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$i18n_vlib/l/last_modified_at"/>
        <br />
        <xsl:apply-templates select="last_modification_timestamp" 
                             mode="datetime" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="item_count">
    <xsl:value-of select="object_count"/>
    <xsl:text> </xsl:text>
    <xsl:call-template name="decide_plural">
      <xsl:with-param name="objectitems_count"
                      select="object_count"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="decide_plural">
    <xsl:param name="objectitems_count"/>
    <xsl:choose>
      <xsl:when test="number($objectitems_count) = 1">
        <xsl:value-of select="$i18n_vlib/l/item"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$i18n_vlib/l/items"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="switch_vlib_views_action">
    <xsl:param name="mo" />
    <table cellpadding="0" 
           cellspacing="0" 
           style="margin: 0px;">
      <tr>
        <td valign="top">
          <strong>
            <xsl:value-of select="$i18n_vlib/l/Switch_to"/>
          </strong>
        </td>
        <td valign="top">
          <ul>
            <xsl:if test="$mo != 'subject'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?m={$m}">
                  <xsl:value-of select="$i18n_vlib/l/subject_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$mo != 'author'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?authors=1;m={$m}">
                  <xsl:value-of select="$i18n_vlib/l/author_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$mo != 'publication'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?publications=1;m={$m}">
                  <xsl:value-of select="$i18n_vlib/l/publication_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$mo != 'keyword'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?keywords=1;m={$m}">
                  <xsl:value-of select="$i18n_vlib/l/keyword_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$most_recent != '1'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?most_recent=1;m={$m}">
                  <xsl:value-of select="$i18n_vlib/l/Latest_entries"/>
                </a>
              </li>
            </xsl:if>
          </ul>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template name="vlib_search_action">

    <xsl:variable name="Search" 
                  select="$i18n_vlib/l/Fulltext_search"/>

    <form style="margin-bottom: 0px;" 
          action="{$xims_box}{$goxims_content}{$absolute_path}" 
          method="GET" 
          name="vlib_search">
      <strong><xsl:value-of select="$Search"/></strong>
      <xsl:text>&#160;</xsl:text>
      <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" 
             type="text" 
             name="vls" 
             size="17" 
             maxlength="200">
        <xsl:if test="$vls != ''">
          <xsl:attribute name="value">
            <xsl:value-of select="$vls"/>
          </xsl:attribute>
        </xsl:if>
      </input>
      <xsl:text>&#160;</xsl:text>
      <input type="image"
             src="{$skimages}go.png"
             name="submit"
             width="25"
             height="14"
             alt="{$Search}"
             title="{$Search}"
             border="0"
             style="vertical-align: text-bottom;"
             />
      <input type="hidden" 
             name="start_here" 
             value="1"/>
      <input type="hidden"
             name="vlsearch" 
             value="1"/>
      </form>
      <br />
      <a href="javascript:createFilterWindow('{$xims_box}{$goxims_content}{$absolute_path}?filter_create=1');">
        <xsl:value-of select="$i18n_vlib/l/filter_create"/>
      </a>
  </xsl:template>

  <xsl:template name="property_link">
    <xsl:param name="mo"/>
    

    <xsl:variable name="display_name">
      <xsl:choose>
        <xsl:when test="$mo = 'author'">
          <xsl:if test="firstname">
            <xsl:value-of select="firstname"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:if test="middlename">
            <xsl:value-of select="middlename"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="lastname"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a href="{$xims_box}{$goxims_content}{$absolute_path}?{$mo}=1;{$mo}_id={id}">
      <xsl:value-of select="$display_name"/>
    </a>

    <!-- only show action icons if user has the privilege "write" on the VLibray -->
    <xsl:if test="$user_privileges/write=1 and object_count">
      &#160;
      <a href="javascript:genericVLibraryPopup('{$xims_box}{$goxims_content}{$absolute_path}?property_edit=1;property_id={id};property={$mo};', '{$mo}')">
        <img src="{$skimages}option_edit.png"
             alt="{$i18n_vlib/l/edit} {$i18n_vlib/l/*[name() = $mo]}"
             title="{$i18n_vlib/l/edit} {$i18n_vlib/l/*[name() = $mo]}"
             border="0"
             onmouseover="pass('edit{id}','edit','h'); return true;"
             onmouseout="pass('edit{id}','edit','c'); return true;"
             onmousedown="pass('edit{id}','edit','s'); return true;"
             onmouseup="pass('edit{id}','edit','s'); return true;"
             name="edit{id}"
             width="32"
             height="19"/>
      </a>

      <xsl:if test="object_count = 0">
        <a href="javascript:genericVLibraryPopup('{$xims_box}{$goxims_content}{$absolute_path}?property_delete_prompt=1;property_id={id};property={$mo};display_name={$display_name}', 'delete')">
          <img src="{$skimages}option_delete.png"
               alt="{$i18n_vlib/l/delete} {$i18n_vlib/l/*[name() = $mo]}"
               title="{$i18n_vlib/l/delete} {$i18n_vlib/l/*[name() = $mo]}"/>
        </a>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  

  <xsl:template name="search_switch">
    <xsl:param name="mo"/>
    <table width="100%" 
           border="0" 
           style="margin: 0px;" 
           id="vlsearchswitch">
      <tr>
        <td valign="top" 
            width="50%" 
            align="center" 
            class="vlsearchswitchcell">
          <xsl:call-template name="vlib_search_action"/>
        </td>
        <td valign="top" 
            width="50%" 
            align="center" 
            class="vlsearchswitchcell">
          <xsl:call-template name="switch_vlib_views_action">
            <xsl:with-param name="mo" select="$mo"/>
          </xsl:call-template>
        </td>
      </tr>
    </table>
  </xsl:template>

  <xsl:template name="chronicle_switch">
    <table width="100%" 
           border="0" 
           style="margin: 0px;" 
           id="vlsearchswitch">
      <tr>
        <td valign="top"
            width="50%" 
            align="center" 
            class="vlsearchswitchcell">
          <form style="margin-bottom: 0px;" 
                action="{$xims_box}{$goxims_content}{$absolute_path}" 
                method="GET" 
                name="vlib_search">
            Chronik von
            <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" 
                   type="text"
                   name="chronicle_from" 
                   size="10" 
                   maxlength="200" 
                   value="{$chronicle_from}"/>
            bis
            <input style="background: #eeeeee; font-face: helvetica; font-size: 10pt" 
                   type="text" 
                   name="chronicle_to" 
                   size="10" 
                   maxlength="200" 
                   value="{$chronicle_to}" />
            <xsl:text>&#160;</xsl:text>
            <input type="image"
                   src="{$skimages}go.png"
                   name="submit"
                   width="25"
                   height="14"
                   alt=""
                   title=""
                   border="0"
                   style="vertical-align: text-bottom;"
                   />
            <input type="hidden" name="start_here" value="1"/>
            <input type="hidden" name="vlchronicle" value="1"/>
          </form>
        </td>
      </tr>
    </table>

  </xsl:template>

  <xsl:template name="mode_switcher">
    <xsl:variable name="vlqs" select="concat('publication=',$publication,';publication_id=',$publication_id,';author=',$author,';author_id=',$author_id,';subject=',$subject,';subject_id=',$subject_id,';publications=',$publications,';authors=',$authors,';page=',$page,';most_recent=',$most_recent)"/>
    <xsl:choose>
      <xsl:when test="$m='e'">
        <a href="{$goxims_content}{$absolute_path}?m=b;{$vlqs}">
          <xsl:value-of select="$i18n/l/switch_to_browse"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a href="{$goxims_content}{$absolute_path}?m=e;{$vlqs}">
          <xsl:value-of select="$i18n/l/switch_to_edit"/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="date_from_timestamp|date_to_timestamp" mode="RFC822">

    <xsl:variable name="datetime">
      <xsl:value-of select="./year"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="./month"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="./day"/>
      <xsl:text>T</xsl:text>
      <xsl:value-of select="./hour"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="./minute"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="./second"/>
      <!--<xsl:value-of select="./tzd"/>-->
    </xsl:variable>

    <xsl:variable name="hour" select="hour"/>

    <xsl:variable name="gmtdiff" select="'1'"/>

    <xsl:variable name="gmthour">
      <xsl:choose>
        <xsl:when test="number($hour)-number($gmtdiff) &lt; 0">
          <xsl:value-of select="number($hour)-number($gmtdiff)+24"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number($hour)-number($gmtdiff)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="substring(date:day-name($datetime),1,3)"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="./day"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="date:month-abbreviation($datetime)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="./year"/>
    <xsl:text> </xsl:text>
    <xsl:if test="string-length($gmthour)=1">0</xsl:if><xsl:value-of select="$gmthour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./minute"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="./second"/>
    <xsl:text> GMT</xsl:text>

  </xsl:template>


  <xsl:template name="post_async_js">
function handleResponse() {
    if (xmlhttp.readyState == 4) {
        
        if (xmlhttp.status == 200) {
            window.opener.document.location.reload();
            window.close();
        } 
        else {
            document.getElementById('message').innerHTML 
                = '<strong>' + xmlhttp.responseText + '</strong>'; 
    document.getElementById('buttons').innerHTML 
                = '<input type="button" 
                          onclick="window.close()" 
                          class="control" 
                          value="{$i18n/l/close_window}"/>';
        }
    }
}

function post_async(poststr) {
    
    xmlhttp.onreadystatechange = handleResponse;
    xmlhttp.open('POST'
                 , '<xsl:value-of select="concat($xims_box,$goxims_content,/document/context/object/location_path)"/>'
                 , true);
    xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlhttp.setRequestHeader("Content-length", poststr.length);
    xmlhttp.setRequestHeader("Connection", "close");
    xmlhttp.send(poststr);                 
}                     
  </xsl:template>

</xsl:stylesheet>