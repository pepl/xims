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
    
    <!--
    <xsl:template name="publish">
    <xsl:choose>
        <xsl:when test="published = 1">
          <p>
            This document is currently published as <a href="{$publishingroot}{$absolute_path}">
            <xsl:value-of select="concat($publishingroot,$absolute_path)"/></a><br/><br/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="publish" value="Republish" class="control"/>
            <input type="submit" name="unpublish" value="Unpublish" class="control"/>
          </p>
          <p/>
        </xsl:when>
        <xsl:otherwise>
          <p>
            This document is currently not published<br/><br/>
            <xsl:text>&#160;</xsl:text>
            <input type="submit" name="publish" value="Publish" class="control"/>
           </p>
          <p/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
-->

    <xsl:template name="grantowneronly">
        <tr>
            <td colspan="2">
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
            <td colspan="2">
                Try to form body well. (If body is not well-balanced an error message will be displayed otherwise.)
                <input name="trytobalance" type="radio" value="true" checked="checked"/>Yes
                <input name="trytobalance" type="radio" value="false" />No
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

  <xsl:template name="tr-locationtitle-create">
    <tr>
        <td valign="top">
            <img src="{$ximsroot}images/spacer_white.gif" alt="*"/>
            <span class="compulsory">Location</span>
        </td>
        <td>
            <input tabindex="1" type="text" name="name" size="40" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Location')" class="doclink">(?)</a>
        </td>
        <td align="right" valign="top">Fields <span style="color:maroon">marked<img src="{$ximsroot}images/spacer_white.gif" alt="with *"/></span> are mandatory!</td>
    </tr>
    <tr>
        <td valign="top">Title</td>
        <td colspan="2">
            <input tabindex="2" type="text" name="title" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Title')" class="doclink">(?)</a>
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
            <textarea tabindex="3" name="body" rows="15" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333 solid 1px;">&#160;</textarea>
        </td>
    </tr>
  </xsl:template>

  <xsl:template name="tr-keywordsabstract-create">
    <tr>
        <td valign="top">Keywords</td>
        <td colspan="2">
            <input tabindex="4" type="text" name="keywords" size="60" class="text"/>
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Keywords')" class="doclink">(?)</a>
        </td>
    </tr>
    <tr>
        <td valign="top" colspan="3">
            Abstract
            <xsl:text>&#160;</xsl:text>
            <a href="javascript:openDocWindow('Abstract')" class="doclink">(?)</a>
            <br/>
            <textarea tabindex="3" name="abstract" rows="3" cols="90" style="font-family: 'Courier New','Verdana'; font-size: 10pt; border:#333333 solid 1px;">&#160;</textarea>
        </td>
    </tr>
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
                    </td><td width="2%">
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
