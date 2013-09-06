<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: sqlreport_common.xsl 2188 2009-01-03 18:24:00Z pepl $
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<!--<xsl:import href="common.xsl"/>-->

    <xsl:variable name="i18n_sqlrep" select="document(concat($currentuilanguage,'/i18n_sqlrep.xml'))"/>

<xsl:template name="skeys">
    <div id="tr-skeys">
        <div class="label-med">
            <label for="input-skeys"><xsl:value-of select="$i18n_sqlrep/l/Search_keys"/></label>
        </div>
            <input name="skeys" type="text" value="{attributes/skeys}" class="text" size="60" id="input-skeys"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('skeys')" class="doclink">
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n_sqlrep/l/Search_keys"/></xsl:attribute>
            (?)</a>-->
        </div>
</xsl:template>

<xsl:template name="pagesize">
    <div id="tr-pagesize">
        <div class="label-med"><label for="input-pagesize">
            <xsl:value-of select="$i18n_sqlrep/l/Pagesize"/></label></div>
            <input name="pagesize" type="text" value="{attributes/pagesize}" class="text" size="5" id="input-pagesize"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('pagesize')" class="doclink">
								<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n_sqlrep/l/Pagesize"/></xsl:attribute>
            (?)</a>-->
        </div>
</xsl:template>

<xsl:template name="dbdsn">
    <div id="tr-dbdsn">
        <div class="label-med">
            <label for="input-dbdsn"><xsl:value-of select="$i18n_sqlrep/l/Database_DSN"/></label>
        </div>
            <input name="dbdsn" type="text" value="{attributes/dbdsn}" class="text" size="60" id="input-dbdsn"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('dbdsn')" class="doclink">
							<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n_sqlrep/l/Database_DSN"/></xsl:attribute>
							(?)</a>-->
        </div>
</xsl:template>

<xsl:template name="dbuser">
    <div id="tr-dbuser">
        <div class="label-med">
            <label for="input-dbuser"><xsl:value-of select="$i18n_sqlrep/l/Database_User"/></label>
        </div>
            <input name="dbuser" type="text" value="{attributes/dbuser}" class="text" size="60" id="input-dbuser" />
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('dbuser')" class="doclink">
							<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n_sqlrep/l/Database_User"/></xsl:attribute>
							(?)</a>-->
        </div>
</xsl:template>

<xsl:template name="dbpwd">
    <div id="tr-dbpwd">
        <div class="label-med">
            <label for="input-dbpwd"><xsl:value-of select="$i18n_sqlrep/l/Database_Password"/></label>
        </div>
            <input name="dbpwd" type="password" value="{attributes/dbpwd}" class="text" size="60" id="input-dbpwd"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('dbpwd')" class="doclink">
							<xsl:attribute name="title"><xsl:value-of select="$i18n/l/Documentation"/>:&#160;<xsl:value-of select="$i18n_sqlrep/l/Database_Password"/></xsl:attribute>
							(?)</a>-->
        </div>
</xsl:template>

<xsl:template name="form-obj-specific">
		<div class="form-div block">
		<h2><xsl:value-of select="$i18n/l/ExtraOptions"/></h2>
			<xsl:call-template name="pagesize"/>
			<xsl:call-template name="skeys"/>
			<xsl:call-template name="dbdsn"/>
			<xsl:call-template name="dbuser"/>
			<xsl:call-template name="dbpwd"/>
		</div>
	</xsl:template>
	
<xsl:template name="form-bodyfromfile-create"/>
<xsl:template name="form-bodyfromfile-edit"/>
<xsl:template name="form-minify"/>
<xsl:template name="testbodysxml"/>
<xsl:template name="prettyprint"/>
<xsl:template name="trytobalance"/>
</xsl:stylesheet>
