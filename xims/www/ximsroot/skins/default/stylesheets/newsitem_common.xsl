<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2011 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:import href="document_common.xsl"/>
<xsl:import href="common_jscalendar_scripts.xsl"/>
<xsl:variable name="i18n_news" select="document(concat($currentuilanguage,'/i18n_newsitem.xml'))" />
<xsl:variable name="parentid" select="/document/context/object/parents/object[@document_id=/document/context/object/@parent_id]/@id"/>

<xsl:template name="tr-leadimage-create">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Lead"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="25" name="abstract" rows="5" cols="100" class="text" onkeyup="keyup(this)"><xsl:text>&#160;</xsl:text></textarea>
            <script type="text/javascript">document.getElementsByName("abstract")[0].value = '';</script>
            <xsl:text>&#160;</xsl:text><span id="charcount"><xsl:text>&#160;</xsl:text></span>
            <xsl:call-template name="charcountcheck"/>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/></td>
        <td colspan="2">
            <input tabindex="26" type="file" name="imagefile" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
      </td>
    </tr>
    <tr>
        <td valign="top">
            <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="$i18n/l/Title"/>
        </td>
        <td colspan="2">
            <input tabindex="27" type="text" name="imagetitle" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ImageTitle')" class="doclink">(?)</a>
      </td>
    </tr>
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="$i18n/l/Description"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('ImageDescription')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="28" name="imagedescription" rows="2" cols="100" class="text"><xsl:text>&#160;</xsl:text></textarea>
            <script type="text/javascript">document.getElementsByName("imagedescription")[0].value = '';</script>
      </td>
    </tr>
    <tr>
         <td valign="top">
            <xsl:value-of select="$i18n/l/Image"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="$i18n/l/target"/>
         </td>
        <td colspan="2">
            <input tabindex="29" type="text" name="imagefolder" size="40" class="text">
                <!--  Provide an "educated-guess" default value -->
                <xsl:attribute name="value">
                    <xsl:for-each select="/document/context/object/parents/object[@document_id != 1]">
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="location"/>
                    </xsl:for-each><xsl:text>/images</xsl:text>
                </xsl:attribute>
            </input>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={$parentid};to={$parentid};otfilter=Folder,DepartmentRoot,SiteRoot;contentbrowse=1;sbfield=eform.imagefolder')" class="doclink"><xsl:value-of select="$i18n/l/browse_target"/></a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('NewsItemImage')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>
<xsl:template name="tr-leadimage-edit">
    <tr>
        <td valign="top" colspan="3">
            <xsl:value-of select="$i18n/l/Lead"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="25" name="abstract" rows="5" cols="100" class="text" onkeyup="keyup(this)">
            <xsl:choose>
                <xsl:when test="string-length(abstract) &gt; 0">
                    <xsl:apply-templates select="abstract"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#160;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            </textarea>
            <xsl:text>&#160;</xsl:text><span id="charcount"><xsl:text>&#160;</xsl:text></span>
            <xsl:call-template name="charcountcheck"/>
        </td>
    </tr>
    <tr>
        <td valign="top"><xsl:value-of select="$i18n/l/Image"/></td>
        <td colspan="2">
            <input tabindex="26" type="text" name="image" size="40" value="{image_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={$parentid};otfilter=Image;sbfield=eform.image')" class="doclink"><xsl:value-of select="$i18n/l/Browse_image"/></a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="charcountcheck">
    <xsl:call-template name="mk-inline-js">
      <xsl:with-param name="code">
        maxKeys = 390; // Should this be a config.xsl value?

        function txtshow( txt2show ) {
            var viewer = document.getElementById("charcount");
            viewer.innerHTML=txt2show;
        }

        function keyup( what ) {
            var str = new String( what.value );
            var len = str.length;
            var showstr = len + " <xsl:value-of select="$i18n_news/l/of"/> " + maxKeys + " <xsl:value-of select="$i18n_news/l/Characters_entered"/>";
            if ( len &gt; maxKeys ) {
                alert( "<xsl:value-of select="$i18n_news/l/Charlimit_reached"/>" );
                what.value = what.value.substring(0,maxKeys);
                return false;
            }
            txtshow( showstr );
        }

        keyup( document.getElementsByName("abstract")[0] );
    </xsl:with-param>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
