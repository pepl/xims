<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_contentbrowse.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="common.xsl"/>
<xsl:import href="container_common.xsl"/>

<xsl:variable name="target_path"><xsl:call-template name="targetpath"/></xsl:variable>
<xsl:variable name="target_path_abs"><xsl:call-template name="targetpath_abs"/></xsl:variable>
<xsl:variable name="target_path_nosite"><xsl:call-template name="targetpath_nosite"/></xsl:variable>
<xsl:param name="otfilter"/>
<xsl:param name="notfilter"/>
<xsl:param name="sbfield"/>
<xsl:param name="urllink" />
<xsl:param name="order" />
<xsl:param name="sb" />

<xsl:param name="pagerowlimit" select="$searchresultrowlimit"/>
<xsl:variable name="totalpages">
    <xsl:choose>
      <xsl:when test="$onepage &gt; 0">
        <xsl:number value="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number value="ceiling(/document/context/object/targetchildren/totalobjects div $pagerowlimit)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<xsl:template match="/document/context/object">
 <xsl:variable name="navurl">
      <xsl:text>javascript:reloadDialog('</xsl:text>
      <xsl:value-of select="concat($xims_box,$goxims_content,'?')"/>
      <xsl:value-of select="concat('id=',@id,';')"/>
      <xsl:text>contentbrowse=1;</xsl:text>
      <xsl:text>otfilter=</xsl:text><xsl:value-of select="$otfilter"/><xsl:text>;</xsl:text>
      <xsl:text>notfilter=</xsl:text><xsl:value-of select="$notfilter"/><xsl:text>;</xsl:text>
      <xsl:if test="$defsorting != 1">
        <xsl:value-of select="concat('sb=',$sb,';order=',$order,';')"/>
      </xsl:if>
      <xsl:if test="$pagerowlimit != $searchresultrowlimit">
        <xsl:value-of select="concat(';pagerowlimit=',$pagerowlimit,';')"/>
      </xsl:if>
      <xsl:text>','default-dialog')</xsl:text>
    </xsl:variable> 
	<form action="{$xims_box}{$goxims_content}" method="post" name="selectform">
		<p>
			<xsl:value-of select="$i18n/l/Browse_to"/>:
			<br/>&#xa0;
			
			<xsl:apply-templates select="targetparents/object[@id !='1']"/>
			<xsl:apply-templates select="target/object"/>
		</p>
		<xsl:call-template name="form-container-sorting"/>

    <xsl:if test="$totalpages &gt; 1">
      <xsl:call-template name="pagenav">
      <xsl:with-param name="totalitems">
        <xsl:value-of  select="/document/context/object/children/@totalobjects"/>
      </xsl:with-param>
        <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
        <xsl:with-param name="currentpage" select="$page"/>
        <xsl:with-param name="url" select="$navurl"/>
      </xsl:call-template>
    </xsl:if>
    <br class="clear"/>
      <xsl:apply-templates select="targetchildren/object[marked_deleted != '1']">
        <xsl:sort select="$sb" order="{concat($order,'ending')}" case-order="lower-first"/> 
      </xsl:apply-templates>    
		<input type="hidden" name="id" value="{@id}"/>
		
		<xsl:if test="$totalpages &gt; 1">
      <xsl:call-template name="pagenav">
      <xsl:with-param name="totalitems">
        <xsl:value-of  select="/document/context/object/children/@totalobjects"/>
      </xsl:with-param>
        <xsl:with-param name="itemsperpage" select="$searchresultrowlimit"/>
        <xsl:with-param name="currentpage" select="$page"/>
        <xsl:with-param name="url" select="$navurl"/>
      </xsl:call-template>
    </xsl:if>
    <br class="clear"/>
	</form>
	<xsl:call-template name="mk-inline-js">
		<xsl:with-param name="code">
			function storeBack(target) {
					document.<xsl:value-of select="$sbfield"/>.value=target;
					$("#default-dialog").dialog("close");
			}
		</xsl:with-param>
</xsl:call-template>
</xsl:template>

<xsl:template name="pagelink-href">
   <xsl:param name="url"/>
   <xsl:param name="page"/>
   <xsl:text>javascript:reloadDialog('</xsl:text>
      <xsl:value-of select="concat($xims_box,$goxims_content,'?')"/>
      <xsl:value-of select="concat('id=',@id,';')"/>
      <xsl:text>contentbrowse=1;</xsl:text>
      <xsl:text>otfilter=</xsl:text><xsl:value-of select="$otfilter"/><xsl:text>;</xsl:text>
      <xsl:text>notfilter=</xsl:text><xsl:value-of select="$notfilter"/><xsl:text>;</xsl:text>
      <xsl:value-of select="concat('to=',target/object/@id,';')"/>
      <!-- <xsl:if test="$defsorting != 1"> -->
        <xsl:value-of select="concat('sb=',$sb,';order=',$order,';')"/>
      <!-- </xsl:if> -->
      <xsl:value-of select="concat('sbfield=',$sbfield,';')"/>
      <xsl:if test="$pagerowlimit != $searchresultrowlimit">
        <xsl:value-of select="concat(';pagerowlimit=',$pagerowlimit,';')"/>
      </xsl:if>
      <xsl:value-of select="concat('page=',$page,';')"/>
      <xsl:text>','default-dialog')</xsl:text>
  </xsl:template>
  
  

<xsl:template name="title">
<xsl:value-of select="$i18n/l/Browse_for"/>
      <xsl:choose>
        <xsl:when test="$otfilter != ''">
          '<xsl:value-of select="$otfilter"/>'
        </xsl:when>
        <xsl:otherwise>
          '<xsl:value-of select="$i18n/l/Object"/>'
        </xsl:otherwise>
      </xsl:choose>
    - XIMS
</xsl:template>

<xsl:template match="targetparents/object|target/object">
	/ <a class="" href="javascript:reloadDialog('{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};sbfield={$sbfield};urllink={$urllink}','default-dialog')">	
		<xsl:value-of select="location"/>
	</a>
</xsl:template>

<xsl:template match="targetchildren/object">
	<xsl:variable name="dataformat">
		<xsl:value-of select="data_format_id"/>
	</xsl:variable>
	<xsl:variable name="objecttype">
		<xsl:value-of select="object_type_id"/>
	</xsl:variable>
	<p style="white-space: nowrap;">
	<xsl:call-template name="cttobject.options.spacer"/>
	<xsl:call-template name="cttobject.dataformat"/>
	<xsl:choose>
	<xsl:when test="/document/data_formats/data_format[@id=$dataformat]/mime_type = 'application/x-container'">
		<a href="javascript:reloadDialog('{$xims_box}{$goxims_content}?id={/document/context/object/@id};contentbrowse=1;to={@id};otfilter={$otfilter};notfilter={$notfilter};sbfield={$sbfield};urllink={$urllink}','default-dialog')"><xsl:value-of select="title"/></a>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="title"/>
	</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$otfilter = '' or contains( $otfilter ,/document/object_types/object_type[@id=$objecttype]/name )">
		<xsl:choose>
			<xsl:when test="$urllink != ''">
				(<xsl:value-of select="$i18n/l/Click"/>&#xa0;
				<xsl:choose>
					<xsl:when test="/document/object_types/object_type[@id=$objecttype]/is_fs_container = 1">
						<a href="javascript:storeBack('{$target_path_nosite}/{location}/');"><xsl:value-of select="$i18n/l/here"/></a>&#xa0;
					</xsl:when>
					<xsl:otherwise>
						<a href="javascript:storeBack('{$target_path_nosite}/{location}');"><xsl:value-of select="$i18n/l/here"/></a>&#xa0;
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$i18n/l/to_store_back"/>)
			</xsl:when>
			<xsl:otherwise>
			(<xsl:value-of select="$i18n/l/Click"/>&#xa0;
				<a href="javascript:storeBack('{$target_path}/{location}');"><xsl:value-of select="$i18n/l/here"/></a>&#xa0;
				<xsl:value-of select="$i18n/l/to_store_back"/>)
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</p>
</xsl:template>

<xsl:template name="form-container-sorting">
    <p style="white-space: nowrap;width:100%">Sortierung:
    <span>
    <select id="select-sb" >
      <option value="position"><xsl:if test="$sb='position'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Position</option>
      <option value="title"><xsl:if test="$sb='title'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Titel</option>
      <option value="date"><xsl:if test="$sb='date'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>Zuletzt geändert</option>
    </select>
    <input id="defaultsorting-asc" class="radio-button" type="radio" value="asc" name="defaultsorting">
      <xsl:if test="$order='asc'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
    </input>
    <label for="defaultsorting-asc">aufsteigend</label>
    <input id="defaultsorting-desc" class="radio-button" type="radio" value="desc" name="defaultsorting">
      <xsl:if test="$order='desc'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if>
    </input>
    <label for="defaultsorting-desc">absteigend</label>
    <xsl:call-template name="mk-inline-js">
    <xsl:with-param name="code">
    $('#select-sb, input[name=defaultsorting]').change(function(){    
      //console.log("style: "+style);
      //console.log($('#select-sb').val()+'\n'+$('input[name=defaultsorting]:checked').val()+'\n');
      if (typeof(style) !== 'undefined' &amp;&amp; style != '' ){        
        var br_url = '<xsl:value-of select="$xims_box"/><xsl:value-of select="$goxims_content"/>?id=<xsl:value-of select="/document/context/object/@id"/>;contentbrowse=1;to=<xsl:value-of select="target/object/@id"/>;otfilter=<xsl:value-of select="$otfilter"/>;notfilter=<xsl:value-of select="$notfilter"/>;style='+style+';sbfield=<xsl:value-of select="$sbfield"/>;urllink=<xsl:value-of select="$urllink"/>;order='+$('input[name=defaultsorting]:checked').val()+';sb='+$('#select-sb').val();
        window.location = br_url;
      }
      else{
        var br_url='<xsl:value-of select="$xims_box"/><xsl:value-of select="$goxims_content"/><xsl:value-of select="/document/context/object/location_path"/>?contentbrowse=1;to=<xsl:value-of select="target/object/@id"/>;otfilter=<xsl:value-of select="$otfilter"/>;notfilter=<xsl:value-of select="$notfilter"/>;sbfield=<xsl:value-of select="$sbfield"/>;urllink=<xsl:value-of select="$urllink"/>;order='+$('input[name=defaultsorting]:checked').val()+';sb='+$('#select-sb').val();
        console.log(br_url);
        return reloadDialog(br_url,'default-dialog');
      }
    });
    </xsl:with-param>
    </xsl:call-template>
    </span>
    </p>
    </xsl:template>
</xsl:stylesheet>

