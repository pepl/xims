<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: anondiscussionforum_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">

<xsl:param name="sb" select="'date'"/>
<xsl:param name="order" select="'desc'"/>

<xsl:template match="br|a|b|i|p|strong|em|dd|dl|li|ul|ol|hr|font|span|div">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
</xsl:template>

<xsl:template name="path2topics">
    <xsl:for-each select="/document/context/object/parents/object[object_type_id != /document/object_types/object_type[name='AnonDiscussionForumContrib']/@id and @id != 1]">
        <xsl:text>/</xsl:text><xsl:value-of select="location"/>
    </xsl:for-each>
</xsl:template>

<xsl:template name="script_bottom">
<script src="{$ximsroot}skins/{$currentskin}/scripts/min.js" type="text/javascript"/>
		<!--<script src="{$ximsroot}skins/{$currentskin}/scripts/2punkt0.js" type="text/javascript"/>-->
		<!--<script src="{$ximsroot}scripts/default.js" type="text/javascript"/>-->
    <!--<script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>-->
    <script src="{$ximsroot}scripts/anondiscussionforum.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
</xsl:template>

<xsl:template name="write-topic">
<xsl:param name="reply" select="false()"/>

	<xsl:if test="$reply">
    <a name="reply"/>
  </xsl:if>
  
  <div class="forumbox">
    <form name="eform" method="post" onsubmit="return checkFields()">
					<xsl:attribute name="action">
						<xsl:choose>
							<xsl:when test="$reply">
								<xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'?objtype=AnonDiscussionForumContrib')"/>	
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($xims_box,$goxims_content,$parent_path,'?objtype=',$objtype)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
      <input type="hidden" name="objtype" value="{$objtype}"/>
      
          <div class="forumhead">
						<xsl:choose>
							<xsl:when test="$reply"><xsl:value-of select="$i18n/l/reply"/></xsl:when>
						</xsl:choose>
						</div>
        <xsl:if test="$reply">
					<div>
					<div class="forumcontent">
						<label for="input-topic">
							<xsl:choose>
								<xsl:when test="$reply"><xsl:value-of select="$i18n/l/Title"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$i18n/l/Topic"/></xsl:otherwise>
							</xsl:choose>
						</label> *</div>
          <input class="foruminput" type="text" name="title" size="60" id="input-topic">
						<xsl:if test="$reply">
										<xsl:attribute name="value">Re: <xsl:value-of select="title"/></xsl:attribute>
									</xsl:if>
						</input>
         </div>
        </xsl:if>        
        <div>
          <div class="forumcontent"><label for="input-author"><xsl:value-of select="$i18n/l/Author"/></label> *</div>
          <input class="foruminput" type="text" name="author" size="60" id="input-author"/>
        </div>
        <div>
          <div class="forumcontent"><label for="input-email"><xsl:value-of select="$i18n/l/Email"/></label></div>
          <input class="foruminput" type="text" name="email" size="60" id="input-email"/>
        </div>
        <xsl:if test="not($reply)">
					<div>
						<div class="forumcontent"><label for="input-coauthor"><xsl:value-of select="$i18n/l/Coauthor"/></label></div>
						<input class="foruminput" type="text" name="coauthor" size="60" id="input-coauthor"/>
        </div>
        <div>
          <div class="forumcontent">
						<xsl:value-of select="$i18n/l/Coauthor"/><label for="input-coemail">&#160;<xsl:value-of select="$i18n/l/Email"/></label>
          </div>
          <div><input class="foruminput" type="text" name="coemail" size="60" id="input-coemail"/></div>
        </div>
        </xsl:if>
        <div>
          <div class="forumcontent"><label for="input-text"><xsl:value-of select="$i18n/l/Text"/></label> *</div>          
            <textarea class="foruminput" name="body" rows="10" cols="57" id="input-text"></textarea>
        </div>
        <xsl:call-template name="saveaction"/>
    </form>
</div>
</xsl:template>

</xsl:stylesheet>

