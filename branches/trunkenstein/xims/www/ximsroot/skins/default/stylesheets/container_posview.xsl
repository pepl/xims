<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2015 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: container_posview.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>

    <xsl:param name="sbfield"/>

<xsl:template match="/document/context/object">
	<form name="repos" action="javascript:storeBack(document.repos.new_position.value)">
		<p>
			<xsl:value-of select="$i18n/l/Choose_position"/>&#160;<strong>'<xsl:value-of select="title"/>'</strong>&#160;<xsl:value-of select="$i18n/l/in"/>
			Container '<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/title"/>':
		</p>
		<p>
			<label for="input-position"><xsl:value-of select="$i18n/l/Position"/></label>
			    <xsl:choose>
    <xsl:when test="siblingscount &gt; 50">
      &#160;<input type="text" name="new_position" id="input-position" size="4"></input>&#160;
    </xsl:when>
    <xsl:otherwise>
			<select name="new_position" class="select" id="input-position">
			    <xsl:call-template name="loop-options">
			        <xsl:with-param name="iter"><xsl:value-of select="1"/></xsl:with-param>
			    </xsl:call-template>
			</select>
			</xsl:otherwise>
    </xsl:choose>
			<button class="button" type="submit" name="submit">
				<xsl:value-of select="$i18n/l/save"/>
			</button>
		</p>
	</form>
	<form name="reposition{@id}" method="post" action="{$xims_box}{$goxims_content}">
      <xsl:call-template name="input-token"/>
	  <input type="hidden" name="id" value="{@id}"/>
	  <input type="hidden" name="reposition" value="yes"/>
	  <input type="hidden" name="new_position" value=""/>
	</form>
	<script type="text/javascript">
		function storeBack(value) {
			document.<xsl:value-of select="$sbfield"/>.value=value;
			document.<xsl:value-of select="substring-before($sbfield, '.')"/>.submit();
			$("#position-dialog").dialog(close);
		}
	</script>
</xsl:template>

<xsl:template name="loop-options">
    <!-- This template loops over a number of position ids -->
    <xsl:param name="iter"/>

    <xsl:if test="$iter != (siblingscount+1)">
        <option value="{$iter}">
            <xsl:if test="position=$iter">
                <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$iter"/>
        </option>

        <xsl:call-template name="loop-options">
            <xsl:with-param name="iter" select="$iter + 1"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="title">
    <xsl:value-of select="$i18n/l/Position_object"/> '<xsl:value-of select="parents/object[@document_id=/document/context/object/@parent_id]/title"/>' - XIMS
</xsl:template>

</xsl:stylesheet>
