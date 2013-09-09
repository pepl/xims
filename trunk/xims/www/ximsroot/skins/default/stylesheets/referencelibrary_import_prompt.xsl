<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_import_prompt.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>
<xsl:import href="create_common.xsl"/>

<xsl:template name="create-content">
	<xsl:call-template name="form-importsourcetype"/>
                    
                    <xsl:call-template name="form-body-import"/>
                    <xsl:call-template name="form-bodyfromfile-import"/>

                <xsl:call-template name="import"/>
</xsl:template>

<xsl:template name="form-importsourcetype">
    <div><label for="importformat">Format</label>:&#160;
            <select name="importformat" id="importformat">
                <option value="BibTeX">BibTeX</option>
                <option value="RIS">RIS</option>
                <option value="Endnote">Endnote</option>
                <option value="Pubmed">Pubmed</option>
                <option value="MODS">MODS</option>
                <option value="ISI">ISI Web of Science</option>
                <option value="COPAC">COPAC</option>
            </select>
            <!--<a href="javascript:openDocWindow('ReferenceLibraryItem Import Source Type')" class="doclink">(?)</a>-->
		</div>
</xsl:template>

<xsl:template name="form-body-import">
            <div id="bodymain">
            <label for="body">Body</label>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import')" class="doclink">(?)</a>-->
            <br/>
            <xsl:call-template name="ui-resizable"/>
                <div id="bodycon">
                    <textarea name="body" id="body" rows="15" cols="90" class="resizable ui-widget-content">&#160;</textarea>
                </div>
            </div>
</xsl:template>

<xsl:template name="form-bodyfromfile-import">
    <div>
        <label for="file"><xsl:value-of select="$i18n/l/or"/>&#160;<xsl:value-of select="$i18n/l/ImportFromFile"/></label>&#160;
            <input type="file" name="file" size="49" class="text" id="file"/>
            <!--<xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import')" class="doclink">(?)</a>-->
    </div>
</xsl:template>

<xsl:template name="import">
    <input type="hidden" name="id" value="{@id}"/>
    <xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
        <input name="sb" type="hidden" value="date"/>
        <input name="order" type="hidden" value="desc"/>
    </xsl:if>
    <input type="submit" name="import" value="{$i18n_vlib/l/Import}" class="control hidden" accesskey="S"/>
</xsl:template>

<xsl:template name="title">
    <xsl:value-of select="$i18n/l/ImportItem"/>&#160;'<xsl:value-of select="title"/>' - XIMS
</xsl:template>

<xsl:template name="save_jsbutton">
		<button class="button" type="submit" name="submit_eform" accesskey="S" onclick="document.eform.import.click(); return false">
				<xsl:value-of select="$i18n/l/save"/>
		</button>
</xsl:template>

</xsl:stylesheet>
