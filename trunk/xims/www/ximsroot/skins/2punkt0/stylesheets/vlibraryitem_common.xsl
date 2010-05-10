<?xml version="1.0" encoding="utf-8"?>
<!--
 # Copyright (c) 2002-2009 The XIMS Project.
 # See the file "LICENSE" for information and conditions for use, reproduction,
 # and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
 # $Id: vlibraryitem_common.xsl 2188 2009-01-03 18:24:00Z pepl $
 -->
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="common.xsl"/>
	<xsl:import href="vlibrary_common.xsl"/>
	
	<xsl:variable name="i18n_vlib" select="document(concat($currentuilanguage,'/i18n_vlibrary.xml'))"/>
	
	<xsl:template name="tr-vlproperties">
		<xsl:param name="mo"/>
		<div>
			<div class="label-large">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>:
      </div>
			<div id="mapped_{$mo}s">
				<xsl:choose>
					<xsl:when test="$mo='author'">
						<xsl:apply-templates select="authorgroup/author"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[name()=concat($mo, 'set')]/*[name()=$mo]"/>
					</xsl:otherwise>
				</xsl:choose>
				<span id="message_{$mo}"/>
				<xsl:text>&#160;</xsl:text>
			</div>
		</div>
		<div>
			<div class="label-large">
				<label for="svl{$mo}">
					<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>
				</label>
			</div>
			<!--<div>-->
			<xsl:if test="/document/context/*[name()=concat('vl', $mo,'s')]">
				<span id="svl{$mo}container">
					<xsl:apply-templates select="/document/context/*[name()=concat('vl', $mo,'s')]"/>
				</span>
				<xsl:text>&#160;</xsl:text>
			<!--<input type="button" name="create_mapping" value="{$i18n_vlib/l/Create_mapping}" class="ui-state-default ui-corner-all fg-button" onclick="createMapping('{$mo}', '{$i18n_vlib/l/select_name}')"/>-->
				<input type="button" name="create_mapping" value="{$i18n_vlib/l/Create_mapping}" class="ui-state-default ui-corner-all fg-button" onclick="createMapping('{$mo}', $('#svl{$mo}').val(), '{$i18n_vlib/l/select_name}')"/>
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo}','{$popupsizes[name()=$mo]/@x}','{$popupsizes[name()=$mo]/@y}')">
				<!--  <a onclick="$('#{$mo}_box').load('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo} fieldset')"> -->
				<xsl:value-of select="concat($i18n/l/create, ' ', $i18n_vlib/l/*[name()=$mo])"/>
			</a>
			<!--</div>-->
			<xsl:text>&#160;</xsl:text>
		</div>
	</xsl:template>
	
		<xsl:template name="form-vlproperties">
		<xsl:param name="mo"/>
		<div class="form-div block">
		<div class="block">
			<div class="label-large">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>:
      </div>
			<div id="mapped_{$mo}s">
				<xsl:choose>
					<xsl:when test="$mo='author'">
						<xsl:apply-templates select="authorgroup/author"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[name()=concat($mo, 'set')]/*[name()=$mo]"/>
					</xsl:otherwise>
				</xsl:choose>
				<span id="message_{$mo}"/>
				<xsl:text>&#160;</xsl:text>
			</div>
		</div>
		<div>
			<div class="label-large">
				<!--<label for="svl{$mo}">-->
				<label for="vl{$mo}">
					<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$i18n_vlib/l/*[name()=concat($mo,'s')]"/>
				</label>
			</div>
			<!--<div>-->
			<xsl:if test="/document/context/*[name()=concat('vl', $mo,'s')]">
				<span id="svl{$mo}container">
					<xsl:apply-templates select="/document/context/*[name()=concat('vl', $mo,'s')]"/>
				</span>
				<xsl:text>&#160;</xsl:text>
			<!--<input type="button" name="create_mapping" value="{$i18n_vlib/l/Create_mapping}" class="ui-state-default ui-corner-all fg-button" onclick="createMapping('{$mo}', '{$i18n_vlib/l/select_name}')"/>-->
				<button type="button" name="create_mapping" onclick="createMapping('{$mo}', $('#svl{$mo}').val(), '{$i18n_vlib/l/select_name}')"><xsl:value-of select="$i18n_vlib/l/Create_mapping" /></button>
				<!--<input type="button" name="create_mapping" value="{$i18n_vlib/l/Create_mapping}" class="ui-state-default ui-corner-all fg-button" onclick="createMapping('{$mo}', $('#svl{$mo}').val(), '{$i18n_vlib/l/select_name}')"/>-->
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			<a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo}','{$popupsizes[name()=$mo]/@x}','{$popupsizes[name()=$mo]/@y}')">
				<!--  <a onclick="$('#{$mo}_box').load('{$xims_box}{$goxims_content}{$parent_path}?property_edit=1;property={$mo} fieldset')"> -->
				<xsl:value-of select="concat($i18n/l/create, ' ', $i18n_vlib/l/*[name()=$mo])"/>
			</a>
			<!--</div>-->
			<xsl:text>&#160;</xsl:text>
		</div>
		</div>
	</xsl:template>
	
	<xsl:template name="tr-vlkeywords-create">
		<div>
			<div class="label-med">
				<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/Keywords"/>
			</div>
				<input tabindex="40" type="text" name="vlkeyword" size="50" value="" class="text" title="VLKeyword"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>
				<xsl:text>&#160;</xsl:text>
				<input type="button" value="&lt;--" onclick="return addVLProperty( 'keyword' );"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:apply-templates select="/document/context/vlkeywords"/>
		</div>
	</xsl:template>
	
	<xsl:template name="tr-vlsubjects-create">
		<div>
			<div class="label-med">
				<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_vlib/l/subjects"/>
			</div>
				<input tabindex="40" type="text" name="vlsubject" size="50" value="" class="text"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
				<xsl:text>&#160;</xsl:text>
				<input type="button" value="&lt;--" onclick="return addVLProperty( 'subject' );"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:apply-templates select="/document/context/vlsubjects"/>

		</div>
	</xsl:template>
	
	<xsl:template name="tr-vlauthors-create">
		<tr>
			<td valign="top">
				<xsl:value-of select="$i18n_vlib/l/Assign_new"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/Author"/>
			</td>
			<td colspan="2">
				<input tabindex="40" type="text" name="vlauthor" size="50" value="" class="text" title="VLAuthor"/>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('VLAuthor')" class="doclink">(?)</a>
				<xsl:text>&#160;</xsl:text>
				<input type="button" value="&lt;--" onclick="return addVLProperty( 'author' );"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:apply-templates select="/document/context/vlauthors"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template name="form-vlkeywords-edit">
		<div class="form-div block">
		<div class="block">
			<div class="label-med">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/Keywords"/>
			</div>
			<div class="div-left" style="width:600px">
				<xsl:apply-templates select="keywordset/keyword">
					<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				</xsl:apply-templates>
				</div>
			<br clear="all"/>
		</div>
		
		<div class="block">
			<div class="label-med">
				<label for="vlkeyword"><xsl:value-of select="$i18n_vlib/l/Assign_new"/>
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n/l/Keywords"/></label>
			</div>				
				<!--<a href="javascript:openDocWindow('VLKeyword')" class="doclink">(?)</a>-->				
				<xsl:apply-templates select="/document/context/vlkeywords"/>
				<xsl:text>&#160;</xsl:text>
				<button type="submit" name="create_mapping"><xsl:value-of select="$i18n_vlib/l/Create_mapping"/></button>
		</div>
		</div>
	</xsl:template>
	
	<xsl:template name="form-vlsubjects-edit">
	<div class="form-div block">
		<div class="block">
			<div class="label-med">
				<xsl:value-of select="$i18n_vlib/l/Currently_mapped"/>				
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="$i18n_vlib/l/subjects"/>
			</div>
			<div class="div-left" style="width:600px">
				<xsl:apply-templates select="subjectset/subject">
					<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				</xsl:apply-templates>
				
			</div>
			<br clear="all"/>
		</div>
		
		<div class="block">
			<div class="label-med">
							<label for="vlsubject"><xsl:value-of select="$i18n_vlib/l/Assign_new"/>				
							<xsl:text>&#160;</xsl:text>
							<xsl:value-of select="$i18n_vlib/l/subjects"/></label>
			</div>
				<!--
				<a href="javascript:openDocWindow('VLSubject')" class="doclink">(?)</a>
				-->
				<xsl:apply-templates select="/document/context/vlsubjects"/>
				<xsl:text>&#160;</xsl:text>
				<button type="submit" name="create_mapping"><xsl:value-of select="$i18n_vlib/l/Create_mapping"/></button>
		</div>
	</div>
	</xsl:template>
	
	<xsl:template match="keywordset/keyword|subjectset/subject|publicationset/publication">
		<a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="Browse in a new window">
			<xsl:value-of select="name"/>
			<xsl:if test="volume != ''">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="volume"/>
				<xsl:text>)</xsl:text>
			</xsl:if>
		</a>
		<xsl:text>&#160;</xsl:text>
		<!--<button type="button" name="remove_mapping" onclick="removeMapping('{name()}','{id}')"><xsl:value-of select="$i18n_vlib/l/Delete_mapping" /></button>-->
		<a href="javascript:removeMapping('{name()}', '{id}')">
			<xsl:attribute name="title"><xsl:value-of select="$i18n_vlib/l/Delete_mapping"/>: <xsl:value-of select="name"/></xsl:attribute>
			<span class="xdelete"> x </span>
		</a>
		<xsl:if test="position()!=last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="authorgroup/author">
		<a href="{$xims_box}{$goxims_content}{$parent_path}?{name()}=1;{concat(name(),'_id')}={id}" target="_blank" title="Browse in a new window">
			<xsl:value-of select="firstname"/>&#160;<xsl:value-of select="lastname"/>
		</a>
		<xsl:text>&#160;</xsl:text>
		<a href="javascript:removeMapping('{name()}', '{id}')" title="$i18n/l/Delete_mapping: {name}">
			<span class="xdelete"> x </span>
		</a>
		<xsl:if test="position()!=last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="vlsubjects">
		<select name="svlsubject" id="svlsubject">
			<xsl:apply-templates select="/document/context/vlsubjects/subject">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlkeywords">
		<select name="svlkeyword" id="svlkeyword">		
			<xsl:apply-templates select="/document/context/vlkeywords/keyword">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlpublications">
		<select name="svlpublication" id="svlpublication">
			<xsl:apply-templates select="/document/context/vlpublications/publication">
				<xsl:sort select="translate(name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
			</xsl:apply-templates>
		</select>
	</xsl:template>
	
	<xsl:template match="vlauthors">
		<select name="svlauthor" id="svlauthor">
			<xsl:apply-templates select="/document/context/vlauthors/author">
				<xsl:sort select="translate(lastname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				<xsl:sort select="translate(firstname,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
				<xsl:sort select="translate(middlename,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" order="ascending"/>
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
		<div>
			<div class="label">Thema</div>
				<input tabindex="20" type="text" name="subject" size="60" class="text" maxlength="256"/>
				<xsl:text>&#160;</xsl:text>
				<!-- <a href="javascript:openDocWindow('Subject')" class="doclink">(?)</a> -->
		</div>
	</xsl:template>
	
	<xsl:template name="form-subtitle">
		<div>
			<div class="label-std">
				<label for="input-subtitle">
					<xsl:value-of select="$i18n/l/Subtitle"/>
				</label>
			</div>
			<input type="text" name="subtitle" size="60" class="text" id="input-subtitle" value="{meta/subtitle}"/>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Title')" class="doclink">
				<xsl:attribute name="title">
					<xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Title"/>
				</xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	
	<xsl:template name="tr-mediatype">
		<xsl:call-template name="mk-textfield">
			<xsl:with-param name="title" select="'Mediatype'"/>
			<xsl:with-param name="xpath" select="'meta/mediatype'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="tr-legalnotice">
		<xsl:call-template name="mk-textfield">
			<xsl:with-param name="title" select="'Legalnotice'"/>
			<xsl:with-param name="xpath" select="'meta/legalnotice'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="tr-coverage">
		<xsl:call-template name="mk-textfield">
			<xsl:with-param name="title" select="'Coverage'"/>
			<xsl:with-param name="xpath" select="'meta/coverage'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="tr-audience">
		<xsl:call-template name="mk-textfield">
			<xsl:with-param name="title" select="'Audience'"/>
			<xsl:with-param name="xpath" select="'meta/audience'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="tr-bibliosource">
	<div>
	<label for="input-bibliosource">Bibliosource</label><br/>
		<textarea rows="3" cols="74" id="input-bibliosource" name="input-bibliosource"><xsl:value-of select="meta/bibliosource"/></textarea>
		<!--<xsl:call-template name="mk-textarea">
			<xsl:with-param name="title" select="'Bibliosource'"/>
			<xsl:with-param name="name" select="'bibliosource'"/>
			<xsl:with-param name="xpath" select="'meta/bibliosource'"/>
			<xsl:with-param name="length" select="2048"/>
			<xsl:with-param name="cols" select="79"/>
			<xsl:with-param name="rows" select="5"/>
		</xsl:call-template>-->
			</div>
	</xsl:template>

	
	<xsl:template name="tr-date-create">
		<tr>
			<td valign="top">Zeitraum</td>
			<td colspan="2">
        von
        <input tabindex="20" type="text" name="date_from" size="10" class="text" maxlength="10"/>
        (JJJJ-MM-TT)
        <img src="{$ximsroot}jscalendar-1.0/img.gif" id="f_trigger_c" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''"/>
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
        <input tabindex="20" type="text" name="date_to" size="10" class="text" maxlength="10"/>
        (JJJJ-MM-TT)<xsl:text>&#160;</xsl:text>
				<!-- <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> -->
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template name="tr-publisher">
		<xsl:call-template name="mk-textfield">
			<xsl:with-param name="title" select="'Institution'"/>
			<xsl:with-param name="name" select="'publisher'"/>
			<xsl:with-param name="xpath" select="'meta/publisher'"/>
		</xsl:call-template>
	</xsl:template>
	
<!--	<xsl:template name="tr-date-edit">
		<xsl:variable name="date_from" select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)"/>
		<tr>
			<td valign="top">Datum</td>
			<td colspan="2">
				<input tabindex="20" type="text" name="date" size="10" class="text" maxlength="10" value="{$date_from}"/>
        (JJJJ-MM-TT)<xsl:text>&#160;</xsl:text>
				--><!-- <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> --><!--
			</td>
		</tr>
	</xsl:template>-->
	
	<xsl:template name="form-date">
		<xsl:variable name="date_from" select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)"/>
		<div>
			<div class="label-std"><label for="input-date">Datum</label></div>
				<input type="text" name="date" id="input-date" size="10" class="text" />
        <!--(JJJJ-MM-TT)--><xsl:text>&#160;</xsl:text>
        <input id="date_from" type="hidden"></input>
				<!-- <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> -->
				<xsl:call-template name="ui-datepicker">
				<xsl:with-param name="input_id" select="'input-date'"/>
				<xsl:with-param name="formfield_id" select="'date_from'"/>
				<xsl:with-param name="xml_node" select="meta/date_from_timestamp"/>
				<xsl:with-param name="buttontext">
					<xsl:value-of select="$i18n/l/Edit"/>&#160;Datum<!--<xsl:value-of select="$i18n_vlib/l/chronicle_from"/>-->
				</xsl:with-param>
			</xsl:call-template>
		</div>
	</xsl:template>
	
	<!--<xsl:template name="tr-chronicle_from">
		<xsl:variable name="chronicle_from_date_tmp" select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)"/>
		<xsl:variable name="chronicle_from_date">
			<xsl:if test="$chronicle_from_date_tmp != '-'">
				<xsl:value-of select="$chronicle_from_date_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div>
			<div class="label-std">
				<xsl:value-of select="$i18n_vlib/l/chronicle_from"/>
			</div>
				<input tabindex="40" type="text" name="chronicle_from_date" id="chronicle_from_date" class="text" size="10" value="{$chronicle_from_date}"/>
				<xsl:text>&#160;</xsl:text>
				<img src="{$skimages}calendar.gif" id="f_trigger_vft" style="cursor: pointer;" alt="{$i18n/l/Date_selector}" title="{$i18n/l/Date_selector}" onmouseover="this.style.background='red';" onmouseout="this.style.background=''"/>
					<xsl:call-template name="mk-inline-js">
						<xsl:with-param name="code">
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
						</xsl:with-param>
					</xsl:call-template>
				<xsl:text>&#160;</xsl:text>
				<a href="javascript:openDocWindow('chronicle_from')" class="doclink">(?)</a>
		</div>
	</xsl:template>-->
	
	<xsl:template name="form-chronicle_from">
	<xsl:variable name="chronicle_from_date_tmp" select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)"/>
		<xsl:variable name="chronicle_from_date">
			<xsl:if test="$chronicle_from_date_tmp != '--'">
				<xsl:value-of select="$chronicle_from_date_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div>
			<div class="label-std">
				<label for="input-validfrom">
					<xsl:value-of select="$i18n_vlib/l/chronicle_from"/>
				</label>
			</div>
			<input type="text" id="input-validfrom" readonly="readonly" class="input">
				<xsl:choose>
					<xsl:when test="$chronicle_from_date != ''">
						<xsl:attribute name="value"><xsl:apply-templates select="meta/date_from_timestamp" mode="date"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<xsl:call-template name="ui-datepicker">
				<xsl:with-param name="input_id" select="'input-validfrom'"/>
				<xsl:with-param name="formfield_id" select="'chronicle_from_date'"/>
				<xsl:with-param name="xml_node" select="meta/date_from_timestamp"/>
				<xsl:with-param name="buttontext">
					<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n_vlib/l/chronicle_from"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_from')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_from"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	
	<xsl:template name="form-chronicle_to">
		<xsl:variable name="chronicle_to_date_tmp" select="concat(meta/date_to_timestamp/year,'-',meta/date_to_timestamp/month,'-',meta/date_to_timestamp/day)"/>
		<xsl:variable name="chronicle_to_date">
			<xsl:if test="$chronicle_to_date_tmp != '--'">
				<xsl:value-of select="$chronicle_to_date_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div>
			<div class="label-std">
				<label for="input-validto">
					<xsl:value-of select="$i18n_vlib/l/chronicle_to"/>
				</label>
			</div>
			<input type="text" id="input-validto" readonly="readonly" class="input">
				<xsl:choose>
					<xsl:when test="chronicle_to_date != ''">
						<xsl:attribute name="value"><xsl:apply-templates select="chronicle_to_date" mode="date"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="value"><xsl:value-of select="$i18n/l/Valid_from_default"/></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</input>
			<xsl:call-template name="ui-datepicker">
				<xsl:with-param name="input_id" select="'input-validto'"/>
				<xsl:with-param name="formfield_id" select="'chronicle_to_date'"/>
				<xsl:with-param name="xml_node" select="meta/date_to_timestamp"/>
				<xsl:with-param name="buttontext">
					<xsl:value-of select="$i18n/l/Edit"/>&#160;<xsl:value-of select="$i18n_vlib/l/chronicle_to"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:text>&#160;</xsl:text>
			<a href="javascript:openDocWindow('Valid_to')" class="doclink">
				<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n/l/Valid_to"/></xsl:attribute>(?)</a>
		</div>
	</xsl:template>
	
<!--	<xsl:template name="tr-chronicle_to">
		<xsl:variable name="chronicle_to_date_tmp" select="concat(meta/date_to_timestamp/year,'-',meta/date_to_timestamp/month,'-',meta/date_to_timestamp/day)"/>
		<xsl:variable name="chronicle_to_date">
			<xsl:if test="$chronicle_to_date_tmp != '-'">
				<xsl:value-of select="$chronicle_to_date_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div>
			<div class="label-std">
				<xsl:value-of select="$i18n_vlib/l/chronicle_to"/>
			</div>
				<input tabindex="40" type="text" name="chronicle_to_date" id="chronicle_to_date" class="text" size="10" value="{$chronicle_to_date}"/>
				<xsl:text>&#160;</xsl:text>
				<img src="{$skimages}calendar.gif" id="t_trigger_vft" style="cursor: pointer;" alt="{$i18n/l/Date_selector}" title="{$i18n/l/Date_selector}" onmouseover="this.style.background='red';" onmouseout="this.style.background=''"/>
				<script type="text/javascript">
var current_datestring = "<xsl:value-of select="$chronicle_to_date"/>";
var current_date;
if ( current_datestring.length &gt; 0 ) {
  current_date = Date.parseDate(current_datestring, "%Y-%m-%d").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
}

Calendar.setup({ inputField     :    "chronicle_to_date",
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
		</div>
	</xsl:template>-->
	
	<xsl:template name="form-dc_date">
		<!--<xsl:variable name="date_from" select="concat(meta/date_from_timestamp/year,'-',meta/date_from_timestamp/month,'-',meta/date_from_timestamp/day)"/>-->
		<div>
			<div class="label-std"><label for="input-dc_date"><xsl:value-of select="$i18n/l/Date_selector"/></label></div>
				<input type="text" name="input-dc_date" id="input-dc_date" size="10" class="text" />
        <!--(JJJJ-MM-TT)--><xsl:text>&#160;</xsl:text>
        <!--<input id="dc_date" name="dc_date" type="hidden"></input>-->
				<!-- <a href="javascript:openDocWindow('Date')" class="doclink">(?)</a> -->
				<xsl:call-template name="ui-datepicker">
				<xsl:with-param name="input_id" select="'input-dc_date'"/>
				<xsl:with-param name="formfield_id" select="'dc_date'"/>
				<xsl:with-param name="xml_node" select="meta/dc_date"/>
				<xsl:with-param name="buttontext">
					<xsl:value-of select="$i18n/l/Edit"/>&#160;Datum<!--<xsl:value-of select="$i18n_vlib/l/chronicle_from"/>-->
				</xsl:with-param>
				<xsl:with-param name="mode" >date</xsl:with-param>
			</xsl:call-template>
		</div>
	</xsl:template>
	
<!--	<xsl:template name="tr-dc_date">
		<xsl:variable name="dc_date_tmp" select="concat(meta/dc_date/year,
                                 '-',
                                 meta/dc_date/month,
                                 '-',
                                 meta/dc_date/day)"/>
		<xsl:variable name="dc_date">
			<xsl:if test="$dc_date_tmp != '- -'">
				<xsl:value-of select="$dc_date_tmp"/>
			</xsl:if>
		</xsl:variable>
		<div>
			<div id="label-validfrom">
				<label for="dc_date">
					<xsl:value-of select="$i18n/l/Date_selector"/>
				</label>
			</div>
			<input type="text" name="dc_date" id="dc_date" class="text" size="10" value="{$dc_date}"/>
			<xsl:text>&#160;</xsl:text>
			<img src="{$skimages}calendar.gif" id="f_trigger_vft" style="cursor: pointer;" alt="{$i18n/l/Date_selector}" title="{$i18n/l/Date_selector}" onmouseover="this.style.background='red';" onmouseout="this.style.background=''"/>
			<xsl:call-template name="mk-inline-js">
				<xsl:with-param name="code">
                  var current_datestring = "<xsl:value-of select="$dc_date"/>";
          var current_date;
          if ( current_datestring.length > 0 ) {
            current_date = Date.parseDate(current_datestring, "%Y-%m-%d").print("<xsl:value-of select="$i18n/l/NamedDateFormat"/>");
          }
          Calendar.setup({
            inputField     :    "dc_date",
            ifFormat       :    "%Y-%m-%d",
            displayArea    :    "show_vft",
            daFormat       :    "<xsl:value-of select="$i18n/l/NamedDateFormat"/>",
            button         :    "f_trigger_vft",
            align          :    "Tl",
            singleClick    :    true,
            showsTime      :    true,
            timeFormat     :    "24"
          });
        </xsl:with-param>
			</xsl:call-template>
		</div>
	</xsl:template>-->
	
	<xsl:template name="form-locationtitlesubtitle-edit">
	<div class="form-div div-left">
		<xsl:call-template name="form-title"/>
		<xsl:call-template name="form-location-edit"/>
	<xsl:call-template name="form-subtitle"/>
		</div>
	</xsl:template>
	
	<xsl:template name="form-locationtitleundertitle-create">
	<div class="form-div div-left">
		<xsl:call-template name="form-title"/>
		<xsl:call-template name="form-location-create"/>
	<xsl:call-template name="form-undertitle"/>
		</div>
	</xsl:template>
	
	<xsl:template name="form-metadata">
	<xsl:param name="mode"/>
		<div class="form-div block">
		<h2>Meta Data</h2>
		<xsl:call-template name="form-abstract"/>
		<xsl:call-template name="tr-publisher"/>
	<!--<xsl:call-template name="tr-chronicle_from"/>
	<xsl:call-template name="tr-chronicle_to"/>-->
	<xsl:choose>
		<xsl:when test="$mode = 'chronicle'">
			<xsl:call-template name="form-chronicle_from"/>
			<xsl:call-template name="form-chronicle_to"/>
		</xsl:when>
		<xsl:when test="$mode = 'date'">
		<xsl:call-template name="form-dc_date"/>
		</xsl:when>
	</xsl:choose>
	
		</div>
	</xsl:template>
	
	<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2>Objekt-spezifische Optionen</h2>
			<xsl:call-template name="tr-mediatype"/>
	<xsl:call-template name="tr-coverage"/>
	<xsl:call-template name="tr-audience"/>
	<xsl:call-template name="tr-legalnotice"/>
	<xsl:call-template name="tr-bibliosource"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
