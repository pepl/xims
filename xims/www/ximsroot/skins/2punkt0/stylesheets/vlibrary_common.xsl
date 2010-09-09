<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: vlibrary_common.xsl 2241 2009-08-03 14:02:50Z susannetober $
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl date">

  <xsl:import href="common.xsl"/>

  <xsl:variable name="i18n"
                select="document(concat($currentuilanguage,'/i18n.xml'))"/>
  <xsl:variable name="i18n_vlib"
                select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
  <xsl:variable name="user_privileges"
                select="/document/context/object/user_privileges" />


  <xsl:variable name="popupsizes-rtf">
    <subject     x="910" y="500"/>
    <author      x="620" y="320"/>
    <keyword     x="550" y="200"/>
    <publication x="600" y="260"/>
    <delete      x="550" y="340"/>
  </xsl:variable>

  <xsl:variable name="popupsizes"
                select="exsl:node-set($popupsizes-rtf)/*"/>
                
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

<!--  <xsl:template name="item">
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
  </xsl:template>-->

  <xsl:template name="item_div">
    <xsl:param name="mo" />
    <div class="vliteminfo" align="center">
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
      <button id="vlib-menu"><xsl:value-of select="$i18n_vlib/l/Switch_to"/></button>  
          <ul style="position:absolute !important">
            <xsl:if test="$mo != 'subject'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?">
                  <xsl:value-of select="$i18n_vlib/l/subject_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$mo != 'author'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?authors=1">
                  <xsl:value-of select="$i18n_vlib/l/author_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$mo != 'publication'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?publications=1">
                  <xsl:value-of select="$i18n_vlib/l/publication_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$mo != 'keyword'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?keywords=1">
                  <xsl:value-of select="$i18n_vlib/l/keyword_list"/>
                </a>
              </li>
            </xsl:if>
            <xsl:if test="$most_recent != '1'">
              <li>
                <a href="{$xims_box}{$goxims_content}{$absolute_path}?most_recent=1">
                  <xsl:value-of select="$i18n_vlib/l/Latest_entries"/>
                </a>
              </li>
            </xsl:if>
          </ul>
    <xsl:text>&#160;</xsl:text>
  </xsl:template>

  <xsl:template name="vlib_search_action">
    <xsl:variable name="Search" select="$i18n_vlib/l/Fulltext_search"/>
    <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" name="vlib_search" id="vlib_search_ft">
      <strong><label for="input-ft-search"><xsl:value-of select="$Search"/></label></strong>
      <xsl:text>&#160;</xsl:text>
      <input type="text" name="vls" size="17" maxlength="200" id="input-ft-search">
        <xsl:if test="$vls != ''">
          <xsl:attribute name="value">
            <xsl:value-of select="$vls"/>
          </xsl:attribute>
        </xsl:if>
      </input>
      <xsl:text>&#160;</xsl:text>

       <button type="submit" name="submit" class="button-search">
						<xsl:value-of select="$i18n/l/Search"/>
				</button>
      <input type="hidden" name="start_here" value="1"/>
      <input type="hidden" name="vlsearch" value="1"/>
      </form>
      <!--<br />-->
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
          <xsl:if test="volume != ''">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="volume"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <span class="property_link">
      <a class="name" href="{$xims_box}{$goxims_content}{$absolute_path}?{$mo}=1;{$mo}_id={id}">
        <xsl:value-of select="$display_name"/>
      </a>
			
      <!-- only show action icons if user has the privilege "write" on the VLibray -->
      <xsl:if test="$user_privileges/write=1 and object_count">
      <xsl:text>&#160;</xsl:text>
				<xsl:call-template name="vl-button.options.edit">
					<xsl:with-param name="mo" select="$mo"/>
				</xsl:call-template>
        <!--<a href="javascript:genericWindow(
                     '{$xims_box}{$goxims_content}{$absolute_path}?property_edit=1;property_id={id};property={$mo};',
                     '{$popupsizes[name()=$mo]/@x}',
                     '{$popupsizes[name()=$mo]/@y}')">
          <img src="{$skimages}option_edit.png"
               alt="{$i18n_vlib/l/edit} {$i18n_vlib/l/*[name() = $mo]}"
               title="{$i18n_vlib/l/edit} {$i18n_vlib/l/*[name() = $mo]}"
               border="0"
               name="edit{id}"
               width="32"
               height="19"/>
        </a>-->
        <xsl:if test="object_count = 0">
        <xsl:text>&#160;</xsl:text>
        <xsl:call-template name="vl-button.options.delete">
					<xsl:with-param name="mo" select="$mo"/>
				</xsl:call-template>
          <!--<a href="javascript:genericWindow(
                       '{$xims_box}{$goxims_content}{$absolute_path}?property_delete_prompt=1;property_id={id};property={$mo};display_name={$display_name}',
                       '{$popupsizes[name()='delete']/@x}',
                       '{$popupsizes[name()='delete']/@y}')">
            <img src="{$skimages}option_delete.png"
                 alt="{$i18n_vlib/l/delete} {$i18n_vlib/l/*[name() = $mo]}"
                 title="{$i18n_vlib/l/delete} {$i18n_vlib/l/*[name() = $mo]}"
                 class="delete"/>
          </a>-->
        </xsl:if>
      </xsl:if>
    </span>
  </xsl:template>


  <xsl:template name="search_switch">
    <xsl:param name="mo"/>
        <div>          
					<xsl:call-template name="vlib_search_action"/>
        </div>
        <div>
          <xsl:call-template name="switch_vlib_views_action">
            <xsl:with-param name="mo" select="$mo"/>
          </xsl:call-template>
        </div>
  </xsl:template>

  <xsl:template name="chronicle_switch">
    <div>
          <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="get" name="vlib_search">
            <strong><xsl:value-of select="$i18n_vlib/l/chronicle"/></strong>&#160;
            <label for="input-from"><xsl:value-of select="$i18n/l/from"/></label><xsl:text>&#160;</xsl:text>
            <input type="text" name="chronicle_from" size="10" maxlength="200" value="{$chronicle_from}" id="input-from"/><xsl:text>&#160;</xsl:text>
            <label for="input-to"><xsl:value-of select="$i18n/l/to"/></label><xsl:text>&#160;</xsl:text>
            <input type="text" name="chronicle_to" size="10" maxlength="200" value="{$chronicle_to}" id="input-to"/>
            <xsl:text>&#160;</xsl:text>
			<button class="button-search" type="submit" name="submit">
						<xsl:value-of select="$i18n/l/Search"/>
				</button>
            <input type="hidden" name="start_here" value="1"/>
            <input type="hidden" name="vlchronicle" value="1"/>
          </form>
          <xsl:text>&#160;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template name="mode_switcher">
    <xsl:variable name="vlqs" select="concat('publication=',$publication,';publication_id=',$publication_id,';author=',$author,';author_id=',$author_id,';subject=',$subject,';subject_id=',$subject_id,';publications=',$publications,';authors=',$authors,';page=',$page,';most_recent=',$most_recent)"/>
        <a href="{$goxims_content}{$absolute_path}?m=b;{$vlqs}">
          <xsl:value-of select="$i18n/l/switch_to_browse"/>
        </a>
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
  
  <xsl:template name="vl-button.options.edit">
  <xsl:param name="mo"/>	
		<xsl:variable name="id" select="@id"/>		
		
				<a class="button option-edit" href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}?property_edit=1;property_id={id};property={$mo};','{$popupsizes[name()=$mo]/@x}','{$popupsizes[name()=$mo]/@y}')">
                     <xsl:attribute name="title"><xsl:value-of select="$l_Edit"/></xsl:attribute><xsl:value-of select="$l_Edit"/>
                    	</a>
                     	</xsl:template>
                     	
  <xsl:template name="vl-button.options.delete">
  <xsl:param name="mo"/>	
		<xsl:variable name="id" select="@id"/>		
		
				<a class="button option-delete" href="{$xims_box}{$goxims_content}{$absolute_path}?property_delete_prompt=1;property_id={id};property={$mo};display_name={name}">
                     <xsl:attribute name="title"><xsl:value-of select="$l_delete"/></xsl:attribute><xsl:value-of select="$l_delete"/>
                    	</a>
                     	</xsl:template>

</xsl:stylesheet>
