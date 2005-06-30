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
    <xsl:import href="common.xsl"/>
    <xsl:param name="userid"/>
    <xsl:param name="newgrant"/>
    <xsl:output method="html" encoding="ISO-8859-1"/>

    <xsl:template match="/document">
        <xsl:apply-templates select="context/object"/>
    </xsl:template>

    <xsl:template match="/document/context/object">
        <html>
            <head>
                <title>
                  <xsl:choose>
                    <xsl:when test="$newgrant='1'">
                      Granting
                    </xsl:when>
                    <xsl:otherwise>
                      Editing
                    </xsl:otherwise>
                  </xsl:choose>
                Privileges on Object <xsl:value-of select="$absolute_path"/> - XIMS</title>
                <link rel="stylesheet" href="{$ximsroot}{$defaultcss}" type="text/css" />
                <script src="{$ximsroot}scripts/default.js" type="text/javascript" />
            </head>
            <body>
                <xsl:call-template name="header"/>
                <xsl:apply-templates select="/document/context/user"/>
            </body>
        </html>
    </xsl:template>

   <xsl:template match="/document/context/user">
        <form action="{$xims_box}{$goxims_content}" method="GET">
        <table width="99%" cellpadding="0" cellspacing="0" border="0" bgcolor="#eeeeee">
          <tr background="{$ximsroot}skins/{$currentskin}/images/generic_tablebg_1x20.png">
            <td>&#160;</td>
          </tr>
          <tr>
            <td align="center">
            
            <br />

            <!-- begin widget table -->
           <table cellpadding="2" cellspacing="0" border="0">
              <tr>
                <td align="center" class="bluebg" colspan="2">
                  <xsl:choose>
                    <xsl:when test="$newgrant='1'">
                      Grant
                    </xsl:when>
                    <xsl:otherwise>
                      Edit
                    </xsl:otherwise>
                  </xsl:choose>
                  Privileges on Object '<xsl:value-of select="$absolute_path"/>' 
                  for User/Role '<xsl:value-of select="name"/>'</td>
              </tr>

        <!-- add optional user info here? -->

             <tr>
               <td>Basic Privileges:</td>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_view" value="1">
                     <xsl:if test="object_privileges/view or $newgrant='1'">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   View
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_write" value="1">
                     <xsl:if test="object_privileges/write">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Write 
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_create" value="1">
                     <xsl:if test="object_privileges/create">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Create 
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_delete" value="1">
                     <xsl:if test="object_privileges/delete">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Delete 
                 </span>

                 <br clear="all"/>

                 <span class="cboxitem">
                   <input type="checkbox" name="acl_move" value="1">
                     <xsl:if test="object_privileges/move">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Move 
                 </span>
<!--                 <span class="cboxitem">
                   <input type="checkbox" name="acl_link" value="1">
                     <xsl:if test="object_privileges/link">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                    Link 
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_attributes" value="1">
                     <xsl:if test="object_privileges/attributes">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Attributes 
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_translate" value="1">
                     <xsl:if test="object_privileges/translate">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Translate
                 </span> -->
               </td>
             </tr>
  <!--           <tr>
               <td>Recursive Privileges:</td>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_attributes_all" value="1">
                     <xsl:if test="object_privileges/attributes_all">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Attributes All 
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_delete_all" value="1">
                     <xsl:if test="object_privileges/delete_all">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Delete All 
                 </span>
               </td>
             </tr> -->
             <tr>
               <td>Publishing Privileges:</td>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_publish" value="1">
                     <xsl:if test="object_privileges/publish">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Publish 
                 </span>
     <!--            <span class="cboxitem">
                   <input type="checkbox" name="acl_publish_all" value="1">
                     <xsl:if test="object_privileges/publish_all">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Publish All 
                 </span> -->
               </td>
             </tr>
             <tr>
               <td>Grant Rights:</td>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_grant" value="1">
                     <xsl:if test="object_privileges/grant">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Grant 
                 </span>
 <!--                <span class="cboxitem">
                   <input type="checkbox" name="acl_grant_all" value="1">
                     <xsl:if test="object_privileges/grant_all">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   Grant All 
                 </span> -->
               </td>
             </tr>
  <!--           <tr>
               <td>Special Privileges:</td>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_owner" value="1">
                     <xsl:if test="object_privileges/owner">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                 </input>
                 is Owner 
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_master" value="1">
                     <xsl:if test="object_privileges/master">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   is Master 
                 </span>
               </td>
             </tr> -->
              <tr>  
                <td colspan="2" align="center">
                  &#160;
                </td>
              </tr>
              <tr>
                <td colspan="2" align="center">
        
                  <!-- begin buttons table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr align="center">
                      <td>
                        <input class="control" name="obj_aclgrant" type="submit" value="Save"/>
                        <input name="userid" type="hidden" value="{$userid}"/>
                        <input name="id" type="hidden" value="{/document/context/object/@id}"/>
                      </td>
                      <td>
                        <input class="control" name="cancel" type="submit" value="Cancel"/>
                      </td>
                    </tr>
                  </table>
                  <!-- end buttons table -->
                    
                </td>
              </tr>
              <!-- begin revoke  -->
              <xsl:if test="$newgrant != '1'">
              <tr>
                <td colspan="2" align="center">
                  &#160;
                </td>
              </tr>
              <tr>  
                <td colspan="2" class="bluebg" align="center">
                  Revoke All Privileges on Object '<xsl:value-of select="$absolute_path"/>'
                  for User/Role '<xsl:value-of select="name"/>'
                </td>
              </tr>
              <tr>  
                <td colspan="2" align="center">
                  &#160;
                </td>
              </tr>
              <tr>
                <td colspan="2" align="center">
        
                  <!-- begin buttons table -->
                  <table cellpadding="2" cellspacing="0" border="0">
                    <tr align="center">
                      <td>
                        <input class="control" name="obj_aclrevoke" type="submit" value="Revoke All"/>
                      </td>
                      <td>
                        <input class="control" name="cancel" type="submit" value="Cancel"/>
                      </td>
                    </tr>
                  </table>
                  <!-- end buttons table -->
                    
                </td>
              </tr>
              </xsl:if>
              <!-- end revoke  -->

              <tr>  
                <td colspan="2" align="center">
                  &#160;
                </td>
              </tr>
            </table>
            <!-- end widgets table -->
       </td></tr></table>
        </form>
   </xsl:template>
</xsl:stylesheet>
