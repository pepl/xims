<?xml version="1.0" encoding="utf-8"?>
<!--
# Copyright (c) 2002-2017 The XIMS Project.
# See the file "LICENSE" for information and conditions for use, reproduction,
# and distribution of this work, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id: common_obj_userlist.xsl 2188 2009-01-03 18:24:00Z pepl $
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml">
  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:param name="sort-by">
    id
  </xsl:param>
  <xsl:param name="order-by">
    ascending
  </xsl:param>
  <xsl:param name="userquery"/>
  <xsl:param name="usertype">
    user
  </xsl:param>
  <xsl:param name="id"/>
  
  <xsl:template match="/document">
    <xsl:apply-templates select="context/user"/>
  </xsl:template>
  
  
  <xsl:template match="/document/context/user">
    
    <input type="checkbox" name="acl_view">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_view_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/view">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_view_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivView"/>
    </label>
    
    <input type="checkbox" name="acl_write">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_write_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/write">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_write_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivWrite"/>
    </label>
    
    <input type="checkbox" name="acl_create">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_create_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/create">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_create_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivCreate"/>
    </label>
    
    <input type="checkbox" name="acl_delete">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_delete_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/delete">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_delete_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivDelete"/>
    </label>
    
    <input type="checkbox" name="acl_copy">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_copy_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/copy">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_copy_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivCopy"/>
    </label>
    
    <input type="checkbox" name="acl_move">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_move_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/move">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_move_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivMove"/>
    </label>
    
    <input type="checkbox" name="acl_publish">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_publish_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/publish">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_publish_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivPublish"/>
    </label>

      <!-- 
           Show SEND_AS_MAIL privilege for mailable
           objects only.  
      -->
      <xsl:if test="/document/object_types/object_type[@id=/document/context/object/object_type_id]/is_mailable = 1">
      <input type="checkbox" name="acl_send_as_mail">
        <xsl:attribute name="id">
          <xsl:value-of select="concat('acl_send_as_mail_',@id,'_',/document/context/object/@id)"/>
        </xsl:attribute>
      </input>
      <label>
        <xsl:attribute name="for">
          <xsl:value-of select="concat('acl_send_as_mail_',@id,'_',/document/context/object/@id)"/>
        </xsl:attribute><xsl:value-of select="$i18n/l/PrivSendMail"/>
      </label>
      </xsl:if>

    <input type="checkbox" name="acl_grant">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('acl_grant_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:if test="object_privileges/grant">
        <xsl:attribute name="checked">
          checked
        </xsl:attribute>
      </xsl:if>
    </input>
    <label>
      <xsl:attribute name="for">
        <xsl:value-of select="concat('acl_grant_',@id,'_',/document/context/object/@id)"/>
      </xsl:attribute>
      <xsl:value-of select="$i18n/l/PrivGrant"/>
    </label>
    
  </xsl:template>
  
  <xsl:template match="lastname|name">
    <td>
      <xsl:value-of select="."/>
    </td>
  </xsl:template>
  
  <xsl:template match="enabled">
    <td>
      <xsl:choose>
        <xsl:when test="text()='1'">
          <xsl:value-of select="$i18n/l/enabled"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$i18n/l/disabled"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </xsl:template>
  
</xsl:stylesheet>

