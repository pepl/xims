<?xml version="1.0" encoding="utf-8" ?>
<!--
# Copyright (c) 2002-2013 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_obj_user.xsl 2192 2009-01-10 20:07:32Z pepl $
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <!--<xsl:import href="common_header.xsl"/>-->

    <xsl:param name="userid"/>
    <xsl:param name="newgrant"/>

    <xsl:template match="/document/context/object">
        <html>
        <xsl:call-template name="head_default">
					<xsl:with-param name="mode">mg-acl</xsl:with-param>
        </xsl:call-template>
            <body>
                <xsl:call-template name="header"/>
                <xsl:apply-templates select="/document/context/user"/>
            </body>
        </html>
    </xsl:template>

   <xsl:template match="/document/context/user">
   <div id="content-container">
     <form action="{$xims_box}{$goxims_content}" method="get">

                <h1 class="bluebg">
                  <xsl:value-of select="$i18n/l/Manage_objectprivs"/> '<xsl:value-of select="$absolute_path"/>'
                  <xsl:value-of select="$i18n/l/For_user_role"/> '<xsl:value-of select="name"/>'</h1>

        <!-- add optional user info here? -->
							<table>
             <tr>
               <th><xsl:value-of select="$i18n/l/Basicprivs"/>:</th>
               <td>
               
                 <span class="cboxitem">
                 
                   <input type="checkbox" name="acl_view" value="1" id="acl_view" class="checkbox">
                     <xsl:if test="object_privileges/view or $newgrant='1'">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_view">View</label>
                   </span>
                 
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_write" value="1" id="acl_write" class="checkbox">
                     <xsl:if test="object_privileges/write">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_write">Write</label>                   
                 </span>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_create" value="1" id="acl_create">
                     <xsl:if test="object_privileges/create">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_create">Create</label>
                 </span>
                 
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_delete" value="1" id="acl_delete" class="checkbox">
                     <xsl:if test="object_privileges/delete">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_delete">Delete</label> 
                 </span>

                <br clear="all"/>

                 <span class="cboxitem">
                   <input type="checkbox" name="acl_copy" value="1" id="acl_copy" class="checkbox">
                     <xsl:if test="object_privileges/copy">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_copy">Copy</label>
                 </span>

                 <span class="cboxitem">
                   <input type="checkbox" name="acl_move" value="1" id="acl_move" class="checkbox">
                     <xsl:if test="object_privileges/move">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_move">Move</label> 
                 </span>

               </td>
             </tr>
 
             <tr>
               <th><xsl:value-of select="$i18n/l/Publishingprivs"/>:</th>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_publish" value="1" id="acl_publish" class="checkbox">
                     <xsl:if test="object_privileges/publish">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_publish">Publish</label> 
                 </span>
                 <!-- 
                      Show SEND_AS_MAIL privilege for mailable
                      objects only.  
                 -->
                 <xsl:if test="/document/object_types/object_type[
                                   @id=/document/context/object/object_type_id
                               ]/is_mailable = 1">
                   <span class="cboxitem">
                     <input type="checkbox" name="acl_send_as_mail" value="1" id="acl_send_as_mail" class="checkbox">
                       <xsl:if test="object_privileges/send_as_mail">
                         <xsl:attribute name="checked">checked</xsl:attribute>
                       </xsl:if>
                     </input>
                     <label for="acl_send_as_mail">Send Email</label> 
                   </span>
                 </xsl:if>

               </td>
             </tr>
             <tr>
               <th><xsl:value-of select="$i18n/l/Grantprivs"/>:</th>
               <td>
                 <span class="cboxitem">
                   <input type="checkbox" name="acl_grant" value="1" id="acl_grant" class="checkbox">
                     <xsl:if test="object_privileges/grant">
                       <xsl:attribute name="checked">checked</xsl:attribute>
                     </xsl:if>
                   </input>
                   <label for="acl_grant">Grant</label> 
                 </span>

               </td>
             </tr>

</table>
<br/><br/>
                  <div>
                        <button class="button" name="obj_aclgrant" type="submit"><xsl:value-of select="$i18n/l/save"/></button>
                        <input name="userid" type="hidden" value="{$userid}"/>
                        <input name="id" type="hidden" value="{/document/context/object/@id}"/>
                        <xsl:call-template name="rbacknav"/>
                        &#160;
                        <button class="button" name="cancel" type="submit"><xsl:value-of select="$i18n/l/cancel"/></button>
                  </div>

              <!-- begin revoke  -->
              <xsl:if test="$newgrant != '1'">
<br/><br/>
                <h1 class="bluebg">
                  <xsl:value-of select="$i18n/l/Revoke_objectgrants"/> '<xsl:value-of select="$absolute_path"/>'
                  <xsl:value-of select="$i18n/l/For_user_role"/> '<xsl:value-of select="name"/>'.
                </h1>

                      <div>
                        <button class="button" name="obj_aclrevoke" type="submit"><xsl:value-of select="$i18n/l/Revoke_grants"/></button>
													&#160;
                        <button class="button" name="cancel" type="submit"><xsl:value-of select="$i18n/l/cancel"/></button>
                      </div>
                      </xsl:if>
              <!-- end revoke  -->

        </form>
     </div>
   </xsl:template>
</xsl:stylesheet>
