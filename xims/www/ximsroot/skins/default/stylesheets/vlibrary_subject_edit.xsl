<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: folder_edit.xsl 1442 2006-03-26 18:51:16Z pepl $
-->
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="vlibraryitem_common.xsl"/>

    <xsl:template match="/document/context/object">
    <html>
        <head>
        <xsl:call-template name="common-head">
            <xsl:with-param name="mode">edit</xsl:with-param>
            <xsl:with-param name="htmlarea" select="true()" /> 
        </xsl:call-template>
        </head>
        <body onLoad="initEditor();">
            <div class="edit">
                <xsl:call-template name="table-edit"/>
                <form action="{$xims_box}{$goxims_content}?id={@id};subject_store=1;subject_id={$subject_id}" name="eform" method="POST">
                    <table border="0" width="98%">
                        <input type="hidden" name="subject_store" value="1" />
                        <input type="hidden" name="subject_id" value="{$subject_id}" />
                        <xsl:call-template name="tr-subject_name_edit" />
                        <xsl:call-template name="tr-description-edit_htmlarea" />
                        <!--<xsl:call-template name="tr-subject_desc_edit" />-->
                    </table>
                    <xsl:call-template name="saveedit"/>
                </form>
            </div>
            <br />
            <xsl:call-template name="canceledit"/>
        </body>
    </html>
    </xsl:template>

    <xsl:template name="tr-subject_name_edit">
        <xsl:variable name="subject_name">
            <xsl:value-of select="/document/context/vlsubjectinfo/subject[id=$subject_id]/name"/>
        </xsl:variable>
        <tr>
            <td valign="top"><xsl:value-of select="$i18n/l/Name"/></td>
            <td colspan="2">
                <input tabindex="20" type="text" name="name" size="60" value="{$subject_name}" class="text"/>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('Name')" class="doclink">(?)</a>
            </td>
    </tr>
    </xsl:template>

    <xsl:template name="tr-description-edit_htmlarea">
        <xsl:variable name="subject_desc">
            <xsl:value-of select="/document/context/vlsubjectinfo/subject[id=$subject_id]/description"/>
        </xsl:variable>
        <tr>
            <td colspan="3">
                <xsl:value-of select="$i18n/l/Description"/>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('Subject_Description')" class="doclink">(?)</a>
                <br/>
                <textarea tabindex="30" name="description" id="body" style="width: 100%" rows="24" cols="32" onChange="document.getElementById('xims_wysiwygeditor').disabled = true;">
                    <xsl:value-of select="$subject_desc"/>
                </textarea>
                <xsl:call-template name="jsorigbody"/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="jsorigbody">
        <script type="text/javascript">
            if (document.readyState != 'complete') {
                var f = function() { origbody = window.editor.getHTML(); }
                if ( navigator.userAgent.indexOf("MSIE") != -1 ) {
                    setTimeout(f, 3700); // MSIE needs that high timeout value
                } 
                else {
                    setTimeout(f, 2000);
                }
            }
            else {
                origbody = window.editor.getHTML();
            }
        </script>
    </xsl:template>


    <xsl:template name="tr-subject_desc_edit">
        <xsl:variable name="subject_desc">
            <xsl:value-of select="/document/context/vlsubjectinfo/subject[id=$subject_id]/description"/>
        </xsl:variable>
        <tr>
            <td valign="top" colspan="3">
                <xsl:value-of select="$i18n/l/Description"/>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('Description')" class="doclink">(?)</a>
                <br />
                <textarea tabindex="50" name="description" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-   size: 10pt; border:#333333  solid 1px;">
                    <xsl:value-of select="$subject_desc"/>
                </textarea>
            </td>
    </tr>
    </xsl:template>

    
    <!-- overwrite template from common.xsl because of button named store. "Store" is the task, event ist "subject" -->
    <xsl:template name="saveedit">
        <input type="hidden" name="id" value="{@id}"/>
        <xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/redir_to_self='0'">
            <input name="sb" type="hidden" value="date"/>
            <input name="order" type="hidden" value="desc"/>
        </xsl:if>
        <input type="submit" name="subject_store" value="{$i18n/l/save}" class="control" accesskey="S"/>
    </xsl:template>


    <xsl:template name="save_jsbutton">
        <script type="text/javascript">
        document.write('<input type="submit" name="submit_eform" value="{$i18n/l/save}" onClick="document.eform.submit.click(); return false" class="control"/>');
        </script>
    </xsl:template>

    <!-- overwrite template from common.xsl because not the object (Vlibrary) is edited but the Subject.-->
    <xsl:template name="table-edit">
        <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
            <tr>
                <td valign="top">
                    <xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n_vlib/l/subject"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/>
                </td>
                <td align="right" valign="top">
                    <xsl:call-template name="cancelform">
                        <xsl:with-param name="with_save">yes</xsl:with-param>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>

    <xsl:template name="head-edit">
        <head>
            <title><xsl:value-of select="$i18n/l/edit"/>&#160;<xsl:value-of select="$objtype"/>&#160;<xsl:value-of select="$i18n_vlib/l/subject"/>&#160;<xsl:value-of select="$i18n/l/in"/>&#160;<xsl:value-of select="$parent_path"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js"     type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        </head>
    </xsl:template>

</xsl:stylesheet>
