<?xml version="1.0" encoding="iso-8859-1" ?>
<!--
# Copyright (c) 2002-2003 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/TR/xhtml1/strict">

    <xsl:import href="../../../../stylesheets/common.xsl"/>
    <xsl:import href="common_footer.xsl"/>
    <xsl:import href="common_header.xsl"/>
    <xsl:import href="common_metadata.xsl"/>

<xsl:template name="publish">
    <xsl:choose>
        <xsl:when test="published = 1">
             <p class="0left10top">
               This object has last been published at <xsl:apply-templates select="last_publication_timestamp" mode="datetime"/> by <xsl:call-template name="lastpublisherfullname"/> at <a href="{$publishingroot}{$absolute_path}">
               <xsl:value-of select="concat($publishingroot,$absolute_path)"/></a><br/>
               <input type="submit" name="publish" value="Republish" class="control"/>
               <input type="submit" name="unpublish" value="Unpublish" class="control"/>
             </p>
             <p/>
        </xsl:when>
        <xsl:otherwise>
             <p class="0left10top">
               This object is currently not published<br/>
               <input type="submit" name="publish" value="Publish" class="control"/>
             </p>
             <p/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="grantowneronly">
    <tr>
        <td colspan="3">
            Grant VIEW privilege to users of your default roles:
            <input name="owneronly" type="radio" value="false" checked="checked"/>Yes
            <input name="owneronly" type="radio" value="true" />No
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('GrantVIEWprivilegetousersofyourdefaultroles')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="markednew">
    <!-- the default should be reverted to be 'true' later with a new content-base -->
    Mark object as new:
    <input name="markednew" type="radio" value="true">
      <xsl:if test="marked_new = '1'">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
    </input>Yes
    <input name="markednew" type="radio" value="false">
      <xsl:if test="marked_new != '1'">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
    </input>No
    <xsl:text>&#160;</xsl:text>
    <a href="javascript:openDocWindow('markednew')" class="doclink">(?)</a>
</xsl:template>

<xsl:template name="trytobalance">
    <tr>
        <td colspan="3">
            Try to form body well. (If body is not well-balanced an error message will be displayed otherwise.)
            <input name="trytobalance" type="radio" value="true" checked="checked"/>Yes
            <input name="trytobalance" type="radio" value="false" />No
        </td>
    </tr>      
</xsl:template>

<xsl:template name="testbodysxml">
    <tr>
        <td colspan="3">
            <a href="javascript:openTestWFWindow()">Test body's XML</a>
        </td>
    </tr>
</xsl:template>

<xsl:template name="expandrefs">
    <!-- the default should be reverted to be 'true' later with a new content-base -->
    Automaticly export Objects refered by this object:
    <input name="expandrefs" type="radio" value="true">
      <xsl:if test="attributes/expandrefs = '1'">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
    </input>Yes
    <input name="expandrefs" type="radio" value="false">
      <xsl:if test="attributes/expandrefs != '1'">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
    </input>No
    <xsl:text>&#160;</xsl:text>
    <a href="javascript:openDocWindow('expandrefs')" class="doclink">(?)</a>
</xsl:template>

<xsl:template name="cancelaction">
    <table border="0" align="center" width="98%">
        <tr>
           <td style="padding-left:6px;">
               Cancel action
              </td>
        </tr>
        <tr>
            <td>
                <form action="{$xims_box}{$goxims_content}{$absolute_path}" method="POST">
                    <input type="submit" name="cancel_create" value="Cancel" class="control"/>
                </form>
           </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="canceledit">
    <table border="0" align="center" width="98%">
    <tr>
        <td style="padding-left:6px;">
            Cancel edit
        </td>
    </tr>
    <tr>
        <td>
        <!-- method GET is needed, because goxims does not handle a PUTed 'id' -->
            <form action="{$xims_box}{$goxims_content}" name="cform" method="GET">
                <input type="hidden" name="id" value="{@id}"/>
                <input type="submit" name="cancel" value="Cancel" class="control"/>
            </form>
        </td>
    </tr>
    </table>
</xsl:template>

<xsl:template name="uploadaction">
    <input type="hidden" name="parid" value="{@id}"/>
    <input type="submit" name="store" value="Upload" class="control"/>
</xsl:template>

<xsl:template name="saveaction">
    <input type="hidden" name="parid" value="{@id}"/>
    <input type="submit" name="store" value="Save" class="control"/>
</xsl:template>

<xsl:template name="saveedit">
    <input type="hidden" name="id" value="{@id}"/>
    <input type="submit" name="store" value="&#160;Save&#160;" class="control"/>
</xsl:template>

<xsl:template name="head-create">
    <head>
        <title>Create new <xsl:value-of select="$objtype"/> in <xsl:value-of select="$absolute_path"/> - XIMS</title>
           <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
           <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
           <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>


<xsl:template name="head-create_discussionforum">
    <head>
        <title>Create new topic - Anonymous Discussion Forum - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>


<xsl:template name="head-create_wepro">
    <head>
            <title>Create new <xsl:value-of select="$objtype"/> in <xsl:value-of select="$absolute_path"/> - XIMS</title>
            <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
            <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <script src="{$ximsroot}ewebedit/ewebeditpro.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
            <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
                <script type="text/javascript">
                <![CDATA[ 
                function setEWProperties(sEditorName) {
                    eWebEditPro.instances[sEditorName].editor.setProperty("BaseURL", "]]><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/><![CDATA[");
                    eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty("TransferMethod","]]><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/><![CDATA[?contentbrowse=1;style=ewebeditimage;otfilter=Image");
                }
                ]]>
            </script>
    </head>
</xsl:template>


<xsl:template name="head-edit">
    <head>
        <title>Edit <xsl:value-of select="$objtype"/> '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
    </head>
</xsl:template>


<xsl:template name="head-edit_wepro">
    <head>
        <title>Edit <xsl:value-of select="$objtype"/> '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
        <script src="{$ximsroot}scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}skins/{$currentskin}/scripts/default.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <script src="{$ximsroot}ewebedit/ewebeditpro.js" type="text/javascript"><xsl:text>&#160;</xsl:text></script>
        <base href="{$xims_box}{$goxims_content}{$parent_path}/" />
            <script type="text/javascript">
            <![CDATA[ 
            function setEWProperties(sEditorName) {
                eWebEditPro.instances[sEditorName].editor.setProperty("BaseURL", "]]><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/><![CDATA[");
                eWebEditPro.instances[sEditorName].editor.MediaFile().setProperty("TransferMethod","]]><xsl:value-of select="concat($xims_box,$goxims_content,$absolute_path,'/')"/><![CDATA[?contentbrowse=1;style=ewebeditimage;otfilter=Image");
            }
            ]]>
        </script>
    </head>
</xsl:template>


<xsl:template name="head-edit_withscript">
    <head>
        <title>Edit <xsl:value-of select="$objtype"/> '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/> - XIMS</title>
        <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css"/>
        <script src="{$ximsroot}scripts/default.js" type="text/javascript">
            <xsl:text>&#160;</xsl:text>
        </script> 
        <script type="text/javascript">
            <![CDATA[ 
            function openTestWFWindow() {
                var testwfwindow = window.open('','windowName',"resizable=yes,scrollbars=yes,width=550,height=400,screenX=50,screenY=200");
                var body = document.forms['eform'].body.value;
                testwfwindow.document.writeln('<html><head>');
                testwfwindow.document.writeln('<link rel="stylesheet" href="]]><xsl:value-of select="concat($ximsroot,'stylesheets/',$defaultcss)"/><![CDATA[" type="text/css" />');
                testwfwindow.document.writeln('<\/head><body onLoad="document.the_form.submit()">');
                testwfwindow.document.writeln('<form name="the_form" action="]]><xsl:value-of select="concat($goxims_content,$absolute_path)"/><![CDATA[" method="post">');
                testwfwindow.document.writeln('<input type="submit" name="test_wellformedness" value="Go!" size="1" class="control" \/>');
                testwfwindow.document.writeln('<textarea name="body" cols="1" rows="1" readonly="readonly" style="visibility:hidden;">' + body + '<\/textarea>');
                testwfwindow.document.writeln("<\/form><\/body><\/html>");
                // testwfwindow.document.the_form.submit();
            }
            ]]>
        </script>
        <base href="{$xims_box}{$goxims_content}{$parent_path}/"/>
    </head>
</xsl:template>


<xsl:template name="table-create">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                Create new <xsl:value-of select="$objtype"/> in <xsl:value-of select="$absolute_path"/>
            </td>
            <td align="right" valign="top">
                <form action="{$xims_box}{$goxims_content}" name="cform" method="GET" style="margin-top:0px; margin-bottom:0px; margin-left:-5px; margin-right:0px;">
                    <input type="hidden" name="id" value="{@id}"/>
                    <input type="submit" name="cancel" value="Cancel" class="control"/>
                </form>
            </td>
        </tr>
    </table>
</xsl:template>


<xsl:template name="table-edit">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                Edit <xsl:value-of select="$objtype"/> '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/>
            </td>
            <td align="right" valign="top">
            <form action="{$xims_box}{$goxims_content}" name="cform" method="GET" style="margin-top:0px; margin-bottom:0px; margin-left:-5px; margin-right:0px;">
                <input type="hidden" name="id" value="{@id}"/>
                <input type="submit" name="cancel" value="Cancel" class="control"/>
            </form>
            </td>
        </tr>
    </table>
</xsl:template>


<xsl:template name="table-edit_wepro">
    <table border="0" align="center" width="98%" cellpadding="0" cellspacing="0">
        <tr>
            <td valign="top">
                Edit <xsl:value-of select="$objtype"/> '<xsl:value-of select="title"/>' in <xsl:value-of select="$parent_path"/>
            </td>
            <td align="right" valign="top">
            <form action="{$xims_box}{$goxims_content}" name="cform" method="GET" style="margin-top:0px; margin-bottom:0px; margin-left:-5px; margin-right:0px;">
                <input type="hidden" name="id" value="{@id}"/>
                <input type="submit" name="cancel" value="Cancel" class="control"/>
            </form>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <a href="{$goxims_content}{$absolute_path}?edit=1;plain=1">Edit without WYSIWYG-Editor</a>
            </td>
        </tr>
    </table>
</xsl:template>


<xsl:template name="tr-locationtitle-create">
    <xsl:call-template name="tr-location-create"/>
    <xsl:call-template name="tr-title-create"/>
</xsl:template>

  
<xsl:template name="tr-locationtitle-edit">
    <xsl:call-template name="tr-location-edit"/>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>


<xsl:template name="tr-locationtitletarget-create">
    <xsl:call-template name="tr-locationtitle-create"/>
    <tr>
        <td valign="top"><span class="compulsory">Target</span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">Browse for Target</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-locationtitletarget-edit">
    <xsl:call-template name="tr-locationtitle-edit"/>
    <tr>
        <td valign="top"><span class="compulsory">Target</span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" value="{symname_to_doc_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">Browse for Target</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-location-create">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory">Location</span>
        </td>
        <td>
            <input tabindex="10" type="text" name="name" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-location-edit">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory">Location</span>
        </td>
        <td>
            <input tabindex="10" type="text" name="name" size="40" value="{location}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-title-create">
    <tr>
        <td valign="top">Title</td>
        <td colspan="2">
            <input tabindex="20" type="text" name="title" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-title-edit">
    <tr>
        <td valign="top">Title</td>
        <td colspan="2">
            <input tabindex="20" type="text" name="title" size="60" value="{title}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-locationtitle-edit_urllink">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory">Location</span>
        </td>
        <td>
            <input tabindex="10" type="text" class="text" name="name" size="40"> 
                <xsl:choose>
                    <xsl:when test="string-length(symname_to_doc_id) > 0 ">
                        <xsl:attribute name="value"><xsl:value-of select="symname_to_doc_id"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="value"><xsl:value-of select="location"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </input> 
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">
            Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!
        </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>


<xsl:template name="tr-locationtitle-edit_xml">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory">Location</span>
        </td>
        <td>
            <input tabindex="10" type="text" class="text" name="name" size="40" 
                        value="{substring-before(location, concat('.', /document/data_formats/data_format
                         [@id = /document/data_formats/data_format]/suffix))}"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
    </tr>
    <xsl:call-template name="tr-title-edit"/>
</xsl:template>

 
<xsl:template name="tr-file-create">
    <tr>
        <td valign="top"><span class="compulsory">File</span></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('File')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-file-edit">
    <tr>
        <td valign="top">Replace file</td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('File')" class="doclink">(?)</a>
        </td>
    </tr>   
</xsl:template>


<xsl:template name="tr-image-create">
    <tr>
        <td valign="top"><span class="compulsory">Image</span></td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-image-edit">
    <tr>
        <td valign="top">Replace image</td>
        <td colspan="2">
            <input tabindex="30" type="file" name="file" size="49" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-imagedepartmentroot-create">
    <tr>
        <td valign="top">Image</td>
            <td>
                <input tabindex="30" type="text" name="image" size="40" value="" class="text"/>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:openDocWindow('DepartmentImage')" class="doclink">(?)</a>
                <xsl:text>&#160;</xsl:text>
                <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">Browse for an image</a>
            </td>
    </tr>
</xsl:template>

    
<xsl:template name="tr-imagedepartmentroot-edit">
    <tr>
        <td valign="top">Image</td>
           <td>
            <input tabindex="30" type="text" name="image" size="40" value="{image_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
                    <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
                    <xsl:text>&#160;</xsl:text>
                 <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">Browse for an image</a>
            </td>
    </tr>
</xsl:template>


<xsl:template name="tr-portlets-create">
    <tr>
        <td colspan="3">
            <table style="margin-bottom:20px; margin-top:5px; border: 1px solid; border-color: black">
                <tr>
                    <td valign="top" colspan="2">Manage Department-Root's Portlets</td>
                </tr>
                <xsl:apply-templates select="/document/objectlist"/>
                <tr>
                    <td valign="top">Add a new Portlet:</td>
                    <td>
                        <input type="text" name="portlet" size="40" class="text"/> <xsl:text>&#160;</xsl:text>
                        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="doclink">Browse for Portlet</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="submit" name="add_portlet" value="Add Portlet" class="control"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-portlets-edit">
    <tr>
        <td colspan="3">
            <table style="margin-bottom:20px; margin-top:5px; border: 1px solid; border-color: black">
                <tr>
                    <td valign="top" colspan="2">Manage Department-Root's Portlets</td>
                </tr>
                <xsl:apply-templates select="/document/objectlist"/>
                <tr>
                    <td valign="top">Add a new Portlet:</td>
                    <td>
                        <input type="text" name="portlet" size="40" class="text" value="{portlet_id}"/> <xsl:text>&#160;</xsl:text>
                        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Portlet;sbfield=eform.portlet')" class="doclink">Browse for Portlet</a>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="submit" name="add_portlet" value="Add Portlet" class="control"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</xsl:template>


<xsl:template match="objectlist/object">
    <tr>
        <td valign="top">
            <a href="{$goxims_content}{location_path}"><xsl:value-of select="title"/></a>
        </td>
        <td>
            <a href="{$goxims_content}{$absolute_path}?portlet_id={id};rem_portlet=1">
            <img src="{$ximsroot}skins/{$currentskin}/images/option_delete.png"
                            border="0"
                            width="37"
                            height="19"
                            alt="Delete Portlet"
                            title="Delete this portlet"
            />
            </a>
        </td>
    </tr>
</xsl:template>

 
<xsl:template name="tr-body-create">
<tr>
    <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="body" rows="15" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333 solid 1px;">&#160;</textarea>
    </td>
</tr>
</xsl:template>


<xsl:template name="tr-body-create_wepro">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <input tabindex="30" type="hidden" name="body" value="" width="100%"/>
            <script language="JavaScript1.2">
            <!-- for ewebedit: pull parent_id into a JavaScript variable -->
            <![CDATA[ var parentID="]]>
            <xsl:apply-templates select="@parent_id"/><![CDATA[";]]>
            <![CDATA[ var documentID="]]>
            <xsl:apply-templates select="@id"/> <![CDATA[";]]>
            <![CDATA[
                var sEditorName = "body";
                eWebEditPro.create(sEditorName, "99.5%", "450");
                eWebEditPro.onready = "setEWProperties(sEditorName)";
            ]]>
            </script>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-body-edit">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="body" rows="15" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333 solid 1px;">
                <xsl:choose>
                    <xsl:when test="string-length(body) &gt; 0">
                        <xsl:apply-templates select="body"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </textarea>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-body-edit_wepro">
    <tr>
        <td colspan="3">
            Body
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Body')" class="doclink">(?)</a>
            <br/>
            <input tabindex="30" type="hidden" name="body" value="{$bodycontent}" width="100%"/>
            <script language="JavaScript1.2">
            <!-- for ewebedit: pull parent_id into a JavaScript variable -->
            <![CDATA[ var parentID="]]>
            <xsl:apply-templates select="@parent_id"/><![CDATA[";]]>
            <![CDATA[ var documentID="]]>
            <xsl:apply-templates select="@id"/> <![CDATA[";]]>
            <![CDATA[
                var sEditorName = "body";
                eWebEditPro.create(sEditorName, "99.5%", "450");
                eWebEditPro.onready = "setEWProperties(sEditorName)";
            ]]>
            </script>
        </td>
    </tr>
</xsl:template>

 
<xsl:template name="tr-description-create">
    <tr>
        <td colspan="3">
            Description
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('adf_description')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="30" name="abstract" rows="5" cols="100" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333 solid 1px;">&#160;</textarea>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-keywords-create">
    <tr>
        <td valign="top">Keywords</td>
        <td colspan="2">
            <input tabindex="40" type="text" name="keywords" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
        </td>
        </tr>
</xsl:template>


<xsl:template name="tr-keywords-edit">
    <tr>
        <td valign="top">Keywords</td>
        <td colspan="2">
            <input tabindex="40" type="text" name="keywords" size="60" value="{keywords}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-abstract-create">
    <tr>
        <td valign="top" colspan="3">
            Abstract
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">&#160;</textarea>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-abstract-edit">
    <tr>
        <td valign="top" colspan="3">
            Abstract
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333  solid 1px;">
                 <xsl:choose>
                    <xsl:when test="string-length(abstract) &gt; 0">
                        <xsl:apply-templates select="abstract"/>
                     </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </textarea>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-leadimage-create">
    <tr>
        <td valign="top" colspan="3">
            Lead
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="30" name="abstract" rows="5" cols="100" class="text"><xsl:text>&#160;</xsl:text></textarea>
        </td>
    </tr>
    <tr>
        <td valign="top">Image</td>
        <td colspan="2">
            <input tabindex="30" type="text" name="image" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">Browse for an image</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-leadimage-edit">
    <tr>
        <td valign="top" colspan="3">
            Lead
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br />
            <textarea tabindex="50" name="abstract" rows="5" cols="100" class="text">
            <xsl:choose>
                <xsl:when test="string-length(abstract) &gt; 0">
                    <xsl:apply-templates select="abstract"/>
                </xsl:when>
                        <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                 </xsl:otherwise>
            </xsl:choose>
            </textarea>
        </td>
    </tr>
    <tr>
        <td valign="top">Image</td>
        <td colspan="2">
            <input tabindex="60" type="text" name="image" size="40" value="{image_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Image')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=Image;sbfield=eform.image')" class="doclink">Browse for an image</a>
        </td>
    </tr>
</xsl:template>

   
<xsl:template name="tr-stylesheet-create">
<tr>
    <td valign="top">Stylesheet</td>
    <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet;sbfield=eform.stylesheet')" class="doclink">Browse for a stylesheet</a>
    </td>
</tr>
</xsl:template>


<xsl:template name="tr-stylesheet-edit">
<tr>
    <td valign="top">Stylesheet</td>
    <td colspan="2">
        <input tabindex="30" type="text" name="stylesheet" size="40" value="{style_id}" class="text"/>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:openDocWindow('Stylesheet')" class="doclink">(?)</a>
        <xsl:text>&#160;</xsl:text>
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;to={@id};otfilter=XSLStylesheet;sbfield=eform.stylesheet')" class="doclink">Browse for a stylesheet</a>
    </td>
</tr>
</xsl:template>


<xsl:template name="tr-target-create">
    <tr>
        <td valign="top"><span class="compulsory">Target</span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">Browse for Target</a>
        </td>
    </tr>
</xsl:template>


<xsl:template name="tr-target-edit">
    <tr>
        <td valign="top"><span class="compulsory">Target</span></td>
        <td colspan="2">
            <input tabindex="30" type="text" name="target" size="40" value="{symname_to_doc_id}" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('PortletTarget')" class="doclink">(?)</a>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:genericWindow('{$xims_box}{$goxims_content}?id={@id};contentbrowse=1;otfilter=Folder,DepartmentRoot,Journal;sbfield=eform.target')" class="doclink">Browse for Target</a>
        </td>
    </tr>
</xsl:template>

 
<xsl:template name="without-wysiwyg">
    <a style="margin-left:18px;" href="{$goxims_content}{$absolute_path}?create=1;plain=1;objtype=Document;parid={@id}">Create without WYSIWYG-Editor</a>
</xsl:template>


<xsl:template name="preview-image">
    <p style="padding-left:20px;">
        <a href="javascript:genericWindow('{$xims_box}{$goxims_content}{$absolute_path}')">Preview image</a>
    </p>
</xsl:template>


<xsl:template match="children/object" mode="link">
    <xsl:variable name="dataformat">
        <xsl:value-of select="data_format_id"/>
    </xsl:variable>
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>
    <xsl:if test="/document/data_formats/data_format[@id=$dataformat]/name='URL' or /document/data_formats/data_format[@id=$dataformat]/name='SymbolicLink'">

        <tr>
            <td bgcolor="#ffffff">
                <!-- icon -->
                <!-- link -->
                <a>
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="/document/data_formats/data_format[@id=$dataformat]/name='URL'">
                                <xsl:value-of select="concat(location,'?sb=',$sb,';order=',$order,';m=',$m)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($goxims_content,symname_to_doc_id,'?m=',$m)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="title" />
                </a>
            </td>
            <xsl:if test="$m='e'">
                <td>
                    <xsl:choose>
                        <xsl:when test="user_privileges/write and locked_time = '' or locked_by = /document/session/user/@id">
                            <a href="{$goxims_content}?id={@document_id};edit=1">
                                <img src="{$ximsroot}skins/{$currentskin}/images/option_edit.png" 
                                     border="0" 
                                     alt="Edit" 
                                     title="Edit this document"
                                     width="32" height="19" 
                                     align="left" 
                                     onmouseover="pass('edit{@document_id}','edit','h'); return true;" 
                                     onmouseout="pass('edit{@document_id}','edit','c'); return true;" 
                                     onmousedown="pass('edit{@document_id}','edit','s'); return true;" 
                                     onmouseup="pass('edit{@document_id}','edit','c'); return true;" 
                                     name="edit{@document_id}" 
                                     />
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$ximsroot}images/spacer_white.gif" 
                                 width="32" 
                                 height="19" 
                                 border="0" 
                                 alt="" 
                                 align="left" 
                                 />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="user_privileges/grant|user_privileges/grant_all">
                            <a href="{$goxims_content}?id={@document_id};obj_acllist=1">
                                <img src="{$ximsroot}skins/{$currentskin}/images/option_acl.png" 
                                     border="0" 
                                     alt="Access Control" 
                                     title="Access Control"
                                     align="left" 
                                     width="32" 
                                     height="19"
                                     />
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$ximsroot}images/spacer_white.gif" 
                                 width="32" 
                                 height="19" 
                                 border="0" 
                                 alt="" 
                                 align="left" 
                                 />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="user_privileges/delete">
                            <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                            <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
                            <form style="margin:0px;" name="delete" method="GET" action="{$xims_box}{$goxims_content}">
                                <input type="hidden" name="del_prompt" value="1"/>
                                <input type="hidden" name="id" value="{@document_id}"/>
                                <input
                                       type="image" 
                                       name="del{@document_id}" 
                                       src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" 
                                       border="0" 
                                       width="37" 
                                       height="19"
                                       />
                            </form>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$ximsroot}images/spacer_white.gif" width="37" height="19" border="0" alt="" align="left" />
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </xsl:if>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="children/object" mode="comment">
    <xsl:variable name="objecttype">
        <xsl:value-of select="object_type_id"/>
    </xsl:variable>

    <!-- <xsl:if test="/document/object_types/object_type[@id=$objecttype]/name='Annotation'"> -->
    <!-- 
         pepl: This hardcoded OT would not be neccessary if the Annotations would be loaded via -getchildren!!! 
         (I guess its time to change the "definition" regarding Annotations and their granted privs)
     -->
    <xsl:if test="$objecttype=16">
        <tr>
            <td colspan="3">
                <img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level}" height="10"/>
                <img src="{$ximsroot}images/icons/list_HTML.gif" alt="" width="20" height="18"/>
                <a href="{$goxims_content}{$absolute_path}?id={@document_id};view=1;m={$m}">
                    <xsl:value-of select="title"/>
                </a>
                by <xsl:call-template name="creatorfullname"/>
            </td>
        </tr>
        <tr>
            <td width="96%">
                <img src="{$ximsroot}images/spacer_white.gif" alt="" width="{10*@level+20}" height="10"/>
                <xsl:apply-templates select="last_modification_timestamp" mode="datetime"/>
            </td>
            <xsl:if test="$m='e'">
                <td width="2%">
                    <xsl:choose>
                        <xsl:when test="/document/context/object/user_privileges/write and locked_time = '' or locked_by = /document/session/user/@id">
                            <a href="{$goxims_content}?id={@document_id};edit=1">
                                <img src="{$ximsroot}skins/{$currentskin}/images/option_edit.png" 
                                     border="0" 
                                     alt="Edit"
                                     title="Edit this Document" 
                                     width="32" height="19" 
                                     align="left" 
                                     onmouseover="pass('edit{@document_id}','edit','h'); return true;" 
                                     onmouseout="pass('edit{@document_id}','edit','c'); return true;" 
                                     onmousedown="pass('edit{@document_id}','edit','s'); return true;" 
                                     onmouseup="pass('edit{@document_id}','edit','c'); return true;" 
                                     name="edit{@document_id}" 
                                     />
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$ximsroot}images/spacer_white.gif" 
                                 width="32" 
                                 height="19" 
                                 border="0" 
                                 alt="" 
                                 align="left" 
                                 />
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
                <td width="2%">
                    <xsl:choose>
                        <xsl:when test="/document/context/object/user_privileges/delete">
                            <!-- note: GET seems to be neccessary here as long we are mixing Apache::args, CGI::param, and Apache::Request::param :-( -->
                            <!-- <form style="margin:0px;" name="delete" method="POST" action="{$xims_box}{$goxims_content}{$absolute_path}/{location}" onSubmit="return confirmDelete()"> -->
                            <form style="margin:0px;" name="delete" method="GET" action="{$xims_box}{$goxims_content}">
                                <input type="hidden" name="del_prompt" value="1"/>
                                <input type="hidden" name="id" value="{@document_id}"/>
                                <input
                                       type="image" 
                                       name="del{@document_id}" 
                                       src="{$ximsroot}skins/{$currentskin}/images/option_delete.png" 
                                       border="0" 
                                       width="37" 
                                       height="19"
                                       />
                            </form>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$ximsroot}images/spacer_white.gif" width="37" height="19" border="0" alt="" align="left" />
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </xsl:if>

        </tr>
        <!-- <tr><td colspan="4"><xsl:apply-templates select="body/*"/></td> -->
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
