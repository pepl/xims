<?xml version="1.0" encoding="utf-8"?>
<!--
 # Copyright (c) 2002-2006 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id$
 -->

<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="common.xsl"/>
  <xsl:import href="vlibrary_common.xsl"/>

  <xsl:output method="html"
              encoding="utf-8"
              media-type="text/html"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              indent="no"/>

  <xsl:variable name="i18n_vlib"
                select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>


 <xsl:template name="tr-vlproperties">

   <xsl:param name="mo"/>

   <tr>
     <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>:
      </td>
      <td colspan="2">
        <xsl:choose>
          <xsl:when test="$mo='author'">
            <xsl:apply-templates select="authorgroup/author"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="*[name()=concat($mo, 'set')]/*[name()=$mo]">
              <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                        order="ascending"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/Assign_new"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>
      </td>
      <td colspan="2">
        <xsl:if test="/document/context/*[name()=concat('vl', $mo,'s')]">
          <xsl:apply-templates select="/document/context/*[name()=concat('vl', $mo,'s')]"/>
          <input type="hidden"
                 name="vl{$mo}"
                 value=""/>
          <input type="hidden"
            name="gotid"
            value="1"/>
          <input type="submit"
                 name="create_mapping"
                 value="{$i18n_vlib/l/Create_mapping}"
                 class="control"
               onClick="submitOnId('{$mo}', '{$i18n_vlib/l/select_name}')"/>
          <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo}','{$popupsizes[name()=$mo]/@x}','{$popupsizes[name()=$mo]/@y}')">
          <xsl:value-of select="concat($i18n/l/create, ' ', $i18n_vlib/l/*[name()=$mo])"/>
        </a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-vlkeywords-create">
    <tr>
      <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/Assign_new"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$i18n/l/Keywords"/>
      </td>
      <td colspan="2">
        <input tabindex="40"
               type="text"
               name="vlkeyword"
               size="50"
               value=""
               class="text"
               title="VLKeyword"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <input type="button"
               value="&lt;--"
               onClick="return addVLProperty( 'keyword' );"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="/document/context/vlkeywords"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-vlsubjects-create">
    <tr>
      <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/Assign_new"/>
        <xsl:text>&#160;</xsl:text>
      <xsl:value-of select="$i18n_vlib/l/subjects"/></td>
      <td colspan="2">
        <input tabindex="40"
               type="text"
               name="vlsubject"
               size="50"
               value=""
               class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <input type="button"
               value="&lt;--"
               onClick="return addVLProperty( 'subject' );"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="/document/context/vlsubjects"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-vlauthors-create">
    <tr>
      <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/Assign_new"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:value-of select="$i18n/l/Author"/>
      </td>
      <td colspan="2">
        <input tabindex="40"
               type="text"
               name="vlauthor"
               size="50"
               value=""
               class="text"
               title="VLAuthor"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <input type="button" value="&lt;--" onClick="return addVLProperty( 'author' );"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="/document/context/vlauthors"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="tr-vlkeywords-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n/l/Keywords"/></td>
      <td colspan="2">
        <xsl:apply-templates select="keywordset/keyword">
          <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
            order="ascending"/>
        </xsl:apply-templates>
      </td>
    </tr>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n/l/Keywords"/></td>
      <td colspan="2">
        <input tabindex="40" type="text" name="vlkeyword" size="50" value="" class="text" title="VLKeyword"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <input type="button" value="&lt;--" onClick="return addVLProperty( 'keyword' );"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="/document/context/vlkeywords"/>
        <xsl:text>&#160;</xsl:text>
        <input type="submit" name="create_mapping" value="{$i18n_vlib/l/Create_mapping}" class="control" onClick="return submitOnValue(document.eform.vlkeyword, 'Please fill in a value for', document.eform.svlkeyword);"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="tr-vlsubjects-edit">
    <tr>
      <td valign="top"><xsl:value-of select="$i18n_vlib/l/Currently_mapped"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/subjects"/></td>
      <td colspan="2">
        <xsl:apply-templates select="subjectset/subject">
          <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
            order="ascending"/>
        </xsl:apply-templates>
      </td>
    </tr>
    <tr>
      <td valign="top"><xsl:value-of select="$i18n_vlib/l/Assign_new"/><xsl:text>&#160;</xsl:text><xsl:value-of select="$i18n_vlib/l/subjects"/></td>
      <td colspan="2">
        <input tabindex="40" type="text" name="vlsubject" size="50" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <input type="button" value="&lt;--" onClick="return addVLProperty( 'subject' );"/>
        <xsl:text>&#160;</xsl:text>
        <xsl:apply-templates select="/document/context/vlsubjects"/>
        <xsl:text>&#160;</xsl:text>
        <input type="submit" name="create_mapping" value="{$i18n_vlib/l/Create_mapping}" class="control"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match="keywordset/keyword|subjectset/subject|publicationset/publication">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}"
       target="_blank"
       title="Browse in a new window">
      <xsl:value-of select="name"/>
      <xsl:if test="volume != ''">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="volume"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </a>
    <xsl:text>&#160;</xsl:text>
    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};remove_mapping=1;property={name()};property_id={id}"
       title="Delete Mapping">
      <span style="background-color:#b1b5b8;
                   border:#333333 solid 1px;
                   color: maroon;
                   font-weight: bold;"> x </span>
    </a>
    <xsl:if test="position()!=last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="authorgroup/author">
    <a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}"
       target="_blank"
       title="Browse in a new window">
      <xsl:value-of select="firstname"/>&#160;<xsl:value-of select="lastname"/>
    </a>
    <xsl:text>&#160;</xsl:text>
    <a href="{$xims_box}{$goxims_content}?id={/document/context/object/@id};remove_mapping=1;property={name()};property_id={id}"
       title="Delete Mapping">
      <span style="background-color:#b1b5b8;
                   border:#333333 solid 1px;
                   color: maroon;
                   font-weight: bold;"> x </span>
    </a>
    <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
  </xsl:template>

  <xsl:template match="vlsubjects">
    <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt"
            name="svlsubject">
    <option value="-1"><xsl:value-of select="$i18n_vlib/l/select_name"/></option>
      <xsl:apply-templates select="/document/context/vlsubjects/subject">
        <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
      </xsl:apply-templates>
    </select>
  </xsl:template>


  <xsl:template match="vlkeywords">
    <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt"
            name="svlkeyword">
      <option value="-1"><xsl:value-of select="$i18n_vlib/l/select_name"/></option>
      <xsl:apply-templates select="/document/context/vlkeywords/keyword">
        <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
      </xsl:apply-templates>
    </select>
  </xsl:template>


  <xsl:template match="vlpublications">
    <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt"
            name="svlpublication">
      <option value="-1"><xsl:value-of select="$i18n_vlib/l/select_name"/></option>
      <xsl:apply-templates select="/document/context/vlpublications/publication">
        <xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
      </xsl:apply-templates>
    </select>
  </xsl:template>


  <xsl:template match="vlauthors">
    <select style="background: #eeeeee; font-face: helvetica; font-size: 10pt"
            name="svlauthor">
      <option value="-1"><xsl:value-of select="$i18n_vlib/l/select_name"/></option>
      <xsl:apply-templates select="/document/context/vlauthors/author">
        <xsl:sort select="translate(lastname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
        <xsl:sort select="translate(firstname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
        <xsl:sort select="translate(middlename,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
                  order="ascending"/>
      </xsl:apply-templates>
    </select>
  </xsl:template>

 <xsl:template match="vlpublications/publication">
    <option value="{id}">
      <xsl:value-of select="normalize-space(concat(name, ' (', volume, ')'))"/>
    </option>
  </xsl:template>



  <xsl:template match="vlsubjects/subject|vlkeywords/keyword">
    <option value="{id}">
      <xsl:value-of select="normalize-space(name)"/>
    </option>
  </xsl:template>


  <xsl:template match="vlauthors/author">
    <option value="{id}">
      <xsl:value-of select="normalize-space(concat(firstname, ' ', middlename, ' ', lastname, ' ', suffix))"/>
    </option>
  </xsl:template>


  <xsl:template name="tr-subject-create">
    <tr>
      <td valign="top">Thema</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="subject"
               size="60"
               class="text"
               maxlength="256"/>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Subject')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-subtitle">
    <tr>
      <td valign="top">Subtitle</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="subtitle"
               size="60"
               class="text"
               maxlength="256"
               value="{meta/subtitle}"/>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-mediatype">
    <tr>
      <td valign="top">Mediatype</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="mediatype"
               size="60"
               class="text"
               maxlength="128"
               value="{meta/mediatype}"/>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-legalnotice">
    <tr>
      <td valign="top">Legalnotice</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="legalnotice"
               size="60"
               class="text"
               maxlength="128"
               value="{meta/legalnotice}"/>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-coverage">
    <tr>
      <td valign="top">Coverage</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="coverage"
               size="60"
               class="text"
               maxlength="256"
               value="{meta/coverage}"/>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-audience">
    <tr>
      <td valign="top">Audience</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="audience"
               size="60"
               class="text"
               maxlength="256"
               value="{meta/audience}"/>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-bibliosource">
    <tr>
      <td valign="top">Bibliosource</td>
      <td colspan="2">
        <textarea tabindex="20"
                  name="bibliosource"
                  cols="60"
                  rows="5"
                  length="2048"
                  class="text">
          <xsl:value-of select="meta/bibliosource"/>
        </textarea>
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-date-create">
    <tr>
      <td valign="top">Zeitraum</td>
      <td colspan="2">
        von
        <input tabindex="20"
               type="text"
               name="date_from"
               size="10"
               class="text"
               maxlength="10"/>
        (JJJJ-MM-TT)
        <img src="{$ximsroot}jscalendar-1.0/img.gif"
             id="f_trigger_c"
             style="cursor: pointer; border: 1px solid red;"
             title="Date selector"
             onmouseover="this.style.background='red';"
             onmouseout="this.style.background=''" />
        <script type="text/javascript">
          Calendar.setup({
          inputField     :    "date_from",
          ifFormat       :    "%Y-%m-%d",
          button         :    "f_trigger_c",
          align          :    "Tl",
          singleClick    :    true
          });
        </script>
        bis
        <input tabindex="20"
               type="text"
               name="date_to"
               size="10"
               class="text"
               maxlength="10"/>
        (JJJJ-MM-TT)<xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-publisher">
    <tr>
      <td valign="top">Institution</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="publisher"
               size="60"
               class="text"
               maxlength="256"
               value="{meta/publisher}" />
        <xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Institution')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-date-edit">
    <xsl:variable name="date_from"
                  select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)" />
    <tr>
      <td valign="top">Datum</td>
      <td colspan="2">
        <input tabindex="20"
               type="text"
               name="date"
               size="10"
               class="text"
               maxlength="10"
               value="{$date_from}" />
        (JJJJ-MM-TT)<xsl:text>&#160;</xsl:text>
        <!-- <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> -->
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-chronicle_from">
    <xsl:variable name="chronicle_from_date_tmp"
                  select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)" />
    <xsl:variable name="chronicle_from_date">
      <xsl:if test="$chronicle_from_date_tmp != '--'">
        <xsl:value-of select="$chronicle_from_date_tmp"/>
      </xsl:if>
    </xsl:variable>
    <tr>
      <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/chronicle_from"/>
      </td>
      <td colspan="2">
        <input tabindex="40"
               type="text"
               name="chronicle_from_date"
               id="chronicle_from_date"
               class="text"
               size="10"
               value="{$chronicle_from_date}" />
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
          var current_datestring = "<xsl:value-of select="$chronicle_from_date"/>";
          var current_date;
          if ( current_datestring.length > 0 ) {
          current_date = Date.parseDate(current_datestring, "%Y-%m-%d").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
          }
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
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('chronicle_from')"
           class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="tr-chronicle_to">

    <xsl:variable name="chronicle_to_date_tmp"
                  select="concat(meta/date_to_timestamp/year,'-',meta/date_to_timestamp/month,'-',meta/date_to_timestamp/day)" />

    <xsl:variable name="chronicle_to_date">
      <xsl:if test="$chronicle_to_date_tmp != '--'">
        <xsl:value-of select="$chronicle_to_date_tmp"/>
      </xsl:if>
    </xsl:variable>

    <tr>
      <td valign="top">
        <xsl:value-of select="$i18n_vlib/l/chronicle_to"/>
      </td>
      <td colspan="2">
        <input tabindex="40"
               type="text"
               name="chronicle_to_date"
               id="chronicle_to_date"
               class="text"
               size="10"
               value="{$chronicle_to_date}" />
        <xsl:text>&#160;</xsl:text>
        <img
            src="{$skimages}calendar.gif"
            id="t_trigger_vft"
            style="cursor: pointer;"
            alt="{$i18n/l/Date_selector}"
            title="{$i18n/l/Date_selector}"
            onmouseover="this.style.background='red';"
            onmouseout="this.style.background=''"/>
        <script type="text/javascript">
          var current_datestring = "<xsl:value-of select="$chronicle_to_date"/>";
          var current_date;
          if ( current_datestring.length > 0 ) {
          current_date = Date.parseDate(current_datestring, "%Y-%m-%d").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
          }
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
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('chronicle_to')" class="doclink">(?)</a>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
