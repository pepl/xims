<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2009 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: referencelibrary_import_prompt.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="referencelibraryitem_common.xsl"/>

<xsl:template match="/document/context/object">
<html>
    <xsl:call-template name="head_default"/>
    <body>
					<xsl:call-template name="header"/>	

			<div class="edit">
				<div id="tab-container" class="ui-corner-top">
					<div id="create-title"><h1><xsl:value-of select="$i18n/l/ImportItem"/>&#160;'<xsl:value-of select="title"/>'</h1></div>
				</div>
				<div class="cancel-save">
					<xsl:call-template name="cancelcreateform">
						<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
				</div>
		    <div id="content-container" class="ui-corner-bottom ui-corner-tr">
            <!--<xsl:call-template name="table-import"/>-->
            <form action="{$xims_box}{$goxims_content}?id={@id}" name="eform" method="post" enctype="multipart/form-data" id="create-edit-form">

                    <xsl:call-template name="tr-importsourcetype"/>
                    
                    <xsl:call-template name="tr-body-import"/>
                    <xsl:call-template name="tr-bodyfromfile-import"/>

                <xsl:call-template name="import"/>
            </form>
        </div>
        <div class="cancel-save">
					<xsl:call-template name="cancelcreateform">
						<xsl:with-param name="with_save">yes</xsl:with-param>
						</xsl:call-template>
				</div>
			</div>
    </body>
</html>
</xsl:template>

<xsl:template name="tr-importsourcetype">
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
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import Source Type')" class="doclink">(?)</a>
		</div>
</xsl:template>

<xsl:template name="tr-body-import">
            <div id="bodymain">
            <label for="body">Body</label>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import')" class="doclink">(?)</a>
            <br/>
            <xsl:call-template name="ui-resizable"/>
                <div id="bodycon">
                    <textarea name="body" id="body" rows="15" cols="90" class="resizable ui-widget-content">&#160;</textarea>
                </div>
            </div>
</xsl:template>

<xsl:template name="tr-bodyfromfile-import">
    <div>
        <label for="file"><xsl:value-of select="$i18n/l/or"/>&#160;<xsl:value-of select="$i18n/l/ImportFromFile"/></label>&#160;
            <input type="file" name="file" size="49" class="text" id="file"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ReferenceLibraryItem Import')" class="doclink">(?)</a>
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

<!--<xsl:template name="table-import">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0" style="margin: 0px; padding: 2px">
        <tr>
            <td valign="top">
                <strong>Import items into &#160;'<xsl:value-of select="title"/>' (<xsl:value-of select="$absolute_path"/>)</strong>
            </td>
            <td align="right" valign="top">
                <xsl:call-template name="cancelform">
                    <xsl:with-param name="with_save">yes</xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </table>
</xsl:template>-->

<xsl:template name="title">
    <xsl:value-of select="$i18n/l/ImportItem"/>&#160;'<xsl:value-of select="title"/>' - XIMS
</xsl:template>

<xsl:template name="save_jsbutton">
		<button class="ui-state-default ui-corner-all fg-button" type="submit" name="submit_eform" accesskey="S" onclick="document.eform.import.click(); return false">
			<span class="text">
				<xsl:value-of select="$i18n/l/save"/>
			</span>
		</button>
</xsl:template>

</xsl:stylesheet>
